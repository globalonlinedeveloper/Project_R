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
  static const String _kReadNotifications = 'ratel.settings.readNotifications';
  static const String _kRecentSearches = 'ratel.settings.recentSearches';
  static const String _kReduceMotion = 'ratel.settings.reduceMotion';
  static const String _kMutedNotifications = 'ratel.settings.mutedNotifications';

  @override
  AppSettings load() => AppSettings.fromMap(<String, Object?>{
        'highContrast': _prefs.getBool(_kHighContrast),
        'sound': _prefs.getBool(_kSound),
        'haptics': _prefs.getBool(_kHaptics),
        'dailyGoal': _prefs.getInt(_kDailyGoal),
        'themeMode': _prefs.getString(_kThemeMode),
        'readNotifications': _prefs.getString(_kReadNotifications),
        'recentSearches': _prefs.getString(_kRecentSearches),
        'reduceMotion': _prefs.getBool(_kReduceMotion),
        'mutedNotifications': _prefs.getString(_kMutedNotifications),
      });

  @override
  Future<void> save(AppSettings s) async {
    await _prefs.setBool(_kHighContrast, s.highContrast);
    await _prefs.setBool(_kSound, s.sound);
    await _prefs.setBool(_kHaptics, s.haptics);
    await _prefs.setInt(_kDailyGoal, s.dailyGoal);
    await _prefs.setString(_kThemeMode, s.themeMode.name);
    await _prefs.setString(
        _kReadNotifications, (s.readNotifications.toList()..sort()).join(','));
    await _prefs.setString(
        _kRecentSearches, s.recentSearches.map(Uri.encodeComponent).join(','));
    await _prefs.setBool(_kReduceMotion, s.reduceMotion);
    await _prefs.setString(
        _kMutedNotifications, (s.mutedNotifications.toList()..sort()).join(','));
  }
}
