// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// FSRS-1 [R-G5] tests for the pure FSRS-6 spaced-repetition scheduler core.
// Golden values were computed from the published FSRS-6 formulas + the default
// 21-weight vector (open-spaced-repetition/py-fsrs) and cross-checked in python.
// Properties proven: initial stability/difficulty per grade + state routing;
// Good schedules strictly further out than Hard than Again; a lapse (Again in
// review) drops stability and routes to relearning; retrievability decays as
// elapsed grows and equals 0.9 at elapsed == stability; the engine is fully
// deterministic (same card+grade+elapsed+weights => same output); the injected
// desired-retention is honored. No clock, no I/O.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/models/enums.dart' show FsrsState;
import 'package:ratel/services/services.dart';

void main() {
  const Fsrs fsrs = Fsrs();
  // A learned, never-lapsed card in the review state (stability 10 days).
  const FsrsCard reviewCard = FsrsCard(
    state: FsrsState.review,
    stability: 10.0,
    difficulty: 5.0,
    reps: 5,
  );

  group('published defaults', () {
    test('FSRS-6 default vector is the pinned 21 weights + 0.85 retention', () {
      expect(FsrsParams.fsrs6DefaultWeights.length, 21);
      expect(FsrsParams.fsrs6Default.desiredRetention, closeTo(0.85, 1e-12));
      // weight[20] is the FSRS-6 decay parameter (FSRS_DEFAULT_DECAY).
      expect(FsrsParams.fsrs6Default.weights[20], closeTo(0.1542, 1e-12));
      expect(FsrsParams.fsrs6Default.decay, closeTo(-0.1542, 1e-12));
    });
  });

  group('first review of a new card', () {
    test('Again: initial stability w0, state -> learning, reps 1', () {
      final FsrsReview r = fsrs.schedule(const FsrsCard.newItem(), FsrsRating.again, 0);
      expect(r.card.stability, closeTo(0.212, 1e-4));
      expect(r.card.difficulty, closeTo(6.4133, 1e-4));
      expect(r.card.state, FsrsState.learning);
      expect(r.card.reps, 1);
      expect(r.card.lapses, 0); // a new-card Again is not a review lapse
      expect(r.retrievability, 0);
    });

    test('Hard: initial stability w1, state -> learning', () {
      final FsrsReview r = fsrs.schedule(const FsrsCard.newItem(), FsrsRating.hard, 0);
      expect(r.card.stability, closeTo(1.2931, 1e-4));
      expect(r.card.difficulty, closeTo(5.112171, 1e-4));
      expect(r.card.state, FsrsState.learning);
    });

    test('Good: initial stability w2, state -> review', () {
      final FsrsReview r = fsrs.schedule(const FsrsCard.newItem(), FsrsRating.good, 0);
      expect(r.card.stability, closeTo(2.3065, 1e-4));
      expect(r.card.difficulty, closeTo(2.118104, 1e-4));
      expect(r.card.state, FsrsState.review);
    });

    test('Easy: initial stability w3, difficulty clamps to 1.0, state -> review', () {
      final FsrsReview r = fsrs.schedule(const FsrsCard.newItem(), FsrsRating.easy, 0);
      expect(r.card.stability, closeTo(8.2956, 1e-4));
      expect(r.card.difficulty, closeTo(1.0, 1e-9)); // raw -4.77 clamped to MIN
      expect(r.card.state, FsrsState.review);
    });
  });

  group('review-state scheduling (S=10, D=5, elapsed=10 days)', () {
    test('retrievability is 0.9 when elapsed == stability', () {
      for (final FsrsRating g in FsrsRating.values) {
        expect(fsrs.schedule(reviewCard, g, 10).retrievability, closeTo(0.9, 1e-9));
      }
    });

    test('Again: forget-stability + relearning + lapse counted', () {
      final FsrsReview r = fsrs.schedule(reviewCard, FsrsRating.again, 10);
      expect(r.card.stability, closeTo(1.391987, 1e-4));
      expect(r.card.difficulty, closeTo(8.341762, 1e-4));
      expect(r.card.state, FsrsState.relearning);
      expect(r.card.lapses, 1);
      expect(r.card.reps, 6);
    });

    test('Hard / Good / Easy: recall-stability, stays in review', () {
      final FsrsReview h = fsrs.schedule(reviewCard, FsrsRating.hard, 10);
      final FsrsReview g = fsrs.schedule(reviewCard, FsrsRating.good, 10);
      final FsrsReview e = fsrs.schedule(reviewCard, FsrsRating.easy, 10);
      expect(h.card.stability, closeTo(23.246875, 1e-4));
      expect(g.card.stability, closeTo(32.026729, 1e-4));
      expect(e.card.stability, closeTo(51.253862, 1e-4));
      expect(g.card.difficulty, closeTo(4.990228, 1e-4));
      for (final FsrsReview r in <FsrsReview>[h, g, e]) {
        expect(r.card.state, FsrsState.review);
        expect(r.card.lapses, 0);
      }
    });
  });

  group('monotonicity: Good further out than Hard than Again', () {
    test('raw intervals and stabilities strictly increase again<hard<good<easy', () {
      final FsrsReview a = fsrs.schedule(reviewCard, FsrsRating.again, 10);
      final FsrsReview h = fsrs.schedule(reviewCard, FsrsRating.hard, 10);
      final FsrsReview g = fsrs.schedule(reviewCard, FsrsRating.good, 10);
      final FsrsReview e = fsrs.schedule(reviewCard, FsrsRating.easy, 10);
      expect(a.rawIntervalDays < h.rawIntervalDays, isTrue);
      expect(h.rawIntervalDays < g.rawIntervalDays, isTrue);
      expect(g.rawIntervalDays < e.rawIntervalDays, isTrue);
      expect(a.card.stability! < h.card.stability!, isTrue);
      expect(h.card.stability! < g.card.stability!, isTrue);
      expect(g.card.stability! < e.card.stability!, isTrue);
      // whole-day interval is >= 1 and never exceeds the cap.
      expect(a.intervalDays >= 1, isTrue);
      expect(e.intervalDays <= 36500, isTrue);
    });
  });

  group('lapse drops stability', () {
    test('Again in review yields stability strictly below the prior value', () {
      final FsrsReview r = fsrs.schedule(reviewCard, FsrsRating.again, 10);
      expect(r.card.stability! < reviewCard.stability!, isTrue);
      expect(r.card.state, FsrsState.relearning);
      expect(r.card.lapses, reviewCard.lapses + 1);
    });
  });

  group('retrievability decays with elapsed time', () {
    test('R is 1 at t=0, monotonically decreasing, 0.9 at t==stability', () {
      final double r0 = fsrs.retrievability(reviewCard, 0);
      final double r1 = fsrs.retrievability(reviewCard, 1);
      final double r10 = fsrs.retrievability(reviewCard, 10);
      final double r100 = fsrs.retrievability(reviewCard, 100);
      expect(r0, closeTo(1.0, 1e-9));
      expect(r1, closeTo(0.985682, 1e-4));
      expect(r10, closeTo(0.9, 1e-9)); // elapsed == stability
      expect(r100, closeTo(0.692827, 1e-4));
      expect(r0 > r1 && r1 > r10 && r10 > r100, isTrue);
    });

    test('a never-reviewed card has retrievability 0', () {
      expect(fsrs.retrievability(const FsrsCard.newItem(), 5), 0);
    });
  });

  group('determinism', () {
    test('same card + grade + elapsed + weights => identical output', () {
      final FsrsReview a = fsrs.schedule(reviewCard, FsrsRating.good, 7.5);
      final FsrsReview b = fsrs.schedule(reviewCard, FsrsRating.good, 7.5);
      expect(a.card.stability, b.card.stability);
      expect(a.card.difficulty, b.card.difficulty);
      expect(a.card.state, b.card.state);
      expect(a.card.reps, b.card.reps);
      expect(a.card.lapses, b.card.lapses);
      expect(a.rawIntervalDays, b.rawIntervalDays);
      expect(a.intervalDays, b.intervalDays);
      expect(a.retrievability, b.retrievability);
    });
  });

  group('desired retention is honored (and injected, not hard-coded)', () {
    test('default 0.85: scheduling to the interval lands at R=0.85', () {
      final FsrsReview g = fsrs.schedule(reviewCard, FsrsRating.good, 10);
      final double rAtDue = fsrs.retrievability(g.card, g.rawIntervalDays);
      expect(rAtDue, closeTo(0.85, 1e-6));
    });

    test('injected 0.90: interval equals stability and lands at R=0.90', () {
      const Fsrs strict = Fsrs(FsrsParams(desiredRetention: 0.9));
      final FsrsReview g = strict.schedule(reviewCard, FsrsRating.good, 10);
      // At DR=0.9 the FSRS interval equals stability (R=0.9 after S days).
      expect(g.rawIntervalDays, closeTo(g.card.stability!, 1e-6));
      expect(strict.retrievability(g.card, g.rawIntervalDays), closeTo(0.9, 1e-6));
      // higher desired retention => shorter interval than the 0.85 default.
      expect(g.rawIntervalDays < fsrs.schedule(reviewCard, FsrsRating.good, 10).rawIntervalDays, isTrue);
    });
  });
}
