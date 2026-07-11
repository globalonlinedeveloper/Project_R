import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/lesson/lesson_runner_screen.dart';

// INF-2.5: an authored-options mcq renders the REAL authored bank (stable-
// shuffled upstream), grades by the authored is_correct, and surfaces the
// authored "Explain this" texts — a correct pick shows the picked (correct)
// option's explanation, a wrong pick shows THAT distractor's explanation
// (both owner scenarios). Items WITHOUT options keep the typed path (the
// legacy ES course, regression-locked).
// [R-D10 · R-B4] authored MCQ runner + pre-generated explanation surfaces.

const CourseSpine _spineMcq =
    CourseSpine(courseCode: 'en', units: <CourseUnit>[
  CourseUnit(
    section: 'S',
    title: 'U',
    lessons: <CourseLesson>[
      CourseLesson(
          id: 'l1',
          title: 'Greet',
          cefr: 'A1',
          exercises: <CourseExercise>[
            CourseExercise(
              id: 'e1',
              exerciseType: 'mcq',
              prompt: 'Pick the morning greeting.',
              accepted: <String>['Good morning'],
              options: <CourseOption>[
                CourseOption(
                    text: 'Good morning',
                    isCorrect: true,
                    explain: 'RIGHT-EXPLAIN'),
                CourseOption(
                    text: 'Good night', isCorrect: false, explain: 'WRONG-B'),
                CourseOption(
                    text: 'Goodbye', isCorrect: false, explain: 'WRONG-C'),
              ],
              explain: 'ITEM-EXPLAIN',
            ),
          ]),
    ],
  ),
]);

const CourseSpine _spineNoOptions =
    CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(
    section: 'S',
    title: 'U',
    lessons: <CourseLesson>[
      CourseLesson(
          id: 'l1',
          title: 'T',
          cefr: 'A1',
          exercises: <CourseExercise>[
            CourseExercise(
                id: 'e1',
                exerciseType: 'mcq',
                prompt: 'p',
                accepted: <String>['hola']),
          ]),
    ],
  ),
]);

Future<void> _pump(WidgetTester tester, CourseSpine spine) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final ProviderContainer c = ProviderContainer(overrides: <Override>[
    courseSpineProvider.overrideWithValue(spine),
  ]);
  addTearDown(c.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: const MaterialApp(home: LessonRunnerScreen(lessonId: 'l1')),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('authored bank renders; CORRECT pick grades + explains',
      (WidgetTester tester) async {
    await _pump(tester, _spineMcq);
    // The REAL authored texts render as a bank (stable-shuffled order).
    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('Good night'), findsOneWidget);
    expect(find.text('Goodbye'), findsOneWidget);
    // Not the typed renderer.
    expect(find.byKey(const ValueKey<String>('lesson-input')), findsNothing);

    await tester.tap(find.text('Good morning'));
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('✓ Nicely done!'), findsOneWidget);

    // Explain this -> the picked (correct) option's authored explanation.
    await tester.tap(find.byKey(const ValueKey<String>('lesson-explain-btn')));
    await tester.pumpAndSettle();
    expect(find.text('RIGHT-EXPLAIN'), findsOneWidget);
    expect(find.text('WRONG-B'), findsNothing);
    await tester.tapAt(const Offset(5, 5)); // dismiss the sheet
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Lesson complete!'), findsOneWidget);
  });

  testWidgets('WRONG pick grades ✕, shows the answer + THAT distractor explain',
      (WidgetTester tester) async {
    await _pump(tester, _spineMcq);
    await tester.tap(find.text('Good night'));
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('✕ Not quite'), findsOneWidget);
    expect(find.text('Answer: Good morning'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('lesson-explain-btn')));
    await tester.pumpAndSettle();
    expect(find.text('WRONG-B'), findsOneWidget); // the PICKED distractor
    expect(find.text('RIGHT-EXPLAIN'), findsNothing);
  });

  testWidgets('mcq WITHOUT options stays on the typed path (ES regression)',
      (WidgetTester tester) async {
    await _pump(tester, _spineNoOptions);
    expect(find.byKey(const ValueKey<String>('lesson-input')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('lesson-mcq-0')), findsNothing);
    await tester.enterText(
        find.byKey(const ValueKey<String>('lesson-input')), 'hola');
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('✓ Nicely done!'), findsOneWidget);
    // No authored explanation -> no Explain button.
    expect(find.byKey(const ValueKey<String>('lesson-explain-btn')),
        findsNothing);
  });
}
