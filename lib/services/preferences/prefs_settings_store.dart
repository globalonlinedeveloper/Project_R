import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';
import 'settings_store.dart';

/// On-device persistence for [AppSettings] via shared_preferences. The
/// [SharedPreferences] instance is loaded ONCE in `main` (async) and handed in,
/// so [load]/[save] stay synchronous-friendly for the controller. Best-effort:
/// if the platform store is unavailable, `main` falls back to in-memory.
class PrefsSettingsStore implements SettingsStore {
  PrefsSettingsStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _kHighContrast = 'ratel.settings.highContrast';
  static const String _kSound = 'ratel.settings.sound';
  static const String _kHaptics = 'ratel.settings.haptics';
  static const String _kDailyGoal = 'ratel.settings.dailyGoal';
  static const String _kThemeMode = 'ratel.settings.themeMode';

  @override
  AppSettings load() => AppSettings.fromMap(<String, Object?>{
        'highContrast': _prefs.getBool(_kHighContrast),
        'sound': _prefs.getBool(_kSound),
        'haptics': _prefs.getBool(_kHaptics),
        'dailyGoal': _prefs.getInt(_kDailyGoal),
        'themeMode': _prefs.getString(_kThemeMode),
      });

  @override
  Future<void> save(AppSettings s) async {
    await _prefs.setBool(_kHighContrast, s.highContrast);
    await _prefs.setBool(_kSound, s.sound);
    await _prefs.setBool(_kHaptics, s.haptics);
    await _prefs.setInt(_kDailyGoal, s.dailyGoal);
    await _prefs.setString(_kThemeMode, s.themeMode.name);
  }
}
