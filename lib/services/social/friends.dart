/// Pure, deterministic friends / social engine (design spec §4 "Friends /
/// social" [R-I9 / R-L8]: followers, friend activity, "passed you"). Like every
/// other `lib/services` engine it holds NO clock and imports nothing from
/// `lib/features`: each view is DERIVED from the learner's REAL relationship
/// rows + real friend-activity events. A fresh account therefore honestly shows
/// an EMPTY social graph — never a fabricated friend or a bot leaderboard
/// (charter "don't fake depth"). The durable cross-user store (Supabase
/// `friendship` + own-rows RLS) is the same flagged go-live wiring as every
/// other R-O1 counter — see `SupabaseFriendsStore`.
library;

/// The relationship between the signed-in learner and another user, FROM THE
/// LEARNER'S PERSPECTIVE.
enum FriendStatus {
  /// No relationship.
  none,

  /// The learner sent a request; awaiting the other user's accept.
  requestOutgoing,

  /// The other user sent a request; awaiting the learner's accept.
  requestIncoming,

  /// Mutually accepted friends.
  friends,

  /// The learner blocked the other user (hidden; cannot be re-requested).
  blocked,
}

/// Parse a stored status string back to its enum (unknown ⇒ [FriendStatus.none]).
FriendStatus friendStatusFromName(String? name) {
  for (final FriendStatus s in FriendStatus.values) {
    if (s.name == name) return s;
  }
  return FriendStatus.none;
}

/// One relationship row owned by the learner (mirrors a `friendship` table row,
/// keyed on the OTHER user's id).
class FriendRecord {
  const FriendRecord({
    required this.userId,
    required this.handle,
    required this.displayName,
    required this.status,
    this.avatarEmoji = '🦡',
    this.weeklyXp = 0,
  });

  /// The OTHER user's id.
  final String userId;

  /// Normalized handle (no leading '@', lowercase).
  final String handle;

  /// Their display name.
  final String displayName;

  /// The relationship state, from the learner's perspective.
  final FriendStatus status;

  /// Their avatar emoji (defaults to the Ratel badger).
  final String avatarEmoji;

  /// Their REAL weekly league XP (0 until known) — drives "passed you".
  final int weeklyXp;

  FriendRecord copyWith({
    FriendStatus? status,
    String? displayName,
    String? avatarEmoji,
    int? weeklyXp,
  }) =>
      FriendRecord(
        userId: userId,
        handle: handle,
        displayName: displayName ?? this.displayName,
        status: status ?? this.status,
        avatarEmoji: avatarEmoji ?? this.avatarEmoji,
        weeklyXp: weeklyXp ?? this.weeklyXp,
      );

  /// Column → value map (Supabase `friendship` row shape; the owning `user_id`
  /// is stamped by the store on save, never here).
  Map<String, Object?> toRow() => <String, Object?>{
        'friend_id': userId,
        'handle': handle,
        'display_name': displayName,
        'status': status.name,
        'avatar_emoji': avatarEmoji,
        'weekly_xp': weeklyXp,
      };

  static FriendRecord fromRow(Map<String, Object?> row) => FriendRecord(
        userId: (row['friend_id'] ?? '').toString(),
        handle: (row['handle'] ?? '').toString(),
        displayName: (row['display_name'] ?? '').toString(),
        status: friendStatusFromName(row['status'] as String?),
        avatarEmoji: (row['avatar_emoji'] ?? '🦡').toString(),
        weeklyXp: (row['weekly_xp'] as num?)?.toInt() ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      other is FriendRecord &&
      other.userId == userId &&
      other.handle == handle &&
      other.displayName == displayName &&
      other.status == status &&
      other.avatarEmoji == avatarEmoji &&
      other.weeklyXp == weeklyXp;

  @override
  int get hashCode =>
      Object.hash(userId, handle, displayName, status, avatarEmoji, weeklyXp);
}

/// What a friend did — the kinds of events that surface in the activity feed.
enum FriendActivityType {
  /// Joined / became your friend.
  joined,

  /// Completed lesson(s).
  lessonsCompleted,

  /// Reached a new CEFR level.
  leveledUp,

  /// Hit a streak milestone.
  streak,

  /// Overtook you in this week's league ("passed you").
  passedYouInLeague,
}

/// One friend-activity feed event (mirrors a `friend_activity` row).
class FriendActivity {
  const FriendActivity({
    required this.actorId,
    required this.actorHandle,
    required this.actorName,
    required this.type,
    required this.summary,
    required this.at,
    this.avatarEmoji = '🦡',
  });

  /// The friend who acted.
  final String actorId;
  final String actorHandle;
  final String actorName;
  final FriendActivityType type;

  /// A short human summary (e.g. "completed 3 lessons").
  final String summary;

  /// When it happened (UTC).
  final DateTime at;
  final String avatarEmoji;

  static FriendActivityType _typeFromName(String? name) {
    for (final FriendActivityType t in FriendActivityType.values) {
      if (t.name == name) return t;
    }
    return FriendActivityType.lessonsCompleted;
  }

  Map<String, Object?> toRow() => <String, Object?>{
        'actor_id': actorId,
        'actor_handle': actorHandle,
        'actor_name': actorName,
        'type': type.name,
        'summary': summary,
        'at': at.toUtc().toIso8601String(),
        'avatar_emoji': avatarEmoji,
      };

  static FriendActivity fromRow(Map<String, Object?> row) => FriendActivity(
        actorId: (row['actor_id'] ?? '').toString(),
        actorHandle: (row['actor_handle'] ?? '').toString(),
        actorName: (row['actor_name'] ?? '').toString(),
        type: _typeFromName(row['type'] as String?),
        summary: (row['summary'] ?? '').toString(),
        at: DateTime.tryParse((row['at'] ?? '').toString())?.toUtc() ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        avatarEmoji: (row['avatar_emoji'] ?? '🦡').toString(),
      );

