import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/library/library_screen.dart';
import 'package:ratel/features/library/last_read_controller.dart';
import 'package:ratel/services/library/last_read_store.dart';

// s163 INC-C3 — the Library CONTINUE card in isolation: NOT shown in the honest
// empty state, shown (as the first Read&Listen item) when a recorded pointer
// resolves in the current spine, and dropped when the pointer is stale.

CourseStory _story(String id, String title, String cefr) => CourseStory(
    id: id, title: title, cefr: cefr, sentences: const <String>['Hola.']);

CourseSpine _spine() => CourseSpine(
      courseCode: 'es',
      units: const <CourseUnit>[],
      stories: <CourseStory>[
        _story('s1', 'El mercado', 'A2'),
        _story('s2', 'La receta', 'A2'),
      ],
    );

const LastReadRef _s2 = LastReadRef(
    courseCode: 'es', passageId: 's2', title: 'La receta', cefr: 'A2');

Future<void> _pump(WidgetTester tester,
    {required CourseSpine spine, LastReadRef? seed}) async {
  tester.view.physicalSize = const Size(460, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[
      courseSpineProvider.overrideWithValue(spine),
      lastReadStoreProvider.overrideWithValue(InMemoryLastReadStore(seed)),
    ],
    child: const MaterialApp(home: LibraryScreen()),
  ));
  await tester.pump();
}

const Key _card = ValueKey<String>('lib-continue');

void main() {
  testWidgets('empty state: no CONTINUE card (honest — nothing opened yet)',
      (WidgetTester tester) async {
    await _pump(tester, spine: _spine()); // no seed
    expect(find.byKey(_card), findsNothing);
    expect(find.text('CONTINUE'), findsNothing);
  });

  testWidgets('recorded + resolvable pointer renders the CONTINUE card',
      (WidgetTester tester) async {
    await _pump(tester, spine: _spine(), seed: _s2);
    expect(find.byKey(_card), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
    // Title/level come from the LIVE spine story (spine wins on display).
    expect(find.descendant(of: find.byKey(_card), matching: find.text('La receta')),
        findsOneWidget);
    expect(
        find.descendant(
            of: find.byKey(_card), matching: find.text('Level A2 · ~1 min')),
        findsOneWidget);
  });

  testWidgets('stale pointer (id not in spine) ⇒ no card', (WidgetTester tester) async {
    const LastReadRef gone = LastReadRef(
        courseCode: 'es', passageId: 'ghost', title: 'Old', cefr: 'A2');
    await _pump(tester, spine: _spine(), seed: gone);
    expect(find.byKey(_card), findsNothing);
  });

  testWidgets('pointer from a different course ⇒ no card', (WidgetTester tester) async {
    const LastReadRef other = LastReadRef(
        courseCode: 'fr', passageId: 's2', title: 'La receta', cefr: 'A2');
    await _pump(tester, spine: _spine(), seed: other);
    expect(find.byKey(_card), findsNothing);
  });

  testWidgets('CONTINUE renders BEFORE the Graded Stories rows',
      (WidgetTester tester) async {
    await _pump(tester, spine: _spine(), seed: _s2);
    final double continueY =
        tester.getTopLeft(find.byKey(_card)).dy;
    // The graded inline row for the OTHER story ('El mercado' is featured, so
    // 'La receta' is also the graded row) — CONTINUE must sit above the section
    // body. Use the "All stories" browse row as a stable "below" anchor.
    final double allStoriesY =
        tester.getTopLeft(find.text('All stories')).dy;
    expect(continueY, lessThan(allStoriesY));
  });
}
