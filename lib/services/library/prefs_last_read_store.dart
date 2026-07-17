import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'last_read_store.dart';

/// On-device persistence for the LAST-READ pointer (s163 INC-C1) via
/// shared_preferences. The pointer has four small fields, so — unlike the
/// adventure explored-SET's CSV — it serialises to ONE JSON string under key
/// `ratel.library.lastRead` (JSON keeps the fields unambiguous). Best-effort +
/// honest: an absent OR malformed/undecodable value loads as `null` (no
/// fabricated pointer), never throws into the boot path. Mirrors
/// `PrefsAdventureProgressStore` / `PrefsImmersionModeStore`.
class PrefsLastReadStore implements LastReadStore {
  PrefsLastReadStore(this._prefs);

  final SharedPreferences _prefs;

  static const String prefsKey = 'ratel.library.lastRead';

  @override
  LastReadRef? load() {
    final String? raw = _prefs.getString(prefsKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return LastReadRef.fromJson(jsonDecode(raw));
    } catch (_) {
      // Corrupt/legacy value ⇒ honest null, never a faked pointer.
      return null;
    }
  }

  @override
  Future<void> save(LastReadRef ref) async {
    await _prefs.setString(prefsKey, jsonEncode(ref.toJson()));
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(prefsKey);
  }
}
