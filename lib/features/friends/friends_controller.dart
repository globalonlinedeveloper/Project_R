import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/services/data_access/data_access.dart'
    show friendsStoreProvider, persistDebounceProvider, FriendsStore,
        kFriendsRelationshipsKey, kFriendsActivityKey;
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/social/friends.dart';
import 'package:ratel/services/social/friends_service.dart';

/// Immutable view of the learner's social graph.
class FriendsState {
  const FriendsState({
    this.relationships = const <FriendRecord>[],
    this.activity = const <FriendActivity>[],
    this.loaded = false,
  });

  /// Every relationship row the learner owns (any [FriendStatus]).
  final List<FriendRecord> relationships;

  /// Friends' activity events (load-only; produced by friends).
  final List<FriendActivity> activity;

  /// True once the durable store has been read (false while a guest / loading).
  final bool loaded;

  FriendsState copyWith({
    List<FriendRecord>? relationships,
    List<FriendActivity>? activity,
    bool? loaded,
  }) =>
      FriendsState(
        relationships: relationships ?? this.relationships,
        activity: activity ?? this.activity,
        loaded: loaded ?? this.loaded,
      );
}

/// Bridges the pure [FriendsEngine] + the durable [FriendsStore] seam to the
/// Friends UI [R-I9 / R-L8]. Honesty (charter "don't fake depth", mirroring the
/// Leagues solo-cohort): a guest — or any learner with no friends yet — sees a
/// genuinely EMPTY graph, never a fabricated friend. On a real `auth.uid()`
/// session it REHYDRATES relationships from the store on first build and WRITES
/// THROUGH (debounced) every mutation; with no session the store/identity
/// defaults make load + save no-ops, so flag-off behaviour is byte-identical to
/// the in-memory build (the durable cross-user graph is the go-live wiring).
class FriendsController extends Notifier<FriendsState> {
  /// The shared pure engine (state-free, clockless).
  static const FriendsEngine engine = FriendsEngine();

  bool _disposed = false;
  Timer? _debounce;

  @override
  FriendsState build() {
    ref.onDispose(() {
      _disposed = true;
      _debounce?.cancel();
    });
    _rehydrate();
    return const FriendsState();
  }

  Future<void> _rehydrate() async {
    final String? uid = ref.read(identityProvider).uid;
    if (uid == null) return; // guest → honest empty graph
    final FriendsStore store = ref.read(friendsStoreProvider);
    final Map<String, Object?> data = await store.load(uid);
    if (_disposed) return;
    final List<Object?> rels =
        (data[kFriendsRelationshipsKey] as List<Object?>?) ?? const <Object?>[];
    final List<Object?> acts =
        (data[kFriendsActivityKey] as List<Object?>?) ?? const <Object?>[];
    state = FriendsState(
      relationships: rels
          .whereType<Map<Object?, Object?>>()
          .map((Map<Object?, Object?> m) =>
              FriendRecord.fromRow(Map<String, Object?>.from(m)))
          .toList(),
      activity: acts
          .whereType<Map<Object?, Object?>>()
          .map((Map<Object?, Object?> m) =>
              FriendActivity.fromRow(Map<String, Object?>.from(m)))
          .toList(),
      loaded: true,
    );
  }

  void _set(List<FriendRecord> relationships) {
    state = state.copyWith(relationships: relationships, loaded: true);
    _persist();
  }

  /// Send a friend request to [target] (no-op on self / a duplicate). The
  /// local optimistic row is added immediately; on a real session the request
  /// is also DELIVERED to the other account via the cross-user RPC (R-I9/R-L8).
  void sendRequest(FriendRecord target) {
    _set(engine.applySendRequest(state.relationships, target));
    _deliver(() async {
      final FriendDeliveryResult r =
          await ref.read(friendsServiceProvider).sendRequest(target.handle);
      // If the request immediately resolved to a mutual friendship (they had
      // already requested us), announce the `joined` to them too.
      if (r.outcome == FriendDeliveryOutcome.friends) {
        await ref.read(friendsServiceProvider).emitActivity(
            FriendActivityType.joined.name,
            summary: 'is now your friend',
            targets: <String>[target.handle]);
      }
      return r;
    });
  }

