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
import 'package:ratel/services/tts_relay/tts_relay.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/auth/auth.dart';
import 'package:ratel/services/data_access/supabase_learner_state_store.dart';
import 'package:ratel/services/data_access/supabase_review_log_sink.dart';
import 'package:ratel/services/data_access/supabase_saved_words_store.dart';
import 'package:ratel/services/learning/review_log_sink.dart';
import 'package:ratel/services/learning/saved_words_store.dart';
import 'package:ratel/services/data_access/supabase_friends_store.dart';
import 'package:ratel/services/data_access/supabase_leagues_store.dart';
import 'package:ratel/services/data_access/supabase_calibration_store.dart';
import 'package:ratel/services/learning/calibration_runner.dart'
    show calibrationStoreProvider;
import 'package:ratel/services/data_access/supabase_friends_service.dart';
import 'package:ratel/services/data_access/supabase_friend_quest_service.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/social/friends_service.dart';
import 'package:ratel/services/social/friend_quest_service.dart';
import 'package:ratel/services/identity/supabase_identity.dart';
import 'package:ratel/services/live_session/live_session.dart';
import 'package:ratel/services/billing/billing.dart';

import 'auth_gate.dart';

/// Compile-time, client-SAFE Supabase config, injected at build via
/// `--dart-define` (the publishable key is public by design; the service-role
/// key is NEVER in client code — see [ServiceRoleKeyContract]). Both default to
/// empty, so an un-configured build (and every test) stays local.
const String kSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String kSupabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
);

/// Opt-in (build-dark until go-live): boot a Supabase ANONYMOUS session on
/// launch so durable persistence works BEFORE login. Two-step go-live (§2):
/// (1) enable Anonymous Sign-Ins in Supabase -> Auth settings; (2) build with
/// `--dart-define=RATEL_ANON=true`. Default false => byte-identical guest boot.
/// AUTH-1 (S112): the session now starts on the persisted guest CHOICE
/// (Welcome gate / returning guest) — no longer unconditionally at launch.
const bool kEnableAnonSession = bool.fromEnvironment('RATEL_ANON');

/// Opt-in (build-dark until go-live): route the AI tutor / adventures through
/// the SERVER-SIDE `ai-relay` edge function (which holds the model key). Go-
/// live: (1) the function is deployed — set its `GEMINI_API_KEY` secret; (2)
/// build with `--dart-define=RATEL_AI_RELAY=true`. Default false => the fail-
/// closed [UnconfiguredAiRelay] stays the provider (byte-identical build).
// R-H7 relay go-live gate.
const bool kEnableAiRelay = bool.fromEnvironment('RATEL_AI_RELAY');

/// The server-side relay endpoint, derived from the Supabase project URL.
String aiRelayUrl(String supabaseUrl) => '$supabaseUrl/functions/v1/ai-relay';

/// Real transport for [EdgeAiRelay]: POST through the Supabase Functions
/// client (which attaches the session JWT + project apikey), adapting its
/// [FunctionResponse] to the relay layer's dependency-free [HttpLikeResponse].
/// The model key is NEVER read here — it lives only in the edge function.
HttpTransport supabaseFunctionsTransport(SupabaseClient client) =>
    (HttpLikeRequest req) async {
      final Map<String, dynamic> body =
          jsonDecode(req.body) as Map<String, dynamic>;
      final FunctionResponse resp = await client.functions.invoke(
        'ai-relay',
        body: body,
      );
      return HttpLikeResponse(
        statusCode: resp.status,
        body: jsonEncode(resp.data),
      );
    };

/// Opt-in (build-dark until go-live): route Listen audio synthesis through the
/// SERVER-SIDE `tts-relay` edge function (which holds the GCP_TTS key). Go-live:
/// (1) the function is deployed — set its `GCP_TTS` secret; (2) build with
/// `--dart-define=RATEL_TTS=true`. Default false => the fail-closed
/// [UnconfiguredTtsRelay] stays the provider (byte-identical build; Listen
/// degrades to typed).
// R-H7 TTS relay go-live gate (twin of kEnableAiRelay).
const bool kEnableTts = bool.fromEnvironment('RATEL_TTS');

/// The server-side TTS relay endpoint, derived from the Supabase project URL.
String ttsRelayUrl(String supabaseUrl) => '$supabaseUrl/functions/v1/tts-relay';

