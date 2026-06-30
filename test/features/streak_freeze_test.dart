import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/shop/shop_screen.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/economy/economy.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/learning/streak.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

import 'auth/fake_identity.dart';

/// Tests for the streak-freeze spend sink (R-I2 streak-freeze · R-I4 gems spend
/// side): the pure [StreakFreezeModel] purchase arithmetic, the [DiamondsModel]
/// debit primitive, the [StreakModel.applyFreezes] coverage math, and the
/// [LearnerController]'s buy + auto-consume + durable round-trip, plus the Shop
/// buy flow through the real UI.

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

Map<String, Object?> _seed(Map<String, Object?> course) => <String, Object?>{
      'courses': <Object?>[
        <String, Object?>{'target_locale': 'es', ...course},
      ],
    };

ProviderContainer _container(
  DateTime Function() clock, {
  int goal = 20,
  Identity? identity,
  LearnerStateStore? store,
}) =>
    ProviderContainer(overrides: <Override>[
      clockProvider.overrideWithValue(clock),
      settingsStoreProvider.overrideWithValue(
          InMemorySettingsStore(AppSettings(dailyGoal: goal))),
      if (identity != null) identityProvider.overrideWithValue(identity),
      if (store != null) learnerStateStoreProvider.overrideWithValue(store),
      persistDebounceProvider.overrideWithValue(Duration.zero),
    ]);

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  group('StreakFreezeModel (pure)', () {
    const StreakFreezeModel m = StreakFreezeModel();

    test('named cost + cap', () {
      expect(StreakFreezeModel.cost, 10);
      expect(StreakFreezeModel.maxHeld, 2);
    });
    test('canBuy needs room AND funds', () {
      expect(m.canBuy(diamonds: 10, held: 0), isTrue); // exactly the price
      expect(m.canBuy(diamonds: 9, held: 0), isFalse); // too poor
      expect(m.canBuy(diamonds: 99, held: 2), isFalse); // at cap
      expect(m.canBuy(diamonds: 99, held: 1), isTrue);
    });
    test('buy debits the price and adds one to inventory', () {
      expect(m.buy(diamonds: 10, held: 0), (diamonds: 0, held: 1));
      expect(m.buy(diamonds: 25, held: 1), (diamonds: 15, held: 2));
    });
    test('buy is a no-op at the cap or when unaffordable', () {
      expect(m.buy(diamonds: 99, held: 2), (diamonds: 99, held: 2));
      expect(m.buy(diamonds: 5, held: 0), (diamonds: 5, held: 0));
    });
  });

  group('DiamondsModel spend (pure)', () {
    const DiamondsModel m = DiamondsModel();
    test('canSpend boundaries', () {
      expect(m.canSpend(balance: 10, amount: 10), isTrue);
      expect(m.canSpend(balance: 9, amount: 10), isFalse);
      expect(m.canSpend(balance: 5, amount: 0), isTrue);
      expect(m.canSpend(balance: 5, amount: -1), isFalse);
    });
    test('spend debits, never below zero, no-op when unaffordable/negative', () {
      expect(m.spend(balance: 10, amount: 10), 0);
      expect(m.spend(balance: 30, amount: 10), 20);
      expect(m.spend(balance: 5, amount: 10), 5); // can't afford → unchanged
      expect(m.spend(balance: 5, amount: -3), 5); // negative → unchanged
    });
  });

  group('StreakModel.applyFreezes (pure)', () {
    const StreakModel m = StreakModel();
    final DateTime today = DateTime(2026, 6, 3);

    test('no last-met / no freezes / met today or yesterday → 0 consumed', () {
      expect(m.applyFreezes(lastMet: null, today: today, freezes: 2).freezesConsumed, 0);
      expect(
          m.applyFreezes(lastMet: DateTime(2026, 6, 1), today: today, freezes: 0).freezesConsumed,
          0);
      expect(m.applyFreezes(lastMet: today, today: today, freezes: 2).freezesConsumed, 0);
      expect(
          m.applyFreezes(lastMet: DateTime(2026, 6, 2), today: today, freezes: 2).freezesConsumed,
          0);
    });
    test('one missed day with a freeze → 1 consumed, last-met rolls to yesterday', () {
      final ({DateTime? lastMet, int freezesConsumed}) r =
          m.applyFreezes(lastMet: DateTime(2026, 6, 1), today: today, freezes: 2);
      expect(r.freezesConsumed, 1);
      expect(r.lastMet, DateTime(2026, 6, 2));
    });
    test('two missed days need two freezes', () {
      expect(
          m.applyFreezes(lastMet: DateTime(2026, 5, 31), today: today, freezes: 2).freezesConsumed,
          2);
    });
    test('too few freezes to cover the gap → nothing spent (lapses)', () {
      final ({DateTime? lastMet, int freezesConsumed}) r =
          m.applyFreezes(lastMet: DateTime(2026, 5, 31), today: today, freezes: 1);
      expect(r.freezesConsumed, 0);
      expect(r.lastMet, DateTime(2026, 5, 31)); // unchanged
    });
  });

  group('LearnerController buy (spend sink, durable)', () {
    test('buy debits 💎, adds a freeze, caps inventory, and persists', () async {
      final _RecordingStore store =
          _RecordingStore(_seed(<String, Object?>{'diamonds': 50, 'streak_freezes': 0}));
      final ProviderContainer c = _container(() => DateTime(2026, 6, 1),
          identity: FakeIdentity(), store: store);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider);
      await _settle(); // hydrate the seeded wallet

      final LearnerController learner = c.read(learnerControllerProvider.notifier);
      expect(c.read(learnerControllerProvider).diamonds, 50);
      expect(learner.canBuyStreakFreeze, isTrue);

      learner.buyStreakFreeze();
      expect(c.read(learnerControllerProvider).diamonds, 40);
      expect(c.read(learnerControllerProvider).streakFreezes, 1);

      learner.buyStreakFreeze(); // 30 / 2 → at cap
      expect(c.read(learnerControllerProvider).streakFreezes, 2);
      learner.buyStreakFreeze(); // no-op at the cap
      expect(c.read(learnerControllerProvider).streakFreezes, 2);
      expect(c.read(learnerControllerProvider).diamonds, 30);
      await _settle();

      final Map<Object?, Object?> row =
          (store.saves.last['courses']! as List<Object?>).first! as Map<Object?, Object?>;
      expect(row['streak_freezes'], 2);
      expect(row['diamonds'], 30);
    });

    test('buy is a no-op when the wallet cannot afford it', () async {
      final _RecordingStore store =
          _RecordingStore(_seed(<String, Object?>{'diamonds': 5, 'streak_freezes': 0}));
      final ProviderContainer c = _container(() => DateTime(2026, 6, 1),
          identity: FakeIdentity(), store: store);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider);
      await _settle();
      final LearnerController learner = c.read(learnerControllerProvider.notifier);
      expect(learner.canBuyStreakFreeze, isFalse);
      learner.buyStreakFreeze();
      expect(c.read(learnerControllerProvider).diamonds, 5);
      expect(c.read(learnerControllerProvider).streakFreezes, 0);
    });
  });

  group('LearnerController auto-consume on day-roll (durable)', () {
    test('a held freeze keeps a missed-day run alive and is spent + persisted',
        () async {
      DateTime now = DateTime(2026, 6, 1, 9);
      final _RecordingStore store = _RecordingStore(_seed(<String, Object?>{
        'streak_days': 5,
        'streak_last_active': '2026-06-01',
        'diamonds': 0,
        'streak_freezes': 2,
      }));
      final ProviderContainer c =
          _container(() => now, identity: FakeIdentity(), store: store);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider);
      await _settle(); // hydrate at D0 — no gap yet
      expect(c.read(learnerControllerProvider).streakDays, 5);
      expect(c.read(learnerControllerProvider).streakFreezes, 2);

      now = DateTime(2026, 6, 3, 9); // one whole day (June 2) missed
      c.read(learnerControllerProvider.notifier).refreshDay();
      expect(c.read(learnerControllerProvider).streakDays, 5); // survived
      expect(c.read(learnerControllerProvider).streakFreezes, 1); // one spent
      await _settle();
      final Map<Object?, Object?> row =
          (store.saves.last['courses']! as List<Object?>).first! as Map<Object?, Object?>;
      expect(row['streak_freezes'], 1);
    });

    test('with no freeze the missed-day run lapses honestly', () async {
      DateTime now = DateTime(2026, 6, 1, 9);
      final _RecordingStore store = _RecordingStore(_seed(<String, Object?>{
        'streak_days': 5,
        'streak_last_active': '2026-06-01',
        'streak_freezes': 0,
      }));
      final ProviderContainer c =
          _container(() => now, identity: FakeIdentity(), store: store);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider);
      await _settle();
      now = DateTime(2026, 6, 3, 9);
      c.read(learnerControllerProvider.notifier).refreshDay();
      expect(c.read(learnerControllerProvider).streakDays, 0); // lapsed
      expect(c.read(learnerControllerProvider).streakFreezes, 0);
    });
  });

  group('LearnerController persistence round-trip', () {
    test('streak_freezes rehydrates from the durable row', () async {
      final _RecordingStore store =
          _RecordingStore(_seed(<String, Object?>{'streak_freezes': 2, 'diamonds': 7}));
      final ProviderContainer c = _container(() => DateTime(2026, 6, 1),
          identity: FakeIdentity(), store: store);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider);
      await _settle();
      expect(c.read(learnerControllerProvider).streakFreezes, 2);
      expect(c.read(learnerControllerProvider).diamonds, 7);
    });
  });

  group('ShopScreen (real spend sink UI)', () {
    testWidgets('shows the live wallet and buys a freeze through the button',
        (WidgetTester tester) async {
      final _RecordingStore store =
          _RecordingStore(_seed(<String, Object?>{'diamonds': 50, 'streak_freezes': 0}));
      final ProviderContainer c = _container(() => DateTime(2026, 6, 1),
          identity: FakeIdentity(), store: store);
      addTearDown(c.dispose);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: ShopScreen()),
      ));
      await tester.pump(const Duration(milliseconds: 50)); // settle async hydrate

      expect(find.text('Owned 0/2'), findsOneWidget);
      expect(find.text('Buy for 10 💎'), findsOneWidget);
      expect(c.read(learnerControllerProvider).diamonds, 50);

      // The Shop now has several power-up buttons; target the freeze one.
      await tester.tap(find.widgetWithText(RatelButton, 'Buy for 10 💎'));
      await tester.pump(); // process the tap + buy mutation

      expect(c.read(learnerControllerProvider).streakFreezes, 1);
      expect(c.read(learnerControllerProvider).diamonds, 40);
      expect(find.text('Owned 1/2'), findsOneWidget);

      // Flush the confirmation SnackBar's auto-dismiss timer so nothing is
      // pending at teardown.
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
