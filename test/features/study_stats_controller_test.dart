import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/services/learning/learning.dart'
    show FsrsRating, ReviewLogEntry;
import 'package:ratel/services/progress/study_stats_store.dart';

/// D2 evidence — the study-stats controller (accuracy + study time) and the
/// live FSRS retention over reviewed items (R-G5 / R-G6 / R-L14). Honest only.
void main() {
  ReviewLogEntry entry(String id, bool correct) => ReviewLogEntry(
        itemId: id,
        skill: 'vocab',
        grade: correct ? FsrsRating.good : FsrsRating.again,
        correct: correct,
        elapsedMs: 0,
        thetaBefore: 0,
        irtBAtReview: 0,
        source: 'lesson',
      );

  test('recordLesson accumulates accuracy + study time and persists', () {
    final InMemoryStudyStatsStore store = InMemoryStudyStatsStore();
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      studyStatsStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(c.dispose);
    c.read(studyStatsControllerProvider.notifier).recordLesson(
        correct: 8, total: 10, session: const Duration(minutes: 2));
    final StudyStats s = c.read(studyStatsControllerProvider);
    expect(s.correct, 8);
    expect(s.total, 10);
    expect(s.studySeconds, 120);
    expect(s.accuracy, closeTo(0.8, 1e-9));
    expect(store.current.total, 10); // written through
  });

  test('rehydrates persisted stats at build', () {
    final InMemoryStudyStatsStore store = InMemoryStudyStatsStore(
        const StudyStats(correct: 5, total: 5, studySeconds: 300));
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      studyStatsStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(c.dispose);
    expect(c.read(studyStatsControllerProvider).accuracy, 1.0);
  });

  test('retention is null with no reviews, real once items are reviewed', () {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(retentionEstimateProvider), isNull);
    expect(c.read(reviewedItemCountProvider), 0);

    final LearnerController n = c.read(learnerControllerProvider.notifier);
    n.recordReview(entry('w1', true));
    n.recordReview(entry('w2', true));
    n.recordReview(entry('w3', false));

    expect(c.read(reviewedItemCountProvider), 3);
    final double? r = c.read(retentionEstimateProvider);
    expect(r, isNotNull);
    expect(r, greaterThan(0.0));
    expect(r, lessThanOrEqualTo(1.0));
  });

  test('retention dedups by item (re-reviewing the same item is one item)', () {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    final LearnerController n = c.read(learnerControllerProvider.notifier);
    n.recordReview(entry('w1', true));
    n.recordReview(entry('w1', true));
    expect(c.read(reviewedItemCountProvider), 1);
  });
}
