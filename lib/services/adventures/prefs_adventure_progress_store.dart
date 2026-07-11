import 'package:shared_preferences/shared_preferences.dart';

import 'adventure_progress_store.dart';

/// On-device persistence for the adventure exploration set via
/// shared_preferences. The set serialises to ONE string key as scenario ids
/// joined by commas — authored `scenario_id`s (`scenario_en_a1_adv`) carry
/// `_` but never `,`, so the split is unambiguous (mirrors the
/// `PrefsEarnedStampsStore` CSV pattern). Best-effort: an empty fragment is
/// skipped, never faked.
class PrefsAdventureProgressStore implements AdventureProgressStore {
  PrefsAdventureProgressStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _kExplored = 'ratel.adventures.explored';

  @override
  Set<String> load() {
    final String? csv = _prefs.getString(_kExplored);
    if (csv == null || csv.isEmpty) return <String>{};
    return <String>{
      for (final String id in csv.split(','))
        if (id.isNotEmpty) id,
    };
  }

  @override
  Future<void> save(Set<String> explored) async {
    final List<String> ids = explored.toList()..sort();
    await _prefs.setString(_kExplored, ids.join(','));
  }
}
