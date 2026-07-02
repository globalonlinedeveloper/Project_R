/// Backend seam wiring (queue #7 — "finish the open backend wiring"). Plugs the
/// Supabase-backed [LearnerStateStore] + [Identity] implementations behind the
/// SAME seams the features read through, ONLY when the build carries the
/// client-safe publishable config. Absent config ⇒ the local in-memory / guest
/// defaults stay in place and the app boots byte-identically (so every existing
/// flag-off test is unchanged). Enabling it in the deployed build is an
/// owner-gated CI step (pass the keys via --dart-define + Pages env).
library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ratel/services/ai_relay/ai_relay.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/auth/auth.dart';
import 'package:ratel/services/data_access/supabase_learner_state_store.dart';
import 'package:ratel/services/data_access/supabase_friends_store.dart';
import 'package:ratel/services/data_access/supabase_leagues_store.dart';
import 'package:ratel/services/data_access/supabase_friends_service.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/social/friends_service.dart';
import 'package:ratel/services/identity/supabase_identity.dart';

/// Compile-time, client-SAFE Supabase config, injected at build via
/// `--dart-define` (the publishable key is public by design; the service-role
/// key is NEVER in client code — see [ServiceRoleKeyContract]). Both default to
/// empty, so an un-configured build (and every test) stays local.
const String kSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String kSupabasePublishableKey =
    String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

/// Opt-in (build-dark until go-live): boot a Supabase ANONYMOUS session on
/// launch so durable persistence works BEFORE login. Two-step go-live (§2):
/// (1) enable Anonymous Sign-Ins in Supabase -> Auth settings; (2) build with
/// `--dart-define=RATEL_ANON=true`. Default false => byte-identical guest boot.
const bool kEnableAnonSession = bool.fromEnvironment('RATEL_ANON');

/// Opt-in (build-dark until go-live): route the AI tutor / adventures through
/// the SERVER-SIDE `ai-relay` edge function (which holds the model key). Go-
/// live: (1) the function is deployed — set its `GEMINI_API_KEY` secret; (2)
/// build with `--dart-define=RATEL_AI_RELAY=true`. Default false => the fail-
/// closed [UnconfiguredAiRelay] stays the provider (byte-identical build).
// R-H7 relay go-live gate.
const bool kEnableAiRelay = bool.fromEnvironment('RATEL_AI_RELAY');

/// The server-side relay endpoint, derived from the Supabase project URL.
String aiRelayUrl(String supabaseUrl) =>
    '$supabaseUrl/functions/v1/ai-relay';

/// Real transport for [EdgeAiRelay]: POST through the Supabase Functions
/// client (which attaches the session JWT + project apikey), adapting its
/// [FunctionResponse] to the relay layer's dependency-free [HttpLikeResponse].
/// The model key is NEVER read here — it lives only in the edge function.
HttpTransport supabaseFunctionsTransport(SupabaseClient client) =>
    (HttpLikeRequest req) async {
      final Map<String, dynamic> body =
          jsonDecode(req.body) as Map<String, dynamic>;
      final FunctionResponse resp =
          await client.functions.invoke('ai-relay', body: body);
      return HttpLikeResponse(
        statusCode: resp.status,
        body: jsonEncode(resp.data),
      );
    };

/// The ONLY gate that turns on the Supabase-backed seams: both the URL and the
/// publishable key must be present. Pure + injectable so it is unit-testable.
bool supabaseConfigured({
  String url = kSupabaseUrl,
  String publishableKey = kSupabasePublishableKey,
}) =>
    url.isNotEmpty && publishableKey.isNotEmpty;

/// Pure gate for booting an anonymous session: only when the backend is
/// configured, anon boot is enabled, and there is no existing session. Kept
/// pure + injectable so the policy is unit-testable without a live client.
bool shouldBootAnonSession({
  required bool configured,
  required bool enabled,
  required bool hasSession,
}) =>
    configured && enabled && !hasSession;

/// Pure (no network): build the Riverpod overrides that plug an already-created
/// [client] behind the data-access + identity seams. `main` supplies the live
/// client via [initBackendOverrides]; tests can supply any client.
List<Override> backendOverridesForClient(SupabaseClient client) => <Override>[
      learnerStateStoreProvider
          .overrideWithValue(SupabaseLearnerStateStore.fromClient(client)),
      friendsStoreProvider
          .overrideWithValue(SupabaseFriendsStore.fromClient(client)),
      leaguesStoreProvider
          .overrideWithValue(SupabaseLeaguesStore.fromClient(client)),
      friendsServiceProvider
          .overrideWithValue(SupabaseFriendsService.fromClient(client)),
      identityProvider
          .overrideWithValue(SupabaseIdentity.fromClient(client)),
      authServiceProvider
          .overrideWithValue(SupabaseAuthService.fromClient(client)),
      if (kEnableAiRelay)
        aiRelayProvider.overrideWithValue(
          RequestSizeLimitedAiRelay(
            EdgeAiRelay(
              transport: supabaseFunctionsTransport(client),
              url: aiRelayUrl(kSupabaseUrl),
            ),
          ),
        ),
    ];

/// Best-effort `main`-side wiring: when [supabaseConfigured], initialise the
/// Supabase singleton and return the seam overrides; otherwise — or on ANY
/// failure — return none, so the app keeps the local defaults and always boots.
Future<List<Override>> initBackendOverrides() async {
  if (!supabaseConfigured()) return const <Override>[];
  try {
    await Supabase.initialize(
      url: kSupabaseUrl,
      publishableKey: kSupabasePublishableKey,
    );
    final SupabaseClient client = Supabase.instance.client;
    // Boot an anonymous session so durable persistence works pre-login (opt-in;
    // gracefully stays guest if anon sign-in is disabled in the project).
    if (shouldBootAnonSession(
      configured: true,
      enabled: kEnableAnonSession,
      hasSession: client.auth.currentSession != null,
    )) {
      try {
        await client.auth.signInAnonymously();
      } catch (_) {
        // Anonymous sign-in disabled in the project (or offline) -> stay guest.
      }
    }
    return backendOverridesForClient(client);
  } catch (_) {
    return const <Override>[]; // never block boot on a backend init failure
  }
}
