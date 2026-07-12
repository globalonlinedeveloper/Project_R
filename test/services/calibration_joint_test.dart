// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// CALIBRATION-1 [R-G3] tests for the go-live TAIL of the batch re-fit math:
//   * calibrateItemJoint — the FULL JOINT / iterated (a, b, c) refit (guarded
//     cyclic coordinate ascent). Properties proven: insufficientData is verbatim
//     (cycles 0); refined1pl is byte-identical to the single-pass b; the 2PL
//     (a, b) co-fit CONVERGES and IMPROVES the data fit over the prior; a weak
//     prior moves the estimate toward the generating truth while a tight prior
//     shrinks it back (thin-data safety); reverse-keyed data clamps `a` to the
//     positive floor (a valid slope, a review flag); the fit is deterministic
//     and order-independent; the mcq 3PL rung fits a valid guessing floor.
//   * EapThetaEstimator — the batch EAP posterior-mean θ. Properties: no
//     responses returns the prior mean EXACTLY (thin-data safe); correct/incorrect
//     evidence moves θ up/down and monotonically in the count; symmetric evidence
//     returns the prior mean; the posterior SD shrinks with evidence; the mcq
//     guessing guard discounts a correct answer; deterministic + order-independent.
// No clock, no I/O, no randomness.
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/models/enums.dart' show ExerciseType;
import 'package:ratel/services/services.dart';

