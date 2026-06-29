/// Backend seam wiring (queue #7 — "finish the open backend wiring"). Plugs the
/// Supabase-backed [LearnerStateStore] + [Identity] implementations behind the
/// SAME seams the features read through, ONLY when the build carries the
/// client-safe publishable config. Absent config ⇒ the local in-memory / guest
/// defaults stay in place and the app boots byte-identically (so every existing
/// flag-off test is unchanged). Enabling it in the deployed build is an
/// owner-gated CI step (pass the keys via --dart-define + Pages env).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/auth/auth.dart';
import 'package:ratel/services/data_access/supabase_learner_state_store.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/identity/supabase_identity.dart';

/// Compile-time, client-SAFE Supabase config, injected at build via
/// `--dart-define` (the publishable key is public by design; the service-role
/// key is NEVER in client code — see [ServiceRoleKeyContract]). Both default to
/// empty, so an un-configured build (and every test) stays local.
const String kSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String kSupabasePublishableKey =
    String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

/// The ONLY gate that turns on the Supabase-backed seams: both the URL and the
/// publishable key must be present. Pure + injectable so it is unit-testable.
bool supabaseConfigured({
  String url = kSupabaseUrl,
  String publishableKey = kSupabasePublishableKey,
}) =>
    url.isNotEmpty && publishableKey.isNotEmpty;

/// Pure (no network): build the Riverpod overrides that plug an already-created
/// [client] behind the data-access + identity seams. `main` supplies the live
/// client via [initBackendOverrides]; tests can supply any client.
List<Override> backendOverridesForClient(SupabaseClient client) => <Override>[
      learnerStateStoreProvider
          .overrideWithValue(SupabaseLearnerStateStore.fromClient(client)),
      identityProvider
          .overrideWithValue(SupabaseIdentity.fromClient(client)),
      authServiceProvider
          .overrideWithValue(SupabaseAuthService.fromClient(client)),
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
    return backendOverridesForClient(Supabase.instance.client);
  } catch (_) {
    return const <Override>[]; // never block boot on a backend init failure
  }
}
