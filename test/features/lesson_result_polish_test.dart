import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/lesson/lesson_runner_screen.dart';

// Q-1 (screen review 2026-07 §2): the lesson-complete surface carries the
// design's celebration — gold LESSON COMPLETE kicker, ACCURACY-TIERED emoji
// hero with a reduce-motion-safe pop-in, and the TOTAL XP / ACCURACY / TIME
// stat-card row. Accuracy comes from the REAL graded denominator (_graded),
// the same number study-stats records. Display-only: awarded XP stays +20.

const CourseSpine _spine = CourseSpine(courseCode: 'en', units: <CourseUnit>[
  CourseUnit(section: 'S', title: 'U', lessons: <CourseLesson>[
    CourseLesson(id: 'l1', title: 'T', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(
        id: 'e1',
        exerciseType: 'mcq',
        prompt: 'Pick RIGHT.',
        accepted: <String>['RIGHT'],
        options: <CourseOption>[
          CourseOption(text: 'RIGHT', isCorrect: true),
          CourseOption(text: 'WRONG', isCorrect: false),
        ],
      ),
    ]),
  ]),
]);

Future<void> _pump(
  WidgetTester tester, {
  bool reduceMotion = false,
  double width = 460,
}) async {
  tester.view.physicalSize = Size(width, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final ProviderContainer c = ProviderContainer(overrides: <Override>[
    courseSpineProvider.overrideWithValue(_spine),
    if (reduceMotion) reduceMotionProvider.overrideWithValue(true),
  ]);
  addTearDown(c.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(
      key: ValueKey<double>(width), // fresh State per width (S124 gotcha)
      home: const LessonRunnerScreen(lessonId: 'l1'),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _complete(WidgetTester tester, {required bool correct}) async {
  await tester.tap(find.text(correct ? 'RIGHT' : 'WRONG'));
  await tester.pump();
  await tester.tap(find.text('Check'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  expect(find.text('Lesson complete!'), findsOneWidget);
}

void main() {
  testWidgets('perfect run: kicker + trophy tier + REAL stat row',
      (WidgetTester tester) async {
    await _pump(tester);
    await _complete(tester, correct: true);
    expect(find.text('LESSON COMPLETE'), findsOneWidget);
    expect(find.text('\u{1F3C6}'), findsOneWidget); // 100% tier trophy
    expect(find.text('TOTAL XP'), findsOneWidget);
    expect(find.text('⚡ +20'), findsOneWidget); // awarded XP unchanged
    expect(find.text('ACCURACY'), findsOneWidget);
    expect(find.text('\u{1F3AF} 100%'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('⏱ 0:00'), findsOneWidget); // fake-async clock
    // Accuracy line uses the graded denominator, not the item count.
    expect(find.textContaining('1 of 1 correct'), findsOneWidget);
  });

  testWidgets('imperfect run: 0% lands the study tier, not the trophy',
      (WidgetTester tester) async {
    await _pump(tester);
    await _complete(tester, correct: false);
    expect(find.text('\u{1F4DA}'), findsOneWidget); // <50% tier
    expect(find.text('\u{1F3C6}'), findsNothing);
    expect(find.text('\u{1F3AF} 0%'), findsOneWidget);
    expect(find.textContaining('0 of 1 correct'), findsOneWidget);
  });

  testWidgets('reduce-motion: hero renders STATIC — no pop-in animation',
      (WidgetTester tester) async {
    await _pump(tester, reduceMotion: true);
    await _complete(tester, correct: true);
    expect(find.text('\u{1F3C6}'), findsOneWidget);
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
  });

  testWidgets('gauntlet: result overflows nowhere @360/430',
      (WidgetTester tester) async {
    for (final double w in <double>[360, 430]) {
      await _pump(tester, width: w);
      await _complete(tester, correct: true);
      expect(find.text('TOTAL XP'), findsOneWidget,
          reason: 'stat row missing @$w');
    }
  });
}
