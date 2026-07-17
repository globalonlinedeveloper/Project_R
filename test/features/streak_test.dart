import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/learning/streak.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

import 'auth/fake_identity.dart';

/// Records every write-through so a test can assert the persisted payload.
class _RecordingStore implements LearnerStateStore {
  _RecordingStore([this.seed = const <String, Object?>{}]);
  final Map<String, Object?> seed;
  final List<Map<String, Object?>> saves = <Map<String, Object?>>[];
  @override
  Future<Map<String, Object?>> load(String userId) async => seed;
  @override
  Future<void> save(String userId, Map<String, Object?> state) async =>
      saves.add(state);
}

ProviderContainer _container(
  DateTime Function() clock, {
  int goal = 20,
  Identity? identity,
  LearnerStateStore? store,
}) =>
    ProviderContainer(overrides: <Override>[
      clockProvider.overrideWithValue(clock),
      settingsStoreProvider
          .overrideWithValue(InMemorySettingsStore(AppSettings(dailyGoal: goal))),
      if (identity != null) identityProvider.overrideWithValue(identity),
      if (store != null) learnerStateStoreProvider.overrideWithValue(store),
      persistDebounceProvider.overrideWithValue(Duration.zero),
    ]);

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  group('StreakModel.afterGoalMet (pure)', () {
    const StreakModel m = StreakModel();
    final DateTime today = DateTime(2026, 6, 29);

    test('first ever goal-met starts the run at 1', () {
      expect(m.afterGoalMet(streak: 0, lastMet: null, today: today), 1);
    });
    test('a consecutive day extends the run', () {
      expect(
          m.afterGoalMet(
              streak: 4, lastMet: DateTime(2026, 6, 28), today: today),
          5);
    });
    test('the same day is idempotent (no double count)', () {
      expect(
          m.afterGoalMet(
              streak: 5, lastMet: DateTime(2026, 6, 29, 8), today: today),
          5);
    });
    test('a missed day restarts the run at 1', () {
      expect(
          m.afterGoalMet(
              streak: 9, lastMet: DateTime(2026, 6, 26), today: today),
          1);
    });
  });

  group('StreakModel.current (honest display)', () {
    const StreakModel m = StreakModel();
    final DateTime today = DateTime(2026, 6, 29);

    test('met today → alive', () {
      expect(
          m.current(streak: 3, lastMet: DateTime(2026, 6, 29, 8), today: today),
          3);
    });
    test('met yesterday → still alive', () {
      expect(m.current(streak: 3, lastMet: DateTime(2026, 6, 28), today: today),
          3);
    });
    test('a full missed day → lapsed to 0', () {
      expect(m.current(streak: 3, lastMet: DateTime(2026, 6, 27), today: today),
          0);
    });
    test('legacy row (no last-met date) shows the stored value as-is', () {
      expect(m.current(streak: 7, lastMet: null, today: today), 7);
    });
  });

  group('LearnerController goal-gated streak', () {
    test('meeting the daily goal advances the streak', () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 20);
      addTearDown(c.dispose);
      expect(c.read(learnerControllerProvider).streakDays, 0);
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      expect(c.read(learnerControllerProvider).streakDays, 1);
    });

    test('not reaching the goal does NOT advance the streak', () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 30);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      expect(c.read(learnerControllerProvider).streakDays, 0);
      expect(c.read(learnerControllerProvider).xpToday, 20);
    });

    test('advancing is idempotent within the same day', () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 20);
      addTearDown(c.dispose);
      final LearnerController n =
          c.read(learnerControllerProvider.notifier);
      n.recordLessonComplete(xp: 20); // reaches the goal → 1
      n.recordLessonComplete(xp: 20); // more XP same day → still 1
      expect(c.read(learnerControllerProvider).streakDays, 1);
      expect(c.read(learnerControllerProvider).xpToday, 40);
    });

    test('consecutive days extend the streak', () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 20);
      addTearDown(c.dispose);
      final LearnerController n = c.read(learnerControllerProvider.notifier);
      n.recordLessonComplete(xp: 20); // day 1 → 1
      expect(c.read(learnerControllerProvider).streakDays, 1);
      clock = DateTime(2026, 6, 30, 9);
      n.recordLessonComplete(xp: 20); // day 2 → 2
      expect(c.read(learnerControllerProvider).streakDays, 2);
    });

    test('a missed day restarts the streak at 1 on the next goal-met', () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 20);
      addTearDown(c.dispose);
      final LearnerController n = c.read(learnerControllerProvider.notifier);
      n.recordLessonComplete(xp: 20); // day 1 → 1
      expect(c.read(learnerControllerProvider).streakDays, 1);
      clock = DateTime(2026, 7, 1, 9); // skip June 30 (a missed day)
      n.recordLessonComplete(xp: 20); // day 3 → the run restarts at 1
      expect(c.read(learnerControllerProvider).streakDays, 1);
    });

    test('a lapsed run surfaces 0 on relaunch (rehydrate after a missed day)',
        () async {
      DateTime clock = DateTime(2026, 6, 30, 9);
      final _RecordingStore seeded = _RecordingStore(<String, Object?>{
        'courses': <Object?>[
          <String, Object?>{
            'target_locale': 'en',
            'xp_total': 100,
            'lessons_completed': 5,
            'streak_days': 5,
            'streak_last_active': '2026-06-27',
            'theta_per_skill': <String, Object?>{'__global__': 0.0},
          },
        ],
        'items': <Object?>[],
      });
      final ProviderContainer c = _container(() => clock,
          goal: 20, identity: FakeIdentity(), store: seeded);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider); // trigger hydrate
      await _settle();
      // Hydration ran (xpTotal proves it), but the goal was last met June 27, so
      // by June 30 the run has lapsed: the honest surfaced streak is 0, not the
      // stale stored 5.
      expect(c.read(learnerControllerProvider).xpTotal, 100);
      expect(c.read(learnerControllerProvider).streakDays, 0);
    });

    test('xpToday rolls over the day boundary; lifetime XP accumulates', () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 20);
      addTearDown(c.dispose);
      final LearnerController n = c.read(learnerControllerProvider.notifier);
      n.recordLessonComplete(xp: 20); // day 1
      expect(c.read(learnerControllerProvider).xpToday, 20);
      clock = DateTime(2026, 6, 30, 9); // next day
      n.recordLessonComplete(xp: 20); // day 2 — xpToday resets first, then +20
      expect(c.read(learnerControllerProvider).xpToday, 20); // only today's XP
      expect(c.read(learnerControllerProvider).xpTotal, 40); // lifetime total
    });

    test('refreshDay re-derives day-scoped surfaces without new activity', () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 20);
      addTearDown(c.dispose);
      final LearnerController n = c.read(learnerControllerProvider.notifier);
      n.recordLessonComplete(xp: 20); // day 1 → streak 1, xpToday 20
      expect(c.read(learnerControllerProvider).streakDays, 1);
      clock = DateTime(2026, 7, 1, 9); // a day was missed while away
      n.refreshDay(); // the app-resume hook — no new XP earned
      final LearnerSnapshot snap = c.read(learnerControllerProvider);
      expect(snap.streakDays, 0); // lapse surfaced without a mutation
      expect(snap.xpToday, 0); // reset at the boundary
      expect(snap.xpTotal, 20); // lifetime XP intact
    });

    test('persists streak_last_active and continues the run after rehydrate',
        () async {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final _RecordingStore store = _RecordingStore();
      final ProviderContainer c1 = _container(() => clock,
          goal: 20, identity: FakeIdentity(), store: store);
      c1.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      await _settle();
      // INC-15: streak is a GLOBAL field → it lands on the __global__ row, not
      // the per-course row.
      final List<Object?> savedCourses =
          store.saves.last['courses']! as List<Object?>;
      final Map<Object?, Object?> row = savedCourses.firstWhere((Object? r) =>
          (r as Map)['target_locale'] == '__global__') as Map<Object?, Object?>;
      expect(row['streak_days'], 1);
      expect(row['streak_last_active'], '2026-06-29');
      c1.dispose();

      // A fresh controller next day rehydrates the global streak from that
      // __global__ row; the run is still alive (met yesterday) and meeting the
      // goal again continues it to 2.
      clock = DateTime(2026, 6, 30, 9);
      final _RecordingStore seeded = _RecordingStore(<String, Object?>{
        'courses': <Object?>[row],
        'items': <Object?>[],
      });
      final ProviderContainer c2 = _container(() => clock,
          goal: 20, identity: FakeIdentity(), store: seeded);
      addTearDown(c2.dispose);
      c2.read(learnerControllerProvider); // trigger hydrate
      await _settle();
      expect(c2.read(learnerControllerProvider).streakDays, 1);
      c2.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      expect(c2.read(learnerControllerProvider).streakDays, 2);
    });
  });
}
