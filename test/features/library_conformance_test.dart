import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/library/library_screen.dart';
import 'package:ratel/features/library/last_read_controller.dart';
import 'package:ratel/services/library/last_read_store.dart';

/// UXA S115-L5 — Library §4.2 dense-rebuild conformance (owner-bundle b-lib.png):
///  B-1 Featured Story card from the REAL first authored story.
///  B-3 inline Graded-Stories / Podcasts / Watch rows from the REAL course.
///  B-6 Adventures "NEW · EXPLORE" eyebrow + "Start exploring →" CTA.
///  Honest deltas (§E): the mock's "· N min" is a COMPUTED "· ~N min" reading-
///  time ESTIMATE from the sentence count (CEFR-only when a story has none —
///  never "~0 min"), the s163 CONTINUE card shown ONLY for a real+resolvable
///  last-read pointer (empty state ⇒ none), no per-podcast PRO badge (no
///  per-item tier).
/// Plus a layout gauntlet at 460 & 800 px (session-craft §11).

CourseStory _story(String id, String title, String cefr,
        {String? audio, String? video}) =>
    CourseStory(
      id: id,
      title: title,
      cefr: cefr,
      sentences: const <String>['Hola.'],
      audioUrl: audio,
      videoUrl: video,
    );

// A story the batch authored with NO resolved sentences: its row must show
// CEFR only (no estimate) — the honesty guard for the no-content case (§E).
CourseStory _emptyStory(String id, String title, String cefr) => CourseStory(
      id: id,
      title: title,
      cefr: cefr,
      sentences: const <String>[],
    );

// Two graded stories, BOTH with no sentences: the first is consumed by the
// Featured card, the second becomes the inline graded row. Neither may show a
// minute estimate ⇒ the whole screen has NO " min" text, and the inline row's
// subtitle is exactly 'Story · A1' (the honesty guard for the no-content case).
CourseSpine _noSentenceSpine() => CourseSpine(
      courseCode: 'es',
      units: const <CourseUnit>[],
      stories: <CourseStory>[
        _emptyStory('e0', 'Portada', 'A1'),
        _emptyStory('e1', 'Sin texto', 'A1'),
      ],
    );

CourseSpine _spine() => CourseSpine(
      courseCode: 'es',
      units: const <CourseUnit>[],
      stories: <CourseStory>[
        _story('s1', 'El mercado', 'A2'),
        _story('s2', 'La receta', 'A2'),
      ],
      podcasts: <CourseStory>[
        _story('p1', 'Cafe con leche', 'A2', audio: 'https://r2/p1.mp3'),
      ],
      watch: <CourseStory>[
        _story('w1', 'Saludos', 'A1', video: 'https://r2/w1.mp4'),
      ],
    );

Future<void> _pump(WidgetTester tester, double width,
    {CourseSpine? spine, LastReadRef? lastRead}) async {
  tester.view.physicalSize = Size(width, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[
      if (spine != null) courseSpineProvider.overrideWithValue(spine),
      lastReadStoreProvider
          .overrideWithValue(InMemoryLastReadStore(lastRead)),
    ],
    child: const MaterialApp(home: LibraryScreen()),
  ));
  await tester.pump();
}

