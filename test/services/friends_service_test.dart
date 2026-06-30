// R-I9 / R-L8 / R-M3 — Friends DELIVERY seam: the honest default never routes,
// and the Supabase service's pure result/handle mappers (unit-tested without a
// live client, mirroring SupabaseFriendsStore.rowsFor).
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ratel/services/data_access/supabase_friends_service.dart';
import 'package:ratel/services/social/friends_service.dart';

void main() {
  group('UnavailableFriendsService (honest default — never fakes a delivery)',
      () {
    const FriendsService svc = UnavailableFriendsService();

    test('sendRequest is unavailable, not a fabricated success', () async {
      final FriendDeliveryResult r = await svc.sendRequest('@mia');
      expect(r.outcome, FriendDeliveryOutcome.unavailable);
      expect(r.ok, isFalse);
      expect(r.message, isNotNull);
    });

    test('respond + setHandle are also unavailable', () async {
      expect((await svc.respond('mia', accept: true)).outcome,
          FriendDeliveryOutcome.unavailable);
      expect((await svc.respond('mia', accept: false)).outcome,
          FriendDeliveryOutcome.unavailable);
      expect((await svc.setHandle('me')).outcome,
          FriendDeliveryOutcome.unavailable);
    });

    test('removeFriend (remove + block) is unavailable, never a fake clear',
        () async {
      final FriendDeliveryResult r =
          await svc.removeFriend('mia', block: false);
      expect(r.outcome, FriendDeliveryOutcome.unavailable);
      expect(r.ok, isFalse);
      expect((await svc.removeFriend('mia', block: true)).outcome,
          FriendDeliveryOutcome.unavailable);
    });

    test('emitActivity is unavailable, never a fabricated feed write', () async {
      final FriendDeliveryResult r =
          await svc.emitActivity('leveledUp', summary: 'reached B1');
      expect(r.outcome, FriendDeliveryOutcome.unavailable);
      expect(r.ok, isFalse);
    });

    test('publishWeeklyXp is unavailable, never a fabricated XP publish',
        () async {
      final FriendDeliveryResult r = await svc.publishWeeklyXp(120);
      expect(r.outcome, FriendDeliveryOutcome.unavailable);
      expect(r.ok, isFalse);
    });
  });

  group('SupabaseFriendsService.normalizeHandle', () {
    test('strips a leading @-run, trims, lowercases', () {
      expect(SupabaseFriendsService.normalizeHandle('  @@Mia '), 'mia');
      expect(SupabaseFriendsService.normalizeHandle('Bob_99'), 'bob_99');
    });
  });

  group('SupabaseFriendsService.resultFromRpc (server status → outcome)', () {
    test('requestOutgoing ⇒ delivered', () {
      final r = SupabaseFriendsService.resultFromRpc(
          <String, Object?>{'status': 'requestOutgoing', 'handle': 'mia'});
      expect(r.outcome, FriendDeliveryOutcome.delivered);
      expect(r.status, 'requestOutgoing');
      expect(r.ok, isTrue);
    });
    test('friends ⇒ friends; none ⇒ cleared', () {
      expect(
          SupabaseFriendsService.resultFromRpc(
                  <String, Object?>{'status': 'friends'})
              .outcome,
          FriendDeliveryOutcome.friends);
      expect(
          SupabaseFriendsService.resultFromRpc(
                  <String, Object?>{'status': 'none'})
              .outcome,
          FriendDeliveryOutcome.cleared);
    });
    test('blocked ⇒ cleared, but keeps the blocked status for the caller', () {
      final r = SupabaseFriendsService.resultFromRpc(
          <String, Object?>{'status': 'blocked', 'handle': 'mia'});
      expect(r.outcome, FriendDeliveryOutcome.cleared);
      expect(r.status, 'blocked');
      expect(r.ok, isTrue);
    });
    test('a non-map / missing status still resolves (delivered, no status)', () {
      final r = SupabaseFriendsService.resultFromRpc(null);
      expect(r.outcome, FriendDeliveryOutcome.delivered);
      expect(r.status, isNull);
    });
  });

  group('SupabaseFriendsService.resultFromEmit (row-count → delivered)', () {
    test('a positive count ⇒ delivered with the count in status', () {
      final r = SupabaseFriendsService.resultFromEmit(2);
      expect(r.outcome, FriendDeliveryOutcome.delivered);
      expect(r.status, '2');
      expect(r.ok, isTrue);
    });
    test('zero is still an honest delivered (no eligible friends)', () {
      expect(SupabaseFriendsService.resultFromEmit(0).outcome,
          FriendDeliveryOutcome.delivered);
    });
    test('a non-number resolves to 0, never throws', () {
      expect(SupabaseFriendsService.resultFromEmit(null).status, '0');
    });
  });

  group('SupabaseFriendsService.resultFromError (raised RPC → honest result)',
      () {
    test('unknown handle ⇒ notFound', () {
      final r = SupabaseFriendsService.resultFromError(
          const PostgrestException(message: 'no user with that handle'));
      expect(r.outcome, FriendDeliveryOutcome.notFound);
    });
    test('missing own handle ⇒ needsHandle', () {
      final r = SupabaseFriendsService.resultFromError(
          const PostgrestException(message: 'set your own @handle first'));
      expect(r.outcome, FriendDeliveryOutcome.needsHandle);
    });
    test('anything else ⇒ failed (surfaces the message, never a fake ok)', () {
      final r = SupabaseFriendsService.resultFromError(
          const PostgrestException(message: 'cannot add yourself'));
      expect(r.outcome, FriendDeliveryOutcome.failed);
      expect(r.ok, isFalse);
    });
  });
}
