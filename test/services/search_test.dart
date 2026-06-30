// R-L12 · Global search — pure-engine unit coverage (titles + tags + full-text).
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

// Full-text fixtures: the query lives only in the lesson's exercise content.
const List<SearchableLesson> _ftLessons = <SearchableLesson>[
  SearchableLesson(
      id: 'es-greet-1',
      title: 'Greetings',
      cefr: 'A1',
      unitTitle: 'Level A1',
      terms: <String>['hola', 'buenos días']),
  SearchableLesson(
      id: 'es-food-1',
      title: 'Food & drink',
      cefr: 'A1',
      unitTitle: 'Level A1',
      terms: <String>['la manzana', 'el agua']),
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

  test('full-text: a query matching only exercise content finds the lesson', () {
    final List<SearchHit> hits = GlobalSearch.run('hola',
        lessons: _ftLessons, words: const <SearchableWord>[]);
    expect(
        hits.any((SearchHit h) =>
            h.kind == SearchHitKind.lesson && h.title == 'Greetings'),
        isTrue);
  });

  test('a title match outranks a content-only match', () {
    const List<SearchableLesson> mix = <SearchableLesson>[
      SearchableLesson(
          id: 'b',
          title: 'Greetings',
          cefr: 'A1',
          unitTitle: 'U',
          terms: <String>['I like food']),
      SearchableLesson(
          id: 'a', title: 'Food & drink', cefr: 'A1', unitTitle: 'U'),
    ];
    final List<SearchHit> hits =
        GlobalSearch.run('food', lessons: mix, words: const <SearchableWord>[]);
    expect(hits.first.title, 'Food & drink');
  });
}