  /// Accept an incoming request → friends (delivered to the requester too).
  void accept(String userId) {
    _set(engine.applyAccept(state.relationships, userId));
    _deliver(() async {
      final FriendDeliveryResult r =
          await ref.read(friendsServiceProvider).respond(userId, accept: true);
      // A confirmed friendship → announce a real `joined` event to the new
      // friend's feed (R-L11), targeted (never broadcast).
      if (r.outcome == FriendDeliveryOutcome.friends) {
        await ref.read(friendsServiceProvider).emitActivity(
            FriendActivityType.joined.name,
            summary: 'is now your friend',
            targets: <String>[userId]);
      }
      return r;
    });
  }

  /// Decline an incoming request → removed (cleared on the requester too).
  void decline(String userId) {
    _set(engine.applyDecline(state.relationships, userId));
    _deliver(() =>
        ref.read(friendsServiceProvider).respond(userId, accept: false));
  }

  /// Remove a friend or cancel an outgoing request. The local row drops
  /// immediately; on a real session the removal is also PROPAGATED to the other
  /// account via the cross-user RPC, so they no longer keep a stale row.
  void remove(String userId) {
    _set(engine.applyRemove(state.relationships, userId));
    _deliver(() =>
        ref.read(friendsServiceProvider).removeFriend(userId, block: false));
  }

  /// Block a user (hidden; cannot be re-requested). Clears the relationship on
  /// BOTH sides and leaves the caller's own 'blocked' row (delivered server-side
  /// too, so the blocked user can no longer reach the learner).
  void block(String userId) {
    _set(engine.applyBlock(state.relationships, userId));
    _deliver(() =>
        ref.read(friendsServiceProvider).removeFriend(userId, block: true));
  }

  /// Report then block a user (R-I9 block/report) — the report routes to
  /// moderation when the durable graph goes live; locally it blocks so the
  /// learner stops seeing them immediately.
  void report(String userId) => block(userId);

  /// Fire a cross-user DELIVERY (R-I9/R-L8) for the just-applied local
  /// mutation — ONLY when signed in (a guest has nobody to route to). It is
  /// fire-and-forget: the optimistic local state + own-row persist already
  /// stand, so a delivery hiccup never blocks the UI, and the authoritative
  /// server state reconciles on the next load. With no session — or the default
  /// [UnavailableFriendsService] — this is a no-op, so behaviour is unchanged.
  void _deliver(Future<FriendDeliveryResult> Function() op) {
    if (ref.read(identityProvider).uid == null) return;
    unawaited(op());
  }

  void _persist() {
    if (ref.read(identityProvider).uid == null) return;
    _debounce?.cancel();
    final Duration debounce = ref.read(persistDebounceProvider);
    _debounce = Timer(debounce, () async {
      if (_disposed) return;
      final String? uid = ref.read(identityProvider).uid;
      if (uid == null) return;
      final FriendsStore store = ref.read(friendsStoreProvider);
      await store.save(uid, <String, Object?>{
        kFriendsRelationshipsKey:
            state.relationships.map((FriendRecord r) => r.toRow()).toList(),
      });
    });
  }
}

final friendsControllerProvider =
    NotifierProvider<FriendsController, FriendsState>(FriendsController.new);

/// Accepted friends, alphabetical.
final friendsListProvider = Provider<List<FriendRecord>>((ref) =>
    FriendsController.engine
        .friends(ref.watch(friendsControllerProvider).relationships));

/// Requests awaiting the learner's accept.
final incomingRequestsProvider = Provider<List<FriendRecord>>((ref) =>
    FriendsController.engine
        .incoming(ref.watch(friendsControllerProvider).relationships));

/// Requests the learner sent, awaiting accept.
final outgoingRequestsProvider = Provider<List<FriendRecord>>((ref) =>
    FriendsController.engine
        .outgoing(ref.watch(friendsControllerProvider).relationships));

/// The activity feed: friends' events, newest first.
final friendFeedProvider = Provider<List<FriendActivity>>((ref) {
  final FriendsState s = ref.watch(friendsControllerProvider);
  return FriendsController.engine.feed(s.activity, s.relationships);
});

/// Friends who overtook the learner in this week's league ("passed you").
final whoPassedMeProvider = Provider<List<FriendRecord>>((ref) {
  final FriendsState s = ref.watch(friendsControllerProvider);
  final int myWeeklyXp = ref.watch(learnerControllerProvider).xpWeekEarned;
  return FriendsController.engine.whoPassedMe(myWeeklyXp, s.relationships);
});
