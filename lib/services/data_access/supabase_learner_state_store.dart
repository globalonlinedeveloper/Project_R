import 'package:supabase_flutter/supabase_flutter.dart';

import 'data_access.dart';

/// Stage-3 [LearnerStateStore] backed by Supabase (R-G6, R-M3). Persists a
/// learner's state into the typed `user_course` + `user_item_state` tables,
/// every row keyed on `auth.uid()` (R-K6) and guarded by own-row RLS. The seam
/// (load / save by `userId`) is unchanged, so feature code never imports a
/// backend type. Wired in `main` via [fromClient] when `authEnabled` is on and
/// the Supabase keys are present (queue #7); the local default stays the
/// in-memory store, so flag-off behaviour is byte-identical.
///
/// Seam-Map shape: `{ 'courses': [ <user_course row>, ... ],
/// 'items': [ <user_item_state row>, ... ] }`, where each row is a
/// column -> value map matching the table. [save] stamps the owning `user_id`
/// on every row (RLS requires it equal `auth.uid()`) and upserts on the natural
/// keys; [load] returns the same shape.
class SupabaseLearnerStateStore implements LearnerStateStore {
  /// Build from any [SupabaseClient]; [fromClient] is the `main`-side factory.
  SupabaseLearnerStateStore(this._db);

  /// Wire to the live Supabase client (its `auth.uid()` owns every row).
  factory SupabaseLearnerStateStore.fromClient(SupabaseClient client) =>
      SupabaseLearnerStateStore(client);

  final SupabaseClient _db;

  /// Per-(user, course) progress table.
  static const String courseTable = 'user_course';

  /// FSRS per-(user, item) scheduler-state table.
  static const String itemTable = 'user_item_state';

  /// Seam-Map key holding the list of `user_course` rows.
  static const String coursesKey = 'courses';

  /// Seam-Map key holding the list of `user_item_state` rows.
  static const String itemsKey = 'items';

  @override
  Future<Map<String, Object?>> load(String userId) async {
    final List<Map<String, dynamic>> courses =
        await _db.from(courseTable).select().eq('user_id', userId);
    final List<Map<String, dynamic>> items =
        await _db.from(itemTable).select().eq('user_id', userId);
    return <String, Object?>{
      coursesKey: courses.map((row) => Map<String, Object?>.from(row)).toList(),
      itemsKey: items.map((row) => Map<String, Object?>.from(row)).toList(),
    };
  }

  @override
  Future<void> save(String userId, Map<String, Object?> state) async {
    final List<Map<String, Object?>> courses =
        rowsFor(state[coursesKey], userId);
    final List<Map<String, Object?>> items = rowsFor(state[itemsKey], userId);
    // Upsert each HOMOGENEOUS batch on its own. A bulk upsert of rows with
    // DIFFERENT column sets fails on PostgREST: postgrest-dart sends the union
    // of keys as `columns`, so any NOT-NULL column a given row omits is written
    // as NULL -> 23502. INC-15 saves a per-course row (xp/lessons/theta)
    // alongside the canonical `__global__` row (streak/diamonds) in one save,
    // and their column sets are disjoint; batching by column set keeps every
    // upsert valid. Homogeneous input (e.g. item rows) yields ONE batch, so
    // those saves are unchanged.
    for (final List<Map<String, Object?>> batch in upsertBatches(courses)) {
      await _db.from(courseTable).upsert(
            batch,
            onConflict: 'user_id,target_locale',
            defaultToNull: false,
          );
    }
    for (final List<Map<String, Object?>> batch in upsertBatches(items)) {
      await _db.from(itemTable).upsert(
            batch,
            onConflict: 'user_id,item_id',
            defaultToNull: false,
          );
    }
  }

  /// Split [rows] into batches that each share an IDENTICAL column set, so a
  /// bulk `upsert` never mixes columns. (PostgREST bulk-inserts the union of
  /// keys as `columns` and sets any NOT-NULL column a row omits to NULL ->
  /// error 23502; heterogeneous rows must therefore be upserted in separate,
  /// homogeneous batches.) Preserves first-seen order; a homogeneous input
  /// returns a single batch, and an empty input returns no batches.
  static List<List<Map<String, Object?>>> upsertBatches(
    List<Map<String, Object?>> rows,
  ) {
    final Map<String, List<Map<String, Object?>>> byShape =
        <String, List<Map<String, Object?>>>{};
    for (final Map<String, Object?> row in rows) {
      final List<String> keys = row.keys.toList()..sort();
      final String shape = keys.join(',');
      byShape.putIfAbsent(shape, () => <Map<String, Object?>>[]).add(row);
    }
    return byShape.values.toList();
  }

  /// Coerce an opaque seam value into a list of row-maps, stamping the owning
  /// [userId] on every row so it satisfies the own-row RLS check
  /// (`user_id = auth.uid()`) and a caller can never write another user's row.
  /// A non-list input (or non-map entries within it) contributes no rows, so an
  /// absent section simply saves nothing.
  static List<Map<String, Object?>> rowsFor(Object? raw, String userId) {
    if (raw is! List) {
      return const <Map<String, Object?>>[];
    }
    final rows = <Map<String, Object?>>[];
    for (final entry in raw) {
      if (entry is! Map) {
        continue;
      }
      final row = <String, Object?>{};
      entry.forEach((key, value) {
        row[key.toString()] = value;
      });
      row['user_id'] = userId;
      rows.add(row);
    }
    return rows;
  }
}
