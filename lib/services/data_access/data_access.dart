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
}

final friendsStoreProvider =
    Provider<FriendsStore>((ref) => InMemoryFriendsStore());
