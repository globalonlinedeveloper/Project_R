import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/services/preferences/app_settings.dart' show WorldTheme;
import 'package:ratel/core/theme/world_theme.dart';
import 'package:ratel/core/theme/world_registry.dart';
import 'package:ratel/features/learner/learner_controller.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/services/billing/billing.dart';

export 'package:ratel/features/learner/learner_controller.dart';
export 'package:ratel/features/saved_words/saved_words_controller.dart';
export 'package:ratel/features/settings/settings_controller.dart';
export 'package:ratel/features/learner/daily_goal.dart';
export 'package:ratel/features/progress/xp_history_controller.dart';
export 'package:ratel/features/progress/study_stats_controller.dart';
export 'package:ratel/services/data_access/data_access.dart' show clockProvider;
export 'package:ratel/app/backend_wiring.dart' show friendsEnabledProvider;

/// Current Pro entitlement (design spec §4 PRO gating) — wraps the existing
/// billing `entitlementsProvider` (free tier by default; server-computed at
/// Stage 3, never client-asserted).
final isProProvider =
    Provider<bool>((ref) => ref.watch(entitlementsProvider).isPro);

/// The active appearance mode (System / Light / Dark), from the persisted
/// [AppSettings]. Drives `MaterialApp.themeMode` so a dark choice survives a
/// relaunch (R-WT3 persisted theme selection, S53).
final themeModeProvider = Provider<ThemeMode>(
    (ref) => ref.watch(appSettingsControllerProvider).themeMode);

/// Whether to reduce non-essential motion/animation (HABITS · §4.9), from the
/// persisted [AppSettings]. Honored app-wide via MediaQuery.disableAnimations
/// (the OS reduce-motion setting stays a hard floor on top).
final reduceMotionProvider = Provider<bool>(
    (ref) => ref.watch(appSettingsControllerProvider).reduceMotion);


/// Predicted FSRS 1-day recall over the learner's reviewed items THIS SESSION
/// (D2 retention · R-G5). null until any item is reviewed (honest "no data yet").
/// Session-scoped — the durable per-item scheduler is go-live wiring.
final retentionEstimateProvider = Provider<double?>((ref) {
  ref.watch(learnerControllerProvider);
  return ref.read(learnerControllerProvider.notifier).retentionEstimate();
});

/// Distinct items reviewed this session — the basis (and honest count) for
/// [retentionEstimateProvider].
final reviewedItemCountProvider = Provider<int>((ref) {
  ref.watch(learnerControllerProvider);
  return ref.read(learnerControllerProvider.notifier).reviewedItemCount;
});


/// The active WORLD theme (Classic / Space — R-WT1/WT2/WT3, S66), from the
/// persisted [AppSettings]. Drives the app-wide Space re-skin + starfield.
final worldThemeProvider = Provider<WorldTheme>(
    (ref) => ref.watch(appSettingsControllerProvider).worldTheme);

/// The resolved active [ThemeWorld] (full 15-token palette + backdrop + Pro
/// gating) for the persisted selection, looked up in `kThemeWorlds`; falls back
/// to the light world. Drives the app-wide re-skin in `RatelApp`.
final activeWorldProvider = Provider<ThemeWorld>((ref) {
  final WorldTheme w = ref.watch(worldThemeProvider);
  return kThemeWorlds[w.name] ?? kThemeWorlds['light']!;
});
