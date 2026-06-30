import 'package:shared_preferences/shared_preferences.dart';

import 'outfits.dart';
import 'outfits_store.dart';

/// On-device persistence for the badger-outfit [OutfitState] via
/// shared_preferences: the owned ids as a comma list + the selected id. The
/// selection falls back to 'classic' when it is not (or no longer) owned.
class PrefsOutfitsStore implements OutfitsStore {
  PrefsOutfitsStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _kOwned = 'ratel.outfits.owned';
  static const String _kSelected = 'ratel.outfits.selected';

  @override
  OutfitState load() {
    final String? owned = _prefs.getString(_kOwned);
    final Set<String> set = <String>{
      'classic',
      if (owned != null)
        for (final String id in owned.split(','))
          if (id.isNotEmpty) id,
    };
    final String selected = _prefs.getString(_kSelected) ?? 'classic';
    return OutfitState(
      owned: set,
      selected: set.contains(selected) ? selected : 'classic',
    );
  }

  @override
  Future<void> save(OutfitState s) async {
    await _prefs.setString(_kOwned, (s.owned.toList()..sort()).join(','));
    await _prefs.setString(_kSelected, s.selected);
  }
}
