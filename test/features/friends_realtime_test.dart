// R-L11b — the friend_activity feed updates LIVE (no reload) via the store's
// realtime activityStream; a non-friend event is still filtered by the engine,
// and a guest / in-memory store (null stream) subscribes to nothing, so
// behaviour is byte-identical to the one-shot-load build.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/friends/friends_controller.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/social/friends.dart';

import 'auth/fake_identity.dart';

/// A FriendsStore whose [activityStream] is driven by a test [controller], so a
/// "realtime insert" is just `controller.add([...])`.
class _RealtimeStore implements FriendsStore {
  _RealtimeStore(this.relRows, this.controller);
  final List<Map<String, Object?>> relRows;
  final StreamController<List<Map<String, Object?>>> controller;

  @override
  Future<Map<String, Object?>> load(String userId) async => <String, Object?>{
        kFriendsRelationshipsKey: relRows,
        kFriendsActivityKey: const <Map<String, Object?>>[],
      };

  @override
  Future<void> save(String userId, Map<String, Object?> data) async {}

  @override
  Stream<List<Map<String, Object?>>>? activityStream(String userId) =>
      controller.stream;
}

Map<String, Object?> _friendRow(String h) => <String, Object?>{
      'friend_id': h,
      'handle': h,
      'display_name': h,
      'status': 'friends',
    };

Map<String, Object?> _activityRow(String actor, String type) =>
    <String, Object?>{
      'actor_id': actor,
      'actor_handle': actor,
      'actor_name': actor,
      'type': type,
      'summary': 'passed you this week',
      'at': '2026-06-30T18:00:00Z',
    };

ProviderContainer _signedIn(FriendsStore store) =>
    ProviderContainer(overrides: <Override>[
      identityProvider.overrideWithValue(FakeIdentity()),
      friendsStoreProvider.overrideWithValue(store),
      persistDebounceProvider.overrideWithValue(Duration.zero),
    ]);

void main() {
  test('R-L11b: a live friend_activity insert updates the feed with no reload',
      () async {
    final ctrl = StreamController<List<Map<String, Object?>>>.broadcast();
    addTearDown(ctrl.close);
    final store =
        _RealtimeStore(<Map<String, Object?>>[_friendRow('alice')], ctrl);
    final c = _signedIn(store);
    addTearDown(c.dispose);

    c.read(friendsControllerProvider); // build → rehydrate + subscribe
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(c.read(friendFeedProvider), isEmpty);

    // A new event from the friend arrives over realtime — no reload.
    ctrl.add(<Map<String, Object?>>[_activityRow('alice', 'passedYouInLeague')]);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final List<FriendActivity> feed = c.read(friendFeedProvider);
    expect(feed, hasLength(1));
    expect(feed.first.type, FriendActivityType.passedYouInLeague);
    expect(feed.first.actorId, 'alice');
  });

  test('a non-friend live event is filtered out (engine.feed honesty)',
      () async {
    final ctrl = StreamController<List<Map<String, Object?>>>.broadcast();
    addTearDown(ctrl.close);
    final store =
        _RealtimeStore(<Map<String, Object?>>[_friendRow('alice')], ctrl);
    final c = _signedIn(store);
    addTearDown(c.dispose);
    c.read(friendsControllerProvider);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    ctrl.add(<Map<String, Object?>>[_activityRow('stranger', 'leveledUp')]);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(c.read(friendFeedProvider), isEmpty); // stranger is not a friend
  });

  test('the in-memory store exposes no realtime stream (byte-identical no-op)',
      () {
    expect(InMemoryFriendsStore().activityStream('me'), isNull);
  });

  test('a GUEST subscribes to nothing (no session => no live feed)', () async {
    final ctrl = StreamController<List<Map<String, Object?>>>.broadcast();
    addTearDown(ctrl.close);
    final store = _RealtimeStore(const <Map<String, Object?>>[], ctrl);
    // No identity override => guest (uid == null).
    final c = ProviderContainer(overrides: <Override>[
      friendsStoreProvider.overrideWithValue(store),
      persistDebounceProvider.overrideWithValue(Duration.zero),
    ]);
    addTearDown(c.dispose);
    c.read(friendsControllerProvider);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    ctrl.add(<Map<String, Object?>>[_activityRow('alice', 'streak')]);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(c.read(friendFeedProvider), isEmpty);
    expect(c.read(friendsControllerProvider).loaded, isFalse);
  });
}
