import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/services/adventures/adventure_progress_store.dart';
import 'package:ratel/services/adventures/exploration.dart';

export 'package:ratel/services/adventures/adventure_progress_store.dart'
    show
        AdventureProgressStore,
        InMemoryAdventureProgressStore,
        adventureProgressStoreProvider;
export 'package:ratel/services/adventures/exploration.dart'
    show AdventureRef, AdventureDistrict, AdventureExplorationEngine;

/// Bridges the pure [AdventureExplorationEngine] to the device-local explored
/// store (L-4 — design §4.12 districts + explored progress). Holds the set of
/// content `scenario_id`s the learner has genuinely explored — marked ONLY
/// when the player reaches an authored ENDING scene, never on open, never
/// backfilled. Device-local for everyone (guest included) — mirrors
/// `EarnedStampsController`, not the uid-gated `user_course`.
class AdventureProgressController extends Notifier<Set<String>> {
  static const AdventureExplorationEngine _engine =
      AdventureExplorationEngine();

  @override
  Set<String> build() => ref.read(adventureProgressStoreProvider).load();

  /// Mark [scenarioId] explored. Returns true when this was a FIRST
  /// exploration (the once-per-adventure reward crossing, design §4.12);
  /// false — and a state no-op — when it was already explored.
  bool markExplored(String scenarioId) {
    if (!_engine.isNewlyExplored(state, scenarioId)) return false;
    final Set<String> next = <String>{...state, scenarioId};
    state = next;
    // Best-effort device-local write; never blocks the player flow.
    ref.read(adventureProgressStoreProvider).save(next);
    return true;
  }

  /// District projection over [refs] with the current explored set.
  List<AdventureDistrict> districts(List<AdventureRef> refs) =>
      _engine.districts(refs, state);
}

final adventureProgressControllerProvider =
    NotifierProvider<AdventureProgressController, Set<String>>(
        AdventureProgressController.new);
