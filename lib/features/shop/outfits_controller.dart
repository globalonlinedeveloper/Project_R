import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/features/learner/learner_controller.dart';
import 'package:ratel/services/economy/outfits.dart';
import 'package:ratel/services/economy/outfits_store.dart';

export 'package:ratel/services/economy/outfits.dart'
    show BadgerOutfit, OutfitCatalogue, OutfitState;

/// Bridges the cosmetic [OutfitState] to the UI + the device-local store seam
/// (E1 · R-I4 spend side). Buying debits the REAL 💎 wallet via
/// [LearnerController.trySpendDiamonds] and only then marks the outfit owned;
/// equipping is free. Holds only real ownership — nothing is granted for free
/// beyond the Classic badger.
class OutfitsController extends Notifier<OutfitState> {
  @override
  OutfitState build() => ref.read(outfitsStoreProvider).load();

  /// Buy [outfit]: debit its 💎 cost, then mark it owned + equip it. Returns
  /// whether the purchase happened — false (no-op) when already owned or
  /// unaffordable (the UI gates the control accordingly).
  bool buy(BadgerOutfit outfit) {
    if (state.isOwned(outfit.id)) return false;
    final bool paid =
        ref.read(learnerControllerProvider.notifier).trySpendDiamonds(outfit.cost);
    if (!paid) return false;
    final OutfitState next = state.copyWith(
      owned: <String>{...state.owned, outfit.id},
      selected: outfit.id,
    );
    state = next;
    ref.read(outfitsStoreProvider).save(next);
    return true;
  }

  /// Equip an already-owned outfit (free). No-op when not owned or already on.
  void equip(String id) {
    if (!state.isOwned(id) || state.selected == id) return;
    final OutfitState next = state.copyWith(selected: id);
    state = next;
    ref.read(outfitsStoreProvider).save(next);
  }
}

final outfitsControllerProvider =
    NotifierProvider<OutfitsController, OutfitState>(OutfitsController.new);

/// The currently equipped outfit (drives the Profile avatar). Recomputes when
/// the selection changes.
final equippedOutfitProvider = Provider<BadgerOutfit>(
    (ref) => OutfitCatalogue.byId(ref.watch(outfitsControllerProvider).selected));
