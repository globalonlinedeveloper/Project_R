import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/features/shop/outfits_controller.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/economy/prefs_outfits_store.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/fake_identity.dart';

/// E1c evidence — badger outfits (R-I4 spend side): a real 💎 spend cosmetic.
/// Classic is free + owned; the rest cost real diamonds, persist device-locally,
/// and never grant themselves.

class _LStore implements LearnerStateStore {
  _LStore(this.seed);
  final Map<String, Object?> seed;
  @override
  Future<Map<String, Object?>> load(String userId) async => seed;
  @override
  Future<void> save(String userId, Map<String, Object?> state) async {}
}

Map<String, Object?> _seed(Map<String, Object?> course) => <String, Object?>{
      'courses': <Object?>[
        <String, Object?>{'target_locale': 'en', ...course},
      ],
    };

ProviderContainer _c(DateTime Function() clock,
        {Identity? identity, LearnerStateStore? store}) =>
    ProviderContainer(overrides: <Override>[
      clockProvider.overrideWithValue(clock),
      if (identity != null) identityProvider.overrideWithValue(identity),
      if (store != null) learnerStateStoreProvider.overrideWithValue(store),
      persistDebounceProvider.overrideWithValue(Duration.zero),
    ]);

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OutfitState', () {
    test('classic is always owned; copyWith adds + equips', () {
      final OutfitState s = OutfitState();
      expect(s.isOwned('classic'), isTrue);
      expect(s.selected, 'classic');
      final OutfitState s2 = s.copyWith(
          owned: <String>{'classic', 'scholar'}, selected: 'scholar');
      expect(s2.isOwned('scholar'), isTrue);
      expect(s2.selected, 'scholar');
    });
  });

  group('PrefsOutfitsStore', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('round-trips owned + selected', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await PrefsOutfitsStore(prefs).save(
          OutfitState(owned: <String>{'classic', 'scholar'}, selected: 'scholar'));
      final OutfitState loaded = PrefsOutfitsStore(prefs).load();
      expect(loaded.isOwned('scholar'), isTrue);
      expect(loaded.selected, 'scholar');
    });

    test('an unowned selection falls back to classic', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'ratel.outfits.owned': 'classic',
        'ratel.outfits.selected': 'astronaut',
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(PrefsOutfitsStore(prefs).load().selected, 'classic');
    });
  });

  group('OutfitsController', () {
    test('buy debits 💎 + owns + equips; equip is free; gated honestly',
        () async {
      final _LStore store = _LStore(_seed(<String, Object?>{'diamonds': 50}));
      final ProviderContainer c =
          _c(() => DateTime(2026, 6, 1), identity: FakeIdentity(), store: store);
      addTearDown(c.dispose);
      c.read(learnerControllerProvider.notifier); // build → hydrate
      await _settle();
      final OutfitsController ctl = c.read(outfitsControllerProvider.notifier);

      final BadgerOutfit scholar = OutfitCatalogue.byId('scholar'); // 25 💎
      expect(ctl.buy(scholar), isTrue);
      expect(c.read(learnerControllerProvider).diamonds, 25); // 50 - 25
      expect(c.read(outfitsControllerProvider).isOwned('scholar'), isTrue);
      expect(c.read(outfitsControllerProvider).selected, 'scholar'); // auto-equip

      // Re-buying an owned outfit is a no-op (no double charge).
      expect(ctl.buy(scholar), isFalse);
      expect(c.read(learnerControllerProvider).diamonds, 25);

      // Equipping an owned outfit is free.
      ctl.equip('classic');
      expect(c.read(outfitsControllerProvider).selected, 'classic');

      // An unaffordable buy is gated — no charge, not owned.
      final BadgerOutfit astronaut = OutfitCatalogue.byId('astronaut'); // 40 💎
      expect(ctl.buy(astronaut), isFalse);
      expect(c.read(learnerControllerProvider).diamonds, 25);
      expect(c.read(outfitsControllerProvider).isOwned('astronaut'), isFalse);
    });
  });
}
