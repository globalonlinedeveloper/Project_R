import 'dart:async' show unawaited;

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ratel/services/learning/learner_state.dart' show ReviewLogEntry;
import 'package:ratel/services/learning/review_log_sink.dart';

/// Stage-3 [ReviewLogSink] backed by the append-only `review_log` table
/// (R-G6). Every graded answer becomes one immutable own-row INSERT (RLS:
/// select+insert only — no client can ever rewrite history). Fire-and-forget:
/// the insert is unawaited and every failure is swallowed, so grading never
/// blocks on the network and offline play just skips the durable copy (the
/// in-memory log still drives θ/FSRS exactly as before).
class SupabaseReviewLogSink implements ReviewLogSink {
  SupabaseReviewLogSink(this._db);

  /// Wire to the live Supabase client (its `auth.uid()` owns every row).
  factory SupabaseReviewLogSink.fromClient(SupabaseClient client) =>
      SupabaseReviewLogSink(client);

  final SupabaseClient? _db;

  /// Append-only answer-spine table.
  static const String table = 'review_log';

  @override
  void append(String targetLocale, ReviewLogEntry entry) {
    final SupabaseClient? db = _db;
    final String? uid = db?.auth.currentUser?.id;
    if (db == null || uid == null) return; // guest: honest no-op
    unawaited(
      db
          .from(table)
          .insert(rowFor(entry, targetLocale, uid))
          .then((_) {}, onError: (_) {/* offline-tolerant */}),
    );
  }

  /// Pure: a [ReviewLogEntry] as its own-row `review_log` row (spine values
  /// frozen at answer time; `grade` = the FSRS 1..4 integer; `taken_at` is the
  /// DB default `now()`).
  static Map<String, Object?> rowFor(
          ReviewLogEntry e, String targetLocale, String userId) =>
      <String, Object?>{
        'user_id': userId,
        'target_locale': targetLocale,
        'item_id': e.itemId,
        'skill': e.skill,
        'grade': e.grade.value,
        'correct': e.correct,
        'elapsed_ms': e.elapsedMs,
        'theta_before': e.thetaBefore,
        'irt_b_at_review': e.irtBAtReview,
        'source': e.source,
        'feeds_theta': e.feedsTheta,
      };
}
