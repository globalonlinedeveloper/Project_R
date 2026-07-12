import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/content/models/enums.dart' show ExerciseType;
import 'package:ratel/services/data_access/supabase_calibration_store.dart';
import 'package:ratel/services/learning/learning.dart';

void main() {
  group('pure row <-> model helpers (no DB)', () {
    test('rowForCalibratedItem maps the calibrated params + provenance, no ts',
        () {
      const CalibratedItem ci = CalibratedItem(
        b: 0.42,
        a: 1.3,
        c: 0.2,
        rung: CalibrationRung.eligible3pl,
        responseCount: 57,
      );
      final Map<String, Object?> row =
          SupabaseCalibrationStore.rowForCalibratedItem('es', 'item_9', ci);
      expect(row, <String, Object?>{
        'target_locale': 'es',
        'item_id': 'item_9',
        'irt_a': 1.3,
        'irt_b': 0.42,
        'irt_c': 0.2,
        'calib_rung': 'eligible3pl',
        'calib_n': 57,
      });
      // The instance method stamps calibrated_at; the pure payload must not, and
      // must never carry exercise_type (authored, untouched on conflict-update).
      expect(row.containsKey('calibrated_at'), isFalse);
      expect(row.containsKey('exercise_type'), isFalse);
    });

    test('rowForTheta maps the EAP result to an own-row payload, no ts', () {
      const EapThetaResult t = EapThetaResult(
        theta: -0.75,
        sd: 0.31,
        responseCount: 12,
        priorMean: 0.0,
      );
      final Map<String, Object?> row =
          SupabaseCalibrationStore.rowForTheta('fr', 'u_7', t);
      expect(row, <String, Object?>{
        'user_id': 'u_7',
        'target_locale': 'fr',
        'theta': -0.75,
        'theta_sd': 0.31,
        'response_count': 12,
      });
      expect(row.containsKey('updated_at'), isFalse);
    });

    test('entryFromRow reconstructs a review_log row (missing user_id OK)', () {
      final ReviewLogEntry e = SupabaseCalibrationStore.entryFromRow(
        <String, Object?>{
          // no user_id — the definer omits it; calibration pools across users
          'item_id': 'item_1',
          'skill': 'greetings',
          'grade': 2,
          'correct': true,
          'elapsed_ms': 4000,
          'theta_before': 0.5,
          'irt_b_at_review': -0.1,
          'source': 'lesson',
          'feeds_theta': true,
        },
      );
      expect(e.itemId, 'item_1');
      expect(e.skill, 'greetings');
      expect(e.grade, FsrsRating.hard); // value 2
      expect(e.correct, isTrue);
      expect(e.elapsedMs, 4000);
      expect(e.thetaBefore, 0.5);
      expect(e.irtBAtReview, -0.1);
      expect(e.source, 'lesson');
      expect(e.feedsTheta, isTrue);
    });

    test('entryFromRow: absent feeds_theta defaults TRUE; null-safe fields', () {
      final ReviewLogEntry e = SupabaseCalibrationStore.entryFromRow(
        <String, Object?>{'item_id': 'x', 'correct': false},
      );
      expect(e.feedsTheta, isTrue); // matches ReviewLogEntry default
      expect(e.skill, ''); // null-safe
      expect(e.correct, isFalse);
      expect(e.elapsedMs, 0);
      expect(e.thetaBefore, 0.0);
      expect(e.grade, FsrsRating.good); // unknown grade -> good
    });

    test('priorFromRow parses params + exercise type; defaults a=1,c=0', () {
      final ItemPrior p = SupabaseCalibrationStore.priorFromRow(
        <String, Object?>{
          'item_id': 'i',
          'irt_b': 1.5,
          'exercise_type': 'translate',
        },
      );
      expect(p.b, 1.5);
      expect(p.a, 1.0); // default
      expect(p.c, 0.0); // default
      expect(p.type, ExerciseType.translate);
    });

    test('exerciseTypeFromName: unknown/null -> mcq (the ItemPrior default)',
        () {
      expect(SupabaseCalibrationStore.exerciseTypeFromName('match'),
          ExerciseType.match);
      expect(SupabaseCalibrationStore.exerciseTypeFromName('nope'),
          ExerciseType.mcq);
      expect(
          SupabaseCalibrationStore.exerciseTypeFromName(null), ExerciseType.mcq);
    });

    test('fsrsRatingFromValue: 1..4 map; unknown -> good', () {
      expect(SupabaseCalibrationStore.fsrsRatingFromValue(1), FsrsRating.again);
      expect(SupabaseCalibrationStore.fsrsRatingFromValue(4), FsrsRating.easy);
      expect(SupabaseCalibrationStore.fsrsRatingFromValue(99), FsrsRating.good);
      expect(SupabaseCalibrationStore.fsrsRatingFromValue(null), FsrsRating.good);
    });

    test('entriesFromRows / priorsFromRows skip malformed + id-less rows', () {
      final List<ReviewLogEntry> entries =
          SupabaseCalibrationStore.entriesFromRows(<Object?>[
        <String, Object?>{'item_id': 'a', 'correct': true},
        'not a map',
        null,
      ]);
      expect(entries, hasLength(1));
      expect(entries.single.itemId, 'a');

      final Map<String, ItemPrior> priors =
          SupabaseCalibrationStore.priorsFromRows(<Object?>[
        <String, Object?>{'item_id': 'a', 'irt_b': 0.2},
        <String, Object?>{'irt_b': 9.9}, // no item_id -> skipped
        42,
      ]);
      expect(priors.keys, <String>['a']);
      expect(priors['a']!.b, 0.2);
    });
  });

  group('parsed rows compose with the pure CalibrationRunner (no DB)', () {
    test('DB-shaped rows -> parse -> refit -> valid write-back payloads',
        () async {
      // Rows exactly as the durable side returns them.
      final List<Map<String, Object?>> reviewRows = <Map<String, Object?>>[
        for (int i = 0; i < 40; i++)
          <String, Object?>{
            'item_id': 'itm',
            'skill': 's',
            'grade': 3,
            // a hard item: mostly wrong even at theta 0 -> difficulty rises
            'correct': i % 5 == 0,
            'elapsed_ms': 1000,
            'theta_before': 0.0,
            'irt_b_at_review': 0.0,
            'source': 'lesson',
            'feeds_theta': true,
          },
      ];
      final List<Map<String, Object?>> bankRows = <Map<String, Object?>>[
        <String, Object?>{
          'item_id': 'itm',
          'irt_b': 0.0,
          'irt_a': 1.0,
          'irt_c': 0.0,
          'exercise_type': 'translate',
        },
      ];

      // Seed the DORMANT in-memory store with the PARSED rows (this is exactly
      // what the Supabase ports would hand the runner) and run the real pass.
      final InMemoryCalibrationStore store = InMemoryCalibrationStore(
        reviewLog: <String, List<ReviewLogEntry>>{
          'es': SupabaseCalibrationStore.entriesFromRows(reviewRows),
        },
        itemBank: <String, Map<String, ItemPrior>>{
          'es': SupabaseCalibrationStore.priorsFromRows(bankRows),
        },
      );
      // Pilot profile: refine after 10 responses (launch default is 200)
      // so this focused 40-answer fixture exercises the refit->write path.
      const CalibrationRunner runner = CalibrationRunner(
        calibrator: IrtCalibrator(CalibrationParams(minResponsesToRefine: 10)),
      );
      final CalibrationRunReport report =
          await runner.runItemCalibration(store, 'es');

      // The item was re-fit and written back (rung above insufficientData).
      expect(report.written, contains('itm'));
      final CalibratedItem written = store.writtenItems['es']!['itm']!;
      // A hard item (20% correct at theta 0) pushes difficulty UP from 0.
      expect(written.b, greaterThan(0.0));
      expect(written.responseCount, 40);

      // Each written item re-serializes into a valid item_bank upsert payload.
      final Map<String, Object?> payload =
          SupabaseCalibrationStore.rowForCalibratedItem('es', 'itm', written);
      expect(payload['irt_b'], written.b);
      expect(payload['calib_n'], 40);
      expect(payload['calib_rung'], written.rung.name);
    });

    test('theta re-estimate: parsed own-row answers -> EAP -> persistable row',
        () async {
      final List<Map<String, Object?>> learnerRows = <Map<String, Object?>>[
        for (int i = 0; i < 8; i++)
          <String, Object?>{
            'item_id': 'itm',
            'skill': 's',
            'grade': 3,
            'correct': true, // consistently correct on a mid item -> theta up
            'elapsed_ms': 1000,
            'theta_before': 0.0,
            'irt_b_at_review': 0.0,
            'source': 'lesson',
            'feeds_theta': true,
          },
      ];
      final InMemoryCalibrationStore store = InMemoryCalibrationStore(
        itemBank: <String, Map<String, ItemPrior>>{
          'es': <String, ItemPrior>{'itm': const ItemPrior(b: 0.0)},
        },
        learnerReviewLog: <String, Map<String, List<ReviewLogEntry>>>{
          'es': <String, List<ReviewLogEntry>>{
            'u1': SupabaseCalibrationStore.entriesFromRows(learnerRows),
          },
        },
      );
      const CalibrationRunner runner = CalibrationRunner();
      final EapThetaResult theta =
          await runner.runThetaReestimate(store, 'es', 'u1');

      expect(theta.responseCount, 8);
      expect(theta.theta, greaterThan(0.0)); // all-correct -> ability above mean
      final Map<String, Object?> row =
          SupabaseCalibrationStore.rowForTheta('es', 'u1', theta);
      expect(row['response_count'], 8);
      expect(row['theta'], theta.theta);
      expect(row['user_id'], 'u1');
    });
  });
}
