import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/services/progress/study_stats.dart';
import 'package:ratel/services/progress/study_stats_store.dart';

export 'package:ratel/services/progress/study_stats.dart' show StudyStats;

/// Bridges the cumulative [StudyStats] to the UI + the device-local store seam
/// (D2 · R-G6 / R-L14). Loads at build, folds each finished lesson's graded
/// tally + session duration in, and writes through. Device-local for everyone
/// (mirrors the D1 XP-history recorder). Holds only REAL recorded values.
class StudyStatsController extends Notifier<StudyStats> {
  @override
  StudyStats build() => ref.read(studyStatsStoreProvider).load();

  /// Fold a finished lesson's graded tally + session duration in, then persist.
  /// A no-op when there is nothing real to record.
  void recordLesson({
    required int correct,
    required int total,
    required Duration session,
  }) {
    final StudyStats next = state.recordLesson(
        correct: correct, total: total, seconds: session.inSeconds);
    if (next == state) return;
    state = next;
    // Best-effort device-local write; never blocks the lesson flow.
    ref.read(studyStatsStoreProvider).save(next);
  }
}

final studyStatsControllerProvider =
    NotifierProvider<StudyStatsController, StudyStats>(
        StudyStatsController.new);
