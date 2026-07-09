import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/services/learning/learner_state.dart' show ReviewLogEntry;

/// Portability seam (R-M3/R-G6): the durable APPEND-ONLY answer-spine sink.
/// [LearnerController.recordReview] fires every graded answer through this —
/// the default is an honest no-op (guest / keyless boots keep today's
/// in-memory-only behaviour, byte-identical), and Stage 3 plugs the Supabase
/// `review_log` table behind the SAME interface. Append is fire-and-forget by
/// contract: a sink NEVER throws into and NEVER blocks the grading path.
abstract interface class ReviewLogSink {
  void append(String targetLocale, ReviewLogEntry entry);
}

/// Default (local / Stage 1–2): drop the entry — the in-memory log inside
/// [LearnerController] remains the session's source of truth (R-O1 stub).
class NoopReviewLogSink implements ReviewLogSink {
  const NoopReviewLogSink();

  @override
  void append(String targetLocale, ReviewLogEntry entry) {}
}

/// The answer-spine sink seam. Defaults to the no-op; `main` overrides it with
/// the Supabase-backed sink when the backend is configured.
final reviewLogSinkProvider =
    Provider<ReviewLogSink>((ref) => const NoopReviewLogSink());
