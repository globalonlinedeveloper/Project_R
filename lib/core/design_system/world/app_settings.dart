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
  });

  /// Light/Classic is the DEFAULT — the app boots in it; Space is opt-in.
  final WorldThemeId world;
  final MotionPreference motion;
  final bool highContrast;
  final bool sound;
  final bool haptics;

  AppSettings copyWith({
    WorldThemeId? world,
    MotionPreference? motion,
    bool? highContrast,
    bool? sound,
    bool? haptics,
  }) =>
      AppSettings(
        world: world ?? this.world,
        motion: motion ?? this.motion,
        highContrast: highContrast ?? this.highContrast,
        sound: sound ?? this.sound,
        haptics: haptics ?? this.haptics,
      );

  Map<String, Object> toMap() => <String, Object>{
        'world': world.name,
        'motion': motion.name,
        'highContrast': highContrast,
        'sound': sound,
        'haptics': haptics,
      };

  static AppSettings fromMap(Map<String, Object?> m) => AppSettings(
        world:
            _enumByName(WorldThemeId.values, m['world'], WorldThemeId.classic),
        motion: _enumByName(
            MotionPreference.values, m['motion'], MotionPreference.high),
        highContrast: m['highContrast'] as bool? ?? false,
        sound: m['sound'] as bool? ?? true,
        haptics: m['haptics'] as bool? ?? true,
      );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.world == world &&
      other.motion == motion &&
      other.highContrast == highContrast &&
      other.sound == sound &&
      other.haptics == haptics;

  @override
  int get hashCode => Object.hash(world, motion, highContrast, sound, haptics);
}

T _enumByName<T extends Enum>(List<T> values, Object? raw, T fallback) {
  for (final v in values) {
    if (v.name == raw) return v;
  }
  return fallback;
}
// Traceability: R-WT3 R-WT5
