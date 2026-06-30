import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ratel/app/backend_wiring.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/data_access/supabase_friends_store.dart';
import 'package:ratel/services/data_access/supabase_leagues_store.dart';
import 'package:ratel/services/data_access/supabase_friends_service.dart';
import 'package:ratel/services/social/friends_service.dart';
import 'package:ratel/services/data_access/supabase_learner_state_store.dart';

void main() {
  group('supabaseConfigured gate (R-M3 / R-K6 seam wiring)', () {
    test('requires BOTH the url and the publishable key', () {
      expect(supabaseConfigured(url: '', publishableKey: ''), isFalse);
      expect(
          supabaseConfigured(url: 'https://x.supabase.co', publishableKey: ''),
          isFalse);
      expect(supabaseConfigured(url: '', publishableKey: 'pk'), isFalse);
      expect(
          supabaseConfigured(
              url: 'https://x.supabase.co', publishableKey: 'pk'),
          isTrue);
    });

    test('an un-configured build (no --dart-define) stays LOCAL', () {
      // The test runner passes no dart-define ⇒ both compile-time consts are
      // empty ⇒ the Supabase seams are NEVER selected ⇒ local defaults hold.
      expect(supabaseConfigured(), isFalse);
    });
  });

  group('backendOverridesForClient seam wiring (R-I9 / R-L8 / R-G6)', () {
    test('default friends store is the in-memory stub (flag-off stays LOCAL)',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      // No overrides ⇒ a fresh learner gets an honestly EMPTY in-memory graph;
      // boot is byte-identical to an un-configured build.
      expect(container.read(friendsStoreProvider), isA<InMemoryFriendsStore>());
      // The leagues standing seam also defaults to the in-memory stub.
      expect(container.read(leaguesStoreProvider), isA<InMemoryLeaguesStore>());
      // The cross-user delivery seam defaults to the honest 'unavailable'
      // service — a local build never routes to another account.
      expect(container.read(friendsServiceProvider),
          isA<UnavailableFriendsService>());
    });

    test('plugs the Supabase-backed friends + learner-state stores when wired',
        () {
      // A client is enough to BUILD the seam overrides (no network on read —
      // the stores just capture the client). Mirrors how the live build wires
      // every durable R-O1 seam behind supabaseConfigured().
      final client = SupabaseClient(
        'https://stub.supabase.co',
        'sb_publishable_stub_key',
      );
      addTearDown(() async => client.dispose());
      final container =
          ProviderContainer(overrides: backendOverridesForClient(client));
      addTearDown(container.dispose);

      expect(container.read(friendsStoreProvider),
          isA<SupabaseFriendsStore>());
      // The leagues standing seam plugs in behind the SAME wiring.
      expect(container.read(leaguesStoreProvider),
          isA<SupabaseLeaguesStore>());
      // DELIVERY: the cross-user RPC service plugs in behind the SAME seam.
      expect(container.read(friendsServiceProvider),
          isA<SupabaseFriendsService>());
      // Regression: wiring friends must not drop the existing learner-state seam.
      expect(container.read(learnerStateStoreProvider),
          isA<SupabaseLearnerStateStore>());
    });
  });
}
