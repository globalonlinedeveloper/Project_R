import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;

/// Minimal, neutral persisted user settings.
///
/// Pure + immutable so it serialises cleanly to any settings store. Holds the
/// a11y toggles, the daily XP goal, and (S53) the [themeMode] appearance
/// preference (System / Light / Dark — R-WT3 persisted theme selection).
@immutable
class AppSettings {
  const AppSettings({
    this.highContrast = false,
    this.sound = true,
    this.haptics = true,
    this.dailyGoal = 20,
    this.themeMode = ThemeMode.system,
  });

  final bool highContrast;
  final bool sound;
  final bool haptics;

  /// Daily XP goal (Casual 10 / Regular 20 / Serious 30).
  final int dailyGoal;

  /// Appearance preference: follow the OS (default), force light, or force dark.
  final ThemeMode themeMode;

  AppSettings copyWith({
    bool? highContrast,
    bool? sound,
    bool? haptics,
    int? dailyGoal,
    ThemeMode? themeMode,
  }) =>
      AppSettings(
        highContrast: highContrast ?? this.highContrast,
        sound: sound ?? this.sound,
        haptics: haptics ?? this.haptics,
        dailyGoal: dailyGoal ?? this.dailyGoal,
        themeMode: themeMode ?? this.themeMode,
      );

  Map<String, Object> toMap() => <String, Object>{
        'highContrast': highContrast,
        'sound': sound,
        'haptics': haptics,
        'dailyGoal': dailyGoal,
        'themeMode': themeMode.name,
      };

  static AppSettings fromMap(Map<String, Object?> m) => AppSettings(
        highContrast: m['highContrast'] as bool? ?? false,
        sound: m['sound'] as bool? ?? true,
        haptics: m['haptics'] as bool? ?? true,
        dailyGoal: (m['dailyGoal'] as int?) ?? 20,
        themeMode: _themeModeFromName(m['themeMode'] as String?),
      );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.highContrast == highContrast &&
      other.sound == sound &&
      other.haptics == haptics &&
      other.dailyGoal == dailyGoal &&
      other.themeMode == themeMode;

  @override
  int get hashCode =>
      Object.hash(highContrast, sound, haptics, dailyGoal, themeMode);
}

/// Parse a persisted [ThemeMode] name; unknown/absent ⇒ follow the system.
ThemeMode _themeModeFromName(String? name) {
  switch (name) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}
