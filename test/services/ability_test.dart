// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// ABILITY-1 [R-G2] tests for the pure online θ ability engine. Golden values
// were computed from the 1PL/Rasch logistic P = σ(θ − b) and the Elo/logit
// step θ' = θ + K(n)·(outcome − P) with the documented default params, and
// cross-checked in python. Properties proven: a correct answer raises θ and a
// wrong one lowers it; a correct answer on a HARD item moves θ more than on an
// easy one; the step shrinks as item count grows (early K > late K); each
// per-skill estimate reverts toward global (and a never-seen skill starts at
// global); an ungraded item is a no-op; the engine is fully deterministic and
// never mutates its input. No clock, no I/O.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

void main() {
  const AbilityModel model = AbilityModel();
  const AbilityState fresh = AbilityState();

  group('logistic P(correct) = sigma(theta - b)', () {
    test('0.5 at theta == b; rises with theta', () {
      expect(model.pCorrect(0, 0), closeTo(0.5, 1e-12));
      expect(model.pCorrect(1, 0), closeTo(0.7310585786, 1e-9));
      expect(model.pCorrect(1, 0), greaterThan(0.5));
      expect(model.pCorrect(-1, 0), lessThan(0.5));
    });

    test('symmetric: P(theta,b) + P(b,theta) == 1', () {
      expect(model.pCorrect(2, 0) + model.pCorrect(0, 2), closeTo(1.0, 1e-12));
    });
  });

  group('step size decays with item count', () {
    test('K(0) == initialK and is non-increasing', () {
      expect(model.stepSize(0), closeTo(1.0, 1e-12));
      expect(model.stepSize(10), closeTo(0.6666666667, 1e-9));
      expect(model.stepSize(100), closeTo(0.1666666667, 1e-9));
      expect(model.stepSize(0), greaterThan(model.stepSize(10)));
      expect(model.stepSize(10), greaterThan(model.stepSize(100)));
    });

    test('minK floors K (injected params, not hard-coded)', () {
      const AbilityModel floored =
          AbilityModel(AbilityParams(initialK: 2.0, kDecay: 0.1, minK: 0.5));
      expect(floored.stepSize(0), closeTo(2.0, 1e-12));
      // raw K(1000) = 2/(1+100) ~ 0.0198 -> floored to minK 0.5
      expect(floored.stepSize(1000), closeTo(0.5, 1e-12));
    });
  });

  group('a correct answer raises theta, a wrong one lowers it', () {
    test('correct raises global + skill theta', () {
      final AbilityState r =
          model.update(fresh, skill: 'listening', itemDifficulty: 0, correct: true);
      expect(r.thetaGlobal, closeTo(0.5, 1e-12));
      expect(r.thetaGlobal, greaterThan(0));
      expect(r.thetaForSkill('listening'), closeTo(0.5, 1e-12));
    });

    test('wrong lowers global theta', () {
      final AbilityState r =
          model.update(fresh, skill: 'listening', itemDifficulty: 0, correct: false);
      expect(r.thetaGlobal, closeTo(-0.5, 1e-12));
      expect(r.thetaGlobal, lessThan(0));
    });
  });

  group('harder items move theta more', () {
    test('a correct answer on a hard item moves theta more than on an easy one', () {
      final AbilityState hard =
          model.update(fresh, skill: 's', itemDifficulty: 2.0, correct: true);
      final AbilityState easy =
          model.update(fresh, skill: 's', itemDifficulty: -2.0, correct: true);
      expect(hard.thetaGlobal, closeTo(0.880797, 1e-6));
      expect(easy.thetaGlobal, closeTo(0.119203, 1e-6));
      expect(hard.thetaGlobal, greaterThan(easy.thetaGlobal));
    });

    test('a wrong answer on an easy item costs more than on a hard one', () {
      final AbilityState wrongEasy =
          model.update(fresh, skill: 's', itemDifficulty: -2.0, correct: false);
      final AbilityState wrongHard =
          model.update(fresh, skill: 's', itemDifficulty: 2.0, correct: false);
      expect(wrongEasy.thetaGlobal, closeTo(-0.880797, 1e-6));
      expect(wrongHard.thetaGlobal, closeTo(-0.119203, 1e-6));
      expect(wrongEasy.thetaGlobal, lessThan(wrongHard.thetaGlobal));
    });
  });

  group('the step shrinks as item count grows', () {
    test('the same answer moves theta less after many items', () {
      const AbilityState experienced = AbilityState(globalItemCount: 100);
      final AbilityState early =
          model.update(fresh, skill: 's', itemDifficulty: 0, correct: true);
      final AbilityState late =
          model.update(experienced, skill: 's', itemDifficulty: 0, correct: true);
      expect(early.thetaGlobal, closeTo(0.5, 1e-12));
      expect(late.thetaGlobal, closeTo(0.0833333333, 1e-9));
      expect(early.thetaGlobal, greaterThan(late.thetaGlobal));
    });
  });

  group('per-skill reverts toward global', () {
    test('a never-seen skill starts at the global theta (cold-start)', () {
      const AbilityState seeded = AbilityState(thetaGlobal: 1.5);
      expect(seeded.thetaForSkill('brand-new'), closeTo(1.5, 1e-12));
      expect(seeded.itemCountForSkill('brand-new'), 0);
    });

    test('coldStart seeds the global prior with no graded items', () {
      const AbilityState cs = AbilityState.coldStart(1.0);
      expect(cs.thetaGlobal, closeTo(1.0, 1e-12));
      expect(cs.globalItemCount, 0);
      expect(cs.thetaForSkill('any'), closeTo(1.0, 1e-12));
    });

    test('shrinkage pulls the per-skill estimate toward global', () {
      const AbilityState diverged = AbilityState(
        thetaGlobal: 2.0,
        thetaPerSkill: <String, double>{'g': -2.0},
        globalItemCount: 5,
        skillItemCounts: <String, int>{'g': 5},
      );
      const AbilityModel pooled = AbilityModel(AbilityParams(skillShrinkage: 0.5));
      const AbilityModel independent =
          AbilityModel(AbilityParams(skillShrinkage: 0.0));
      final AbilityState withShrink =
          pooled.update(diverged, skill: 'g', itemDifficulty: 0, correct: true);
      final AbilityState noShrink =
          independent.update(diverged, skill: 'g', itemDifficulty: 0, correct: true);
      // The shrinkage term pulls the (low) skill estimate up toward the (high) global.
      expect(noShrink.thetaForSkill('g'), closeTo(-1.2953623376, 1e-9));
      expect(withShrink.thetaForSkill('g'), closeTo(0.4, 1e-9));
      expect(withShrink.thetaForSkill('g'), greaterThan(noShrink.thetaForSkill('g')));
      // ...but never past global: it lands strictly between the Elo-only value
      // and the updated global theta (both models compute the same global).
      expect(withShrink.thetaForSkill('g'), lessThan(withShrink.thetaGlobal));
    });
  });

  group('an ungraded item is a no-op', () {
    test('graded:false returns the input state unchanged', () {
      const AbilityState before = AbilityState(
        thetaGlobal: 0.7,
        thetaPerSkill: <String, double>{'g': 0.3},
        globalItemCount: 4,
        skillItemCounts: <String, int>{'g': 2},
      );
      final AbilityState after = model.update(before,
          skill: 'g', itemDifficulty: 0, correct: false, graded: false);
      // Identical object back — theta and every count untouched.
      expect(identical(after, before), isTrue);
      expect(after.thetaGlobal, 0.7);
      expect(after.thetaForSkill('g'), 0.3);
      expect(after.globalItemCount, 4);
      expect(after.itemCountForSkill('g'), 2);
    });

    test('an ungraded item never introduces a new skill', () {
      final AbilityState after = model.update(fresh,
          skill: 'reading', itemDifficulty: 0, correct: true, graded: false);
      expect(after.itemCountForSkill('reading'), 0);
      expect(after.thetaForSkill('reading'), closeTo(0.0, 1e-12));
    });
  });

  group('determinism, immutability + counts', () {
    test('same inputs => identical outputs', () {
      final AbilityState a =
          model.update(fresh, skill: 's', itemDifficulty: 0.4, correct: true);
      final AbilityState b =
          model.update(fresh, skill: 's', itemDifficulty: 0.4, correct: true);
      expect(a.thetaGlobal, b.thetaGlobal);
      expect(a.thetaForSkill('s'), b.thetaForSkill('s'));
      expect(a.globalItemCount, b.globalItemCount);
      expect(a.itemCountForSkill('s'), b.itemCountForSkill('s'));
    });

    test('update does not mutate the input state', () {
      const AbilityState before = AbilityState(
        skillItemCounts: <String, int>{'g': 1},
        thetaPerSkill: <String, double>{'g': 0.0},
      );
      model.update(before, skill: 'h', itemDifficulty: 0, correct: true);
      // The original maps are untouched (the engine copies, never mutates).
      expect(before.itemCountForSkill('h'), 0);
      expect(before.skillItemCounts.containsKey('h'), isFalse);
      expect(before.skillItemCounts['g'], 1);
    });

    test('a graded item increments the global + per-skill counts', () {
      final AbilityState one =
          model.update(fresh, skill: 's', itemDifficulty: 0, correct: true);
      expect(one.globalItemCount, 1);
      expect(one.itemCountForSkill('s'), 1);
      final AbilityState two =
          model.update(one, skill: 's', itemDifficulty: 0, correct: true);
      expect(two.globalItemCount, 2);
      expect(two.itemCountForSkill('s'), 2);
    });
  });
}
