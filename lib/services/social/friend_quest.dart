/// [R-I9 / R-L8] Co-op friend-quest view model — a quest two friends share
/// ("finish N lessons together"). Immutable; parsed straight from the
/// `*_friend_quest` SECURITY DEFINER RPC json (`schema/sql/0013_friend_quest.sql`).
/// Progress is SERVER-DERIVED (from each member's durable `user_course.lessons_completed`
/// baseline-diff) — this client only DISPLAYS it, never asserts it, so nothing is fabricated.
class FriendQuest {
  const FriendQuest({
    required this.id,
    required this.creatorId,
    required this.partnerId,
    this.creatorHandle = '',
    this.creatorName = '',
    this.partnerHandle = '',
    this.partnerName = '',
    required this.goalLessons,
    required this.status,
    required this.creatorProgress,
    required this.partnerProgress,
    required this.combinedProgress,
    required this.done,
    this.completedAt,
  });

  final String id;
  final String creatorId;
  final String partnerId;
  final String creatorHandle;
  final String creatorName;
  final String partnerHandle;
  final String partnerName;
  final int goalLessons;

  /// pending | active | completed | declined | cancelled (server text; an
  /// unknown value is treated as pending for forward-compat).
  final String status;
  final int creatorProgress;
  final int partnerProgress;

  /// Combined lessons finished since the baseline, clamped to [goalLessons] by
  /// the server.
  final int combinedProgress;
  final bool done;
  final DateTime? completedAt;

  bool get isPending => status == 'pending';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';

  /// Lessons still to finish together (never negative).
  int get remaining =>
      (goalLessons - combinedProgress) < 0 ? 0 : goalLessons - combinedProgress;

  /// Progress toward the shared goal in [0,1].
  double get fraction =>
      goalLessons <= 0 ? 0 : (combinedProgress / goalLessons).clamp(0.0, 1.0);

  /// The OTHER member's uid relative to [myUid] (the friend, from my seat).
  String otherId(String myUid) => myUid == creatorId ? partnerId : creatorId;

  /// The friend's @handle from my seat (empty ⇒ unknown, never fabricated).
  String otherHandle(String myUid) =>
      myUid == creatorId ? partnerHandle : creatorHandle;

  /// The friend's display name from my seat.
  String otherName(String myUid) =>
      myUid == creatorId ? partnerName : creatorName;

  /// My own contribution relative to [myUid].
  int myProgress(String myUid) =>
      myUid == creatorId ? creatorProgress : partnerProgress;

  static String _s(Object? v) => v == null ? '' : v.toString();
  static int _i(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

  factory FriendQuest.fromJson(Map<String, dynamic> j) => FriendQuest(
    id: _s(j['friend_quest_id']),
    creatorId: _s(j['creator_id']),
    partnerId: _s(j['partner_id']),
    creatorHandle: _s(j['creator_handle']),
    creatorName: _s(j['creator_name']),
    partnerHandle: _s(j['partner_handle']),
    partnerName: _s(j['partner_name']),
    goalLessons: _i(j['goal_lessons']),
    status: _s(j['status']).isEmpty ? 'pending' : _s(j['status']),
    creatorProgress: _i(j['creator_progress']),
    partnerProgress: _i(j['partner_progress']),
    combinedProgress: _i(j['combined_progress']),
    done: j['done'] == true,
    completedAt: j['completed_at'] == null
        ? null
        : DateTime.tryParse(_s(j['completed_at'])),
  );
}
