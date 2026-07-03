import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/lesson/lesson_runner_screen.dart';

// Guided-Writing (INF-5): a `write` CourseExercise (no accepted[], carries a
// display rubric + deterministic rubric_spec checks) surfaces via its OWN
// renderer -- the writing prompt as the title, the display rubric as guidance,
// a multi-line free-text box -- and self-grades DETERMINISTICALLY + UN-GATED
// (min words / required lemmas / terminal punctuation). No live AI.

CourseSpine _spineWithWrite() => const CourseSpine(
      courseCode: 'en',
      units: <CourseUnit>[
        CourseUnit(
          section: 'SECTION 1 · FOUNDATIONS',
          title: 'First Words',
          lessons: <CourseLesson>[
            CourseLesson(
              id: 'l1',
              title: 'Guided Writing',
              cefr: 'A1',
              exercises: <CourseExercise>[
                CourseExercise(
                  id: 'item_w1',
                  exerciseType: 'write',
                  prompt: 'Introduce yourself in two short sentences.',
                  accepted: <String>[],
                  irtB: -1.0,
                  rubric:
                      'Write at least 6 words. Say hello and give your name.',
                  minTokens: 6,
                  requiredWords: <String>['hello', 'name'],
                  requireTerminalPunct: true,
                  explain: 'A strong answer greets and names you in full '
                      'sentences.',
                ),
              ],
            ),
          ],
        ),
      ],
    );

Future<void> _pump(WidgetTester tester, ProviderContainer c) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: const MaterialApp(home: LessonRunnerScreen(lessonId: 'l1')),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('write item renders prompt + rubric + multi-line box',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithWrite()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    expect(find.text('Introduce yourself in two short sentences.'),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('lesson-write-rubric')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('lesson-write-input')),
        findsOneWidget);
    // It is NOT the typed single-line renderer.
    expect(find.byKey(const ValueKey<String>('lesson-input')), findsNothing);
  });

  testWidgets('write self-grades CORRECT when the rubric is met',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithWrite()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    await tester.enterText(
        find.byKey(const ValueKey<String>('lesson-write-input')),
        'Hello, my name is Sam and I am new here.');
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('✓ Correct!'), findsOneWidget);
  });

  testWidgets('write self-grades NOT-QUITE when too short / missing a lemma',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithWrite()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    // 3 words, no 'hello'/'name', no terminal punctuation -> fails all checks.
    await tester.enterText(
        find.byKey(const ValueKey<String>('lesson-write-input')),
        'hi there friend');
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('✕ Not quite'), findsOneWidget);
  });
}
