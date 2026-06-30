import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The result of routing a friend request / response to the OTHER user's
/// account — the cross-user half that own-row persistence cannot do
/// [R-I9 / R-L8].
enum FriendDeliveryOutcome {
  /// Routed to the other account (their incoming row was written).
  delivered,

  /// Resolved to a mutual accept — now friends on both sides.
  friends,

  /// Cleared on both sides (a decline removed the request).
  cleared,

  /// No durable backend is wired (guest / un-configured build): the local
  /// optimistic update stands, but nothing was routed to the other person.
  unavailable,

  /// The @handle did not resolve to a real account.
  notFound,

  /// The caller has not claimed their own @handle yet (needed for the
  /// reciprocal row).
  needsHandle,

  /// A genuine backend error.
  failed,
}

/// Immutable outcome + an honest, user-facing message. Never fabricates success.
class FriendDeliveryResult {
  const FriendDeliveryResult(this.outcome, {this.message, this.status});

  final FriendDeliveryOutcome outcome;

  /// Honest note to surface to the learner (null ⇒ caller picks a default).
  final String? message;

  /// The authoritative `FriendStatus` name the server settled on, when known
  /// (e.g. `requestOutgoing`, `friends`, `none`).
  final String? status;

  /// True only when the call actually routed to the other account.
  bool get ok =>
      outcome == FriendDeliveryOutcome.delivered ||
      outcome == FriendDeliveryOutcome.friends ||
      outcome == FriendDeliveryOutcome.cleared;
}

/// Portability seam (R-M3) over the cross-user social RPCs [R-I9 / R-L8]. The
/// Friends controller calls this to DELIVER a request / accept / decline to the
/// OTHER user's account — the half the own-row [FriendsStore] cannot reach.
/// Default = the honest [UnavailableFriendsService]: every call returns
/// `unavailable`, so a local / guest build behaves byte-identically to before
/// (the optimistic graph still persists own-row; nothing is routed). Stage-3
/// plugs the Supabase `SECURITY DEFINER` RPCs behind the SAME seam, every write
/// still authorized by the caller's `auth.uid()` (R-K6).
abstract interface class FriendsService {
  /// Send a friend request to [targetHandle]: the definer RPC resolves the
  /// handle → uid and writes the recipient's incoming row.
  Future<FriendDeliveryResult> sendRequest(String targetHandle);

  /// Accept ([accept] = true) or decline an incoming request from
  /// [requesterHandle], mirroring BOTH sides.
  Future<FriendDeliveryResult> respond(String requesterHandle,
      {required bool accept});

  /// Claim / change the caller's own public @handle (own-row profile write) so
  /// other learners can add them. Returns the normalized handle on success.
  Future<FriendDeliveryResult> setHandle(String desiredHandle);
}

/// Default (local / guest / un-configured build): no backend, so nothing can be
/// routed to another account. Honest — never fabricates a delivery.
class UnavailableFriendsService implements FriendsService {
  const UnavailableFriendsService();

  static const FriendDeliveryResult _unavailable = FriendDeliveryResult(
    FriendDeliveryOutcome.unavailable,
    message: 'Sign in to connect with other learners.',
  );

  @override
  Future<FriendDeliveryResult> sendRequest(String targetHandle) async =>
      _unavailable;

  @override
  Future<FriendDeliveryResult> respond(String requesterHandle,
          {required bool accept}) async =>
      _unavailable;

  @override
  Future<FriendDeliveryResult> setHandle(String desiredHandle) async =>
      _unavailable;
}

/// Inject the social-delivery seam. Stage-3 overrides this with the
/// Supabase-backed service when auth is on and the keys are present.
final friendsServiceProvider =
    Provider<FriendsService>((ref) => const UnavailableFriendsService());
