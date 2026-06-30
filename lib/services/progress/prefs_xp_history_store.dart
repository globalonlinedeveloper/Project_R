import 'package:shared_preferences/shared_preferences.dart';

import 'xp_history.dart';
import 'xp_history_store.dart';

/// On-device persistence for the per-day XP history via shared_preferences. The
/// whole map serialises to ONE string key as `YYYY-MM-DD:xp` pairs joined by
/// commas (mirrors the `PrefsSettingsStore` CSV pattern). Best-effort: a missing
/// / malformed / non-positive entry is skipped, never faked.
class PrefsXpHistoryStore implements XpHistoryStore {
  PrefsXpHistoryStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _kHistory = 'ratel.progress.xpHistory';

  @override
  Map<String, int> load() {
    final String? csv = _prefs.getString(_kHistory);
    if (csv == null || csv.isEmpty) return <String, int>{};
    final Map<String, int> out = <String, int>{};
    for (final String pair in csv.split(',')) {
      if (pair.isEmpty) continue;
      final int sep = pair.indexOf(':');
      if (sep <= 0) continue;
      final String key = pair.substring(0, sep);
      if (XpHistoryModel.parseKey(key) == null) continue;
      final int? xp = int.tryParse(pair.substring(sep + 1));
      if (xp == null || xp <= 0) continue;
      out[key] = xp;
    }
    return out;
  }

  @override
  Future<void> save(Map<String, int> history) async {
    final List<String> keys = history.keys.toList()..sort();
    final String csv = <String>[
      for (final String k in keys)
        if ((history[k] ?? 0) > 0) '$k:${history[k]}',
    ].join(',');
    await _prefs.setString(_kHistory, csv);
  }
}
