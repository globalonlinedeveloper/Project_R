import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ratel/services/preferences/prefs_settings_store.dart';

import 'app/ratel_app.dart';
import 'features/settings/settings_controller.dart';

/// RATEL entrypoint — boots the design-system theme + the go_router 5-tab shell
/// (P1 foundation). On-device settings persistence is best-effort: if the
/// platform store is unavailable the app falls back to the in-memory default.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<Override> overrides = const <Override>[];
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    overrides = <Override>[
      settingsStoreProvider.overrideWithValue(PrefsSettingsStore(prefs)),
    ];
  } catch (_) {
    overrides = const <Override>[]; // keep the in-memory settings default
  }
  runApp(ProviderScope(overrides: overrides, child: const RatelApp()));
}
