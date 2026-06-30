/// Pure, deterministic GLOBAL-SEARCH engine (design spec §4.2 / R-L12 "Global
/// search"). It matches a query against the learner's REAL, published catalogue
/// — authored course lessons, their saved words, and the app's genuine
/// navigable destinations — and returns type-tagged hits that route straight
/// through. Exact, clockless, holds no state and does no IO: the caller adapts
/// the live providers (course spine + saved words) into the lightweight inputs
/// below, so a fresh account with an empty course honestly returns nothing.
///
/// Honesty (charter "don't fake depth"): the engine invents no results and ranks
/// only genuine matches. Per the LOCKED R-L12 decision it searches TITLES + TAGS
/// at launch; full sentence/gloss text, a server content index, multi-course
/// scope and recent/trending are the spec's explicitly-deferred fast-follow —
/// never fabricated here. Layer rule: this file imports nothing from
/// `lib/features` (pure engine), exactly like the other `lib/services` engines.
library;

/// The kind of thing a [SearchHit] points at — drives its type tag and glyph.
enum SearchHitKind { lesson, word, destination }

/// A published course lesson, flattened for search (the screen projects each
/// `CourseUnit`/`CourseLesson` of the live spine into one of these).
class SearchableLesson {
  const SearchableLesson({
    required this.id,
    required this.title,
    required this.cefr,
    required this.unitTitle,
    this.terms = const <String>[],
  });

  final String id;
  final String title;

  /// 'A1'..'C2' — shown as the result's type tag.
  final String cefr;
  final String unitTitle;

  /// The lesson's REAL published exercise text (prompts + accepted answers).
  /// Matched at the WEAKEST rank so full-text hits never outrank a title match
  /// (the R-L12 "extend to full text" fast-follow over already-authored content).
  final List<String> terms;
}

/// One of the learner's saved words, flattened for search.
class SearchableWord {
  const SearchableWord({required this.word, this.glyph});

  final String word;
  final String? glyph;
}

/// A real, navigable app destination searchable by name (R-L12 "plus app
/// destinations"). Every [route] is a genuine route registered in `buildRouter`.
class SearchDestination {
  const SearchDestination(this.title, this.subtitle, this.route, this.emoji);

  final String title;
  final String subtitle;
  final String route;
  final String emoji;
}

/// The app's real navigable destinations — each [route] exists in the router, so
/// a destination hit genuinely "taps straight through" (never a dead link).
const List<SearchDestination> kSearchDestinations = <SearchDestination>[
  SearchDestination('Practice hub', 'Mistakes, weak words & drills', '/practice', '🎯'),
  SearchDestination('AI Tutor', 'Talk, chat & roleplay', '/tutor', '🦡'),
  SearchDestination('Adventures', 'Real conversations — free', '/adventures', '🗺️'),
  SearchDestination('Leagues', 'Your weekly league', '/leagues', '🏆'),
  SearchDestination('Quests', 'Daily goals & quests', '/quests', '🎯'),
  SearchDestination('Progress', 'Your stats & streak', '/progress', '📊'),
  SearchDestination('Profile', 'Your profile', '/profile', '🦡'),
  SearchDestination('Settings', 'Account & preferences', '/settings', '⚙️'),
  SearchDestination('Shop', 'Spend your diamonds', '/shop', '💎'),
  SearchDestination('Notifications', 'Your milestone inbox', '/notifications', '🔔'),
];

/// One real, navigable search result.
class SearchHit {
  const SearchHit({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.tag,
    this.emoji,
  });

  final SearchHitKind kind;
  final String title;
  final String subtitle;

  /// The in-app route this hit taps through to (e.g. '/daily-quiz?lesson=…').
  final String route;

  /// The type tag shown on the result chip ('A1', 'Word', 'Page', …).
  final String tag;
  final String? emoji;

  @override
  bool operator ==(Object other) =>
      other is SearchHit &&
      other.kind == kind &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.route == route &&
      other.tag == tag &&
      other.emoji == emoji;

