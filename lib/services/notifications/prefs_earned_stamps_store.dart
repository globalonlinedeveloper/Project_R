import 'package:shared_preferences/shared_preferences.dart';

import 'earned_stamps_store.dart';

/// On-device persistence for the notification earn-time stamps via
/// shared_preferences. The whole map serialises to ONE string key as
/// `id@epochMillisUtc` pairs joined by commas — catalogue ids contain `:` but
/// never `@` or `,`, so the split is unambiguous (mirrors the
/// `PrefsXpHistoryStore` CSV pattern). Best-effort: a malformed entry is
/// skipped, never faked.
class PrefsEarnedStampsStore implements EarnedStampsStore {
  PrefsEarnedStampsStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _kStamps = 'ratel.notifications.earnedAt';

  @override
  Map<String, DateTime> load() {
    final String? csv = _prefs.getString(_kStamps);
    if (csv == null || csv.isEmpty) return <String, DateTime>{};
    final Map<String, DateTime> out = <String, DateTime>{};
    for (final String pair in csv.split(',')) {
      if (pair.isEmpty) continue;
      final int sep = pair.lastIndexOf('@');
      if (sep <= 0) continue;
      final String id = pair.substring(0, sep);
      final int? ms = int.tryParse(pair.substring(sep + 1));
      if (ms == null || ms <= 0) continue;
      out[id] = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    }
    return out;
  }

  @override
  Future<void> save(Map<String, DateTime> stamps) async {
    final List<String> ids = stamps.keys.toList()..sort();
    final String csv = <String>[
      for (final String id in ids)
        '$id@${stamps[id]!.toUtc().millisecondsSinceEpoch}',
    ].join(',');
    await _prefs.setString(_kStamps, csv);
  }
}
