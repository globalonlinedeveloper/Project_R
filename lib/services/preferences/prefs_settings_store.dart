import 'package:shared_preferences/shared_preferences.dart';

import '../../core/design_system/world/app_settings.dart';
import 'settings_store.dart';

/// On-device persistence for [AppSettings] via shared_preferences. The
/// [SharedPreferences] instance is loaded ONCE in `main` (async) and handed in,
/// so [load]/[save] stay synchronous-friendly for the controller. Best-effort:
/// if the platform store is unavailable, `main` falls back to in-memory.
class PrefsSettingsStore implements SettingsStore {
  PrefsSettingsStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _kWorld = 'ratel.settings.world';
  static const String _kMotion = 'ratel.settings.motion';
  static const String _kHighContrast = 'ratel.settings.highContrast';
  static const String _kSound = 'ratel.settings.sound';
  static const String _kHaptics = 'ratel.settings.haptics';

  @override
  AppSettings load() => AppSettings.fromMap(<String, Object?>{
        'world': _prefs.getString(_kWorld),
        'motion': _prefs.getString(_kMotion),
        'highContrast': _prefs.getBool(_kHighContrast),
        'sound': _prefs.getBool(_kSound),
        'haptics': _prefs.getBool(_kHaptics),
      });

  @override
  Future<void> save(AppSettings s) async {
    await _prefs.setString(_kWorld, s.world.name);
    await _prefs.setString(_kMotion, s.motion.name);
    await _prefs.setBool(_kHighContrast, s.highContrast);
    await _prefs.setBool(_kSound, s.sound);
    await _prefs.setBool(_kHaptics, s.haptics);
  }
}
