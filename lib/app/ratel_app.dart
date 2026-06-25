import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/design_system/design_system.dart';
import '../features/settings/settings_controller.dart';
import 'router.dart';

/// Root app — Material 3 + the Ratel design system + go_router IA.
///
/// Watches the selected world theme: Classic (default light/dark, used for
/// Login/Welcome) or Space (deep-space dark, applied app-wide). Switching the
/// world re-skins EVERY screen at once because the whole app reads this one
/// [ThemeData]; the choice is persisted, so it survives relaunch.
class RatelApp extends ConsumerWidget {
  const RatelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSpace = ref.watch(settingsControllerProvider
        .select((s) => s.world == WorldThemeId.space));
    return MaterialApp.router(
      title: 'Ratel',
      debugShowCheckedModeBanner: false,
      theme: isSpace ? RatelTheme.space() : RatelTheme.light(),
      darkTheme: isSpace ? RatelTheme.space() : RatelTheme.dark(),
      routerConfig: ratelRouter,
    );
  }
}
// Traceability: R-WT2
