import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ratel/services/preferences/prefs_settings_store.dart';
import 'package:ratel/services/progress/prefs_xp_history_store.dart';
import 'package:ratel/services/progress/xp_history_store.dart';

import 'app/backend_wiring.dart';
import 'app/content_wiring.dart';
import 'app/ratel_app.dart';
import 'features/settings/settings_controller.dart';

/// RATEL entrypoint — boots the design-system theme + the go_router 5-tab shell.
/// Best-effort wirings, each failing safe to a local default so the app ALWAYS
/// boots: (1) the Supabase-backed data-access + identity seams when the build
/// carries the publishable config (else in-memory / guest); (2) on-device
/// settings persistence (else in-memory settings); (3) the authored course
/// spine projected from the bundled content batch (else an honest empty path).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<Override> overrides = <Override>[];

  // (1) Backend seams: live Supabase when configured, else local defaults.
  overrides.addAll(await initBackendOverrides());

  // (2) On-device settings persistence (best-effort).
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    overrides.add(
      settingsStoreProvider.overrideWithValue(PrefsSettingsStore(prefs)),
    );
    overrides.add(
      xpHistoryStoreProvider.overrideWithValue(PrefsXpHistoryStore(prefs)),
    );
  } catch (_) {
    // keep the in-memory settings default
  }

  // (3) Content-driven learning path: project the bundled course batch.
  overrides.addAll(await initContentOverrides());

  runApp(ProviderScope(overrides: overrides, child: const RatelApp()));
}
