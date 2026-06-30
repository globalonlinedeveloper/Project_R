import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/features/shop/shop_screen.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

import 'auth/fake_identity.dart';

/// E1a evidence — the Shop's Energy Refill + Streak Repair diamond SPEND sinks
/// (R-I3 / R-I2 / R-I4). Every buy debits the REAL 💎 wallet and is gated on
/// affordability AND applicability; nothing is faked.

class _Store implements LearnerStateStore {
  _Store([this.seed = const <String, Object?>{}]);
  final Map<String, Object?> seed;
  @override
  Future<Map<String, Object?>> load(String userId) async => seed;
  @override
  Future<void> save(String userId, Map<String, Object?> state) async {}
}

Map<String, Object?> _seed(Map<String, Object?> course) => <String, Object?>{
      'courses': <Object?>[
        <String, Object?>{'target_locale': 'es', ...course},
      ],
    };

ProviderContainer _c(DateTime Function() clock,
        {int goal = 20, Identity? identity, LearnerStateStore? store}) =>
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
  group('Energy Refill', () {
    test('refills energy to the cap and debits 💎', () async {
      final _Store store =
          _Store(_seed(<String, Object?>{'diamonds': 30}));
      final ProviderContainer c =
          _c(() => DateTime(2026, 6, 1, 9), identity: FakeIdentity(), store: store);
      addTearDown(c.dispose);
      final LearnerController n = c.read(learnerControllerProvider.notifier);
      await _settle(); // hydrate the seeded wallet

      // Full energy → nothing to refill yet.
      expect(n.canBuyEnergyRefill, isFalse);
      // A sub-goal lesson spends 1 ⚡ (+1 💎), no goal-met bonus.
      n.recordLessonComplete(xp: 10);
      expect(c.read(learnerControllerProvider).energy, 4);
      expect(c.read(learnerControllerProvider).diamonds, 31);
      expect(n.canBuyEnergyRefill, isTrue);

      n.buyEnergyRefill();
      expect(c.read(learnerControllerProvider).energy, 5); // refilled
      expect(c.read(learnerControllerProvider).diamonds, 26); // 31 - 5
      expect(n.canBuyEnergyRefill, isFalse); // full again
    });

    test('gated when the wallet cannot afford it', () async {
      final _Store store = _Store(_seed(<String, Object?>{'diamonds': 2}));
      final ProviderContainer c =
          _c(() => DateTime(2026, 6, 1, 9), identity: FakeIdentity(), store: store);
      addTearDown(c.dispose);
      final LearnerController n = c.read(learnerControllerProvider.notifier);
      await _settle();
      n.recordLessonComplete(xp: 10); // energy 4, diamonds 3
      expect(c.read(learnerControllerProvider).energy, 4);
      expect(n.canBuyEnergyRefill, isFalse); // 3 < 5
      n.buyEnergyRefill(); // no-op
      expect(c.read(learnerControllerProvider).energy, 4);
      expect(c.read(learnerControllerProvider).diamonds, 3);
    });
  });

  group('Streak Repair', () {
    test('restores a lapsed streak and debits 💎', () async {
      final _Store store = _Store(_seed(<String, Object?>{
        'diamonds': 30,
        'streak_days': 5,
        'streak_last_active': '2026-06-01',
      }));
      final ProviderContainer c = _c(() => DateTime(2026, 6, 10, 9),
          identity: FakeIdentity(), store: store);
      addTearDown(c.dispose);
      final LearnerController n = c.read(learnerControllerProvider.notifier);
      await _settle();

      expect(c.read(learnerControllerProvider).streakDays, 0); // lapsed view
      expect(n.streakLapsed, isTrue);
      expect(n.canRepairStreak, isTrue); // 30 >= 20

      n.repairStreak();
      expect(c.read(learnerControllerProvider).streakDays, 5); // restored
      expect(c.read(learnerControllerProvider).diamonds, 10); // 30 - 20
      expect(n.streakLapsed, isFalse); // run is alive again
    });

    test('gated when the streak is still alive (nothing to repair)', () async {
      final _Store store = _Store(_seed(<String, Object?>{
        'diamonds': 30,
        'streak_days': 3,
        'streak_last_active': '2026-06-10',
      }));
      final ProviderContainer c = _c(() => DateTime(2026, 6, 10, 9),
          identity: FakeIdentity(), store: store);
      addTearDown(c.dispose);
      final LearnerController n = c.read(learnerControllerProvider.notifier);
      await _settle();
      expect(c.read(learnerControllerProvider).streakDays, 3); // alive
      expect(n.streakLapsed, isFalse);
      expect(n.canRepairStreak, isFalse);
      n.repairStreak(); // no-op
      expect(c.read(learnerControllerProvider).diamonds, 30);
    });
  });

  testWidgets('Shop renders the Energy Refill + Streak Repair cards',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: ShopScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Energy Refill'), findsOneWidget);
    expect(find.text('Streak Repair'), findsOneWidget);
    // Honest disabled state on a fresh account (full energy / safe streak).
    expect(find.text('Already full'), findsOneWidget);
    expect(find.textContaining('nothing to repair'), findsOneWidget);
  });
}
