import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/services/social/friend_quest.dart';

/// Portability seam (R-M3) over the co-op friend-quest RPCs [R-I9 / R-L8]
/// (`create_friend_quest` / `respond_friend_quest` / `refresh_friend_quest` /
/// `list_friend_quests`, all SECURITY DEFINER — every write authorized by the
/// caller's `auth.uid()`, R-K6). Default = the honest
/// [UnavailableFriendQuestService]: `list` is empty and every write is a no-op,
/// so a guest / friends-off build shows NO co-op quest (the honest coming-soon
/// card stays) and never fabricates a partner. Stage-3 plugs the Supabase impl
/// behind the SAME seam.
abstract interface class FriendQuestService {
  /// The caller's co-op quests (pending/active/completed) with live progress.
  Future<List<FriendQuest>> list();

  /// Invite [partnerHandle] to a co-op quest of [goal] combined lessons.
  Future<FriendQuest?> create(String partnerHandle, {int goal});

  /// Accept ([accept] = true) or decline an invited quest [questId].
  Future<FriendQuest?> respond(String questId, {required bool accept});

  /// Recompute live progress for [questId] (flips to completed at the goal).
  Future<FriendQuest?> refresh(String questId);

  /// Whether a REAL co-op backend is wired (Supabase). Honest default false ⇒
  /// the UI shows NO co-op surface (no invite entry, no fabricated quest) for
  /// guest / friends-off builds.
  bool get isAvailable;
}

/// Honest default: no co-op backend wired ⇒ nothing to show, nothing written.
class UnavailableFriendQuestService implements FriendQuestService {
  const UnavailableFriendQuestService();

  @override
  Future<List<FriendQuest>> list() async => const <FriendQuest>[];

  @override
  Future<FriendQuest?> create(String partnerHandle, {int goal = 12}) async =>
      null;

  @override
  Future<FriendQuest?> respond(String questId, {required bool accept}) async =>
      null;

  @override
  Future<FriendQuest?> refresh(String questId) async => null;

  @override
  bool get isAvailable => false;
}

/// The co-op friend-quest seam. Default honest no-op; overridden with the
/// Supabase impl in `backend_wiring.dart` when auth + keys are present (same
/// flagged go-live wiring as `friendsServiceProvider`).
final friendQuestServiceProvider = Provider<FriendQuestService>(
  (ref) => const UnavailableFriendQuestService(),
);
