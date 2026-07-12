// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// CALIBRATION-RUNNER [R-G3] tests for the pure re-calibration ORCHESTRATION
// (calibration_runner.dart) — the wiring that composes the shipped batch joint
// (a,b,c) refit + EAP theta estimator against the [CalibrationStore] seam, the
// go-live tail the irt.dart/ability.dart STOPs name. Properties proven:
//   * ITEM CALIBRATION reads the whole ReviewLog + item bank, joint-refits, and
//     writes back ONLY the items the staged ladder actually re-fit — the
//     thin-data verbatim set is reported but NEVER written (the guard travels
//     with the write);
//   * the feedsTheta gate drops non-calibrated rows on BOTH the item and theta
//     paths; unseen / unknown items keep their priors (params never invented);
//   * write-back updates the in-memory bank (read-back consistency); untouched
//     items stay byte-equal;
//   * the pass is deterministic + order-independent (a per-item sum);
//   * THETA re-estimate scores a learner's answers against the CURRENT params,
//     moves toward the evidence, and persists; no responses ⇒ the prior mean;
//   * the DORMANT default store makes both passes a genuine no-op (byte-
//     identical live — nothing consumes the providers yet);
//   * a recording fake pins the read-then-write call order + the write-gating.
// No clock, no randomness; all I/O crosses the injected store seam.
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/content/models/enums.dart';
import 'package:ratel/services/learning/calibration.dart';
import 'package:ratel/services/learning/calibration_runner.dart';
import 'package:ratel/services/learning/fsrs.dart' show FsrsRating;
import 'package:ratel/services/learning/learner_state.dart' show ReviewLogEntry;

/// A graded answer-spine entry with test-sensible defaults (only [itemId] +
/// [correct] matter to calibration; [feedsTheta] gates inclusion).
ReviewLogEntry _e(
  String itemId,
  bool correct, {
  double theta = 0.0,
  double b = 0.0,
  bool feedsTheta = true,
}) =>
    ReviewLogEntry(
      itemId: itemId,
      skill: 'sk',
      grade: correct ? FsrsRating.good : FsrsRating.again,
      correct: correct,
      elapsedMs: 0,
      thetaBefore: theta,
      irtBAtReview: b,
      source: 'lesson',
      feedsTheta: feedsTheta,
    );

/// Small-threshold runner so a handful of synthetic answers crosses the refine
/// rung (real defaults are 200 / 1000 / 2000). 2PL held far off ⇒ items stay
/// refined1pl, so `b` is the only moved coordinate (cleaner assertions).
const CalibrationRunner _smallRunner = CalibrationRunner(
  calibrator: IrtCalibrator(
    CalibrationParams(
      minResponsesToRefine: 4,
      twoPlThreshold: 40,
      threePlThreshold: 80,
    ),
  ),
);

/// Records the seam call order and gates nothing — proves the runner's I/O
/// sequence + write-gating independently of the in-memory double.
class _RecordingStore implements CalibrationStore {
  _RecordingStore({
    this.log = const <ReviewLogEntry>[],
    this.bank = const <String, ItemPrior>{},
    this.learnerLog = const <ReviewLogEntry>[],
  });

  final List<ReviewLogEntry> log;
  final Map<String, ItemPrior> bank;
  final List<ReviewLogEntry> learnerLog;
  final List<String> calls = <String>[];
  Map<String, CalibratedItem>? lastWrite;

  @override
  Future<List<ReviewLogEntry>> loadReviewLog(String courseId) async {
    calls.add('loadReviewLog');
    return log;
  }

  @override
  Future<Map<String, ItemPrior>> loadItemBank(String courseId) async {
    calls.add('loadItemBank');
    return bank;
  }

  @override
  Future<List<ReviewLogEntry>> loadLearnerReviewLog(
      String courseId, String userId) async {
    calls.add('loadLearnerReviewLog');
    return learnerLog;
  }

  @override
  Future<void> writeCalibratedItems(
      String courseId, Map<String, CalibratedItem> items) async {
    calls.add('writeCalibratedItems');
    lastWrite = items;
  }

