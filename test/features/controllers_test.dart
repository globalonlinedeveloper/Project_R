import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/content/models/enums.dart';
import 'package:ratel/services/learning/learning.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

void main() {
  test('LearnerController cold-starts at A1 with zero counters (honest §6)', () {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    final LearnerSnapshot snap = c.read(learnerControllerProvider);
    expect(snap.level, CefrLevel.a1);
    expect(snap.lessonsCompleted, 0);
    expect(snap.xpTotal, 0);
    expect(snap.streakDays, 0);
  });

  test('recordLessonComplete bumps lessons + XP', () {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
    final LearnerSnapshot snap = c.read(learnerControllerProvider);
    expect(snap.lessonsCompleted, 1);
    expect(snap.xpTotal, 20);
    expect(snap.xpToday, 20);
  });

  test('recordReview folds a correct answer up through the ability engine', () {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    final double before = c.read(learnerControllerProvider).theta;
    c.read(learnerControllerProvider.notifier).recordReview(
          const ReviewLogEntry(
            itemId: 'i1',
            skill: 's1',
            grade: FsrsRating.good,
            correct: true,
            elapsedMs: 0,
            thetaBefore: -2.5,
            irtBAtReview: -2.5,
            source: 'lesson',
          ),
        );
    final double after = c.read(learnerControllerProvider).theta;
    expect(after, greaterThan(before));
  });

  test('SavedWordsController dedups normalized saves', () {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    final SavedWordsController ctrl =
        c.read(savedWordsControllerProvider.notifier);
    expect(ctrl.save('Hola'), SavedWordDisposition.admitted);
    expect(c.read(savedWordsControllerProvider).count, 1);
    expect(ctrl.save('  hola '), SavedWordDisposition.duplicate);
    expect(c.read(savedWordsControllerProvider).count, 1);
  });

  test('AppSettingsController writes back through the store', () async {
    final InMemorySettingsStore store =
        InMemorySettingsStore(const AppSettings(dailyGoal: 20));
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      settingsStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(c.dispose);
    expect(c.read(appSettingsControllerProvider).dailyGoal, 20);
    await c.read(appSettingsControllerProvider.notifier).setDailyGoal(30);
    expect(c.read(appSettingsControllerProvider).dailyGoal, 30);
    expect(store.current.dailyGoal, 30);
  });
}
