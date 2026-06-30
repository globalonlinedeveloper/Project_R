import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/services/billing/billing.dart';

export 'package:ratel/features/learner/learner_controller.dart';
export 'package:ratel/features/saved_words/saved_words_controller.dart';
export 'package:ratel/features/settings/settings_controller.dart';
export 'package:ratel/features/learner/daily_goal.dart';
export 'package:ratel/services/data_access/data_access.dart' show clockProvider;

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
