// R-L12 · Global search — pure-engine unit coverage.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/search/search.dart';

const List<SearchableLesson> _lessons = <SearchableLesson>[
  SearchableLesson(
      id: 'es-food-1', title: 'Food & drink', cefr: 'A1', unitTitle: 'Level A1'),
  SearchableLesson(
      id: 'es-greet-1', title: 'Greetings', cefr: 'A1', unitTitle: 'Level A1'),
  SearchableLesson(
      id: 'es-past-1', title: 'Past tense', cefr: 'B1', unitTitle: 'Level B1'),
  SearchableLesson(
      id: 'es-past-2',
      title: 'A recap of the past',
      cefr: 'B1',
      unitTitle: 'Level B1'),
];

const List<SearchableWord> _words = <SearchableWord>[
  SearchableWord(word: 'manzana', glyph: '🍎'),
  SearchableWord(word: 'agua'),
];

void main() {
  test('empty / whitespace query returns no hits', () {
    expect(GlobalSearch.run('', lessons: _lessons, words: _words), isEmpty);
    expect(GlobalSearch.run('   ', lessons: _lessons, words: _words), isEmpty);
  });

  test('matches a lesson by title, type-tagged + routing through', () {
    final List<SearchHit> hits =
        GlobalSearch.run('food', lessons: _lessons, words: _words);
    final SearchHit hit =
        hits.firstWhere((SearchHit h) => h.kind == SearchHitKind.lesson);
    expect(hit.title, 'Food & drink');
    expect(hit.tag, 'A1');
    expect(hit.route, contains('/daily-quiz?lesson=es-food-1'));
  });

  test('search is case-insensitive', () {
    final List<SearchHit> lower =
        GlobalSearch.run('greetings', lessons: _lessons, words: _words);
    final List<SearchHit> upper =
        GlobalSearch.run('GREETINGS', lessons: _lessons, words: _words);
    expect(lower.first.title, 'Greetings');
    expect(upper.first.title, 'Greetings');
  });

  test('prefix matches rank above mere substring matches', () {
    // "Past tense" starts with the query (score 3); "A recap of the past" only
    // has "past" as a trailing word-start (score 2) → the prefix wins.
    final List<SearchHit> hits =
        GlobalSearch.run('past', lessons: _lessons, words: _words);
    expect(hits.first.title, 'Past tense');
  });

  test('matches a saved word, carrying its glyph + Word tag', () {
    final SearchHit hit = GlobalSearch.run('manz', lessons: _lessons, words: _words)
        .firstWhere((SearchHit h) => h.kind == SearchHitKind.word);
    expect(hit.title, 'manzana');
    expect(hit.tag, 'Word');
    expect(hit.emoji, '🍎');
    expect(hit.route, '/practice');
  });

  test('matches a real app destination by name', () {
    final SearchHit hit =
        GlobalSearch.run('settings', lessons: _lessons, words: _words)
            .firstWhere((SearchHit h) => h.kind == SearchHitKind.destination);
    expect(hit.title, 'Settings');
    expect(hit.tag, 'Page');
    expect(hit.route, '/settings');
  });

  test('no match returns an empty list (never a fabricated hit)', () {
    expect(GlobalSearch.run('zzzzzz', lessons: _lessons, words: _words), isEmpty);
  });

  test('results are capped at maxResults', () {
    final List<SearchableLesson> many = <SearchableLesson>[
      for (int i = 0; i < 60; i++)
        SearchableLesson(
            id: 'l$i', title: 'Lesson $i', cefr: 'A1', unitTitle: 'U'),
    ];
    final List<SearchHit> hits =
        GlobalSearch.run('lesson', lessons: many, words: const <SearchableWord>[]);
    expect(hits.length, GlobalSearch.maxResults);
  });

  test('every shipped destination route is non-empty (taps through)', () {
    for (final SearchDestination d in kSearchDestinations) {
      expect(d.route.startsWith('/'), isTrue, reason: d.title);
    }
  });
}