void main() {
  // Runtime-arg helpers (no const-eval → keeps the analyzer happy, mirroring
  // calibration_test.dart's `one`).
  CalibrationResponse one(double theta, bool correct) =>
      CalibrationResponse(theta: theta, correct: correct);

  List<CalibrationResponse> atTheta(double theta, int nCorrect, int nWrong) =>
      <CalibrationResponse>[
        for (int i = 0; i < nCorrect; i++) one(theta, true),
        for (int i = 0; i < nWrong; i++) one(theta, false),
      ];

  // A 2PL-ish dataset symmetric around b* = 0: correctness rises with θ.
  List<CalibrationResponse> spread(int mult) => <CalibrationResponse>[
        ...atTheta(-2.0, 0, 3 * mult),
        ...atTheta(-1.0, 1 * mult, 2 * mult),
        ...atTheta(1.0, 2 * mult, 1 * mult),
        ...atTheta(2.0, 3 * mult, 0),
      ];

  // Reverse-keyed: correctness FALLS with θ (negative slope).
  List<CalibrationResponse> reverse(int mult) => <CalibrationResponse>[
        ...atTheta(2.0, 0, 3 * mult),
        ...atTheta(1.0, 1 * mult, 2 * mult),
        ...atTheta(-1.0, 2 * mult, 1 * mult),
        ...atTheta(-2.0, 3 * mult, 0),
      ];

  // mcq data with real correct answers down at low θ (a guessing floor).
  List<CalibrationResponse> guessy(int mult) => <CalibrationResponse>[
        ...atTheta(-2.0, 1 * mult, 3 * mult),
        ...atTheta(0.0, 2 * mult, 2 * mult),
        ...atTheta(2.0, 3 * mult, 1 * mult),
      ];

  double p3(double theta, double a, double b, double c) {
    final double g = 1.0 / (1.0 + math.exp(-a * (theta - b)));
    return c + (1.0 - c) * g;
  }

  double logLik(List<CalibrationResponse> rs, double a, double b, double c,
      {bool mcq = true}) {
    final double cc = mcq ? c : 0.0;
    double s = 0.0;
    for (final CalibrationResponse r in rs) {
      final double p = p3(r.theta, a, b, cc);
      final double pc = p < 1e-12 ? 1e-12 : (p > 1.0 - 1e-12 ? 1.0 - 1e-12 : p);
      s += r.correct ? math.log(pc) : math.log(1.0 - pc);
    }
    return s;
  }

  // Low thresholds so modest datasets reach the rungs; wide priors → data leads.
  const CalibrationParams looseP = CalibrationParams(
    minResponsesToRefine: 4,
    twoPlThreshold: 8,
    threePlThreshold: 1000,
    priorVariance: 100.0,
    discriminationPriorVariance: 100.0,
  );
  // Tight priors → strong shrinkage.
  const CalibrationParams tightP = CalibrationParams(
    minResponsesToRefine: 4,
    twoPlThreshold: 8,
    threePlThreshold: 1000,
    priorVariance: 1e-4,
    discriminationPriorVariance: 1e-4,
  );
  // 3PL reachable at a small count.
  const CalibrationParams mcqP = CalibrationParams(
    minResponsesToRefine: 4,
    twoPlThreshold: 8,
    threePlThreshold: 20,
    priorVariance: 100.0,
    discriminationPriorVariance: 100.0,
    guessingPriorVariance: 0.5,
  );

  group('joint refit — insufficient / refined1pl parity', () {
    test('insufficientData returns authored params verbatim, cycles 0', () {
      const IrtCalibrator cal = IrtCalibrator();
      final CalibrationResult r = cal.calibrateItemJoint(
        responses: atTheta(3.0, 0, 5),
        priorB: 0.4,
        priorA: 1.3,
        priorC: 0.1,
        type: ExerciseType.mcq,
      );
      expect(r.rung, CalibrationRung.insufficientData);
      expect(r.b, 0.4);
      expect(r.a, 1.3);
      expect(r.c, 0.1);
      expect(r.cycles, 0);
      expect(r.jointConverged, isTrue);
      expect(r.refined, isFalse);
    });

    test('refined1pl b is byte-identical to the single-pass, cycles 1', () {
      const IrtCalibrator cal = IrtCalibrator(looseP); // n=6 → refined1pl
      final List<CalibrationResponse> d = atTheta(1.0, 4, 2);
      final CalibrationResult single =
          cal.calibrateItem(responses: d, priorB: 0.2, priorA: 1.1);
      final CalibrationResult joint =
          cal.calibrateItemJoint(responses: d, priorB: 0.2, priorA: 1.1);
      expect(joint.rung, CalibrationRung.refined1pl);
      expect(joint.b, single.b); // exact
      expect(joint.a, 1.1); // a passes through below the 2PL rung
      expect(joint.cycles, 1);
      expect(joint.jointConverged, isTrue);
    });
  });

  group('joint refit — 2PL co-fit converges and improves the fit', () {
    test('eligible2pl converges with a and b both refined, valid ranges', () {
      const IrtCalibrator cal = IrtCalibrator(looseP);
      final CalibrationResult r = cal.calibrateItemJoint(
        responses: spread(4), // 48 responses
        priorB: 1.5,
        priorA: 0.8,
        type: ExerciseType.translate,
      );
      expect(r.rung, CalibrationRung.eligible2pl);
      expect(r.jointConverged, isTrue);
      expect(r.aRefined, isTrue);
      expect(r.cycles, greaterThanOrEqualTo(1));
      expect(r.a, inInclusiveRange(looseP.aMin, looseP.aMax));
      expect(r.b, inInclusiveRange(looseP.bMin, looseP.bMax));
    });

    test('the joint fit raises the data log-likelihood above the prior', () {
      const IrtCalibrator cal = IrtCalibrator(looseP);
      final List<CalibrationResponse> d = spread(4);
      final CalibrationResult r = cal.calibrateItemJoint(
        responses: d,
        priorB: 1.5,
        priorA: 0.8,
        type: ExerciseType.translate,
      );
      final double llFit = logLik(d, r.a, r.b, 0.0, mcq: false);
      final double llPrior = logLik(d, 0.8, 1.5, 0.0, mcq: false);
      expect(llFit, greaterThanOrEqualTo(llPrior - 1e-9));
    });

    test('weak prior moves b and a TOWARD the generating truth (b*=0)', () {
      const IrtCalibrator cal = IrtCalibrator(looseP);
      final CalibrationResult r = cal.calibrateItemJoint(
        responses: spread(4),
        priorB: 1.5, // offset from truth 0
        priorA: 0.5,
        type: ExerciseType.translate,
      );
      expect(r.b.abs(), lessThan(1.5)); // moved toward 0
      expect(r.b, lessThan(1.5)); // strictly down
      expect(r.a, greaterThan(0.5)); // positive discrimination emerged
    });

    test('tight prior SHRINKS the estimate back to the authored priors', () {
      const IrtCalibrator cal = IrtCalibrator(tightP);
      final CalibrationResult r = cal.calibrateItemJoint(
        responses: spread(4),
        priorB: 1.5,
        priorA: 0.9,
        type: ExerciseType.translate,
      );
      expect(r.b, closeTo(1.5, 0.1)); // barely moved
      expect(r.a, closeTo(0.9, 0.1));
    });

    test('reverse-keyed data clamps a to the positive floor (valid slope)', () {
      const IrtCalibrator cal = IrtCalibrator(looseP);
      final CalibrationResult r = cal.calibrateItemJoint(
        responses: reverse(4),
        priorB: 0.0,
        priorA: 1.0,
        type: ExerciseType.translate,
      );
      expect(r.a, greaterThan(0.0)); // never a non-positive slope
      expect(r.a, closeTo(looseP.aMin, 1e-9)); // pinned to the floor
    });

    test('joint refit is deterministic and order-independent', () {
      const IrtCalibrator cal = IrtCalibrator(looseP);
      final List<CalibrationResponse> d = spread(4);
      final List<CalibrationResponse> shuffled =
          d.reversed.toList(growable: false);
      final CalibrationResult a = cal.calibrateItemJoint(
          responses: d, priorB: 0.7, priorA: 1.0, type: ExerciseType.translate);
      final CalibrationResult b = cal.calibrateItemJoint(
          responses: shuffled,
          priorB: 0.7,
          priorA: 1.0,
          type: ExerciseType.translate);
      expect(a.b, b.b);
      expect(a.a, b.a);
      expect(a.cycles, b.cycles);
    });
  });

  group('joint refit — 3PL and batch', () {
    test('mcq 3PL rung fits a valid IRT item (a≥aMin, 0≤c<1)', () {
      const IrtCalibrator cal = IrtCalibrator(mcqP);
      final CalibrationResult r = cal.calibrateItemJoint(
        responses: guessy(4), // 48 mcq responses ≥ threePlThreshold 20
        priorB: 0.0,
        priorA: 1.0,
        priorC: 0.1,
        type: ExerciseType.mcq,
      );
      expect(r.rung, CalibrationRung.eligible3pl);
      expect(r.cRefined, isTrue);
      expect(r.a, greaterThanOrEqualTo(mcqP.aMin));
      expect(r.c, inInclusiveRange(mcqP.cMin, mcqP.cMax));
      expect(r.c, lessThan(1.0));
      // Thin 3PL data may not settle to jointTolerance within jointMaxCycles
      // (the guessing coordinate is weakly identified) — the fit is still a
      // VALID, improved item, and jointConverged HONESTLY reports settling.
      expect(r.cycles, lessThanOrEqualTo(mcqP.jointMaxCycles));
      final double llFit = logLik(guessy(4), r.a, r.b, r.c);
      final double llPrior = logLik(guessy(4), 1.0, 0.0, 0.1);
      expect(llFit, greaterThanOrEqualTo(llPrior - 1e-9));
    });

    test('non-mcq at the 2PL rung leaves c untouched', () {
      const IrtCalibrator cal = IrtCalibrator(looseP);
      final CalibrationResult r = cal.calibrateItemJoint(
        responses: spread(4),
        priorB: 0.2,
        priorA: 1.0,
        priorC: 0.15,
        type: ExerciseType.translate,
      );
      expect(r.cRefined, isFalse);
      expect(r.c, 0.15); // verbatim
    });

    test('calibrateBatchJoint maps items and keeps unseen ones on their prior',
        () {
      const IrtCalibrator cal = IrtCalibrator(looseP);
      final Map<String, CalibrationResult> out = cal.calibrateBatchJoint(
        priors: <String, ItemPrior>{
          'seen': const ItemPrior(b: 1.5, type: ExerciseType.translate),
          'unseen': const ItemPrior(b: -0.3, type: ExerciseType.translate),
        },
        responsesByItem: <String, List<CalibrationResponse>>{
          'seen': spread(4),
        },
      );
      expect(out['unseen']!.rung, CalibrationRung.insufficientData);
      expect(out['unseen']!.b, -0.3);
      expect(out['seen']!.rung, CalibrationRung.eligible2pl);
      expect(out['seen']!.b, lessThan(1.5));
    });
  });

  group('EAP θ — thin-data safety and evidence direction', () {
    ThetaResponse tr(double b, bool correct,
            {double a = 1.0,
            double c = 0.0,
            ExerciseType type = ExerciseType.mcq}) =>
        ThetaResponse(
          item: IrtItem(b: b, a: a, c: c),
          correct: correct,
          type: type,
        );

    test('no responses returns the prior mean EXACTLY', () {
      const EapThetaEstimator est = EapThetaEstimator();
      final EapThetaResult r = est.estimate(const <ThetaResponse>[]);
      expect(r.theta, closeTo(0.0, 1e-9));
      expect(r.responseCount, 0);
      expect(r.refined, isFalse);
    });

    test('a non-zero prior mean is returned verbatim when thin', () {
      const EapThetaEstimator est =
          EapThetaEstimator(EapThetaParams(priorMean: 1.5));
      final EapThetaResult r = est.estimate(const <ThetaResponse>[]);
      expect(r.theta, closeTo(1.5, 1e-9));
    });

    test('correct evidence pulls θ up, incorrect pulls it down', () {
      const EapThetaEstimator est = EapThetaEstimator();
      final double up = est
          .estimate(<ThetaResponse>[for (int i = 0; i < 4; i++) tr(0.0, true)])
          .theta;
      final double down = est
          .estimate(<ThetaResponse>[for (int i = 0; i < 4; i++) tr(0.0, false)])
          .theta;
      expect(up, greaterThan(0.0));
      expect(down, lessThan(0.0));
    });

    test('θ increases monotonically with the count of correct answers', () {
      const EapThetaEstimator est = EapThetaEstimator();
      final double one =
          est.estimate(<ThetaResponse>[tr(0.0, true)]).theta;
      final double three = est
          .estimate(<ThetaResponse>[for (int i = 0; i < 3; i++) tr(0.0, true)])
          .theta;
      expect(three, greaterThan(one));
      expect(one, greaterThan(0.0));
    });

    test('symmetric evidence returns the prior mean exactly', () {
      const EapThetaEstimator est = EapThetaEstimator();
      final EapThetaResult r =
          est.estimate(<ThetaResponse>[tr(0.0, true), tr(0.0, false)]);
      expect(r.theta, closeTo(0.0, 1e-9));
    });

    test('the posterior SD shrinks as evidence accumulates', () {
      const EapThetaEstimator est = EapThetaEstimator();
      final double sdPrior = est.estimate(const <ThetaResponse>[]).sd;
      final double sdMany = est
          .estimate(<ThetaResponse>[for (int i = 0; i < 8; i++) tr(0.0, i.isEven)])
          .sd;
      expect(sdMany, lessThan(sdPrior));
    });

    test('the mcq guessing guard discounts a correct answer', () {
      const EapThetaEstimator est = EapThetaEstimator();
      final double mcqUp = est
          .estimate(<ThetaResponse>[
            tr(0.0, true, c: 0.4, type: ExerciseType.mcq)
          ])
          .theta;
      final double plainUp = est
          .estimate(<ThetaResponse>[
            tr(0.0, true, c: 0.4, type: ExerciseType.translate)
          ])
          .theta;
      expect(mcqUp, greaterThan(0.0)); // still informative
      expect(mcqUp, lessThan(plainUp)); // but less than the un-guessed item
    });

    test('EAP is deterministic and order-independent', () {
      const EapThetaEstimator est = EapThetaEstimator();
      final List<ThetaResponse> rs = <ThetaResponse>[
        tr(-1.0, true),
        tr(0.5, false),
        tr(1.0, true),
      ];
      final double a = est.estimate(rs).theta;
      final double b =
          est.estimate(rs.reversed.toList(growable: false)).theta;
      expect(a, closeTo(b, 1e-12));
    });
  });
}
