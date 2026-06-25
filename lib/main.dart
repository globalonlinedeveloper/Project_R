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
    WidgetsFlutterBinding.ensureInitialized();
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabasePublishableKey,
    );
    final client = Supabase.instance.client;
    signedIn.value = client.auth.currentSession != null; // restore on launch
    client.auth.onAuthStateChange.listen(
      (state) => signedIn.value = state.session != null,
    );
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
        ),
      ),
    );
    overrides.add(
      learnerStateStoreProvider
          .overrideWithValue(SupabaseLearnerStateStore.fromClient(client)),
    );
  }
  runApp(ProviderScope(overrides: overrides, child: const RatelApp()));
}
