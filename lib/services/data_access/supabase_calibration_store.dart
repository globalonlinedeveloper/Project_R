import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ratel/content/models/enums.dart' show ExerciseType;
import 'package:ratel/services/learning/calibration.dart'
    show ItemPrior, EapThetaResult;
import 'package:ratel/services/learning/calibration_runner.dart'
    show CalibratedItem, CalibrationStore;
import 'package:ratel/services/learning/fsrs.dart' show FsrsRating;
import 'package:ratel/services/learning/learner_state.dart' show ReviewLogEntry;

/// Stage-3 [CalibrationStore] backed by Supabase (R-G3 go-live tail) — the
/// durable side of batch IRT re-calibration behind the S139 seam.
///
/// BUILD-AHEAD / DORMANT: nothing consumes `calibrationRunnerProvider` at
/// runtime, so wiring this into `backendOverridesForClient` is byte-identical
/// live (the same flagged go-live wiring as [SupabaseLeaguesStore]). It goes
/// live only when a batch HOST (an edge function or a scheduled job holding
/// service_role) runs the pure `CalibrationRunner` against it — see
/// `RATEL_L5_CALIBRATION_MIGRATION.sql` for the prod schema + the owner-gated
/// choice of batch host + `pg_cron` cadence.
///
/// Role model (why the ports split by caller — mirrors the leagues own-row vs.
/// SECURITY DEFINER lesson, S73):
///  - [loadReviewLog] — the CROSS-USER course ReviewLog aggregate. `review_log`
///    is own-row RLS, so no client may SELECT every learner's answers; it is
///    served by the `read_course_review_log` SECURITY DEFINER whose EXECUTE is
///    restricted to the batch (service_role), never authenticated clients.
///  - [writeCalibratedItems] — an UPDATE of the shared `item_bank` param
///    overlay; service_role (the batch) only. Authenticated clients get
///    read-only current params.
///  - [loadLearnerReviewLog] / [persistTheta] — OWN-ROW: a learner reads their
///    own answers and writes their own theta under own-row RLS (client-capable).
///  - [loadItemBank] — reads the shared `item_bank` params (authenticated
///    SELECT); the priors the batch shrinks toward.
///
/// The pure row<->model helpers are static + DB-free so they unit-test exactly
/// like [SupabaseReviewLogSink.rowFor]; the instance methods add only the
/// Supabase transport + the write timestamp.
class SupabaseCalibrationStore implements CalibrationStore {
  SupabaseCalibrationStore(this._db);

  /// Wire to the live Supabase client (role governs which ports succeed).
  factory SupabaseCalibrationStore.fromClient(SupabaseClient client) =>
      SupabaseCalibrationStore(client);

  final SupabaseClient _db;

  /// Shared item-parameter overlay (updatable `irt_a`/`irt_b`/`irt_c` + the
  /// `calib_rung`/`calib_n` provenance the thin-data guard records).
  static const String itemBankTable = 'item_bank';

  /// Per-learner global-theta persistence (own-row).
  static const String thetaTable = 'learner_theta';

  /// The append-only answer spine (own-row) the theta re-estimate reads.
  static const String reviewLogTable = 'review_log';

  /// SECURITY DEFINER serving the CROSS-USER course ReviewLog to the batch.
  static const String courseReviewLogFn = 'read_course_review_log';

  // ---- durable ports (role-governed transport) ----

  @override
  Future<List<ReviewLogEntry>> loadReviewLog(String courseId) async {
    final Object? res = await _db.rpc(
      courseReviewLogFn,
      params: <String, Object?>{'p_target_locale': courseId},
    );
    if (res is! List) return const <ReviewLogEntry>[];
    return entriesFromRows(res);
  }

  @override
  Future<Map<String, ItemPrior>> loadItemBank(String courseId) async {
    final List<Map<String, dynamic>> rows =
        await _db.from(itemBankTable).select().eq('target_locale', courseId);
    return priorsFromRows(rows);
  }

  @override
  Future<List<ReviewLogEntry>> loadLearnerReviewLog(
      String courseId, String userId) async {
    final List<Map<String, dynamic>> rows = await _db
        .from(reviewLogTable)
        .select()
        .eq('target_locale', courseId)
        .eq('user_id', userId);
    return entriesFromRows(rows);
  }

  @override
  Future<void> writeCalibratedItems(
      String courseId, Map<String, CalibratedItem> items) async {
    if (items.isEmpty) return; // nothing refined -> no write (thin-data guard)
    final String stampedAt = DateTime.now().toUtc().toIso8601String();
    final List<Map<String, Object?>> rows = <Map<String, Object?>>[];
    items.forEach((String id, CalibratedItem ci) {
      rows.add(<String, Object?>{
        ...rowForCalibratedItem(courseId, id, ci),
        'calibrated_at': stampedAt,
      });
    });
    await _db
        .from(itemBankTable)
        .upsert(rows, onConflict: 'target_locale,item_id');
  }