  @override
  Future<void> persistTheta(
      String courseId, String userId, EapThetaResult theta) async {
    calls.add('persistTheta');
  }
}

void main() {
  group('item calibration', () {
    test('refines above the rung, keeps thin items verbatim, writes only refined',
        () async {
      final InMemoryCalibrationStore store = InMemoryCalibrationStore(
        itemBank: <String, Map<String, ItemPrior>>{
          'es': <String, ItemPrior>{
            'i_hard': const ItemPrior(b: 0.0, type: ExerciseType.translate),
            'i_thin': const ItemPrior(b: 0.5, type: ExerciseType.translate),
            'i_unseen': const ItemPrior(b: -0.3, type: ExerciseType.translate),
          },
        },
        reviewLog: <String, List<ReviewLogEntry>>{
          'es': <ReviewLogEntry>[
            // i_hard: 6 answers at θ=0, mostly WRONG ⇒ true b > authored 0.
            _e('i_hard', true),
            _e('i_hard', false),
            _e('i_hard', false),
            _e('i_hard', false),
            _e('i_hard', false),
            _e('i_hard', false),
            // i_thin: only 2 graded ⇒ insufficientData (verbatim).
            _e('i_thin', true),
            _e('i_thin', false),
            // feedsTheta=false noise on i_thin ⇒ dropped by the gate.
            _e('i_thin', false, feedsTheta: false),
            _e('i_thin', false, feedsTheta: false),
          ],
        },
      );

      final CalibrationRunReport report =
          await _smallRunner.runItemCalibration(store, 'es');

      expect(report.itemCount, 3);
      expect(report.written, <String>{'i_hard'});
      expect(report.writtenCount, 1);
      expect(report.verbatimCount, 2);
      expect(report.anyWritten, isTrue);

      final CalibrationResult hard = report.results['i_hard']!;
      expect(hard.rung, CalibrationRung.refined1pl);
      expect(hard.refined, isTrue);
      expect(hard.responseCount, 6);
      expect(hard.b, greaterThan(0.0)); // mostly-wrong at θ=0 ⇒ harder

      final CalibrationResult thin = report.results['i_thin']!;
      expect(thin.rung, CalibrationRung.insufficientData);
      expect(thin.refined, isFalse);
      expect(thin.responseCount, 2); // feedsTheta=false rows dropped
      expect(thin.b, 0.5); // verbatim

      final CalibrationResult unseen = report.results['i_unseen']!;
      expect(unseen.responseCount, 0);
      expect(unseen.b, -0.3); // verbatim

      // Only the refined item was written back, carrying its provenance.
      expect(store.writtenItems['es']!.keys, <String>{'i_hard'});
      expect(store.writtenItems['es']!['i_hard']!.b, hard.b);
      expect(store.writtenItems['es']!['i_hard']!.rung,
          CalibrationRung.refined1pl);
      expect(store.writtenItems['es']!['i_hard']!.responseCount, 6);
    });

    test('write-back updates the bank (read-back consistency); others unchanged',
        () async {
      final InMemoryCalibrationStore store = InMemoryCalibrationStore(
        itemBank: <String, Map<String, ItemPrior>>{
          'es': <String, ItemPrior>{
            'i_hard': const ItemPrior(b: 0.0, type: ExerciseType.translate),
            'i_thin': const ItemPrior(b: 0.5, type: ExerciseType.translate),
          },
        },
        reviewLog: <String, List<ReviewLogEntry>>{
          'es': <ReviewLogEntry>[
            _e('i_hard', true),
            _e('i_hard', false),
            _e('i_hard', false),
            _e('i_hard', false),
            _e('i_hard', false),
            _e('i_thin', true),
            _e('i_thin', false),
          ],
        },
      );

      final CalibrationRunReport report =
          await _smallRunner.runItemCalibration(store, 'es');
      final Map<String, ItemPrior> bank = await store.loadItemBank('es');
      expect(bank['i_hard']!.b, report.results['i_hard']!.b); // reflects calib
      expect(bank['i_hard']!.type, ExerciseType.translate); // type preserved
      expect(bank['i_thin']!.b, 0.5); // untouched
    });

    test('feedsTheta=false rows never calibrate (all-non-feed item stays thin)',
        () async {
      final InMemoryCalibrationStore store = InMemoryCalibrationStore(
        itemBank: <String, Map<String, ItemPrior>>{
          'es': <String, ItemPrior>{
            'i': const ItemPrior(b: 0.2, type: ExerciseType.translate),
          },
        },
        reviewLog: <String, List<ReviewLogEntry>>{
          'es': <ReviewLogEntry>[
            for (int k = 0; k < 20; k++) _e('i', false, feedsTheta: false),
          ],
        },
      );

      final CalibrationRunReport report =
          await _smallRunner.runItemCalibration(store, 'es');
      expect(report.results['i']!.responseCount, 0);
      expect(report.results['i']!.rung, CalibrationRung.insufficientData);
      expect(report.results['i']!.b, 0.2);
      expect(report.written, isEmpty);
      expect(store.writtenItems['es'], isNull); // never written at all
    });

    test('deterministic + order-independent (shuffled log ⇒ identical result)',
        () async {
      final Map<String, ItemPrior> bank = <String, ItemPrior>{
        'i_hard': const ItemPrior(b: 0.0, type: ExerciseType.translate),
        'i_easy': const ItemPrior(b: 0.0, type: ExerciseType.translate),
      };
      final List<ReviewLogEntry> entries = <ReviewLogEntry>[
        _e('i_hard', true),
        _e('i_hard', false),
        _e('i_hard', false),
        _e('i_hard', false),
        _e('i_hard', false),
        _e('i_hard', false),
        _e('i_easy', true),
        _e('i_easy', true),
        _e('i_easy', true),
        _e('i_easy', true),
        _e('i_easy', false),
      ];
      final InMemoryCalibrationStore a = InMemoryCalibrationStore(
        itemBank: <String, Map<String, ItemPrior>>{'es': bank},
        reviewLog: <String, List<ReviewLogEntry>>{'es': entries},
      );
      final InMemoryCalibrationStore b = InMemoryCalibrationStore(
        itemBank: <String, Map<String, ItemPrior>>{'es': bank},
        reviewLog: <String, List<ReviewLogEntry>>{
          'es': entries.reversed.toList(),
        },
      );
      final CalibrationRunReport rA = await _smallRunner.runItemCalibration(a, 'es');
      final CalibrationRunReport rB = await _smallRunner.runItemCalibration(b, 'es');
      expect(rA.written, rB.written);
      expect(rA.written, <String>{'i_hard', 'i_easy'});
      for (final String id in rA.results.keys) {
        expect(rA.results[id]!.b, closeTo(rB.results[id]!.b, 1e-12));
        expect(rA.results[id]!.a, closeTo(rB.results[id]!.a, 1e-12));
      }
    });
  });

  group('theta re-estimate', () {
    test('moves toward the evidence and persists the result', () async {
      final InMemoryCalibrationStore store = InMemoryCalibrationStore(
        itemBank: <String, Map<String, ItemPrior>>{
          'es': <String, ItemPrior>{
            'hard': const ItemPrior(b: 2.0, a: 1.0, type: ExerciseType.translate),
          },
        },
        learnerReviewLog: <String, Map<String, List<ReviewLogEntry>>>{
          'es': <String, List<ReviewLogEntry>>{
            'u1': <ReviewLogEntry>[
              _e('hard', true),
              _e('hard', true),
              _e('hard', true),
              _e('hard', true),
            ],
          },
        },
      );
      final EapThetaResult res =
          await const CalibrationRunner().runThetaReestimate(store, 'es', 'u1');
      expect(res.responseCount, 4);
      expect(res.theta, greaterThan(0.3)); // 4 corrects on a b=2 item ⇒ high θ
      expect(res.refined, isTrue);
      expect(store.persistedTheta['es']!['u1'], same(res));
    });

    test('no responses ⇒ prior mean exactly; unknown / non-feed rows skipped',
        () async {
      final InMemoryCalibrationStore store = InMemoryCalibrationStore(
        itemBank: <String, Map<String, ItemPrior>>{
          'es': <String, ItemPrior>{
            'known': const ItemPrior(b: 0.0, type: ExerciseType.translate),
          },
        },
        learnerReviewLog: <String, Map<String, List<ReviewLogEntry>>>{
          'es': <String, List<ReviewLogEntry>>{
            'empty': const <ReviewLogEntry>[],
            'u2': <ReviewLogEntry>[
              _e('ghost', true), // not in the bank ⇒ skipped
              _e('known', true), // counted
              _e('known', false, feedsTheta: false), // gate-dropped
            ],
          },
        },
      );
      final EapThetaResult r0 =
          await const CalibrationRunner().runThetaReestimate(store, 'es', 'empty');
      expect(r0.responseCount, 0);
      expect(r0.theta, closeTo(0.0, 1e-9)); // prior mean to fp precision
      expect(r0.refined, isFalse);

      final EapThetaResult r2 =
          await const CalibrationRunner().runThetaReestimate(store, 'es', 'u2');
      expect(r2.responseCount, 1); // only 'known' (feedsTheta) counted
    });
  });

  group('dormant default (byte-identical live)', () {
    test('item calibration on the empty default store is a genuine no-op',
        () async {
      final InMemoryCalibrationStore store = InMemoryCalibrationStore();
      final CalibrationRunReport report =
          await const CalibrationRunner().runItemCalibration(store, 'es');
      expect(report.itemCount, 0);
      expect(report.written, isEmpty);
      expect(report.anyWritten, isFalse);
      expect(store.writtenItems, isEmpty);
    });

    test('theta re-estimate on the empty default store ⇒ prior mean, persisted',
        () async {
      final InMemoryCalibrationStore store = InMemoryCalibrationStore();
      final EapThetaResult res = await const CalibrationRunner()
          .runThetaReestimate(store, 'es', 'nobody');
      expect(res.responseCount, 0);
      expect(res.theta, closeTo(0.0, 1e-9)); // prior mean to fp precision
      expect(res.refined, isFalse);
      expect(store.persistedTheta['es']!['nobody'], same(res));
    });
  });

  group('seam call order + write-gating (recording fake)', () {
    test('item calibration reads then writes when an item is refined', () async {
      final _RecordingStore store = _RecordingStore(
        bank: <String, ItemPrior>{
          'i': const ItemPrior(b: 0.0, type: ExerciseType.translate),
        },
        log: <ReviewLogEntry>[
          _e('i', true),
          _e('i', false),
          _e('i', false),
          _e('i', false),
          _e('i', false),
        ],
      );
      await _smallRunner.runItemCalibration(store, 'es');
      expect(store.calls,
          <String>['loadReviewLog', 'loadItemBank', 'writeCalibratedItems']);
      expect(store.lastWrite!.keys, <String>{'i'});
    });

    test('item calibration reads but does NOT write when all items are thin',
        () async {
      final _RecordingStore store = _RecordingStore(
        bank: <String, ItemPrior>{
          'i': const ItemPrior(b: 0.0, type: ExerciseType.translate),
        },
        log: <ReviewLogEntry>[_e('i', true), _e('i', false)],
      );
      final CalibrationRunReport report =
          await _smallRunner.runItemCalibration(store, 'es');
      expect(store.calls, <String>['loadReviewLog', 'loadItemBank']);
      expect(report.written, isEmpty);
    });

    test('theta re-estimate reads learner log + bank then persists', () async {
      final _RecordingStore store = _RecordingStore(
        bank: <String, ItemPrior>{
          'i': const ItemPrior(b: 0.0, type: ExerciseType.translate),
        },
        learnerLog: <ReviewLogEntry>[_e('i', true)],
      );
      await const CalibrationRunner().runThetaReestimate(store, 'es', 'u1');
      expect(store.calls,
          <String>['loadLearnerReviewLog', 'loadItemBank', 'persistTheta']);
    });
  });
}
