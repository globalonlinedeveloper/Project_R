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
}
