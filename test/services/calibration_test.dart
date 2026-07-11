// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// CALIBRATION-1 [R-G3] tests for the pure, thin-data-safe batch IRT item
// re-calibrator (the 1PL difficulty MAP re-fit). Properties proven:
//   * THIN-DATA GUARD — below the refine threshold the authored difficulty is
//     returned VERBATIM (no small-sample noise can move a good prior);
//   * the staged ladder rungs (insufficient → refined1pl → eligible2pl →
//     eligible3pl, 3PL mcq-only) are gated purely on the response count;
//   * with a weak prior the fit recovers the closed-form 1PL MLE
//     b = θ0 − logit(f) (golden), and the estimate SHRINKS toward the prior as
//     the prior tightens (monotone in τ²);
//   * degenerate all-correct / all-wrong data stays FINITE and clamped (the raw
//     MLE would diverge to ∓∞);
//   * the fit is deterministic and order-independent, monotone in the evidence,
//     and passes `a`/`c` through untouched;
//   * groupResponses folds the append-only ReviewLog (feedsTheta-gated) and
//     calibrateBatch keeps unseen items on their prior.
// No clock, no I/O, no randomness.
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/models/enums.dart' show ExerciseType;
import 'package:ratel/services/services.dart';

/// Closed-form 1PL MLE difficulty for n responses all at the same ability
/// [theta0] with fraction [f] correct: b = θ0 − logit(f). The estimator must
/// recover this when the prior is weak (large τ²).
double _mleB(double theta0, double f) => theta0 - math.log(f / (1.0 - f));

