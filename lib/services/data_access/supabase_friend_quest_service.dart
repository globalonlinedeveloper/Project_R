import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ratel/services/social/friend_quest.dart';
import 'package:ratel/services/social/friend_quest_service.dart';

/// Stage-3 [FriendQuestService] backed by the co-op friend-quest SECURITY
/// DEFINER RPCs [R-I9 / R-L8 / R-K6 / R-M3] (`schema/sql/0013_friend_quest.sql`;
/// applied live in the `friend_quest_coop_table_and_rpcs` migration). Progress
/// is derived server-side from each member's durable `user_course.lessons_completed`
/// baseline — a client can never inflate it. Errors fall back to the HONEST
/// empty/null (mirrors `SupabaseFriendsService` / `SupabaseLeaguesStore`): a
/// transient failure shows no fabricated quest rather than aborting the screen.
class SupabaseFriendQuestService implements FriendQuestService {
  SupabaseFriendQuestService(this._db);

  factory SupabaseFriendQuestService.fromClient(SupabaseClient client) =>
      SupabaseFriendQuestService(client);

  final SupabaseClient _db;

  static const String listFn = 'list_friend_quests';
  static const String createFn = 'create_friend_quest';
  static const String respondFn = 'respond_friend_quest';
  static const String refreshFn = 'refresh_friend_quest';

  /// Normalize a handle exactly like the friends seam (trim, drop leading '@',
  /// lowercase); the RPC re-normalizes server-side.
  static String normalizeHandle(String raw) =>
      raw.trim().replaceFirst(RegExp(r'^@+'), '').toLowerCase();

  static FriendQuest? _one(Object? res) => res is Map
      ? FriendQuest.fromJson(Map<String, dynamic>.from(res))
      : null;

  @override
  Future<List<FriendQuest>> list() async {
    try {
      final Object? res = await _db.rpc(listFn);
      if (res is List) {
        return res
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> m) =>
                FriendQuest.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return const <FriendQuest>[];
    } catch (_) {
      return const <FriendQuest>[];
    }
  }

  @override
  Future<FriendQuest?> create(String partnerHandle, {int goal = 12}) async {
    try {
      final Object? res = await _db.rpc(createFn, params: <String, Object?>{
        'partner_handle': normalizeHandle(partnerHandle),
        'p_goal': goal,
      });
      return _one(res);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<FriendQuest?> respond(String questId, {required bool accept}) async {
    try {
      final Object? res = await _db.rpc(respondFn, params: <String, Object?>{
        'p_quest_id': questId,
        'p_accept': accept,
      });
      return _one(res);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<FriendQuest?> refresh(String questId) async {
    try {
      final Object? res = await _db.rpc(refreshFn, params: <String, Object?>{
        'p_quest_id': questId,
      });
      return _one(res);
    } catch (_) {
      return null;
    }
  }

  @override
  bool get isAvailable => true;
}
