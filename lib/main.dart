import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_flags.dart';
import 'app/ratel_app.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/supabase_auth_service.dart';
import 'services/data_access/data_access.dart';
import 'services/data_access/supabase_learner_state_store.dart';
import 'services/identity/identity.dart';
import 'services/identity/supabase_identity.dart';

/// Supabase connection, injected at build time via `--dart-define` (never
/// committed). Empty when not provided — auth then stays inert even if
/// [authEnabled] is on, so a keyless build degrades to guest-only instead of
/// crashing. (`SUPABASE_PUBLISHABLE_KEY` is safe to ship in a client.)
const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String _supabasePublishableKey =
    String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

/// RATEL entrypoint — Riverpod scope + the design-system app shell.
///
/// With [authEnabled] on AND Supabase keys present, the live client backs
/// identity + auth + learner-state persistence and the launch session is
/// restored into [signedIn]; otherwise the app runs exactly as before (guest,
/// in-memory), so `main` is unchanged while the flag is off (R-L1).
Future<void> main() async {
  final overrides = <Override>[];
  if (authEnabled &&
      _supabaseUrl.isNotEmpty &&
      _supabasePublishableKey.isNotEmpty) {
    try {
    WidgetsFlutterBinding.ensureInitialized();
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabasePublishableKey,
    );
    final client = Supabase.instance.client;
    // A live session counts as *signed in* only when it is an account — never
    // the anonymous guest session (TS-11): anonymous guests still flow through
    // Welcome / onboarding, so they must not be treated as signed-in.
    bool isAccount(Session? s) => s != null && s.user.isAnonymous != true;
    signedIn.value = isAccount(client.auth.currentSession); // restore on launch
    client.auth.onAuthStateChange.listen(
      (state) => signedIn.value = isAccount(state.session),
    );
    // Guest-first (TS-11): with no session, sign in anonymously so on-device
    // progress is owned by a real auth.uid() that can be claimed into an account
    // on sign-in. Best-effort — a keyless/offline/anon-disabled guest stays a
    // local guest.
    if (client.auth.currentSession == null) {
      try {
        await client.auth.signInAnonymously();
      } catch (_) {
        // offline or anonymous sign-ins disabled — remain a local guest.
      }
    }
    overrides.add(
      authServiceProvider
          .overrideWithValue(SupabaseAuthService.fromClient(client)),
    );
    overrides.add(
      identityProvider.overrideWithValue(
        SupabaseIdentity.fromClient(
          client,
          // Flip the TS-11 claim relay on: forward a server-minted claim token
          // to the deployed claim-anonymous-state edge function (queue #6).
          onClaim: (token) async {
            final res = await client.functions.invoke(
              'claim-anonymous-state',
              body: <String, dynamic>{'action': 'claim', 'token': token.value},
            );
            if (res.status != 200) {
              throw StateError('claim failed (${res.status})');
            }
          },
          // Mint (authed as the anonymous guest A) a single-use server token
          // capturing A's state, to be redeemed by onClaim after sign-in (B).
          onMint: () async {
            final res = await client.functions.invoke(
              'claim-anonymous-state',
              body: <String, dynamic>{'action': 'mint'},
            );
            if (res.status != 200) return null;
            final data = res.data;
            return data is Map ? data['token'] as String? : null;
          },
        ),
      ),
    );
    overrides.add(
      learnerStateStoreProvider
          .overrideWithValue(SupabaseLearnerStateStore.fromClient(client)),
    );
    } catch (e) {
      // If the live backend fails to initialise (e.g. a web auth-init crash),
      // degrade to guest-only instead of white-screening the whole app.
      debugPrint('Supabase init failed; running guest-only: $e');
      overrides.clear();
    }
  }
  runApp(ProviderScope(overrides: overrides, child: const RatelApp()));
}