void main() {
  // A single response (runtime args → no const-eval, keeps the analyzer happy).
  CalibrationResponse one(double theta, bool correct) =>
      CalibrationResponse(theta: theta, correct: correct);

  /// [nCorrect] correct + [nWrong] wrong responses, all at ability [theta].
  List<CalibrationResponse> atTheta(
    double theta,
    int nCorrect,
    int nWrong,
  ) =>
      <CalibrationResponse>[
        for (int i = 0; i < nCorrect; i++) one(theta, true),
        for (int i = 0; i < nWrong; i++) one(theta, false),
      ];

  group('thin-data guard — the headline invariant', () {
    test('below minResponsesToRefine the authored difficulty is verbatim', () {
      const IrtCalibrator cal = IrtCalibrator(); // default floor = 200
      // 5 all-wrong at a high θ would scream "make it harder" — but it is far
      // too little data, so the prior MUST NOT move.
      final CalibrationResult r =
          cal.calibrateItem(responses: atTheta(3.0, 0, 5), priorB: 0.4);
      expect(r.rung, CalibrationRung.insufficientData);
      expect(r.b, 0.4); // byte-exact prior
      expect(r.delta, 0.0);
      expect(r.refined, isFalse);
      expect(r.responseCount, 5);
    });

    test('an empty response set leaves the prior untouched', () {
      const IrtCalibrator cal = IrtCalibrator();
      final CalibrationResult r = cal.calibrateItem(
        responses: const <CalibrationResponse>[],
        priorB: -1.2,
      );
      expect(r.rung, CalibrationRung.insufficientData);
      expect(r.b, -1.2);
      expect(r.refined, isFalse);
    });
  });

  group('staged ladder rungs (gated on the response count)', () {
    // Small thresholds so the rungs are cheap to reach in a test.
    const IrtCalibrator cal = IrtCalibrator(
      CalibrationParams(
        minResponsesToRefine: 3,
        twoPlThreshold: 5,
        threePlThreshold: 7,
      ),
    );

    test('n below the floor → insufficientData', () {
      expect(
        cal.calibrateItem(responses: atTheta(0.0, 1, 1), priorB: 0.0).rung,
        CalibrationRung.insufficientData,
      );
    });

    test('floor ≤ n < 2PL → refined1pl', () {
      expect(
        cal.calibrateItem(responses: atTheta(0.0, 2, 1), priorB: 0.0).rung,
        CalibrationRung.refined1pl,
      );
    });

    test('2PL ≤ n < 3PL → eligible2pl', () {
      expect(
        cal.calibrateItem(responses: atTheta(0.0, 3, 2), priorB: 0.0).rung,
        CalibrationRung.eligible2pl,
      );
    });

    test('mcq at ≥ 3PL → eligible3pl', () {
      expect(
        cal
            .calibrateItem(
              responses: atTheta(0.0, 4, 3),
              priorB: 0.0,
            )
            .rung,
        CalibrationRung.eligible3pl,
      );
    });

    test('3PL is mcq-only: a non-mcq item at ≥ 3PL stays eligible2pl', () {
      expect(
        cal
            .calibrateItem(
              responses: atTheta(0.0, 4, 3),
              priorB: 0.0,
              type: ExerciseType.translate,
            )
            .rung,
        CalibrationRung.eligible2pl,
      );
    });
  });

  group('1PL MLE recovery (weak prior → data dominates)', () {
    // τ² huge ⇒ the prior is inert ⇒ the MAP is the raw MLE b = θ0 − logit(f).
    const IrtCalibrator cal = IrtCalibrator(
      CalibrationParams(minResponsesToRefine: 1, priorVariance: 1e9),
    );

    test('3 of 4 correct at θ=0 → b ≈ −ln 3', () {
      final CalibrationResult r =
          cal.calibrateItem(responses: atTheta(0.0, 3, 1), priorB: 0.0);
      expect(r.b, closeTo(_mleB(0.0, 0.75), 1e-4));
      expect(r.b, closeTo(-math.log(3), 1e-4));
      expect(r.converged, isTrue);
      expect(r.rung, CalibrationRung.refined1pl);
    });

    test('1 of 4 correct at θ=0 → b ≈ +ln 3 (harder)', () {
      final CalibrationResult r =
          cal.calibrateItem(responses: atTheta(0.0, 1, 3), priorB: 0.0);
      expect(r.b, closeTo(_mleB(0.0, 0.25), 1e-4));
      expect(r.b, closeTo(math.log(3), 1e-4));
    });

    test('half correct at θ=1.5 → b ≈ 1.5 (the ability level)', () {
      final CalibrationResult r =
          cal.calibrateItem(responses: atTheta(1.5, 2, 2), priorB: 0.0);
      expect(r.b, closeTo(1.5, 1e-4));
    });
  });

  group('MAP shrinkage — the thin-data ramp', () {
    double fitB(double tau2) => IrtCalibrator(
          CalibrationParams(minResponsesToRefine: 1, priorVariance: tau2),
        ).calibrateItem(responses: atTheta(0.0, 3, 1), priorB: 0.0).b;

    test('the MAP lies strictly between the prior and the MLE', () {
      final double mle = _mleB(0.0, 0.75); // ≈ −1.0986
      final double map = fitB(1.0);
      expect(map, greaterThan(mle)); // shrunk back toward the prior (0)
      expect(map, lessThan(0.0)); // but genuinely moved from the prior
    });

    test('a weaker prior (larger τ²) moves the estimate toward the MLE', () {
      // Prior 0, data pulls negative ⇒ stronger prior = less negative b.
      expect(fitB(0.5), greaterThan(fitB(2.0)));
      expect(fitB(2.0), greaterThan(fitB(1e9)));
    });

    test('a stronger prior shrinks harder (closer to the prior mean 0)', () {
      expect(fitB(0.1).abs(), lessThan(fitB(1.0).abs()));
    });
  });

  group('degenerate data stays finite and clamped (no MLE divergence)', () {
    test('all-correct → a finite, easier (lower) difficulty', () {
      const IrtCalibrator cal = IrtCalibrator(
        CalibrationParams(minResponsesToRefine: 1, priorVariance: 1.0),
      );
      final CalibrationResult r =
          cal.calibrateItem(responses: atTheta(0.0, 10, 0), priorB: 0.0);
      expect(r.b.isFinite, isTrue);
      expect(r.b, lessThan(0.0));
      expect(r.b, greaterThanOrEqualTo(-6.0));
    });

    test('all-wrong → a finite, harder (higher) difficulty', () {
      const IrtCalibrator cal = IrtCalibrator(
        CalibrationParams(minResponsesToRefine: 1, priorVariance: 1.0),
      );
      final CalibrationResult r =
          cal.calibrateItem(responses: atTheta(0.0, 0, 10), priorB: 0.0);
      expect(r.b.isFinite, isTrue);
      expect(r.b, greaterThan(0.0));
      expect(r.b, lessThanOrEqualTo(6.0));
    });

    test('separated data with an inert prior clamps to the bound, not ∞', () {
      const IrtCalibrator cal = IrtCalibrator(
        CalibrationParams(
          minResponsesToRefine: 1,
          priorVariance: 1e9,
          bMin: -6.0,
          bMax: 6.0,
        ),
      );
      // 20 all-correct with no effective prior → MLE −∞ → clamped to bMin.
      final CalibrationResult easy =
          cal.calibrateItem(responses: atTheta(0.0, 20, 0), priorB: 0.0);
      expect(easy.b, closeTo(-6.0, 1e-6));
      final CalibrationResult hard =
          cal.calibrateItem(responses: atTheta(0.0, 0, 20), priorB: 0.0);
      expect(hard.b, closeTo(6.0, 1e-6));
    });
  });

  group('determinism + order independence', () {
    const IrtCalibrator cal = IrtCalibrator(
      CalibrationParams(minResponsesToRefine: 1, priorVariance: 1.0),
    );
    final List<CalibrationResponse> mixed = <CalibrationResponse>[
      one(0.5, true),
      one(-0.4, false),
      one(1.2, true),
      one(0.0, false),
      one(-1.0, true),
    ];

    test('identical inputs give a byte-identical estimate', () {
      final double a =
          cal.calibrateItem(responses: mixed, priorB: 0.1).b;
      final double b =
          cal.calibrateItem(responses: mixed, priorB: 0.1).b;
      expect(a, b);
    });

    test('reversing the response order gives the identical estimate', () {
      final double forward =
          cal.calibrateItem(responses: mixed, priorB: 0.1).b;
      final double reversed = cal
          .calibrateItem(
            responses: mixed.reversed.toList(),
            priorB: 0.1,
          )
          .b;
      expect(reversed, forward);
    });
  });

  group('monotone in the evidence + a/c pass-through', () {
    const IrtCalibrator cal = IrtCalibrator(
      CalibrationParams(minResponsesToRefine: 1, priorVariance: 1e9),
    );

    test('more correct answers → an easier (lower) difficulty', () {
      final double easier =
          cal.calibrateItem(responses: atTheta(0.0, 4, 1), priorB: 0.0).b;
      final double harder =
          cal.calibrateItem(responses: atTheta(0.0, 1, 4), priorB: 0.0).b;
      expect(easier, lessThan(harder));
    });

    test('discrimination a and guessing c pass through untouched', () {
      final CalibrationResult r = cal.calibrateItem(
        responses: atTheta(0.0, 3, 1),
        priorB: 0.0,
        priorA: 1.7,
        priorC: 0.22,
      );
      expect(r.a, 1.7);
      expect(r.c, 0.22);
    });

    test('a/c are preserved even when the prior is kept (insufficient)', () {
      const IrtCalibrator floored = IrtCalibrator(); // floor 200
      final CalibrationResult r = floored.calibrateItem(
        responses: atTheta(0.0, 1, 1),
        priorB: 0.3,
        priorA: 1.4,
        priorC: 0.1,
      );
      expect(r.refined, isFalse);
      expect(r.a, 1.4);
      expect(r.c, 0.1);
    });
  });

  group('groupResponses folds the append-only ReviewLog', () {
    ReviewLogEntry entry(
      String itemId,
      bool correct,
      double theta, {
      bool feedsTheta = true,
    }) =>
        ReviewLogEntry(
          itemId: itemId,
          skill: 'skill_x',
          grade: correct ? FsrsRating.good : FsrsRating.again,
          correct: correct,
          elapsedMs: 0,
          thetaBefore: theta,
          irtBAtReview: 0.0,
          source: 'lesson',
          feedsTheta: feedsTheta,
        );

    test('groups by item, keeps (θ,correct), drops non-feedsTheta rows', () {
      final List<ReviewLogEntry> log = <ReviewLogEntry>[
        entry('i1', true, 0.5),
        entry('i1', false, -0.3),
        entry('i2', true, 1.0),
        entry('i1', true, 2.0, feedsTheta: false), // saved-word → excluded
      ];
      final Map<String, List<CalibrationResponse>> grouped =
          IrtCalibrator.groupResponses(log);
      expect(grouped['i1']!.length, 2); // the feedsTheta:false row dropped
      expect(grouped['i2']!.length, 1);
      expect(grouped['i1']![0].theta, 0.5);
      expect(grouped['i1']![0].correct, isTrue);
      expect(grouped['i1']![1].correct, isFalse);
    });

    test('folded responses feed calibrateItem end-to-end', () {
      final List<ReviewLogEntry> log = <ReviewLogEntry>[
        for (int i = 0; i < 3; i++) entry('i1', true, 0.0),
        entry('i1', false, 0.0),
      ];
      final Map<String, List<CalibrationResponse>> grouped =
          IrtCalibrator.groupResponses(log);
      const IrtCalibrator cal = IrtCalibrator(
        CalibrationParams(minResponsesToRefine: 1, priorVariance: 1e9),
      );
      final CalibrationResult r =
          cal.calibrateItem(responses: grouped['i1']!, priorB: 0.0);
      expect(r.b, closeTo(-math.log(3), 1e-4)); // 3/4 correct at θ=0
    });
  });

  group('calibrateBatch', () {
    const IrtCalibrator cal = IrtCalibrator(
      CalibrationParams(
        minResponsesToRefine: 3,
        twoPlThreshold: 1000,
        threePlThreshold: 2000,
        priorVariance: 1e9,
      ),
    );

    Map<String, CalibrationResult> run() => cal.calibrateBatch(
          priors: <String, ItemPrior>{
            'easy': const ItemPrior(b: 0.0),
            'hard': const ItemPrior(b: 0.0, type: ExerciseType.translate),
            'unseen': const ItemPrior(b: 0.9),
          },
          responsesByItem: <String, List<CalibrationResponse>>{
            'easy': atTheta(0.0, 4, 1), // n=5 mostly right → easier
            'hard': atTheta(0.0, 1, 4), // n=5 mostly wrong → harder
            // 'unseen' absent → zero responses
          },
        );

    test('seen items refine in the right direction; unseen keeps its prior', () {
      final Map<String, CalibrationResult> out = run();
      expect(out['easy']!.refined, isTrue);
      expect(out['easy']!.b, lessThan(0.0));
      expect(out['hard']!.refined, isTrue);
      expect(out['hard']!.b, greaterThan(0.0));
      expect(out['unseen']!.rung, CalibrationRung.insufficientData);
      expect(out['unseen']!.b, 0.9); // untouched
    });

    test('the batch is order-independent (map values match on a re-run)', () {
      final Map<String, CalibrationResult> a = run();
      final Map<String, CalibrationResult> b = run();
      for (final String k in a.keys) {
        expect(a[k]!.b, b[k]!.b);
      }
    });
  });

  group('parameter validation', () {
    test('invalid CalibrationParams trip an assertion', () {
      const List<double> invalidVariances = <double>[0.0, -1.0];
      for (final double v in invalidVariances) {
        expect(
          () => CalibrationParams(priorVariance: v),
          throwsA(isA<AssertionError>()),
        );
      }
    });
  });

  // ---- CALIBRATION-2 [R-G3]: the 2PL discrimination + 3PL guessing rungs ----
  // The staged coordinate MAP now PERFORMS the a fit (rung eligible2pl+) and the
  // mcq c fit (rung eligible3pl), holding the already-fit parameters. Same
  // thin-data guards as b: verbatim below the rung, shrinkage above it, finite
  // clamped on separated/degenerate data.

  // The 2PL discrimination MAP score S(a) = Σ d_j·(y_j − σ(a·d_j)) − (a − a0)/τ_a²
  // recomputed at the fitted (a, b): the estimator's own root equation, so
  // |S(a)| ≈ 0 proves the fit solved it (white-box, holds for ANY data).
  double scoreA(
    List<CalibrationResponse> rs,
    double a,
    double b,
    double a0,
    double tau2,
  ) {
    double s = 0.0;
    for (final CalibrationResponse r in rs) {
      final double d = r.theta - b;
      s += d * ((r.correct ? 1.0 : 0.0) - 1.0 / (1.0 + math.exp(-a * d)));
    }
    return s - (a - a0) / tau2;
  }

  // The 3PL guessing MAP score S(c) recomputed at the fitted (a, b, c).
  double scoreC(
    List<CalibrationResponse> rs,
    double a,
    double b,
    double c,
    double c0,
    double tau2,
  ) {
    double s = 0.0;
    for (final CalibrationResponse r in rs) {
      final double g = 1.0 / (1.0 + math.exp(-a * (r.theta - b)));
      final double p = c + (1.0 - c) * g;
      if (r.correct) {
        s += (1.0 - g) / p;
      } else {
        s -= 1.0 / (1.0 - c);
      }
    }
    return s - (c - c0) / tau2;
  }

  group('2PL discrimination fit (rung eligible2pl)', () {
    // Ability-balanced data pins the 1PL b EXACTLY at 0, isolating the
    // discrimination fit: kPlus/n correct at θ=+1 and kMinus/n at θ=−1 give the
    // closed-form 2PL MLE σ(a) = [(kPlus − kMinus)/n + 1]/2.
    List<CalibrationResponse> balanced(int kPlus, int kMinus, {int n = 10}) =>
        <CalibrationResponse>[
          ...atTheta(1.0, kPlus, n - kPlus),
          ...atTheta(-1.0, kMinus, n - kMinus),
        ];

    const IrtCalibrator weak = IrtCalibrator(
      CalibrationParams(
        minResponsesToRefine: 1,
        twoPlThreshold: 2,
        threePlThreshold: 100000,
        priorVariance: 1e9,
        discriminationPriorVariance: 1e9,
      ),
    );

    test('recovers the closed-form 2PL MLE a = ln 4 (b stays 0)', () {
      final CalibrationResult r =
          weak.calibrateItem(responses: balanced(8, 2), priorB: 0.0);
      expect(r.rung, CalibrationRung.eligible2pl);
      expect(r.b, closeTo(0.0, 1e-6)); // balanced data pins b at 0
      expect(r.a, closeTo(math.log(4), 1e-3)); // σ(a)=0.8 ⇒ a=ln4≈1.386
      expect(r.aRefined, isTrue);
      expect(r.aConverged, isTrue);
      expect(r.c, 0.0); // c passes through below the 3PL rung
      expect(r.cRefined, isFalse);
    });

    test('the fitted a is the root of its own MAP score (mixed data)', () {
      final List<CalibrationResponse> mixed = <CalibrationResponse>[
        ...atTheta(1.3, 7, 3),
        ...atTheta(-0.6, 2, 6),
        ...atTheta(0.2, 3, 3),
      ];
      final CalibrationResult r =
          weak.calibrateItem(responses: mixed, priorB: 0.1);
      expect(r.rung, CalibrationRung.eligible2pl);
      expect(r.a, greaterThan(0.2)); // not clamped
      expect(r.a, lessThan(4.0));
      expect(scoreA(mixed, r.a, r.b, 1.0, 1e9).abs(), lessThan(1e-6));
    });

    test('more sharply ability-separated data → a higher discrimination', () {
      final double sharp =
          weak.calibrateItem(responses: balanced(9, 1), priorB: 0.0).a;
      final double flat =
          weak.calibrateItem(responses: balanced(6, 4), priorB: 0.0).a;
      expect(sharp, greaterThan(flat)); // ln9 ≈ 2.20 vs ln1.5 ≈ 0.41
    });

    test('reverse-keyed data (higher ability does worse) clamps to aMin', () {
      // 2/10 right at θ=+1, 8/10 right at θ=−1 → the raw slope is negative.
      final CalibrationResult r =
          weak.calibrateItem(responses: balanced(2, 8), priorB: 0.0);
      expect(r.a, closeTo(0.2, 1e-6)); // aMin, never a ≤ 0 slope
      expect(r.aDelta, lessThan(0.0)); // a big drop from prior 1.0 flags it
      expect(r.a.isFinite, isTrue);
    });

    test('perfectly separating data clamps to a finite aMax, not ∞', () {
      final CalibrationResult r =
          weak.calibrateItem(responses: balanced(10, 0), priorB: 0.0);
      expect(r.a, closeTo(4.0, 1e-6)); // aMax
      expect(r.a.isFinite, isTrue);
    });

    test('a is shrunk toward the prior; a tighter prior shrinks harder', () {
      double fitA(double tau2) => IrtCalibrator(
            CalibrationParams(
              minResponsesToRefine: 1,
              twoPlThreshold: 2,
              threePlThreshold: 100000,
              priorVariance: 1e9,
              discriminationPriorVariance: tau2,
            ),
          ).calibrateItem(responses: balanced(9, 1), priorB: 0.0).a;
      expect(fitA(1e9), closeTo(math.log(9), 1e-3)); // inert prior → MLE
      expect(fitA(0.2), lessThan(fitA(1e9))); // shrinks back toward prior 1.0
      expect(fitA(0.2), greaterThan(1.0)); // but genuinely moved from the prior
      expect((fitA(0.05) - 1.0).abs(), lessThan((fitA(0.2) - 1.0).abs()));
    });

    test('no discrimination signal (all answers at θ=b) keeps the prior a', () {
      final CalibrationResult r = weak.calibrateItem(
        responses: atTheta(0.0, 6, 6), // every d_j = 0 → no data term in S(a)
        priorB: 0.0,
        priorA: 1.4,
      );
      expect(r.b, closeTo(0.0, 1e-6));
      expect(r.a, closeTo(1.4, 1e-6)); // stays at the prior mean
    });

    test('the a fit is deterministic and order-independent', () {
      final List<CalibrationResponse> d = balanced(7, 3);
      final double forward = weak.calibrateItem(responses: d, priorB: 0.0).a;
      final double reversed =
          weak.calibrateItem(responses: d.reversed.toList(), priorB: 0.0).a;
      expect(reversed, forward);
    });

    test('below the 2PL rung (refined1pl) a passes through verbatim', () {
      const IrtCalibrator floor = IrtCalibrator(
        CalibrationParams(
          minResponsesToRefine: 1,
          twoPlThreshold: 1000,
          threePlThreshold: 2000,
          priorVariance: 1e9,
        ),
      );
      final CalibrationResult r = floor.calibrateItem(
        responses: balanced(8, 2), // n=20 < 1000 → refined1pl
        priorB: 0.0,
        priorA: 1.7,
      );
      expect(r.rung, CalibrationRung.refined1pl);
      expect(r.a, 1.7); // byte-exact prior
      expect(r.aRefined, isFalse);
      expect(r.aDelta, 0.0);
    });
  });

  group('3PL guessing fit (rung eligible3pl, mcq only)', () {
    const IrtCalibrator weak = IrtCalibrator(
      CalibrationParams(
        minResponsesToRefine: 1,
        twoPlThreshold: 2,
        threePlThreshold: 4,
        priorVariance: 1e9,
        discriminationPriorVariance: 1e9,
        guessingPriorVariance: 1e9,
      ),
    );

    // Low-ability learners succeed FAR above the 2PL floor (guessing); high
    // ability nearly always right.
    List<CalibrationResponse> guessy() => <CalibrationResponse>[
          // Sampled from a TRUE 3PL (b=0, a=1.5, c=0.25) at five ability levels:
          // a low-ability success floor that NO c=0 2PL curve can reach (a 2PL
          // asymptotes to 0 at low θ), so the staged fit is forced to c > 0.
          // Two ability points alone would let (a, b) fit both exactly ⇒ c=0.
          ...atTheta(-3.0, 10, 30), // p≈0.26
          ...atTheta(-1.0, 15, 25), // p≈0.39
          ...atTheta(0.0, 25, 15), // p≈0.63
          ...atTheta(1.0, 35, 5), // p≈0.86
          ...atTheta(3.0, 39, 1), // p≈0.99
        ];

    test('the fitted c is the root of its own MAP score', () {
      final List<CalibrationResponse> rs = guessy();
      final CalibrationResult r =
          weak.calibrateItem(responses: rs, priorB: 0.0);
      expect(r.rung, CalibrationRung.eligible3pl);
      expect(r.c, greaterThan(0.0));
      expect(r.c, lessThan(0.5));
      expect(scoreC(rs, r.a, r.b, r.c, 0.0, 1e9).abs(), lessThan(1e-6));
    });

    test('a guessing signal lifts c above the prior floor', () {
      final CalibrationResult r =
          weak.calibrateItem(responses: guessy(), priorB: 0.0);
      expect(r.cRefined, isTrue);
      expect(r.c, greaterThan(0.0)); // low-ability corrects ⇒ c > 0
      expect(r.cConverged, isTrue);
    });

    test('clean 2PL data (no guessing) keeps c at the floor', () {
      // Low ability ~all wrong, high ~all right → c-MLE ≤ 0 → clamp cMin.
      final List<CalibrationResponse> clean = <CalibrationResponse>[
        ...atTheta(-2.5, 0, 30),
        ...atTheta(2.5, 30, 0),
      ];
      final CalibrationResult r =
          weak.calibrateItem(responses: clean, priorB: 0.0);
      expect(r.c, closeTo(0.0, 1e-6)); // cMin
    });

    test('c is shrunk toward the prior; a tighter prior shrinks harder', () {
      double fitC(double tau2) => IrtCalibrator(
            CalibrationParams(
              minResponsesToRefine: 1,
              twoPlThreshold: 2,
              threePlThreshold: 4,
              priorVariance: 1e9,
              discriminationPriorVariance: 1e9,
              guessingPriorVariance: tau2,
            ),
          ).calibrateItem(responses: guessy(), priorB: 0.0).c;
      expect(fitC(1e9), greaterThan(fitC(0.02))); // inert prior moves c furthest
      expect(fitC(0.02), greaterThanOrEqualTo(0.0)); // stays a valid floor
    });

    test('3PL is mcq-only: a non-mcq item never fits c', () {
      final CalibrationResult r = weak.calibrateItem(
        responses: guessy(),
        priorB: 0.0,
        priorC: 0.15,
        type: ExerciseType.translate,
      );
      expect(r.rung, CalibrationRung.eligible2pl); // capped below 3PL
      expect(r.cRefined, isFalse);
      expect(r.c, 0.15); // authored guessing passes through
    });

    test('below the 3PL rung (eligible2pl) c passes through verbatim', () {
      const IrtCalibrator twoPlOnly = IrtCalibrator(
        CalibrationParams(
          minResponsesToRefine: 1,
          twoPlThreshold: 2,
          threePlThreshold: 100000,
          priorVariance: 1e9,
          discriminationPriorVariance: 1e9,
        ),
      );
      final CalibrationResult r = twoPlOnly.calibrateItem(
        responses: guessy(),
        priorB: 0.0,
        priorC: 0.2,
      );
      expect(r.rung, CalibrationRung.eligible2pl);
      expect(r.cRefined, isFalse);
      expect(r.c, 0.2);
    });

    test('the c fit is deterministic and order-independent', () {
      final List<CalibrationResponse> rs = guessy();
      final double forward = weak.calibrateItem(responses: rs, priorB: 0.0).c;
      final double reversed =
          weak.calibrateItem(responses: rs.reversed.toList(), priorB: 0.0).c;
      expect(reversed, forward);
    });
  });

  group('calibrated params are always a valid IRT item', () {
    const IrtCalibrator weak = IrtCalibrator(
      CalibrationParams(
        minResponsesToRefine: 1,
        twoPlThreshold: 2,
        threePlThreshold: 4,
        priorVariance: 1e9,
        discriminationPriorVariance: 1e9,
        guessingPriorVariance: 1e9,
      ),
    );

    test('a fitted (a, b, c) constructs an IrtItem without tripping asserts', () {
      // Guessing, reverse and separating extremes all stay inside IrtItem's
      // a > 0, c ∈ [0, 1) contract.
      final List<List<CalibrationResponse>> datasets =
          <List<CalibrationResponse>>[
        <CalibrationResponse>[...atTheta(-2.5, 9, 21), ...atTheta(2.5, 28, 2)],
        <CalibrationResponse>[...atTheta(1.0, 2, 8), ...atTheta(-1.0, 8, 2)],
        <CalibrationResponse>[...atTheta(1.0, 10, 0), ...atTheta(-1.0, 0, 10)],
      ];
      for (final List<CalibrationResponse> rs in datasets) {
        final CalibrationResult r =
            weak.calibrateItem(responses: rs, priorB: 0.0);
        expect(r.a, greaterThan(0.0)); // IrtItem: a > 0
        expect(r.c, greaterThanOrEqualTo(0.0)); // IrtItem: c ∈ [0, 1)
        expect(r.c, lessThan(1.0));
        final IrtItem item = IrtItem(b: r.b, a: r.a, c: r.c);
        final double p = const IrtModel().pCorrectForItem(0.0, item);
        expect(p, greaterThanOrEqualTo(r.c)); // 3PL lower asymptote
        expect(p, lessThan(1.0));
      }
    });
  });

  group('2PL/3PL parameter validation', () {
    test('invalid new knobs trip an assertion', () {
      // Runtime values (no const-eval) so the assert fires at call time.
      double rt(double x) => <double>[x].first;
      expect(() => CalibrationParams(discriminationPriorVariance: rt(0.0)),
          throwsA(isA<AssertionError>()));
      expect(() => CalibrationParams(guessingPriorVariance: rt(-1.0)),
          throwsA(isA<AssertionError>()));
      expect(() => CalibrationParams(aMin: rt(0.0)),
          throwsA(isA<AssertionError>())); // a must stay > 0
      expect(() => CalibrationParams(aMin: rt(2.0), aMax: rt(1.0)),
          throwsA(isA<AssertionError>()));
      expect(() => CalibrationParams(cMin: rt(-0.1)),
          throwsA(isA<AssertionError>()));
      expect(() => CalibrationParams(cMax: rt(1.0)),
          throwsA(isA<AssertionError>())); // c must stay < 1
    });
  });

}
