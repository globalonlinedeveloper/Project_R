import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/components/ratel_top_bar.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/economy/economy.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

import 'auth/fake_identity.dart';

/// Tests for the diamonds soft-currency earn side (R-I4): the pure
/// [DiamondsModel] arithmetic and the [LearnerController]'s goal-gated accrual +
/// durable round-trip.

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
  group('DiamondsModel (pure)', () {
    const DiamondsModel m = DiamondsModel();

    test('per-event reward amounts', () {
      expect(m.reward(DiamondEvent.lessonCompleted), 1);
      expect(m.reward(DiamondEvent.dailyGoalMet), 5);
    });
    test('award credits a fresh wallet', () {
      expect(m.award(balance: 0, event: DiamondEvent.lessonCompleted), 1);
      expect(m.award(balance: 0, event: DiamondEvent.dailyGoalMet), 5);
    });
    test('award accumulates onto an existing balance', () {
      expect(m.award(balance: 5, event: DiamondEvent.dailyGoalMet), 10);
      expect(m.award(balance: 12, event: DiamondEvent.lessonCompleted), 13);
    });
    test('a negative balance is treated as empty (never below zero)', () {
      expect(m.award(balance: -3, event: DiamondEvent.lessonCompleted), 1);
    });
  });

  group('LearnerController diamonds (goal-gated earn)', () {
    test('a completed lesson below the goal credits only the lesson diamond',
        () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 30);
      addTearDown(c.dispose);
      expect(c.read(learnerControllerProvider).diamonds, 0);
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      expect(c.read(learnerControllerProvider).diamonds, 1);
      expect(c.read(learnerControllerProvider).streakDays, 0); // goal not met
    });

    test('meeting the daily goal credits the lesson diamond + the bonus', () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 20);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      expect(c.read(learnerControllerProvider).diamonds, 6); // 1 lesson + 5 goal
      expect(c.read(learnerControllerProvider).streakDays, 1);
    });

    test('the goal-met bonus is awarded once per day (lesson diamond still adds)',
        () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 20);
      addTearDown(c.dispose);
      final LearnerController n = c.read(learnerControllerProvider.notifier);
      n.recordLessonComplete(xp: 20); // 1 + 5 = 6
      n.recordLessonComplete(xp: 20); // +1 lesson only (no second bonus) = 7
      expect(c.read(learnerControllerProvider).diamonds, 7);
      expect(c.read(learnerControllerProvider).streakDays, 1);
    });

    test('consecutive days each award the goal-met bonus', () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 20);
      addTearDown(c.dispose);
      final LearnerController n = c.read(learnerControllerProvider.notifier);
      n.recordLessonComplete(xp: 20); // day 1 → 6
      expect(c.read(learnerControllerProvider).diamonds, 6);
      clock = DateTime(2026, 6, 30, 9);
      n.recordLessonComplete(xp: 20); // day 2 → +1 +5 = 12
      expect(c.read(learnerControllerProvider).diamonds, 12);
    });

    test('a guest (no session) still earns diamonds in memory (flag-off path)',
        () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 20);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      expect(c.read(learnerControllerProvider).diamonds, 6);
    });
  });

  group('LearnerController diamonds (durable)', () {
    test('diamonds are written through to the user_course row', () async {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final _RecordingStore store = _RecordingStore();
      final ProviderContainer c = _container(() => clock,
          goal: 20, identity: FakeIdentity(), store: store);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      await _settle();
      final Map<Object?, Object?> row =
          (store.saves.last['courses']! as List<Object?>).single
              as Map<Object?, Object?>;
      expect(row['diamonds'], 6);
    });

    test('diamonds rehydrate from the user_course row on relaunch', () async {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final _RecordingStore seeded = _RecordingStore(<String, Object?>{
        'courses': <Object?>[
          <String, Object?>{
            'target_locale': 'es',
            'xp_total': 100,
            'lessons_completed': 5,
            'streak_days': 3,
            'streak_last_active': '2026-06-29',
            'diamonds': 42,
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
      expect(c.read(learnerControllerProvider).diamonds, 42);
      expect(c.read(learnerControllerProvider).xpTotal, 100);
    });
  });

  group('RatelTopBar diamonds display', () {
    testWidgets('renders the 💎 chip when a diamonds value is supplied',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: RatelTopBar(
              flagEmoji: '🇪🇸', langCode: 'ES', streak: 3, diamonds: '6'),
        ),
      ));
      expect(find.text('💎'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
    });
  });
}
