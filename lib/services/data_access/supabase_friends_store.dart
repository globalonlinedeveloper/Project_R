import 'package:supabase_flutter/supabase_flutter.dart';

import 'data_access.dart';

/// Stage-3 [FriendsStore] backed by Supabase (R-I9 / R-L8 / R-M3). Persists the
/// learner's relationship rows into the `friendship` table and reads the
/// `friend_activity` feed, every row keyed on `auth.uid()` (R-K6) and guarded by
/// RLS (a learner reads + writes ONLY rows where `user_id = auth.uid()`). The
/// seam (load / save by `userId`) is unchanged, so feature code never imports a
/// backend type. Wired in `main` via [fromClient] when auth is on and the
/// Supabase keys are present; the local default stays the in-memory store, so
/// flag-off behaviour is byte-identical — i.e. this is the same flagged go-live
/// wiring as every other durable R-O1 counter and is NOT the live default yet.
///
/// [save] makes the learner's persisted relationship set EXACTLY match
/// `data['relationships']` (delete-own + insert), stamping the owning `user_id`
/// on every row so it satisfies the own-row RLS check; the activity feed is
/// produced by friends, so it is load-only.
class SupabaseFriendsStore implements FriendsStore {
  SupabaseFriendsStore(this._db);

  /// Wire to the live Supabase client (its `auth.uid()` owns every row).
  factory SupabaseFriendsStore.fromClient(SupabaseClient client) =>
      SupabaseFriendsStore(client);

  final SupabaseClient _db;

  /// Per-(user, friend) relationship table.
  static const String relationshipTable = 'friendship';

  /// Friends' activity events surfaced in the learner's feed.
  static const String activityTable = 'friend_activity';

  @override
  Future<Map<String, Object?>> load(String userId) async {
    final List<Map<String, dynamic>> rels =
        await _db.from(relationshipTable).select().eq('user_id', userId);
    final List<Map<String, dynamic>> acts =
        await _db.from(activityTable).select().eq('user_id', userId);
    return <String, Object?>{
      kFriendsRelationshipsKey:
          rels.map((row) => Map<String, Object?>.from(row)).toList(),
      kFriendsActivityKey:
          acts.map((row) => Map<String, Object?>.from(row)).toList(),
    };
  }

  @override
  Future<void> save(String userId, Map<String, Object?> data) async {
    final List<Map<String, Object?>> rows =
        rowsFor(data[kFriendsRelationshipsKey], userId);
    // Make the persisted own-set exactly match the provided relationships:
    // delete the learner's rows, then insert the current set (own-row RLS keeps
    // this scoped to `auth.uid()`).
    await _db.from(relationshipTable).delete().eq('user_id', userId);
    if (rows.isNotEmpty) {
      await _db.from(relationshipTable).insert(rows);
    }
  }

  /// Coerce an opaque seam value into a list of row-maps, stamping the owning
  /// [userId] on every row (RLS requires `user_id = auth.uid()`).
  static List<Map<String, Object?>> rowsFor(Object? raw, String userId) {
    if (raw is! List) return const <Map<String, Object?>>[];
    final List<Map<String, Object?>> rows = <Map<String, Object?>>[];
    for (final Object? entry in raw) {
      if (entry is! Map) continue;
      final Map<String, Object?> row = <String, Object?>{};
      entry.forEach((key, value) => row[key.toString()] = value);
      row['user_id'] = userId;
      rows.add(row);
    }
    return rows;
  }
}
