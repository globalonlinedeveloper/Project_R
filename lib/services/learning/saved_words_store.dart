import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/services/learning/saved_words.dart' show SavedWordKey;

/// Portability seam (R-M3): durable backlog for tap-to-save words. The
/// [SavedWordsModel] engine stays pure (it takes `alreadySaved` IN); this seam
/// owns where that set LIVES. Stage 1–2 default is in-memory (an honestly
/// empty backlog each boot); Stage 3 plugs the Supabase `saved_words` table
/// behind the SAME interface. Consumed by the future saved-words surface —
/// wired now so the backend is live the moment the UI lands (O-3, S110).
abstract interface class SavedWordsStore {
  /// Every saved key for [courseId] (empty for a fresh learner — never fake).
  Future<Set<SavedWordKey>> loadSaved(String courseId);

  /// Persist one saved word ([raw] = the surface form the learner tapped).
  Future<void> saveWord(SavedWordKey key, String raw);

  /// Remove one saved word (learner-curated list stays learner-editable).
  Future<void> removeWord(SavedWordKey key);
}

/// Default (local / Stage 1–2): ephemeral in-memory backlog (R-O1 stub).
class InMemorySavedWordsStore implements SavedWordsStore {
  final Map<String, Set<SavedWordKey>> _byCourse = <String, Set<SavedWordKey>>{};

  @override
  Future<Set<SavedWordKey>> loadSaved(String courseId) async =>
      <SavedWordKey>{...?_byCourse[courseId]};

  @override
  Future<void> saveWord(SavedWordKey key, String raw) async =>
      (_byCourse[key.courseId] ??= <SavedWordKey>{}).add(key);

  @override
  Future<void> removeWord(SavedWordKey key) async =>
      _byCourse[key.courseId]?.remove(key);
}

/// The saved-words persistence seam. Defaults to in-memory; `main` overrides
/// it with the Supabase-backed store when the backend is configured.
final savedWordsStoreProvider =
    Provider<SavedWordsStore>((ref) => InMemorySavedWordsStore());
