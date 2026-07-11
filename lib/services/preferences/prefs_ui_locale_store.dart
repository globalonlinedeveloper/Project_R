import 'package:shared_preferences/shared_preferences.dart';

import 'ui_locale_store.dart';

/// SharedPreferences-backed [UiLocaleStore] — key `ratel.uiLocale`, a bare
/// language code. Absent key = no override (follow the device locale).
class PrefsUiLocaleStore implements UiLocaleStore {
  PrefsUiLocaleStore(this._prefs);

  static const String prefsKey = 'ratel.uiLocale';

  final SharedPreferences _prefs;

  @override
  String? load() => _prefs.getString(prefsKey);

  @override
  Future<void> save(String? languageCode) async {
    if (languageCode == null) {
      await _prefs.remove(prefsKey);
    } else {
      await _prefs.setString(prefsKey, languageCode);
    }
  }
}
