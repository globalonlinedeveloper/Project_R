// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// IRT-1 [R-G3] tests for the pure 1PL/2PL/3PL recall-probability family
// P = c + (1−c)·σ(a·(θ−b)). Golden values were computed from that formula and
// cross-checked in python. Properties proven: 1PL (a=1,c=0) reduces EXACTLY to
// the Rasch `AbilityModel.pCorrect` σ(θ−b); a 2PL slope a>1 sharpens the curve
// while the midpoint P(θ=b) stays 0.5; a 3PL c>0 lifts the lower asymptote to c
// while the upper asymptote stays 1 (midpoint 0.5+c/2); guessing applies to mcq
// only; P is monotonic increasing in θ and bounded in [c,1); the family is
// fully deterministic. No clock, no I/O.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/models/enums.dart' show ExerciseType;
import 'package:ratel/services/services.dart';

void main() {
  const IrtModel model = IrtModel();
  const AbilityModel ability = AbilityModel();

  group('1PL (a=1, c=0) reduces to the Rasch curve', () {
    test('equals the existing AbilityModel.pCorrect σ(θ−b)', () {
      for (final (double th, double b) in const <(double, double)>[
        (0.0, 0.0),
        (1.0, 0.0),
        (0.0, 1.0),
        (1.5, 0.5),
        (-0.5, 0.5),
      ]) {
        expect(model.pCorrect3pl(th, b),
            closeTo(ability.pCorrect(th, b), 1e-12));
      }
    });

    test('golden logistic values', () {
      expect(model.pCorrect3pl(0.0, 0.0), closeTo(0.5, 1e-12));
      expect(model.pCorrect3pl(1.0, 0.0), closeTo(0.7310585786, 1e-9));
      expect(model.pCorrect3pl(0.0, 1.0), closeTo(0.2689414214, 1e-9));
    });

    test('depends only on θ−b and is symmetric: P(1,0)+P(0,1)=1', () {
      expect(model.pCorrect3pl(1.5, 0.5),
          closeTo(model.pCorrect3pl(1.0, 0.0), 1e-12));
      expect(model.pCorrect3pl(1.0, 0.0) + model.pCorrect3pl(0.0, 1.0),
          closeTo(1.0, 1e-12));
    });
  });

  group('2PL discrimination slope (c=0)', () {
    test('the midpoint P(θ=b) is 0.5 for every a', () {
      expect(model.pCorrect3pl(0.0, 0.0, a: 2.0), closeTo(0.5, 1e-12));
      expect(model.pCorrect3pl(0.0, 0.0, a: 0.5), closeTo(0.5, 1e-12));
      expect(model.pCorrect3pl(1.3, 1.3, a: 3.7), closeTo(0.5, 1e-12));
    });

    test('a>1 sharpens: steeper above b, steeper-down below b', () {
      // Above b a higher slope gives a higher P; below b a lower P.
      expect(model.pCorrect3pl(0.5, 0.0, a: 2.0),
          greaterThan(model.pCorrect3pl(0.5, 0.0)));
      expect(model.pCorrect3pl(-0.5, 0.0, a: 2.0),
          lessThan(model.pCorrect3pl(-0.5, 0.0)));
    });

    test('golden 2PL values (a=2)', () {
      expect(model.pCorrect3pl(0.5, 0.0, a: 2.0), closeTo(0.7310585786, 1e-9));
      expect(model.pCorrect3pl(-0.5, 0.0, a: 2.0), closeTo(0.2689414214, 1e-9));
      expect(model.pCorrect3pl(0.5, 0.0), closeTo(0.6224593312, 1e-9));
    });
  });

  group('3PL pseudo-guessing floor (c>0)', () {
    test('c lifts the midpoint to 0.5 + c/2', () {
      expect(model.pCorrect3pl(0.0, 0.0, c: 0.25), closeTo(0.625, 1e-12));
      expect(model.pCorrect3pl(2.0, 2.0, c: 0.4), closeTo(0.7, 1e-12));
    });

    test('lower asymptote → c as θ→−∞, upper stays 1 as θ→+∞', () {
      expect(model.pCorrect3pl(-20.0, 0.0, c: 0.25), closeTo(0.25, 1e-6));
      expect(model.pCorrect3pl(20.0, 0.0, c: 0.25), closeTo(1.0, 1e-6));
    });

    test('golden 3PL value (a=1.5, c=0.2)', () {
      expect(model.pCorrect3pl(1.0, 0.0, a: 1.5, c: 0.2),
          closeTo(0.854059581, 1e-9));
    });
  });

  group('mcq-only guessing guard', () {
    test('guessingFor returns c for mcq, 0 for every other type', () {
      expect(model.guessingFor(ExerciseType.mcq, 0.25), 0.25);
      for (final ExerciseType t in const <ExerciseType>[
        ExerciseType.cloze,
        ExerciseType.translate,
        ExerciseType.listen,
        ExerciseType.speak,
        ExerciseType.write,
      ]) {
        expect(model.guessingFor(t, 0.25), 0.0);
      }
    });

    test('a typed mcq honours its floor; a non-mcq drops to 2PL', () {
      const IrtItem item = IrtItem(b: 0.0, c: 0.25);
      expect(model.pCorrectForTypedItem(0.0, item, ExerciseType.mcq),
          closeTo(0.625, 1e-12));
      // Same item, non-mcq type: the stored c is ignored → 2PL midpoint 0.5.
      expect(model.pCorrectForTypedItem(0.0, item, ExerciseType.cloze),
          closeTo(0.5, 1e-12));
    });
  });

  group('monotonic, bounded, deterministic', () {
    test('strictly increasing in θ across the family', () {
      for (final (double a, double c) in const <(double, double)>[
        (1.0, 0.0),
        (2.0, 0.0),
        (1.0, 0.25),
        (0.5, 0.1),
      ]) {
        double? prev;
        for (int i = 0; i <= 12; i++) {
          final double th = -3.0 + i * 0.5;
          final double p = model.pCorrect3pl(th, 0.0, a: a, c: c);
          if (prev != null) {
            expect(p, greaterThan(prev));
          }
          prev = p;
        }
      }
    });

    test('bounded in (c, 1) for finite inputs', () {
      const double c = 0.25;
      final double low = model.pCorrect3pl(-8.0, 0.0, c: c);
      final double high = model.pCorrect3pl(8.0, 0.0, c: c);
      expect(low, greaterThan(c));
      expect(high, lessThan(1.0));
      expect(low, lessThan(high));
    });

    test('deterministic: same inputs → identical output', () {
      expect(model.pCorrect3pl(0.7, 0.2, a: 1.3, c: 0.15),
          model.pCorrect3pl(0.7, 0.2, a: 1.3, c: 0.15));
    });
  });

  group('IrtItem params + pCorrectForItem', () {
    test('IrtItem defaults to the 1PL launch rung (a=1, c=0)', () {
      const IrtItem item = IrtItem(b: 0.5);
      expect(item.a, 1.0);
      expect(item.c, 0.0);
      expect(model.pCorrectForItem(0.5, item), closeTo(0.5, 1e-12));
    });

    test('pCorrectForItem applies the full stored (a, b, c)', () {
      const IrtItem item = IrtItem(b: 0.3, a: 1.4, c: 0.15);
      expect(model.pCorrectForItem(0.7, item),
          closeTo(model.pCorrect3pl(0.7, 0.3, a: 1.4, c: 0.15), 1e-12));
      expect(model.pCorrectForItem(0.7, item), closeTo(0.6909846592, 1e-9));
    });
  });
}