  @override
  bool operator ==(Object other) =>
      other is FriendActivity &&
      other.actorId == actorId &&
      other.actorHandle == actorHandle &&
      other.actorName == actorName &&
      other.type == type &&
      other.summary == summary &&
      other.at == at &&
      other.avatarEmoji == avatarEmoji;

  @override
  int get hashCode => Object.hash(
      actorId, actorHandle, actorName, type, summary, at, avatarEmoji);
}

/// Pure social-graph derivations + relationship transitions. Stateless &
/// clockless: every method maps inputs → a NEW value (transitions return a new
/// list), so it is trivially unit-testable and safe to call on every rebuild.
class FriendsEngine {
  const FriendsEngine();

  static final RegExp _handleOk = RegExp(r'^[a-z0-9_]{2,20}$');

  /// Trim, drop a leading run of '@', lowercase.
  String normalizeHandle(String raw) =>
      raw.trim().replaceFirst(RegExp(r'^@+'), '').toLowerCase();

  /// A 2–20 char handle of `[a-z0-9_]` after normalization.
  bool isValidHandle(String raw) => _handleOk.hasMatch(normalizeHandle(raw));

  List<FriendRecord> _by(List<FriendRecord> records, FriendStatus status) {
    final List<FriendRecord> out =
        records.where((FriendRecord r) => r.status == status).toList();
    out.sort((FriendRecord a, FriendRecord b) =>
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    return out;
  }

  /// Accepted friends, alphabetical.
  List<FriendRecord> friends(List<FriendRecord> records) =>
      _by(records, FriendStatus.friends);

  /// Requests awaiting the learner's accept.
  List<FriendRecord> incoming(List<FriendRecord> records) =>
      _by(records, FriendStatus.requestIncoming);

  /// Requests the learner sent, awaiting accept.
  List<FriendRecord> outgoing(List<FriendRecord> records) =>
      _by(records, FriendStatus.requestOutgoing);

  /// Ids of current friends (for feed filtering).
  Set<String> friendIds(List<FriendRecord> records) =>
      friends(records).map((FriendRecord r) => r.userId).toSet();

  /// The activity feed: events from CURRENT friends only, newest first, capped.
  List<FriendActivity> feed(
    List<FriendActivity> events,
    List<FriendRecord> records, {
    int cap = 50,
  }) {
    final Set<String> ids = friendIds(records);
    final List<FriendActivity> out = events
        .where((FriendActivity e) => ids.contains(e.actorId))
        .toList()
      ..sort((FriendActivity a, FriendActivity b) => b.at.compareTo(a.at));
    return out.length > cap ? out.sublist(0, cap) : out;
  }

  /// Friends whose weekly XP exceeds the learner's — "passed you" (design spec),
  /// biggest lead first.
  List<FriendRecord> whoPassedMe(int myWeeklyXp, List<FriendRecord> records) {
    final List<FriendRecord> out = friends(records)
        .where((FriendRecord r) => r.weeklyXp > myWeeklyXp)
        .toList()
      ..sort((FriendRecord a, FriendRecord b) =>
          b.weeklyXp.compareTo(a.weeklyXp));
    return out;
  }

  FriendRecord? _find(List<FriendRecord> records, String userId) {
    for (final FriendRecord r in records) {
      if (r.userId == userId) return r;
    }
    return null;
  }

  /// Whether a fresh outgoing request to [target] is allowed: not yourself, not
  /// already related (any non-[FriendStatus.none] state blocks a duplicate).
  bool canSendRequest(
    List<FriendRecord> records,
    FriendRecord target, {
    String? myHandle,
  }) {
    if (myHandle != null && normalizeHandle(myHandle) == target.handle) {
      return false;
    }
    final FriendRecord? existing = _find(records, target.userId);
    return existing == null || existing.status == FriendStatus.none;
  }

  /// Add an outgoing request to [target] (no-op if [canSendRequest] is false).
  List<FriendRecord> applySendRequest(
    List<FriendRecord> records,
    FriendRecord target, {
    String? myHandle,
  }) {
    if (!canSendRequest(records, target, myHandle: myHandle)) return records;
    return <FriendRecord>[
      ...records.where((FriendRecord r) => r.userId != target.userId),
      target.copyWith(status: FriendStatus.requestOutgoing),
    ];
  }

  /// Accept an incoming request → friends (no-op unless currently incoming).
  List<FriendRecord> applyAccept(List<FriendRecord> records, String userId) =>
      records
          .map((FriendRecord r) => r.userId == userId &&
                  r.status == FriendStatus.requestIncoming
              ? r.copyWith(status: FriendStatus.friends)
              : r)
          .toList();

  /// Decline an incoming request → remove it (no-op unless currently incoming).
  List<FriendRecord> applyDecline(List<FriendRecord> records, String userId) =>
      records
          .where((FriendRecord r) => !(r.userId == userId &&
              r.status == FriendStatus.requestIncoming))
          .toList();

  /// Cancel an outgoing request OR remove a friend → drop the row.
  List<FriendRecord> applyRemove(List<FriendRecord> records, String userId) =>
      records.where((FriendRecord r) => r.userId != userId).toList();

  /// Block a user (hidden everywhere; cannot be re-requested).
  List<FriendRecord> applyBlock(List<FriendRecord> records, String userId) {
    final FriendRecord? existing = _find(records, userId);
    if (existing == null) return records;
    return <FriendRecord>[
      ...records.where((FriendRecord r) => r.userId != userId),
      existing.copyWith(status: FriendStatus.blocked),
    ];
  }
}
