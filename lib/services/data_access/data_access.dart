import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Portability seam (R-M3): data-access layer for learner state. Features read and
/// write ONLY through this. Stage 1–2 back it on-device/in-memory; Stage 3 adds
/// Supabase behind the SAME interface (every row keyed on `auth.uid()`, R-K6).
abstract interface class LearnerStateStore {
  Future<Map<String, Object?>> load(String userId);
  Future<void> save(String userId, Map<String, Object?> state);
}

/// Default (local / Stage 1–2): ephemeral in-memory store (R-O1 stub).
class InMemoryLearnerStateStore implements LearnerStateStore {
  final Map<String, Map<String, Object?>> _data = {};
  @override
  Future<Map<String, Object?>> load(String userId) async =>
      Map<String, Object?>.from(_data[userId] ?? const <String, Object?>{});
  @override
  Future<void> save(String userId, Map<String, Object?> state) async =>
      _data[userId] = Map<String, Object?>.from(state);
}

final learnerStateStoreProvider =
    Provider<LearnerStateStore>((ref) => InMemoryLearnerStateStore());

/// The course code (`target_locale`) the app is currently mounted on — the
/// live spine for per-course learner state (INC-15). Defaults to `'en'` so a
/// guest, a flag-off boot, or a bare test [ProviderContainer] behaves exactly
/// as the single-course build did. [RatelCourseRoot] overrides it inside its
/// remounting [ProviderScope] with the selected course, so switching course
/// re-boots the scope and the [LearnerController] re-reads this for free —
/// hydrating / persisting that course's own `user_course` row. The GLOBAL
/// fields (streak / diamonds) are NOT keyed by this; they live in a canonical
/// `__global__` row (see [LearnerController]).
final currentCourseCodeProvider = Provider<String>((ref) => 'en');

/// Debounce window that coalesces a burst of learner mutations into ONE durable
/// write-through (R-O1 persistence). Trailing-edge: the save captures the latest
/// state. Tests override it to [Duration.zero] for a deterministic flush.
final persistDebounceProvider =
    Provider<Duration>((ref) => const Duration(milliseconds: 400));

/// Injectable wall-clock seam (R-M3). The learning ENGINES are deliberately
/// clockless (FSRS / saved-words / streak take elapsed-or-now IN), so the
/// scheduling LAYER owns the clock here: a fresh review is timestamped against
/// real time, the streak is gated on the calendar day, and tests pin it via an
/// override. Defaults to the real [DateTime.now].
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Portability seam (R-M3) for the social graph [R-I9 / R-L8]. The Friends
/// feature reads + writes ONLY through this. Stage 1–2 back it in-memory (an
/// honestly EMPTY graph for a fresh learner); Stage 3 plugs
/// [SupabaseFriendsStore] behind the SAME interface, every row keyed on
/// `auth.uid()` (R-K6). Seam-Map shape:
/// `{ 'relationships': [ <friendship row>, … ], 'activity': [ <friend_activity
/// row>, … ] }` — `load` returns it, `save` persists the relationships (the
/// activity feed is produced by friends, so it is load-only).
abstract interface class FriendsStore {
  Future<Map<String, Object?>> load(String userId);
  Future<void> save(String userId, Map<String, Object?> data);

  /// Optional LIVE stream of the learner's OWN `friend_activity` rows (R-L11b):
  /// emits the current own-row set whenever it changes, so the feed updates
  /// without a reload. Returns null when the backend has no realtime channel
  /// (the in-memory default) — the controller then skips the subscription and
  /// behaviour stays byte-identical.
  Stream<List<Map<String, Object?>>>? activityStream(String userId);
}

/// Key holding the list of relationship (`friendship`) rows in the seam-Map.
const String kFriendsRelationshipsKey = 'relationships';

/// Key holding the list of `friend_activity` rows in the seam-Map.
const String kFriendsActivityKey = 'activity';

/// Default (local / Stage 1–2): ephemeral in-memory store (R-O1 stub). A fresh
/// learner starts with an empty graph — never seeded with fake friends.
class InMemoryFriendsStore implements FriendsStore {
  final Map<String, Map<String, Object?>> _data =
      <String, Map<String, Object?>>{};
  @override
  Future<Map<String, Object?>> load(String userId) async =>
      Map<String, Object?>.from(_data[userId] ?? const <String, Object?>{});
  @override
  Future<void> save(String userId, Map<String, Object?> data) async =>
      _data[userId] = Map<String, Object?>.from(data);

  /// No realtime channel for the in-memory store — the controller skips the
  /// live subscription, so behaviour is unchanged.
  @override
  Stream<List<Map<String, Object?>>>? activityStream(String userId) => null;
}

final friendsStoreProvider =
    Provider<FriendsStore>((ref) => InMemoryFriendsStore());

/// Portability seam (R-M3) for the weekly LEAGUE standing [R-I6]. The Leagues
/// feature reads + writes ONLY through this. Stage 1–2 back it in-memory (an
/// honest solo cohort for a fresh learner — never seeded with fabricated
/// rivals); Stage 3 plugs [SupabaseLeaguesStore] behind the SAME interface,
/// every row keyed on `auth.uid()` (R-K6) and guarded by own-row RLS. Seam-Map
/// shape: `{ 'membership': [ <league_member row>, … ] }` — `load` returns the
/// learner's OWN weekly-standing rows, `save` persists them. The cross-user
/// leaderboard (co-members' XP) is a server-side (SECURITY DEFINER) read path in
/// a later slice, never part of this own-row seam.
abstract interface class LeaguesStore {
  Future<Map<String, Object?>> load(String userId);
  Future<void> save(String userId, Map<String, Object?> data);

  /// The caller's CROSS-USER weekly cohort (the real leaderboard). Own-row RLS
  /// forbids a direct cross-row client SELECT, so the durable backend serves this
  /// via a SECURITY DEFINER (`read_league_cohort`) that forms/joins the caller's
  /// cohort then returns its members. The in-memory default returns an EMPTY list
  /// (no cross-user backend) so the Leagues feature stays an honest solo cohort —
  /// byte-identical to the pre-go-live build.
  Future<List<Map<String, Object?>>> readCohort(String userId);
}

/// Key holding the list of the learner's own `league_member` rows in the seam-Map.
const String kLeagueMembershipKey = 'membership';

/// Default (local / Stage 1–2): ephemeral in-memory store (R-O1 stub). A fresh
/// learner is an honest solo cohort — never seeded with fake rivals.
class InMemoryLeaguesStore implements LeaguesStore {
  final Map<String, Map<String, Object?>> _data =
      <String, Map<String, Object?>>{};
  @override
  Future<Map<String, Object?>> load(String userId) async =>
      Map<String, Object?>.from(_data[userId] ?? const <String, Object?>{});
  @override
  Future<void> save(String userId, Map<String, Object?> data) async =>
      _data[userId] = Map<String, Object?>.from(data);
  @override
  Future<List<Map<String, Object?>>> readCohort(String userId) async =>
      const <Map<String, Object?>>[]; // no cross-user backend -> honest solo cohort
}

final leaguesStoreProvider =
    Provider<LeaguesStore>((ref) => InMemoryLeaguesStore());