  @override
  Future<void> persistTheta(
      String courseId, String userId, EapThetaResult theta) async {
    await _db.from(thetaTable).upsert(
      <String, Object?>{
        ...rowForTheta(courseId, userId, theta),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id,target_locale',
    );
  }

  // ---- pure helpers (no I/O; unit-tested without a DB) ----

  /// A `review_log` (or `read_course_review_log`) row -> [ReviewLogEntry].
  /// Reads only the calibration-relevant columns, tolerant of a missing
  /// `user_id` (the definer omits it — item calibration pools across users and
  /// never needs identity) and null-safe on every field. `feeds_theta` defaults
  /// TRUE when absent (matches the [ReviewLogEntry] default).
  static ReviewLogEntry entryFromRow(Map<String, Object?> row) =>
      ReviewLogEntry(
        itemId: (row['item_id'] ?? '').toString(),
        skill: (row['skill'] ?? '').toString(),
        grade: fsrsRatingFromValue((row['grade'] as num?)?.toInt()),
        correct: row['correct'] == true,
        elapsedMs: (row['elapsed_ms'] as num?)?.toInt() ?? 0,
        thetaBefore: (row['theta_before'] as num?)?.toDouble() ?? 0.0,
        irtBAtReview: (row['irt_b_at_review'] as num?)?.toDouble() ?? 0.0,
        source: (row['source'] ?? '').toString(),
        feedsTheta: row['feeds_theta'] != false,
      );

  /// Parse a list of raw rows (rpc result or a `select`) into entries, skipping
  /// non-map rows defensively.
  static List<ReviewLogEntry> entriesFromRows(List<Object?> rows) => rows
      .whereType<Map<dynamic, dynamic>>()
      .map((Map<dynamic, dynamic> r) =>
          entryFromRow(Map<String, Object?>.from(r)))
      .toList();

  /// An `item_bank` row -> [ItemPrior] (the prior the batch shrinks toward).
  /// Missing `irt_a`/`irt_c` fall back to the [ItemPrior] defaults (a=1, c=0).
  static ItemPrior priorFromRow(Map<String, Object?> row) => ItemPrior(
        b: (row['irt_b'] as num?)?.toDouble() ?? 0.0,
        a: (row['irt_a'] as num?)?.toDouble() ?? 1.0,
        c: (row['irt_c'] as num?)?.toDouble() ?? 0.0,
        type: exerciseTypeFromName(row['exercise_type']?.toString()),
      );

  /// Parse item-bank rows into the id -> [ItemPrior] map the runner reads,
  /// skipping rows with no `item_id`.
  static Map<String, ItemPrior> priorsFromRows(List<Object?> rows) {
    final Map<String, ItemPrior> out = <String, ItemPrior>{};
    for (final Object? r in rows) {
      if (r is! Map) continue;
      final Map<String, Object?> row = Map<String, Object?>.from(r);
      final String id = (row['item_id'] ?? '').toString();
      if (id.isEmpty) continue;
      out[id] = priorFromRow(row);
    }
    return out;
  }

  /// [CalibratedItem] -> an `item_bank` upsert payload (the calibrated params +
  /// provenance). NO timestamp — the instance method stamps `calibrated_at`; and
  /// NO `exercise_type` — it is authored content, left untouched on the
  /// conflict-UPDATE (only ever pre-existing answered items are re-calibrated).
  static Map<String, Object?> rowForCalibratedItem(
          String courseId, String itemId, CalibratedItem ci) =>
      <String, Object?>{
        'target_locale': courseId,
        'item_id': itemId,
        'irt_a': ci.a,
        'irt_b': ci.b,
        'irt_c': ci.c,
        'calib_rung': ci.rung.name,
        'calib_n': ci.responseCount,
      };

  /// [EapThetaResult] -> a `learner_theta` upsert payload (own-row). NO
  /// timestamp — the instance method stamps `updated_at`.
  static Map<String, Object?> rowForTheta(
          String courseId, String userId, EapThetaResult t) =>
      <String, Object?>{
        'user_id': userId,
        'target_locale': courseId,
        'theta': t.theta,
        'theta_sd': t.sd,
        'response_count': t.responseCount,
      };

  /// Parse an [ExerciseType] by its enum name, defaulting to [ExerciseType.mcq]
  /// on unknown/null (the [ItemPrior] default; only `mcq` reaches the 3PL rung).
  static ExerciseType exerciseTypeFromName(String? name) =>
      ExerciseType.values.firstWhere((ExerciseType e) => e.name == name,
          orElse: () => ExerciseType.mcq);

  /// Parse an FSRS 1..4 grade int, defaulting to [FsrsRating.good] on unknown
  /// (calibration reads `correct`, not `grade`, so the exact rating never
  /// affects the fit — but the field is reconstructed faithfully).
  static FsrsRating fsrsRatingFromValue(int? value) =>
      FsrsRating.values.firstWhere((FsrsRating r) => r.value == value,
          orElse: () => FsrsRating.good);
}
