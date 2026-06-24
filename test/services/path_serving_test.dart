// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// PATHSERVE-1 [R-G8] tests for the pure path-serving selection core. Properties
// proven: encoding-phase ordering starts BLOCKED at cold-start (never seen) and
// while a seen skill's per-skill θ is below the encoded threshold, flipping to
// INTERLEAVED once θ reaches it (with a raised/lowered injected threshold moving
// the flip point — proving the threshold is injected, not hard-coded); the
// productive-retrieval review bias keeps mcq/match for cold-start, the CAT
// placement and A1, defaults to the productive set from A2 up, and narrows the
// productive set to its non-typing types under an injected typing-awkward
// device/locale hint; the type sets + band cutoff are injected; and everything
// is deterministic. No clock, no I/O, no randomness.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel, ExerciseType;
import 'package:ratel/services/services.dart';

void main() {
  const model = PathServingModel();

  // The documented defaults, restated here so the tests pin the contract.
  const productive = <ExerciseType>{
    ExerciseType.translate,
    ExerciseType.cloze,
    ExerciseType.dictation,
    ExerciseType.speak,
    ExerciseType.wordOrder,
  };
  const recognition = <ExerciseType>{ExerciseType.mcq, ExerciseType.match};
  const nonTypingProductive = <ExerciseType>{
    ExerciseType.speak,
    ExerciseType.wordOrder,
  };

  group('encoding phase — cold-start is always blocked', () {
    test('a never-seen skill is blocked regardless of (even high) θ', () {
      expect(
        model.encodingPhase(hasSeen: false, perSkillTheta: 3.0),
        EncodingPhase.blocked,
      );
      expect(
        model.encodingPhase(hasSeen: false, perSkillTheta: 0.0),
        EncodingPhase.blocked,
      );
      expect(
        model.encodingPhase(hasSeen: false, perSkillTheta: -3.0),
        EncodingPhase.blocked,
      );
    });
  });

  group('encoding phase — seen skill flips at the encoded threshold', () {
    // Default encoded threshold is -1.0 logits.
    test('a seen skill well below the threshold is blocked', () {
      expect(
        model.encodingPhase(hasSeen: true, perSkillTheta: -2.5),
        EncodingPhase.blocked,
      );
    });

    test('just below the threshold is still blocked', () {
      expect(
        model.encodingPhase(hasSeen: true, perSkillTheta: -1.0001),
        EncodingPhase.blocked,
      );
    });

    test('exactly at the threshold counts as encoded (interleaved)', () {
      expect(
        model.encodingPhase(hasSeen: true, perSkillTheta: -1.0),
        EncodingPhase.interleaved,
      );
    });

    test('just above the threshold is interleaved', () {
      expect(
        model.encodingPhase(hasSeen: true, perSkillTheta: -0.9999),
        EncodingPhase.interleaved,
      );
    });

    test('a strong seen skill is interleaved', () {
      expect(
        model.encodingPhase(hasSeen: true, perSkillTheta: 1.5),
        EncodingPhase.interleaved,
      );
    });
  });

  group('encoding phase — the threshold is injected, not hard-coded', () {
    test('raising the threshold turns a previously-encoded θ back to blocked',
        () {
      const raised =
          PathServingModel(config: PathServingConfig(encodedThreshold: 0.5));
      // θ = 0.0 is interleaved under the default (-1.0) but blocked under 0.5.
      expect(
        model.encodingPhase(hasSeen: true, perSkillTheta: 0.0),
        EncodingPhase.interleaved,
      );
      expect(
        raised.encodingPhase(hasSeen: true, perSkillTheta: 0.0),
        EncodingPhase.blocked,
      );
    });

    test('lowering the threshold flips a previously-blocked θ to interleaved',
        () {
      const lowered =
          PathServingModel(config: PathServingConfig(encodedThreshold: -3.0));
      // θ = -2.0 is blocked under the default (-1.0) but interleaved under -3.0.
      expect(
        model.encodingPhase(hasSeen: true, perSkillTheta: -2.0),
        EncodingPhase.blocked,
      );
      expect(
        lowered.encodingPhase(hasSeen: true, perSkillTheta: -2.0),
        EncodingPhase.interleaved,
      );
    });
  });

  group('review types — recognition is kept for the named exceptions', () {
    test('cold-start keeps mcq/match even at a high band', () {
      expect(
        model.reviewTypes(band: CefrLevel.b2, phase: SelectionPhase.coldStart),
        unorderedEquals(recognition),
      );
    });

    test('the CAT placement keeps mcq/match even at a high band', () {
      expect(
        model.reviewTypes(band: CefrLevel.c1, phase: SelectionPhase.placement),
        unorderedEquals(recognition),
      );
    });

    test('A1 first-exposure keeps mcq/match', () {
      expect(
        model.reviewTypes(
            band: CefrLevel.a1, phase: SelectionPhase.firstExposure),
        unorderedEquals(recognition),
      );
    });

    test('A1 review still keeps mcq/match (below the A2 cutoff)', () {
      expect(
        model.reviewTypes(band: CefrLevel.a1, phase: SelectionPhase.review),
        unorderedEquals(recognition),
      );
    });
  });

  group('review types — productive from A2 up', () {
    test('A2 review biases to the productive set', () {
      expect(
        model.reviewTypes(band: CefrLevel.a2, phase: SelectionPhase.review),
        unorderedEquals(productive),
      );
    });

    test('every band B1..C2 review biases to the productive set', () {
      for (final band in <CefrLevel>[
        CefrLevel.b1,
        CefrLevel.b2,
        CefrLevel.c1,
        CefrLevel.c2,
      ]) {
        expect(
          model.reviewTypes(band: band, phase: SelectionPhase.review),
          unorderedEquals(productive),
          reason: 'band $band review should be productive',
        );
      }
    });

    test('A2 first-exposure is productive (only A1 first-exposure is excepted)',
        () {
      expect(
        model.reviewTypes(
            band: CefrLevel.a2, phase: SelectionPhase.firstExposure),
        unorderedEquals(productive),
      );
    });
  });

  group('review types — injected device/locale typing-awkward hint', () {
    test('A2+ review with typing awkward narrows to the non-typing productive '
        'types', () {
      expect(
        model.reviewTypes(
          band: CefrLevel.b1,
          phase: SelectionPhase.review,
          hints: const DeviceLocaleHints(typingAwkward: true),
        ),
        unorderedEquals(nonTypingProductive),
      );
    });

    test('the default (no hint) returns the full productive set', () {
      expect(
        model.reviewTypes(band: CefrLevel.b1, phase: SelectionPhase.review),
        unorderedEquals(productive),
      );
    });

    test('the typing hint does NOT override a recognition context', () {
      // Cold-start stays recognition even when typing is awkward.
      expect(
        model.reviewTypes(
          band: CefrLevel.a2,
          phase: SelectionPhase.coldStart,
          hints: const DeviceLocaleHints(typingAwkward: true),
        ),
        unorderedEquals(recognition),
      );
    });
  });

  group('review types — the type sets + band cutoff are injected', () {
    test('a custom productive set is honored', () {
      const custom = PathServingModel(
        config: PathServingConfig(
          productiveTypes: <ExerciseType>{ExerciseType.speak},
        ),
      );
      expect(
        custom.reviewTypes(band: CefrLevel.b1, phase: SelectionPhase.review),
        unorderedEquals(<ExerciseType>{ExerciseType.speak}),
      );
    });

    test('a custom recognition set is honored', () {
      const custom = PathServingModel(
        config: PathServingConfig(
          recognitionTypes: <ExerciseType>{ExerciseType.listen},
        ),
      );
      expect(
        custom.reviewTypes(
            band: CefrLevel.a1, phase: SelectionPhase.firstExposure),
        unorderedEquals(<ExerciseType>{ExerciseType.listen}),
      );
    });

    test('raising the productive band cutoff to B1 makes A2 review recognition',
        () {
      const custom = PathServingModel(
        config: PathServingConfig(productiveFromBand: CefrLevel.b1),
      );
      // A2 is productive under the default (cutoff A2) but recognition when the
      // cutoff is raised to B1.
      expect(
        model.reviewTypes(band: CefrLevel.a2, phase: SelectionPhase.review),
        unorderedEquals(productive),
      );
      expect(
        custom.reviewTypes(band: CefrLevel.a2, phase: SelectionPhase.review),
        unorderedEquals(recognition),
      );
      // B1 is still productive under the raised cutoff.
      expect(
        custom.reviewTypes(band: CefrLevel.b1, phase: SelectionPhase.review),
        unorderedEquals(productive),
      );
    });
  });

  group('determinism + invariants', () {
    test('identical inputs return identical decisions', () {
      final a = model.encodingPhase(hasSeen: true, perSkillTheta: -0.5);
      final b = model.encodingPhase(hasSeen: true, perSkillTheta: -0.5);
      expect(a, b);
      final s1 =
          model.reviewTypes(band: CefrLevel.b2, phase: SelectionPhase.review);
      final s2 =
          model.reviewTypes(band: CefrLevel.b2, phase: SelectionPhase.review);
      expect(s1, unorderedEquals(s2));
    });

    test('the default productive and recognition sets are disjoint', () {
      expect(productive.intersection(recognition), isEmpty);
    });

    test('the non-typing productive subset is contained in the productive set',
        () {
      expect(productive.containsAll(nonTypingProductive), isTrue);
    });
  });
}
