import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'study_stats.dart';

/// Persistence seam for the device-local cumulative [StudyStats] (D2).
/// Synchronous [load] keeps controller construction test-friendly; the real
/// `PrefsStudyStatsStore` reads the platform store once at boot (mirrors
/// `SettingsStore` / `XpHistoryStore`).
abstract class StudyStatsStore {
  StudyStats load();
  Future<void> save(StudyStats stats);
}

/// Default — in-memory (tests + keyless boots, R-O1). A `PrefsStudyStatsStore`
/// override in `main` gives real on-device persistence.
class InMemoryStudyStatsStore implements StudyStatsStore {
  InMemoryStudyStatsStore([StudyStats initial = const StudyStats()])
      : _stats = initial;

  StudyStats _stats;

  /// The most recently saved value (handy for tests).
  StudyStats get current => _stats;

  @override
  StudyStats load() => _stats;

  @override
  Future<void> save(StudyStats stats) async {
    _stats = stats;
  }
}

/// The study-stats persistence seam. Defaults to in-memory; `main` overrides it
/// with a `PrefsStudyStatsStore` for real on-device persistence.
final studyStatsStoreProvider =
    Provider<StudyStatsStore>((ref) => InMemoryStudyStatsStore());
