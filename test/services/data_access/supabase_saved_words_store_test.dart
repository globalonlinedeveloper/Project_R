import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/data_access/supabase_saved_words_store.dart';
import 'package:ratel/services/learning/learning.dart';

void main() {
  const SavedWordKey key =
      SavedWordKey(courseId: 'en', normalizedLemma: 'bakery');

  test('rowFor stamps the owner + the dedup identity', () {
    expect(SupabaseSavedWordsStore.rowFor(key, 'Bakeries', 'u1'),
        <String, Object?>{
          'user_id': 'u1',
          'course_id': 'en',
          'normalized_lemma': 'bakery',
          'raw_word': 'Bakeries',
        });
  });

  test('keysFromRows round-trips and skips garbage rows', () {
    expect(
      SupabaseSavedWordsStore.keysFromRows(<Map<String, dynamic>>[
        <String, dynamic>{'course_id': 'en', 'normalized_lemma': 'bakery'},
        <String, dynamic>{'course_id': null, 'normalized_lemma': 'x'},
        <String, dynamic>{'course_id': 'en'},
      ]),
      <SavedWordKey>{key},
    );
  });

  test('guest store (null client) fail-opens empty + write no-ops', () async {
    final SupabaseSavedWordsStore store = SupabaseSavedWordsStore(null);
    expect(await store.loadSaved('en'), isEmpty);
    await store.saveWord(key, 'Bakeries');
    await store.removeWord(key);
  });

  test('InMemorySavedWordsStore saves / loads / removes per course', () async {
    final InMemorySavedWordsStore store = InMemorySavedWordsStore();
    await store.saveWord(key, 'Bakeries');
    expect(await store.loadSaved('en'), <SavedWordKey>{key});
    expect(await store.loadSaved('fr'), isEmpty);
    await store.removeWord(key);
    expect(await store.loadSaved('en'), isEmpty);
  });
}
