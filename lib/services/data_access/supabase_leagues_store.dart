import 'package:supabase_flutter/supabase_flutter.dart';

import 'data_access.dart';

/// Stage-3 [LeaguesStore] backed by Supabase (R-I6 / R-M3). Persists the
/// learner's OWN weekly-standing rows into the `league_member` table, every row
/// keyed on `auth.uid()` (R-K6) and guarded by own-row RLS (a learner reads +
/// writes ONLY rows where `user_id = auth.uid()`). The seam (load / save by
/// `userId`) is unchanged, so feature code never imports a backend type. Wired
/// in `main` via [fromClient] when auth is on and the Supabase keys are present;
/// the local default stays the in-memory store, so flag-off behaviour is
/// byte-identical — this is the same flagged go-live wiring as every other
/// durable R-O1 counter and is NOT the live default yet. The cross-user
/// leaderboard (co-members' XP) is a server-side read path in a later slice; it
/// is NOT exposed through this own-row store.
///
/// [save] makes the learner's persisted membership set EXACTLY match
/// `data['membership']` (delete-own + insert), stamping the owning `user_id` on
/// every row so it satisfies the own-row RLS check.
class SupabaseLeaguesStore implements LeaguesStore {
  SupabaseLeaguesStore(this._db);

  /// Wire to the live Supabase client (its `auth.uid()` owns every row).
  factory SupabaseLeaguesStore.fromClient(SupabaseClient client) =>
      SupabaseLeaguesStore(client);

  final SupabaseClient _db;

  /// The learner's own weekly-standing table.
  static const String memberTable = 'league_member';

  /// The SECURITY DEFINER that serves the cross-user leaderboard read (R-I6).
  static const String readCohortFn = 'read_league_cohort';

  @override
  Future<Map<String, Object?>> load(String userId) async {
    final List<Map<String, dynamic>> rows =
        await _db.from(memberTable).select().eq('user_id', userId);
    return <String, Object?>{
      kLeagueMembershipKey:
          rows.map((row) => Map<String, Object?>.from(row)).toList(),
    };
  }

  @override
  Future<void> save(String userId, Map<String, Object?> data) async {
    final List<Map<String, Object?>> rows =
        rowsFor(data[kLeagueMembershipKey], userId);
    // Make the persisted own-set exactly match the provided membership: delete
    // the learner's rows, then insert the current set (own-row RLS keeps this
    // scoped to `auth.uid()`).
    await _db.from(memberTable).delete().eq('user_id', userId);
    if (rows.isNotEmpty) {
      await _db.from(memberTable).insert(rows);
    }
  }

  /// The CROSS-USER leaderboard: the caller's cohort members, served by the
  /// `read_league_cohort` SECURITY DEFINER (own-row RLS forbids a direct cross-row
  /// client SELECT — the S73 own-row lesson). The definer forms/joins the caller's
  /// tier+week cohort then returns its members ranked by weekly XP; it exposes the
  /// opaque league_member row id, NEVER a co-member's `auth.uid()`. [userId] is
  /// accepted for seam symmetry; the definer derives the caller from `auth.uid()`.
  @override
  Future<List<Map<String, Object?>>> readCohort(String userId) async {
    final Object? res = await _db.rpc(readCohortFn);
    if (res is! List) return const <Map<String, Object?>>[];
    return res
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> row) => Map<String, Object?>.from(row))
        .toList();
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
