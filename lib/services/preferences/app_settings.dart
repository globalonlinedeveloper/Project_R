import 'package:flutter/foundation.dart';

/// Minimal, neutral persisted user settings.
///
/// The world-theme / motion-tier seam (Classic/Space + MotionPreference) was
/// removed in the Session 35 UI reset together with the whole design system.
/// Those fields will return when the new design system and a Settings screen
/// are rebuilt from the owner's Claude designs; for now this keeps the backend
/// preferences store (`SettingsStore` / `PrefsSettingsStore`) compiling and the
/// a11y + daily-goal values persisting across the rebuild.
///
/// Pure + immutable so it serialises cleanly to any settings store.
@immutable
class AppSettings {
  const AppSettings({
    this.highContrast = false,
    this.sound = true,
    this.haptics = true,
    this.dailyGoal = 20,
  });

  final bool highContrast;
  final bool sound;
  final bool haptics;

  /// Daily XP goal (Casual 10 / Regular 20 / Serious 30).
  final int dailyGoal;

  AppSettings copyWith({
    bool? highContrast,
    bool? sound,
    bool? haptics,
    int? dailyGoal,
  }) =>
      AppSettings(
        highContrast: highContrast ?? this.highContrast,
        sound: sound ?? this.sound,
        haptics: haptics ?? this.haptics,
        dailyGoal: dailyGoal ?? this.dailyGoal,
      );

  Map<String, Object> toMap() => <String, Object>{
        'highContrast': highContrast,
        'sound': sound,
        'haptics': haptics,
        'dailyGoal': dailyGoal,
      };

  static AppSettings fromMap(Map<String, Object?> m) => AppSettings(
        highContrast: m['highContrast'] as bool? ?? false,
        sound: m['sound'] as bool? ?? true,
        haptics: m['haptics'] as bool? ?? true,
        dailyGoal: (m['dailyGoal'] as int?) ?? 20,
      );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.highContrast == highContrast &&
      other.sound == sound &&
      other.haptics == haptics &&
      other.dailyGoal == dailyGoal;

  @override
  int get hashCode => Object.hash(highContrast, sound, haptics, dailyGoal);
}
