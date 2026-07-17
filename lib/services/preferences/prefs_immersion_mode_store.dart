import 'package:shared_preferences/shared_preferences.dart';

import 'immersion_mode_store.dart';

/// SharedPreferences-backed [ImmersionModeStore] — key `ratel.immersionMode`, a
/// bare bool. Absent key = immersion off.
class PrefsImmersionModeStore implements ImmersionModeStore {
  PrefsImmersionModeStore(this._prefs);

  static const String prefsKey = 'ratel.immersionMode';

  final SharedPreferences _prefs;

  @override
  bool load() => _prefs.getBool(prefsKey) ?? false;

  @override
  Future<void> save(bool enabled) async {
    await _prefs.setBool(prefsKey, enabled);
  }
}