/// Real transport for [EdgeTtsRelay]: POST through the Supabase Functions client
/// (which attaches the session JWT + project apikey). The GCP_TTS key is NEVER
/// read here — it lives only in the edge function.
HttpTransport supabaseTtsTransport(SupabaseClient client) =>
    (HttpLikeRequest req) async {
      final Map<String, dynamic> body =
          jsonDecode(req.body) as Map<String, dynamic>;
      final FunctionResponse resp = await client.functions.invoke(
        'tts-relay',
        body: body,
      );
      return HttpLikeResponse(
        statusCode: resp.status,
        body: jsonEncode(resp.data),
      );
    };

/// L-2 (S112): mint a live-session ephemeral token via the `live-token` edge
/// function (deployed + E2E-verified at L-1). The Functions client attaches
/// the user JWT; the SERVER enforces the Pro entitlement + voice budgets and
/// LOCKS the model + system prompt into the single-use token
/// (liveConnectConstraints) — no model key, model name, or prompt ships in
/// client code. 403/429 surface as honest [LiveSessionUnavailable] reasons.
LiveTokenFetcher supabaseLiveTokenFetcher(SupabaseClient client) =>
    ({Map<String, Object?>? payload}) async {
      try {
        final FunctionResponse resp = await client.functions.invoke(
          'live-token',
          body: payload,
        );
        final dynamic data = resp.data;
        final String? token = data is Map
            ? (data['token'] ?? data['name']) as String?
            : null;
        if (token == null || token.isEmpty) {
          throw const LiveSessionUnavailable(
            'live AI is unavailable right now.',
            code: LiveUnavailableCode.unavailable,
          );
        }
        return LiveTokenGrant(
          token: token,
          wssHost: data is Map ? data['wss_host'] as String? : null,
        );
      } on LiveSessionUnavailable {
        rethrow;
      } on FunctionException catch (e) {
        final dynamic det = e.details;
        // A dynamic server-provided reason renders verbatim (no code).
        if (det is Map && det['error'] is String) {
          throw LiveSessionUnavailable(det['error'] as String);
        }
        if (e.status == 403) {
          throw const LiveSessionUnavailable(
            'Live AI is part of RATEL PRO.',
            code: LiveUnavailableCode.needsPro,
          );
        }
        if (e.status == 429) {
          throw const LiveSessionUnavailable(
            "You've used this month's live minutes.",
            code: LiveUnavailableCode.minutesUsed,
          );
        }
        throw const LiveSessionUnavailable(
          'live AI is unavailable right now.',
          code: LiveUnavailableCode.unavailable,
        );
      } catch (_) {
        throw const LiveSessionUnavailable(
          'live AI is unavailable right now.',
          code: LiveUnavailableCode.unavailable,
        );
      }
    };

/// The ONLY gate that turns on the Supabase-backed seams: both the URL and the
/// publishable key must be present. Pure + injectable so it is unit-testable.
bool supabaseConfigured({
  String url = kSupabaseUrl,
  String publishableKey = kSupabasePublishableKey,
}) => url.isNotEmpty && publishableKey.isNotEmpty;

/// Pure gate for booting an anonymous session: only when the backend is
/// configured, anon boot is enabled, there is no existing session, AND the
/// user has previously chosen "Continue as guest" (AUTH-1, S112 — the anon
/// session is an explicit choice now: the first launch shows the Welcome gate
/// and [guestEntryProvider] runs the sign-in; later boots auto-resume it via
/// the persisted choice). Kept pure + injectable so the policy stays
/// unit-testable without a live client.
bool shouldBootAnonSession({
  required bool configured,
  required bool enabled,
  required bool hasSession,
  required bool guestChosen,
}) => configured && enabled && !hasSession && guestChosen;

/// Pure (no network): build the Riverpod overrides that plug an already-created
/// [client] behind the data-access + identity seams. `main` supplies the live
/// client via [initBackendOverrides]; tests can supply any client.
/// L-5b (S114): read the signed-in user's own `profiles.is_pro` row (own-row
/// RLS + the S114 SELECT grant; anon-guest rows are trigger-created with
/// is_pro=false). ANY failure => false — the client flag only drives honest UI
/// gating; real spend stays fail-closed server-side at the token mint.
Future<bool> fetchIsPro(SupabaseClient client) async {
  try {
    final String? uid = client.auth.currentUser?.id;
    if (uid == null) return false;
    final Map<String, dynamic>? row = await client
        .from('profiles')
        .select('is_pro')
        .eq('id', uid)
        .maybeSingle();
    return row?['is_pro'] == true;
  } catch (_) {
    return false;
  }
}

