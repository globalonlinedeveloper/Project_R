// R-I9 / R-L8 / R-L11 — the Friends controller DELIVERS cross-user mutations
// through the FriendsService seam on a real session (incl. a `joined` activity
// emit when a friendship forms on accept), and stays purely local for a guest.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/friends/friends_controller.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/social/friends.dart';
import 'package:ratel/services/social/friends_service.dart';

class _RecordingService implements FriendsService {
  final List<String> sent = <String>[];
  final List<(String, bool)> responded = <(String, bool)>[];
  final List<String> handles = <String>[];
  final List<(String, bool)> removed = <(String, bool)>[];
  final List<(String, String, List<String>?)> emitted =
      <(String, String, List<String>?)>[];

  @override
  Future<FriendDeliveryResult> sendRequest(String targetHandle) async {
    sent.add(targetHandle);
    return const FriendDeliveryResult(FriendDeliveryOutcome.delivered);
  }

  @override
  Future<FriendDeliveryResult> respond(String requesterHandle,
      {required bool accept}) async {
    responded.add((requesterHandle, accept));
    // Mirror the real RPC: an accept settles to `friends`, a decline clears.
    return FriendDeliveryResult(
        accept ? FriendDeliveryOutcome.friends : FriendDeliveryOutcome.cleared);
  }

  @override
  Future<FriendDeliveryResult> setHandle(String desiredHandle) async {
    handles.add(desiredHandle);
    return const FriendDeliveryResult(FriendDeliveryOutcome.delivered);
  }

  @override
  Future<FriendDeliveryResult> removeFriend(String otherHandle,
      {required bool block}) async {
    removed.add((otherHandle, block));
    return const FriendDeliveryResult(FriendDeliveryOutcome.cleared);
  }

  @override
  Future<FriendDeliveryResult> emitActivity(String activityType,
      {String summary = '', List<String>? targets}) async {
    emitted.add((activityType, summary, targets));
    return const FriendDeliveryResult(FriendDeliveryOutcome.delivered);
  }

  @override
  Future<FriendDeliveryResult> publishWeeklyXp(int weeklyXp) async =>
      const FriendDeliveryResult(FriendDeliveryOutcome.delivered);
}

class _SignedInIdentity implements Identity {
  @override
  String? get uid => 'u1';
  @override
  bool get isAuthenticated => true;
  @override
  Future<void> claimAnonymousState(AnonymousClaimToken token) async =>
      throw UnimplementedError();
  @override
  Future<AnonymousClaimToken?> mintClaimToken() async => null;
}

const FriendRecord _mia = FriendRecord(
  userId: 'mia',
  handle: 'mia',
  displayName: '@mia',
  status: FriendStatus.none,
);

void main() {
  test(
      'a signed-in learner DELIVERS send/accept/decline/remove/block, and '
      'emits a targeted joined activity to the new friend on accept', () async {
    final svc = _RecordingService();
    final container = ProviderContainer(overrides: <Override>[
      identityProvider.overrideWithValue(_SignedInIdentity()),
      friendsServiceProvider.overrideWithValue(svc),
      persistDebounceProvider.overrideWithValue(Duration.zero),
    ]);
    addTearDown(container.dispose);

    final c = container.read(friendsControllerProvider.notifier);
    c.sendRequest(_mia);
    c.accept('mia');
    c.decline('bob');
    c.remove('mia');
    c.block('bob');
    await Future<void>.delayed(Duration.zero); // let chained deliveries run

    expect(svc.sent, <String>['mia']);
    expect(svc.responded, <(String, bool)>[('mia', true), ('bob', false)]);
    expect(svc.removed, <(String, bool)>[('mia', false), ('bob', true)]);
    // accept('mia') settled to friends ⇒ exactly one targeted `joined` to mia;
    // the decline did NOT emit.
    expect(svc.emitted.length, 1);
    final e = svc.emitted.single;
    expect(e.$1, 'joined');
    expect(e.$2, 'is now your friend');
    expect(e.$3, <String>['mia']);
  });

  test('a guest routes NOTHING (no session ⇒ no delivery, no activity emit)',
      () async {
    final svc = _RecordingService();
    final container = ProviderContainer(overrides: <Override>[
      friendsServiceProvider.overrideWithValue(svc),
      persistDebounceProvider.overrideWithValue(Duration.zero),
    ]);
    addTearDown(container.dispose);

    final c = container.read(friendsControllerProvider.notifier);
    c.sendRequest(_mia);
    c.accept('mia');
    c.remove('mia');
    c.block('bob');
    await Future<void>.delayed(Duration.zero);

    expect(svc.sent, isEmpty);
    expect(svc.responded, isEmpty);
    expect(svc.removed, isEmpty);
    expect(svc.emitted, isEmpty);
  });
}