void main() {
  // Pure unit: the display-only reading-time estimate (INC-LIB1). ~4
  // sentences/minute, clamped to >=1, and 0 (⇒ rendered as nothing) when the
  // story has no resolved sentences — so a no-content row never shows '~0 min'.
  group('CourseStory.estMinutes (computed reading-time estimate)', () {
    CourseStory withSentences(int n) => CourseStory(
          id: 'x',
          title: 't',
          cefr: 'A1',
          sentences: List<String>.generate(n, (int i) => 'Sentence $i.'),
        );
    test('0 sentences ⇒ 0 (no estimate shown)', () {
      expect(withSentences(0).estMinutes, 0);
    });
    test('1 sentence ⇒ clamped up to 1', () {
      expect(withSentences(1).estMinutes, 1);
    });
    test('4 sentences ⇒ 1', () {
      expect(withSentences(4).estMinutes, 1);
    });
    test('5 sentences ⇒ 2 (ceil)', () {
      expect(withSentences(5).estMinutes, 2);
    });
    test('9 sentences ⇒ 3 (ceil)', () {
      expect(withSentences(9).estMinutes, 3);
    });
  });

  group('Library §4.2 dense rebuild', () {
    testWidgets('B-1: Featured Story from the REAL first story',
        (WidgetTester tester) async {
      await _pump(tester, 460, spine: _spine());
      expect(find.text('FEATURED · STORY'), findsOneWidget);
      expect(find.text('El mercado'), findsOneWidget); // stories.first
      expect(find.text('Read now'), findsOneWidget);
    });

    testWidgets('B-1: Featured level line appends the computed "~N min" estimate',
        (WidgetTester tester) async {
      await _pump(tester, 460, spine: _spine());
      // stories.first ('El mercado', A2, 1 sentence) ⇒ 'Level A2 · ~1 min'.
      expect(find.text('Level A2 · ~1 min'), findsOneWidget);
    });

    testWidgets('B-1: no Featured Story when the course authors none (honest)',
        (WidgetTester tester) async {
      await _pump(tester, 460); // default CourseSpine.empty
      expect(find.text('FEATURED · STORY'), findsNothing);
    });

    testWidgets('B-3: inline Graded-Stories / Podcasts / Watch rows are REAL',
        (WidgetTester tester) async {
      await _pump(tester, 460, spine: _spine());
      // Graded stories skips the featured first story ⇒ shows the second.
      expect(find.text('La receta'), findsOneWidget);
      expect(find.text('Cafe con leche'), findsOneWidget);
      expect(find.text('Saludos'), findsOneWidget);
      // Honest subtitle: kind + REAL CEFR + a COMPUTED "· ~N min" estimate.
      // Each fixture story has 1 sentence ⇒ ceil(1/4) clamped to 1 ⇒ "~1 min".
      expect(find.text('Podcast · A2 · ~1 min'), findsOneWidget);
      // The estimate carries a '~' (a display estimate, never an authored fact).
      expect(find.textContaining('~1 min'), findsWidgets);
      // …and is NEVER a bare (authored-looking) "N min" with no '~'.
      expect(find.text('Podcast · A2 · 1 min'), findsNothing);
    });

    testWidgets('B-3: empty course still shows honest browse rows',
        (WidgetTester tester) async {
      await _pump(tester, 460);
      expect(find.text('All stories'), findsOneWidget);
      expect(find.text('All podcasts'), findsOneWidget);
      expect(find.text('All videos'), findsOneWidget);
    });

    testWidgets(
        'honesty: a story with NO sentences shows CEFR only (never "~0 min")',
        (WidgetTester tester) async {
      await _pump(tester, 460, spine: _noSentenceSpine());
      // The inline graded row (second empty story) is exactly kind + CEFR.
      expect(find.text('Story · A1'), findsOneWidget);
      // No estimate is rendered ANYWHERE when no story has sentences —
      // neither a bare 'N min' nor a fabricated '~0 min'.
      expect(find.textContaining(' min'), findsNothing);
      expect(find.textContaining('~0'), findsNothing);
    });

    testWidgets('B-6: Adventures eyebrow + CTA',
        (WidgetTester tester) async {
      await _pump(tester, 460);
      expect(find.text('NEW · EXPLORE'), findsOneWidget);
      expect(find.text('Start exploring →'), findsOneWidget);
    });

    // s163 INC-C3 — the honest CONTINUE contract (this replaces the old
    // "no resume engine" omission): NOTHING is shown until the learner has
    // actually opened a story on this device AND it still resolves in the
    // current spine; a stale/foreign pointer is dropped (clearIfStale). We
    // never fabricate a progress %/time-left.
    testWidgets('honest: no CONTINUE card in the empty state (nothing opened yet)',
        (WidgetTester tester) async {
      await _pump(tester, 460, spine: _spine()); // no last-read seeded
      expect(find.byKey(const ValueKey<String>('lib-continue')), findsNothing);
      expect(find.text('CONTINUE'), findsNothing);
    });

    testWidgets('INC-C3: a recorded + resolvable last-read shows the CONTINUE card',
        (WidgetTester tester) async {
      await _pump(tester, 460,
          spine: _spine(),
          lastRead: const LastReadRef(
              courseCode: 'es',
              passageId: 's2',
              title: 'La receta',
              cefr: 'A2'));
      expect(
          find.byKey(const ValueKey<String>('lib-continue')), findsOneWidget);
      expect(find.text('CONTINUE'), findsOneWidget);
      // Spine wins on display: the LIVE story title/level render on the card.
      expect(
          find.descendant(
              of: find.byKey(const ValueKey<String>('lib-continue')),
              matching: find.text('La receta')),
          findsOneWidget);
    });

    testWidgets('INC-C3: a stale last-read (id not in spine) shows NO card',
        (WidgetTester tester) async {
      await _pump(tester, 460,
          spine: _spine(),
          lastRead: const LastReadRef(
              courseCode: 'es',
              passageId: 'not-in-spine',
              title: 'Gone',
              cefr: 'A2'));
      expect(find.byKey(const ValueKey<String>('lib-continue')), findsNothing);
    });

    for (final double w in <double>[460, 800]) {
      // Populated spine: every row/Featured card now carries the extra
      // " · ~N min" — the subtitle must still not overflow at either width.
      testWidgets('layout gauntlet @ ${w.toInt()}px — no overflow (with estimate)',
          (WidgetTester tester) async {
        await _pump(tester, w, spine: _spine());
        expect(tester.takeException(), isNull);
        expect(find.byKey(const ValueKey<String>('tab-library')),
            findsOneWidget);
        // The estimate is present on a populated row (guards the append path).
        expect(find.textContaining('~1 min'), findsWidgets);
      });
      // No-sentence spine: the CEFR-only path must also lay out cleanly.
      testWidgets('layout gauntlet @ ${w.toInt()}px — no overflow (no sentences)',
          (WidgetTester tester) async {
        await _pump(tester, w, spine: _noSentenceSpine());
        expect(tester.takeException(), isNull);
        expect(find.textContaining(' min'), findsNothing);
      });
    }
  });
}
