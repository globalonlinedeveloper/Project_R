import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ratel/services/social/friends_service.dart';

/// Stage-3 [FriendsService] backed by the `SECURITY DEFINER` RPCs
/// [R-I9 / R-L8 / R-M3 / R-K6]. `send_friend_request` and
/// `respond_to_friend_request` write BOTH sides' `friendship` rows — the
/// cross-user half own-row RLS forbids — by resolving `@handle` → uid via
/// `profiles` inside a `postgres`-owned definer (the project's existing
/// `handle_new_user` pattern). Those two functions are the ONLY privilege
/// surface; every other read / write stays own-row. [setHandle] is a plain
/// own-row `profiles` UPDATE (RLS + the unique index enforce it — no definer).
/// Wired in `main` via [fromClient] when auth is on + the keys are present; the
/// local default stays the honest [UnavailableFriendsService], so flag-off
/// behaviour is byte-identical — i.e. this is the same flagged go-live wiring as
/// every other durable seam and is NOT the live default yet.
class SupabaseFriendsService implements FriendsService {
  SupabaseFriendsService(this._db);

  /// Wire to the live Supabase client (its `auth.uid()` authorizes every call).
  factory SupabaseFriendsService.fromClient(SupabaseClient client) =>
      SupabaseFriendsService(client);

  final SupabaseClient _db;

  /// SECURITY DEFINER RPC: resolve + write both sides of a request.
  static const String sendFn = 'send_friend_request';

  /// SECURITY DEFINER RPC: accept / decline, mirroring both sides.
  static const String respondFn = 'respond_to_friend_request';

  /// The caller's own `profiles` row (own-row RLS; unique index on the handle).
  static const String profilesTable = 'profiles';

  /// Normalize a handle exactly like `FriendsEngine`: trim, drop a leading run
  /// of '@', lowercase. (The RPC re-normalizes server-side; this keeps the wire
  /// clean and the unit test pure.)
  static String normalizeHandle(String raw) =>
      raw.trim().replaceFirst(RegExp(r'^@+'), '').toLowerCase();

  @override
  Future<FriendDeliveryResult> sendRequest(String targetHandle) async {
    try {
      final Object? res = await _db.rpc(
        sendFn,
        params: <String, Object?>{
          'target_handle': normalizeHandle(targetHandle),
        },
      );
      return resultFromRpc(res);
    } on PostgrestException catch (e) {
      return resultFromError(e);
    } catch (_) {
      return _network;
    }
  }

  @override
  Future<FriendDeliveryResult> respond(String requesterHandle,
      {required bool accept}) async {
    try {
      final Object? res = await _db.rpc(
        respondFn,
        params: <String, Object?>{
          'requester_handle': normalizeHandle(requesterHandle),
          'accept': accept,
        },
      );
      return resultFromRpc(res);
    } on PostgrestException catch (e) {
      return resultFromError(e);
    } catch (_) {
      return _network;
    }
  }

  @override
  Future<FriendDeliveryResult> setHandle(String desiredHandle) async {
    final String h = normalizeHandle(desiredHandle);
    final String? uid = _db.auth.currentUser?.id;
    if (uid == null) {
      return const FriendDeliveryResult(FriendDeliveryOutcome.unavailable,
          message: 'Sign in to claim your @handle.');
    }
    try {
      await _db
          .from(profilesTable)
          .update(<String, Object?>{'handle': h}).eq('id', uid);
      return FriendDeliveryResult(FriendDeliveryOutcome.delivered, status: h);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return const FriendDeliveryResult(FriendDeliveryOutcome.failed,
            message: 'That @handle is already taken.');
      }
      if (e.code == '23514') {
        return const FriendDeliveryResult(FriendDeliveryOutcome.failed,
            message: 'Use 2–20 letters, numbers or _ for your handle.');
      }
      return FriendDeliveryResult(FriendDeliveryOutcome.failed,
          message: e.message);
    } catch (_) {
      return _network;
    }
  }

  static const FriendDeliveryResult _network = FriendDeliveryResult(
    FriendDeliveryOutcome.failed,
    message: 'Could not reach the server. Try again.',
  );

  /// Map a successful RPC payload (`{status, handle}`) → a delivery result.
  /// Public + pure so it is unit-tested without a live client (mirrors
  /// `SupabaseFriendsStore.rowsFor`).
  static FriendDeliveryResult resultFromRpc(Object? res) {
    final String? status = (res is Map && res['status'] != null)
        ? res['status'].toString()
        : null;
    switch (status) {
      case 'friends':
        return FriendDeliveryResult(FriendDeliveryOutcome.friends,
            status: status);
      case 'none':
        return FriendDeliveryResult(FriendDeliveryOutcome.cleared,
            status: status);
      default:
        return FriendDeliveryResult(FriendDeliveryOutcome.delivered,
            status: status);
    }
  }

  /// Map a raised RPC error → an honest, specific result (never a fake
  /// success). Public + pure for unit testing.
  static FriendDeliveryResult resultFromError(PostgrestException e) {
    final String m = e.message.toLowerCase();
    if (m.contains('no user with that handle') ||
        m.contains('no pending request')) {
      return FriendDeliveryResult(FriendDeliveryOutcome.notFound,
          message: e.message);
    }
    if (m.contains('set your own')) {
      return const FriendDeliveryResult(FriendDeliveryOutcome.needsHandle,
          message: 'Set your own @handle first (Edit profile).');
    }
    return FriendDeliveryResult(FriendDeliveryOutcome.failed, message: e.message);
  }
}
