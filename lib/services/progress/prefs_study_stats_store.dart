import 'package:shared_preferences/shared_preferences.dart';

import 'study_stats.dart';
import 'study_stats_store.dart';

/// On-device persistence for the cumulative [StudyStats] via shared_preferences
/// (three int keys). Best-effort: a missing key reads as zero, never faked.
class PrefsStudyStatsStore implements StudyStatsStore {
  PrefsStudyStatsStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _kCorrect = 'ratel.progress.correct';
  static const String _kTotal = 'ratel.progress.total';
  static const String _kStudySeconds = 'ratel.progress.studySeconds';

  @override
  StudyStats load() => StudyStats(
        correct: _prefs.getInt(_kCorrect) ?? 0,
        total: _prefs.getInt(_kTotal) ?? 0,
        studySeconds: _prefs.getInt(_kStudySeconds) ?? 0,
      );

  @override
  Future<void> save(StudyStats s) async {
    await _prefs.setInt(_kCorrect, s.correct);
    await _prefs.setInt(_kTotal, s.total);
    await _prefs.setInt(_kStudySeconds, s.studySeconds);
  }
}
