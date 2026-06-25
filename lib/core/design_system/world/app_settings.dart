import 'package:flutter/foundation.dart';
import '../motion/ratel_motion_tier.dart';
import 'world_theme.dart';

/// All app-wide, persisted user settings (the Profile › Settings surface).
/// Pure + immutable so it serialises cleanly to any settings store.
@immutable
class AppSettings {
  const AppSettings({
    this.world = WorldThemeId.classic,
    this.motion = MotionPreference.high,
    this.highContrast = false,
    this.sound = true,
    this.haptics = true,
    this.dailyGoal = 20,
  });

  /// Light/Classic is the DEFAULT — the app boots in it; Space is opt-in.
  final WorldThemeId world;
  final MotionPreference motion;
  final bool highContrast;
  final bool sound;
  final bool haptics;

  /// Daily XP goal (Casual 10 / Regular 20 / Serious 30) — drives the goal ring.
  final int dailyGoal;

  AppSettings copyWith({
    WorldThemeId? world,
    MotionPreference? motion,
    bool? highContrast,
    bool? sound,
    bool? haptics,
    int? dailyGoal,
  }) =>
      AppSettings(
        world: world ?? this.world,
        motion: motion ?? this.motion,
        highContrast: highContrast ?? this.highContrast,
        sound: sound ?? this.sound,
        haptics: haptics ?? this.haptics,
        dailyGoal: dailyGoal ?? this.dailyGoal,
      );

  Map<String, Object> toMap() => <String, Object>{
        'world': world.name,
        'motion': motion.name,
        'highContrast': highContrast,
        'sound': sound,
        'haptics': haptics,
        'dailyGoal': dailyGoal,
      };

  static AppSettings fromMap(Map<String, Object?> m) => AppSettings(
        world:
            _enumByName(WorldThemeId.values, m['world'], WorldThemeId.classic),
        motion: _enumByName(
            MotionPreference.values, m['motion'], MotionPreference.high),
        highContrast: m['highContrast'] as bool? ?? false,
        sound: m['sound'] as bool? ?? true,
        haptics: m['haptics'] as bool? ?? true,
        dailyGoal: (m['dailyGoal'] as int?) ?? 20,
      );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.world == world &&
      other.motion == motion &&
      other.highContrast == highContrast &&
      other.sound == sound &&
      other.haptics == haptics &&
      other.dailyGoal == dailyGoal;

  @override
  int get hashCode =>
      Object.hash(world, motion, highContrast, sound, haptics, dailyGoal);
}

T _enumByName<T extends Enum>(List<T> values, Object? raw, T fallback) {
  for (final v in values) {
    if (v.name == raw) return v;
  }
  return fallback;
}
// Traceability: R-WT3 R-WT5
