import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/library/library_screen.dart';

/// UXA S115-L5 — Library §4.2 dense-rebuild conformance (owner-bundle b-lib.png):
///  B-1 Featured Story card from the REAL first authored story.
///  B-3 inline Graded-Stories / Podcasts / Watch rows from the REAL course.
///  B-6 Adventures "NEW · EXPLORE" eyebrow + "Start exploring →" CTA.
///  Honest deltas (§E): no "· N min" (no duration on CourseStory), no Continue
///  card (no resume engine), no per-podcast PRO badge (no per-item tier).
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
    {CourseSpine? spine}) async {
  tester.view.physicalSize = Size(width, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[
      if (spine != null) courseSpineProvider.overrideWithValue(spine),
    ],
    child: const MaterialApp(home: LibraryScreen()),
  ));
  await tester.pump();
}

void main() {
  group('Library §4.2 dense rebuild', () {
    testWidgets('B-1: Featured Story from the REAL first story',
        (WidgetTester tester) async {
      await _pump(tester, 460, spine: _spine());
      expect(find.text('FEATURED · STORY'), findsOneWidget);
      expect(find.text('El mercado'), findsOneWidget); // stories.first
      expect(find.text('Read now'), findsOneWidget);
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
      // Honest subtitle: kind + REAL CEFR, and NO fabricated "· N min".
      expect(find.text('Podcast · A2'), findsOneWidget);
      expect(find.textContaining(' min'), findsNothing);
    });

    testWidgets('B-3: empty course still shows honest browse rows',
        (WidgetTester tester) async {
      await _pump(tester, 460);
      expect(find.text('All stories'), findsOneWidget);
      expect(find.text('All podcasts'), findsOneWidget);
      expect(find.text('All videos'), findsOneWidget);
    });

    testWidgets('B-6: Adventures eyebrow + CTA',
        (WidgetTester tester) async {
      await _pump(tester, 460);
      expect(find.text('NEW · EXPLORE'), findsOneWidget);
      expect(find.text('Start exploring →'), findsOneWidget);
    });

    testWidgets('honest: no Continue/resume card (no resume engine, §E)',
        (WidgetTester tester) async {
      await _pump(tester, 460, spine: _spine());
      expect(find.text('Continue'), findsNothing);
      expect(find.textContaining('Resume'), findsNothing);
    });

    for (final double w in <double>[460, 800]) {
      testWidgets('layout gauntlet @ ${w.toInt()}px — no overflow',
          (WidgetTester tester) async {
        await _pump(tester, w, spine: _spine());
        expect(tester.takeException(), isNull);
        expect(find.byKey(const ValueKey<String>('tab-library')),
            findsOneWidget);
      });
    }
  });
}
