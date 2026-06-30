import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'outfits.dart';

/// Persistence seam for the device-local badger-outfit [OutfitState] (E1).
/// Synchronous [load] keeps controller construction test-friendly (mirrors
/// `SettingsStore` / `XpHistoryStore`).
abstract class OutfitsStore {
  OutfitState load();
  Future<void> save(OutfitState state);
}

/// Default — in-memory (tests + keyless boots, R-O1). A `PrefsOutfitsStore`
/// override in `main` gives real on-device persistence.
class InMemoryOutfitsStore implements OutfitsStore {
  InMemoryOutfitsStore([OutfitState? initial]) : _state = initial ?? OutfitState();

  OutfitState _state;

  /// The most recently saved value (handy for tests).
  OutfitState get current => _state;

  @override
  OutfitState load() => _state;

  @override
  Future<void> save(OutfitState state) async {
    _state = state;
  }
}

/// The outfits persistence seam. Defaults to in-memory; `main` overrides it with
/// a `PrefsOutfitsStore`.
final outfitsStoreProvider =
    Provider<OutfitsStore>((ref) => InMemoryOutfitsStore());
