// R-I9 / R-L8 — the Friends controller DELIVERS cross-user mutations through the
// FriendsService seam on a real session, and stays purely local for a guest.
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

  @override
  Future<FriendDeliveryResult> sendRequest(String targetHandle) async {
    sent.add(targetHandle);
    return const FriendDeliveryResult(FriendDeliveryOutcome.delivered);
  }

  @override
  Future<FriendDeliveryResult> respond(String requesterHandle,
      {required bool accept}) async {
    responded.add((requesterHandle, accept));
    return const FriendDeliveryResult(FriendDeliveryOutcome.delivered);
  }

  @override
  Future<FriendDeliveryResult> setHandle(String desiredHandle) async {
    handles.add(desiredHandle);
    return const FriendDeliveryResult(FriendDeliveryOutcome.delivered);
  }
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
  test('a signed-in learner DELIVERS send / accept / decline via the service',
      () {
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

    expect(svc.sent, <String>['mia']);
    expect(svc.responded, <(String, bool)>[('mia', true), ('bob', false)]);
  });

  test('a guest routes NOTHING (no session ⇒ delivery is skipped)', () {
    final svc = _RecordingService();
    final container = ProviderContainer(overrides: <Override>[
      // identityProvider stays the default AnonymousIdentity (uid == null).
      friendsServiceProvider.overrideWithValue(svc),
      persistDebounceProvider.overrideWithValue(Duration.zero),
    ]);
    addTearDown(container.dispose);

    final c = container.read(friendsControllerProvider.notifier);
    c.sendRequest(_mia);
    c.accept('mia');

    // The local optimistic row still exists, but nothing was delivered.
    expect(svc.sent, isEmpty);
    expect(svc.responded, isEmpty);
    expect(container.read(friendsControllerProvider).relationships, isNotEmpty);
  });
}
