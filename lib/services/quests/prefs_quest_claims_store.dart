import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'quest_claims_store.dart';

/// On-device persistence for the quest-claims record (INC-QR1) via
/// shared_preferences. The record is a small `{day, ids}` object, so it
/// serialises to ONE JSON string under key `ratel.quests.claims` (an ISO
/// date-only plus a list of quest ids). Best-effort + honest: an absent OR
/// malformed/undecodable value loads as [QuestClaims.empty] (no fabricated
/// claim), never throws into the boot/earn path. Mirrors `PrefsLastReadStore`.
class PrefsQuestClaimsStore implements QuestClaimsStore {
  PrefsQuestClaimsStore(this._prefs);

  final SharedPreferences _prefs;

  static const String prefsKey = 'ratel.quests.claims';

  @override
  QuestClaims load() {
    final String? raw = _prefs.getString(prefsKey);
    if (raw == null || raw.isEmpty) return QuestClaims.empty;
    try {
      return QuestClaims.fromJson(jsonDecode(raw));
    } catch (_) {
      // Corrupt/legacy value ⇒ honest empty, never faked claims.
      return QuestClaims.empty;
    }
  }

  @override
  Future<void> save(QuestClaims claims) async {
    await _prefs.setString(prefsKey, jsonEncode(claims.toJson()));
  }
}
