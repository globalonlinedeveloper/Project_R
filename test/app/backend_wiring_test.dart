import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ratel/app/auth_gate.dart';
import 'package:ratel/app/backend_wiring.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/data_access/supabase_friends_store.dart';
import 'package:ratel/services/data_access/supabase_leagues_store.dart';
import 'package:ratel/services/data_access/supabase_friends_service.dart';
import 'package:ratel/services/social/friends_service.dart';
import 'package:ratel/services/data_access/supabase_learner_state_store.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart';

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

  group('shouldBootAnonSession gate (§2 pre-login durable persistence)', () {
    test(
        'auto-resumes only when configured AND enabled AND no session '
        'AND the guest choice was persisted (AUTH-1)', () {
      expect(
          shouldBootAnonSession(
              configured: true,
              enabled: true,
              hasSession: false,
              guestChosen: true),
          isTrue);
    });
    test('stays guest when anon boot is disabled (default build-dark)', () {
      expect(
          shouldBootAnonSession(
              configured: true,
              enabled: false,
              hasSession: false,
              guestChosen: true),
          isFalse);
    });
    test('stays guest when the backend is not configured', () {
      expect(
          shouldBootAnonSession(
              configured: false,
              enabled: true,
              hasSession: false,
              guestChosen: true),
          isFalse);
    });
    test('never double-boots over an existing session', () {
      expect(
          shouldBootAnonSession(
              configured: true,
              enabled: true,
              hasSession: true,
              guestChosen: true),
          isFalse);
    });
    test(
        'AUTH-1: never auto-boots before the user chose "Continue as guest" '
        '(first launch shows the Welcome gate instead)', () {
      expect(
          shouldBootAnonSession(
              configured: true,
              enabled: true,
              hasSession: false,
              guestChosen: false),
          isFalse);
    });
  });

  group('shouldShowWelcomeGate policy (AUTH-1, S112)', () {
    test('first configured launch (no session, no choice) shows the gate', () {
      expect(
          shouldShowWelcomeGate(
              configured: true, hasSession: false, choiceMade: false),
          isTrue);
    });
    test('keyless/local builds never gate (tests stay byte-identical)', () {
      expect(
          shouldShowWelcomeGate(
              configured: false, hasSession: false, choiceMade: false),
          isFalse);
    });
    test('a live session skips the gate (returning user)', () {
      expect(
          shouldShowWelcomeGate(
              configured: true, hasSession: true, choiceMade: false),
          isFalse);
    });
    test('a persisted choice skips the gate (returning guest)', () {
      expect(
          shouldShowWelcomeGate(
              configured: true, hasSession: false, choiceMade: true),
          isFalse);
    });
  });

  group('TTS relay wiring (RATEL_TTS gate — twin of ai-relay)', () {
    test('ttsRelayProvider defaults to fail-closed UnconfiguredTtsRelay (flag off)',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final relay = container.read(ttsRelayProvider);
      expect(relay, isA<UnconfiguredTtsRelay>());
      expect(relay.isAvailable, isFalse);
    });

    test('backend overrides do NOT flip TTS on (kEnableTts defaults false)', () {
      final client = SupabaseClient(
        'https://stub.supabase.co',
        'sb_publishable_stub_key',
      );
      addTearDown(() async => client.dispose());
      final container =
          ProviderContainer(overrides: backendOverridesForClient(client));
      addTearDown(container.dispose);
      // Wiring the Supabase seams must not silently enable TTS — the flag gate
      // keeps Listen dark (byte-identical) until an explicit go-live build.
      expect(container.read(ttsRelayProvider), isA<UnconfiguredTtsRelay>());
    });

    test('ttsRelayUrl derives the functions endpoint', () {
      expect(ttsRelayUrl('https://abc.supabase.co'),
          'https://abc.supabase.co/functions/v1/tts-relay');
    });
  });
}
