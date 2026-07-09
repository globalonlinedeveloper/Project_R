import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ratel/services/learning/saved_words.dart' show SavedWordKey;
import 'package:ratel/services/learning/saved_words_store.dart';

/// Stage-3 [SavedWordsStore] backed by the own-row `saved_words` table. Keys
/// are (user, course, normalized lemma) — the same dedup identity the pure
/// [SavedWordsModel] uses — so a word saved on any device is saved everywhere.
/// Reads fail-open to an EMPTY set and writes are best-effort (offline play
/// never blocks on the backlog).
class SupabaseSavedWordsStore implements SavedWordsStore {
  SupabaseSavedWordsStore(this._db);

  /// Wire to the live Supabase client (its `auth.uid()` owns every row).
  factory SupabaseSavedWordsStore.fromClient(SupabaseClient client) =>
      SupabaseSavedWordsStore(client);

  final SupabaseClient? _db;

  /// Learner-curated saved-words table.
  static const String table = 'saved_words';

  String? get _uid => _db?.auth.currentUser?.id;

  @override
  Future<Set<SavedWordKey>> loadSaved(String courseId) async {
    final SupabaseClient? db = _db;
    final String? uid = _uid;
    if (db == null || uid == null) return const <SavedWordKey>{};
    try {
      final List<Map<String, dynamic>> rows = await db
          .from(table)
          .select('course_id, normalized_lemma')
          .eq('user_id', uid)
          .eq('course_id', courseId);
      return keysFromRows(rows);
    } catch (_) {
      return const <SavedWordKey>{}; // fail-open: empty, never fake
    }
  }

  @override
  Future<void> saveWord(SavedWordKey key, String raw) async {
    final SupabaseClient? db = _db;
    final String? uid = _uid;
    if (db == null || uid == null) return;
    try {
      await db.from(table).upsert(rowFor(key, raw, uid));
    } catch (_) {/* offline-tolerant */}
  }

  @override
  Future<void> removeWord(SavedWordKey key) async {
    final SupabaseClient? db = _db;
    final String? uid = _uid;
    if (db == null || uid == null) return;
    try {
      await db
          .from(table)
          .delete()
          .eq('user_id', uid)
          .eq('course_id', key.courseId)
          .eq('normalized_lemma', key.normalizedLemma);
    } catch (_) {/* offline-tolerant */}
  }

  /// Pure: a saved word as its own-row `saved_words` row.
  static Map<String, Object?> rowFor(
          SavedWordKey key, String raw, String userId) =>
      <String, Object?>{
        'user_id': userId,
        'course_id': key.courseId,
        'normalized_lemma': key.normalizedLemma,
        'raw_word': raw,
      };

  /// Pure: `saved_words` rows back into seam keys.
  static Set<SavedWordKey> keysFromRows(List<Map<String, dynamic>> rows) =>
      <SavedWordKey>{
        for (final Map<String, dynamic> r in rows)
          if (r['course_id'] != null && r['normalized_lemma'] != null)
            SavedWordKey(
              courseId: r['course_id'].toString(),
              normalizedLemma: r['normalized_lemma'].toString(),
            ),
      };
}
