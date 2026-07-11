import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persistence seam for the device-local adventure exploration set (L-4 —
/// design §4.12 explored progress). Holds the content `scenario_id`s the
/// learner has EXPLORED — i.e. genuinely reached an ending of, in the player —
/// never a fabricated backfill. Synchronous [load] keeps controller
/// construction test-friendly; the real `PrefsAdventureProgressStore` reads
/// the platform store once at boot (mirrors `EarnedStampsStore`).
///
/// Device-local for everyone (guest included) — the synced `user_settings`
/// row is fixed-column, so a cross-device column is a separate owner-gated
/// migration (S126 precedent, same home as xpHistory/earnedAt).
abstract class AdventureProgressStore {
  Set<String> load();
  Future<void> save(Set<String> explored);
}

/// Default — in-memory (tests + keyless boots, R-O1). A
/// `PrefsAdventureProgressStore` override in `main` gives real on-device
/// persistence.
class InMemoryAdventureProgressStore implements AdventureProgressStore {
  InMemoryAdventureProgressStore([Set<String>? initial])
      : _explored = <String>{...?initial};

  Set<String> _explored;

  /// The most recently saved value (handy for tests).
  Set<String> get current => <String>{..._explored};

  @override
  Set<String> load() => <String>{..._explored};

  @override
  Future<void> save(Set<String> explored) async {
    _explored = <String>{...explored};
  }
}

/// The adventure-progress persistence seam. Defaults to in-memory; `main`
/// overrides it with a `PrefsAdventureProgressStore` for real on-device
/// persistence.
final adventureProgressStoreProvider =
    Provider<AdventureProgressStore>((ref) => InMemoryAdventureProgressStore());
