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
import 'package:ratel/services/quests/quest_claims_store.dart';

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
  QuestClaimsStore? claims,
}) =>
    ProviderContainer(overrides: <Override>[
      clockProvider.overrideWithValue(clock),
      settingsStoreProvider
          .overrideWithValue(InMemorySettingsStore(AppSettings(dailyGoal: goal))),
      if (identity != null) identityProvider.overrideWithValue(identity),
      if (store != null) learnerStateStoreProvider.overrideWithValue(store),
      if (claims != null)
        questClaimsStoreProvider.overrideWithValue(claims),
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
      // INC-QR1: +1 lesson + 3 streak_keeper quest (any XP completes it); the
      // daily goal (30) is NOT met so no +5 goal bonus.
      expect(c.read(learnerControllerProvider).diamonds, 4);
      expect(c.read(learnerControllerProvider).streakDays, 0); // goal not met
    });

    test('meeting the daily goal credits the lesson diamond + the bonus', () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 20);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      // INC-QR1: 1 lesson + 5 goal + 3 streak_keeper quest = 9.
      expect(c.read(learnerControllerProvider).diamonds, 9);
      expect(c.read(learnerControllerProvider).streakDays, 1);
    });

    test('the goal-met bonus is awarded once per day (lesson diamond still adds)',
        () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 20);
      addTearDown(c.dispose);
      final LearnerController n = c.read(learnerControllerProvider.notifier);
      n.recordLessonComplete(xp: 20); // 1 lesson + 5 goal + 3 streak_keeper = 9
      // Second lesson today (xpToday 20→40): the goal bonus and streak_keeper
      // are already claimed today, but power_session (2×goal = 40) NOW crosses
      // done → +1 lesson +3 power_session quest = 13 (INC-QR1). This proves the
      // per-quest claimed-set: only the newly-completed quest pays.
      n.recordLessonComplete(xp: 20);
      expect(c.read(learnerControllerProvider).diamonds, 13);
      expect(c.read(learnerControllerProvider).streakDays, 1);
    });

    test('consecutive days each award the goal-met bonus', () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 20);
      addTearDown(c.dispose);
      final LearnerController n = c.read(learnerControllerProvider.notifier);
      n.recordLessonComplete(xp: 20); // day 1 → 1 + 5 + 3 = 9
      expect(c.read(learnerControllerProvider).diamonds, 9);
      clock = DateTime(2026, 6, 30, 9);
      // Day 2: the day-roll resets the goal-met date, xpToday AND the quest
      // claimed-set → +1 lesson +5 goal +3 streak_keeper again = 18 (INC-QR1).
      n.recordLessonComplete(xp: 20);
      expect(c.read(learnerControllerProvider).diamonds, 18);
    });

    test('a guest (no session) still earns diamonds in memory (flag-off path)',
        () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 20);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      // INC-QR1: 1 lesson + 5 goal + 3 streak_keeper quest = 9 (in memory).
      expect(c.read(learnerControllerProvider).diamonds, 9);
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
      // INC-15: diamonds are a GLOBAL field → the __global__ row.
      final Map<Object?, Object?> row = (store.saves.last['courses']!
              as List<Object?>)
          .firstWhere((Object? r) => (r as Map)['target_locale'] == '__global__')
              as Map<Object?, Object?>;
      expect(row['diamonds'], 9); // INC-QR1: 1 lesson + 5 goal + 3 quest
    });

    test('diamonds rehydrate from the user_course row on relaunch', () async {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final _RecordingStore seeded = _RecordingStore(<String, Object?>{
        'courses': <Object?>[
          <String, Object?>{
            'target_locale': 'en',
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

  // INC-QR1: crediting REAL 💎 the first time a daily quest is genuinely
  // completed during a session. Conservative, session-local idempotency (no
  // durable column): a quest pays at most once per day, only on an in-session
  // incomplete→done transition; boot-done quests are pre-seeded WITHOUT paying;
  // the claimed-set resets on a new day. streak_keeper completes on ANY XP, so
  // one lesson is enough to cross it. A high daily goal keeps the goal-met +5
  // and the stretch quests out of the way so the quest 💎 are isolated.
  group('LearnerController quest rewards (INC-QR1)', () {
    test('a quest genuinely completed in-session credits exactly 3💎 once', () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 100);
      addTearDown(c.dispose);
      expect(c.read(learnerControllerProvider).diamonds, 0);
      // streak_keeper (any XP) crosses done → +3 quest; +1 lesson; goal (100)
      // not met so no +5, and power/on-fire (200/300) stay open.
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      expect(c.read(learnerControllerProvider).diamonds, 4); // 1 lesson + 3 quest
      expect(c.read(learnerControllerProvider).streakDays, 0); // goal not met
    });

    test('a second completion the same day credits 0 quest 💎 (idempotent)', () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 100);
      addTearDown(c.dispose);
      final LearnerController n = c.read(learnerControllerProvider.notifier);
      n.recordLessonComplete(xp: 20); // 1 lesson + 3 quest = 4
      expect(c.read(learnerControllerProvider).diamonds, 4);
      // streak_keeper is already claimed today; the others are still open, so a
      // re-trigger pays the lesson diamond ONLY — no second quest credit.
      n.recordLessonComplete(xp: 20); // +1 lesson only → 5
      expect(c.read(learnerControllerProvider).diamonds, 5);
    });

    test('a quest already done at session start does not pay (conservative '
        'pre-seed — no restart double-credit)', () async {
      // A learner with real prior progress relaunches. xpToday has NO durable
      // column, so it rehydrates at 0 → the quest board is honestly re-opened,
      // and the pre-seed set starts empty. Crucially, merely opening the app
      // credits NO quest 💎 (the balance is exactly the restored value); a
      // quest only pays when genuinely re-earned this session.
      DateTime clock = DateTime(2026, 6, 29, 9);
      final _RecordingStore seeded = _RecordingStore(<String, Object?>{
        'courses': <Object?>[
          <String, Object?>{
            'target_locale': 'en',
            'xp_total': 500,
            'lessons_completed': 20,
            'streak_days': 4,
            'streak_last_active': '2026-06-29',
            'diamonds': 42,
            'theta_per_skill': <String, Object?>{'__global__': 0.0},
          },
        ],
        'items': <Object?>[],
      });
      final ProviderContainer c = _container(() => clock,
          goal: 100, identity: FakeIdentity(), store: seeded);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider); // trigger hydrate
      await _settle();
      // Opening the app pays nothing — no quest 💎 for already-done history.
      expect(c.read(learnerControllerProvider).diamonds, 42);
      expect(c.read(learnerControllerProvider).xpToday, 0); // reset on relaunch
      // A genuine new in-session completion then pays the 3💎 (+1 lesson).
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      await _settle();
      expect(c.read(learnerControllerProvider).diamonds, 46); // 42 + 1 + 3
    });

    test('the day-roll resets the claimed-set so a new day pays again', () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c = _container(() => clock, goal: 100);
      addTearDown(c.dispose);
      final LearnerController n = c.read(learnerControllerProvider.notifier);
      n.recordLessonComplete(xp: 20); // day 1: +1 lesson +3 quest = 4
      expect(c.read(learnerControllerProvider).diamonds, 4);
      n.recordLessonComplete(xp: 20); // day 1 again: +1 lesson only = 5
      expect(c.read(learnerControllerProvider).diamonds, 5);
      // New day → _rollDay clears the claimed-set AND resets xpToday, so
      // streak_keeper re-opens and its 3💎 can be earned once more.
      clock = DateTime(2026, 6, 30, 9);
      n.recordLessonComplete(xp: 20); // day 2: +1 lesson +3 quest = 9
      expect(c.read(learnerControllerProvider).diamonds, 9);
    });
  });

  // INC-QR1 (durable): the claimed-set is now DEVICE-LOCAL DURABLE via
  // `questClaimsStoreProvider`, so a quest paid today does NOT re-pay after a
  // RELAUNCH even once xpToday resets to 0 (non-durable) and the quest
  // re-completes. Simulated relaunch = a NEW controller/container sharing the
  // SAME InMemoryQuestClaimsStore, with xpToday reset (a fresh container starts
  // its in-memory xpToday at 0, exactly as a real boot does).
  group('LearnerController quest rewards durable idempotency (INC-QR1)', () {
    test('a quest paid today does NOT re-pay after a relaunch (xpToday reset)',
        () {
      DateTime clock = DateTime(2026, 6, 29, 9);
      // ONE durable claims store shared across both "launches".
      final InMemoryQuestClaimsStore claims = InMemoryQuestClaimsStore();

      // Launch #1: complete a lesson → streak_keeper crosses done → +3 quest.
      final ProviderContainer c1 =
          _container(() => clock, goal: 100, claims: claims);
      addTearDown(c1.dispose);
      c1.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      expect(c1.read(learnerControllerProvider).diamonds, 4); // 1 lesson + 3
      // The paid quest id is now DURABLE for today.
      expect(claims.current.day, DateTime(2026, 6, 29));
      expect(claims.current.ids, contains('streak_keeper'));
      c1.dispose();

      // Launch #2 (relaunch): SAME day, SAME durable store, but xpToday is 0
      // again (fresh container). Re-earning re-completes streak_keeper — yet it
      // is already in the persisted claims for today, so it pays 0 quest 💎.
      final ProviderContainer c2 =
          _container(() => clock, goal: 100, claims: claims);
      addTearDown(c2.dispose);
      expect(c2.read(learnerControllerProvider).xpToday, 0); // reset on relaunch
      c2.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      // +1 lesson only — NO second 3💎 for streak_keeper (durable idempotency).
      expect(c2.read(learnerControllerProvider).diamonds, 1);
    });

    test('a NEW day in the durable store CAN pay again (stale day ignored)', () {
      // The store already holds YESTERDAY's paid claims; today re-opens the
      // quest, so a genuine completion today pays the 3💎 once more.
      final InMemoryQuestClaimsStore claims = InMemoryQuestClaimsStore(
        QuestClaims(
          day: DateTime(2026, 6, 28),
          ids: const <String>{'streak_keeper'},
        ),
      );
      DateTime clock = DateTime(2026, 6, 29, 9); // a NEW day vs the stored one
      final ProviderContainer c =
          _container(() => clock, goal: 100, claims: claims);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
      // Stale day ⇒ empty seed ⇒ streak_keeper pays: +1 lesson + 3 quest = 4.
      expect(c.read(learnerControllerProvider).diamonds, 4);
      // And the store now carries TODAY's paid id.
      expect(claims.current.day, DateTime(2026, 6, 29));
      expect(claims.current.ids, contains('streak_keeper'));
    });

    test('a live in-session day-roll clears AND re-persists the durable set',
        () {
      final InMemoryQuestClaimsStore claims = InMemoryQuestClaimsStore();
      DateTime clock = DateTime(2026, 6, 29, 9);
      final ProviderContainer c =
          _container(() => clock, goal: 100, claims: claims);
      addTearDown(c.dispose);
      final LearnerController n = c.read(learnerControllerProvider.notifier);
      n.recordLessonComplete(xp: 20); // day 1: +1 lesson +3 quest = 4
      expect(c.read(learnerControllerProvider).diamonds, 4);
      expect(claims.current.ids, contains('streak_keeper'));

      // Cross local midnight in a LIVE session → _rollDay clears the set and
      // persists the empty new-day state, then the fresh completion re-pays.
      clock = DateTime(2026, 6, 30, 9);
      n.recordLessonComplete(xp: 20); // day 2: +1 lesson +3 quest = 8
      expect(c.read(learnerControllerProvider).diamonds, 8);
      // The durable store now reflects day 2 (yesterday's ids are gone; today's
      // paid id is present).
      expect(claims.current.day, DateTime(2026, 6, 30));
      expect(claims.current.ids, contains('streak_keeper'));
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