  @override
  int get hashCode => Object.hash(kind, title, subtitle, route, tag, emoji);
}

/// The pure global-search engine.
class GlobalSearch {
  const GlobalSearch._();

  /// Max hits returned (keeps the list scannable; the UI shows the top matches).
  static const int maxResults = 40;

  /// Search [query] across [lessons] (published authored content), the learner's
  /// [words], and the real app [destinations]. Returns ranked, type-tagged hits;
  /// an empty / whitespace-only query returns an empty list (the UI then shows
  /// its honest browse/empty state). Deterministic: ties break by kind then
  /// title, so tests can pin properties rather than incidental ordering.
  static List<SearchHit> run(
    String query, {
    required List<SearchableLesson> lessons,
    required List<SearchableWord> words,
    List<SearchDestination> destinations = kSearchDestinations,
  }) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) return const <SearchHit>[];

    final List<_Scored> scored = <_Scored>[];

    for (final SearchableLesson l in lessons) {
      int s = _score(l.title, q);
      if (s == 0 && _matchesAny(l.terms, q)) s = _kContentScore;
      if (s > 0) {
        scored.add(_Scored(
          s,
          SearchHit(
            kind: SearchHitKind.lesson,
            title: l.title,
            subtitle: '${l.unitTitle} · Lesson',
            route: '/daily-quiz?lesson=${Uri.encodeComponent(l.id)}',
            tag: l.cefr,
            emoji: '📘',
          ),
        ));
      }
    }

    for (final SearchableWord w in words) {
      final int s = _score(w.word, q);
      if (s > 0) {
        scored.add(_Scored(
          s,
          SearchHit(
            kind: SearchHitKind.word,
            title: w.word,
            subtitle: 'Saved word',
            route: '/practice',
            tag: 'Word',
            emoji: (w.glyph != null && w.glyph!.isNotEmpty) ? w.glyph : '📒',
          ),
        ));
      }
    }

    for (final SearchDestination d in destinations) {
      final int s = _score(d.title, q);
      if (s > 0) {
        scored.add(_Scored(
          s,
          SearchHit(
            kind: SearchHitKind.destination,
            title: d.title,
            subtitle: d.subtitle,
            route: d.route,
            tag: 'Page',
            emoji: d.emoji,
          ),
        ));
      }
    }

    scored.sort((_Scored a, _Scored b) {
      if (a.score != b.score) return b.score.compareTo(a.score);
      if (a.hit.kind != b.hit.kind) {
        return a.hit.kind.index.compareTo(b.hit.kind.index);
      }
      return a.hit.title.toLowerCase().compareTo(b.hit.title.toLowerCase());
    });

    final List<SearchHit> out = <SearchHit>[
      for (final _Scored s in scored) s.hit,
    ];
    return out.length > maxResults ? out.sublist(0, maxResults) : out;
  }

  /// Title/name match score: exact (5) > whole-string prefix (4) > word-start
  /// (3) > substring (2) > no match (0). Case-insensitive; [q] is already
  /// lower-cased and trimmed by [run]. Score 1 is reserved for [_kContentScore]
  /// so a deep full-text hit always ranks below any title/name match.
  static int _score(String field, String q) {
    final String f = field.toLowerCase();
    if (f == q) return 5;
    if (f.startsWith(q)) return 4;
    for (final String w in f.split(RegExp(r'\s+'))) {
      if (w.startsWith(q)) return 3;
    }
    return f.contains(q) ? 2 : 0;
  }

  /// Weakest signal: the query appears only in a lesson's deep CONTENT (an
  /// exercise prompt/answer), not its title — always ranked below title/name.
  static const int _kContentScore = 1;

  /// True if [q] matches any of a lesson's real exercise [terms].
  static bool _matchesAny(List<String> terms, String q) {
    for (final String t in terms) {
      if (_score(t, q) > 0) return true;
    }
    return false;
  }
}

class _Scored {
  const _Scored(this.score, this.hit);
  final int score;
  final SearchHit hit;
}