List<Override> backendOverridesForClient(SupabaseClient client) => <Override>[
  learnerStateStoreProvider.overrideWithValue(
    SupabaseLearnerStateStore.fromClient(client),
  ),
  friendsStoreProvider.overrideWithValue(
    SupabaseFriendsStore.fromClient(client),
  ),
  leaguesStoreProvider.overrideWithValue(
    SupabaseLeaguesStore.fromClient(client),
  ),
  friendsServiceProvider.overrideWithValue(
    SupabaseFriendsService.fromClient(client),
  ),
  friendQuestServiceProvider.overrideWithValue(
    SupabaseFriendQuestService.fromClient(client),
  ),
  identityProvider.overrideWithValue(SupabaseIdentity.fromClient(client)),
  reviewLogSinkProvider.overrideWithValue(
    SupabaseReviewLogSink.fromClient(client),
  ),
  savedWordsStoreProvider.overrideWithValue(
    SupabaseSavedWordsStore.fromClient(client),
  ),
  // L-5 (S140): batch IRT re-calibration store — DORMANT build-ahead.
  // Nothing consumes calibrationRunnerProvider at runtime, so this
  // override is byte-identical live; it powers the go-live batch host.
  calibrationStoreProvider.overrideWithValue(
    SupabaseCalibrationStore.fromClient(client),
  ),
  authServiceProvider.overrideWithValue(SupabaseAuthService.fromClient(client)),
  // L-5b (S114): PRO entitlements follow profiles.is_pro — reactive via
  // proStatusProvider (boot-seeded in main; refreshed on session entry).
  entitlementsProvider.overrideWith(
    (ref) => StaticEntitlements(isPro: ref.watch(proStatusProvider)),
  ),
  proStatusRefresherProvider.overrideWith(
    (ref) => () async {
      final bool isPro = await fetchIsPro(client);
      ref.read(proStatusProvider.notifier).state = isPro;
    },
  ),
  if (kEnableAiRelay)
    aiRelayProvider.overrideWithValue(
      RequestSizeLimitedAiRelay(
        EdgeAiRelay(
          transport: supabaseFunctionsTransport(client),
          url: aiRelayUrl(kSupabaseUrl),
        ),
      ),
    ),
  if (kEnableTts)
    ttsRelayProvider.overrideWithValue(
      TtsSizeLimitedTtsRelay(
        EdgeTtsRelay(
          transport: supabaseTtsTransport(client),
          url: ttsRelayUrl(kSupabaseUrl),
        ),
      ),
    ),
  // L-2 (S112): DORMANT live-AI seam — flag off => this override is absent
  // and the engine stays the honest Unavailable default (byte-identical
  // build; the Tutor two-signal gate stays false). Flip = L-5.
  if (kEnableLiveAi)
    liveSessionEngineProvider.overrideWithValue(
      createLiveSessionEngine(tokenFetcher: supabaseLiveTokenFetcher(client)),
    ),
];

/// Best-effort `main`-side wiring: when [supabaseConfigured], initialise the
/// Supabase singleton and return the seam overrides; otherwise — or on ANY
/// failure — return none, so the app keeps the local defaults and always boots.
Future<List<Override>> initBackendOverrides({bool guestChosen = false}) async {
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
      guestChosen: guestChosen,
    )) {
      try {
        await client.auth.signInAnonymously();
      } catch (_) {
        // Anonymous sign-in disabled in the project (or offline) -> stay guest.
      }
    }
    return <Override>[
      ...backendOverridesForClient(client),
      // AUTH-1 (S112): the explicit "Continue as guest" action — the SAME
      // anonymous-session boot pre-gate builds ran automatically, now fired
      // only from the Welcome screen. Best-effort: offline / anon-disabled
      // stays a local guest, never an error surfaced to the gate.
      if (kEnableAnonSession)
        guestEntryProvider.overrideWithValue(() async {
          if (client.auth.currentSession != null) return;
          try {
            await client.auth.signInAnonymously();
          } catch (_) {
            // Anonymous sign-in disabled (or offline) -> stay a local guest.
          }
        }),
    ];
  } catch (_) {
    return const <Override>[]; // never block boot on a backend init failure
  }
}
