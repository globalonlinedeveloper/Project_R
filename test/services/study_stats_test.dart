import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/progress/prefs_study_stats_store.dart';
import 'package:ratel/services/progress/study_stats.dart';
import 'package:ratel/services/progress/study_stats_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// D2 evidence — cumulative device-local accuracy + study time (R-G6 / R-L14):
/// real recorded values only; empty reads as "no data" (accuracy null).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StudyStats', () {
    test('empty stats report null accuracy (honest no-data)', () {
      const StudyStats s = StudyStats();
      expect(s.accuracy, isNull);
      expect(s.total, 0);
      expect(s.studySeconds, 0);
    });

    test('recordLesson accumulates and clamps correct<=total', () {
      StudyStats s = const StudyStats();
      s = s.recordLesson(correct: 8, total: 10, seconds: 120);
      s = s.recordLesson(correct: 9, total: 10, seconds: 90);
      expect(s.correct, 17);
      expect(s.total, 20);
      expect(s.studySeconds, 210);
      expect(s.accuracy, closeTo(0.85, 1e-9));
      // correct over total is capped so accuracy never exceeds 100%.
      final StudyStats capped =
          const StudyStats().recordLesson(correct: 99, total: 5, seconds: 0);
      expect(capped.correct, 5);
      expect(capped.total, 5);
    });

    test('a no-op lesson (nothing graded, no time) returns the same value', () {
      const StudyStats s = StudyStats(correct: 1, total: 2, studySeconds: 30);
      expect(s.recordLesson(correct: 0, total: 0, seconds: 0), s);
    });

    test('toMap / fromMap round-trip', () {
      const StudyStats s = StudyStats(correct: 3, total: 4, studySeconds: 55);
      expect(StudyStats.fromMap(s.toMap()), s);
    });
  });

  group('InMemoryStudyStatsStore', () {
    test('save then load round-trips', () async {
      final InMemoryStudyStatsStore store = InMemoryStudyStatsStore();
      await store.save(const StudyStats(correct: 2, total: 3, studySeconds: 40));
      expect(store.load(), const StudyStats(correct: 2, total: 3, studySeconds: 40));
    });
  });

  group('PrefsStudyStatsStore', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('save then load survives a relaunch (fresh store, same prefs)', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await PrefsStudyStatsStore(prefs)
          .save(const StudyStats(correct: 12, total: 15, studySeconds: 600));
      expect(PrefsStudyStatsStore(prefs).load(),
          const StudyStats(correct: 12, total: 15, studySeconds: 600));
    });

    test('absent keys read as zero (honest no-data)', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(PrefsStudyStatsStore(prefs).load(), const StudyStats());
    });
  });
}
