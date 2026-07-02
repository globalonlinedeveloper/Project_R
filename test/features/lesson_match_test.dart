import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/lesson/lesson_runner_screen.dart';
import 'package:ratel/features/lesson/renderers/match_exercise.dart';

// WS4 WIRING (this increment): the runner appends a text-Match built from the
// course spine's REAL authored (prompt -> answer) pairs (>=3 distinct, else
// omitted). The Match auto-grades (no Check button) and folds one review into
// the REAL ability engine, then Continue advances. No dummy data. [R-D7]

/// Spine with 3 distinct authored pairs -> a Match item is created + appended.
const CourseSpine _spine3 = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(
      section: 'SECTION 1 · LEVEL A1',
      title: 'Level A1',
      lessons: <CourseLesson>[
        CourseLesson(id: 'lm1', title: 'Match me', cefr: 'A1', exercises: <CourseExercise>[
          CourseExercise(id: 'e1', exerciseType: 'translate', prompt: 'alpha', accepted: <String>['one']),
          CourseExercise(id: 'e2', exerciseType: 'translate', prompt: 'bravo', accepted: <String>['two']),
          CourseExercise(id: 'e3', exerciseType: 'translate', prompt: 'charlie', accepted: <String>['three']),
        ]),
      ]),
]);

/// Spine with only 2 distinct pairs -> NO Match (never faked below the floor).
const CourseSpine _spine2 = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(
      section: 'SECTION 1 · LEVEL A1',
      title: 'Level A1',
      lessons: <CourseLesson>[
        CourseLesson(id: 'lo1', title: 'Too few', cefr: 'A1', exercises: <CourseExercise>[
          CourseExercise(id: 'f1', exerciseType: 'translate', prompt: 'alpha', accepted: <String>['one']),
          CourseExercise(id: 'f2', exerciseType: 'translate', prompt: 'bravo', accepted: <String>['two']),
        ]),
      ]),
]);

Future<void> _pump(WidgetTester tester, ProviderContainer c, String lessonId) async {
  tester.view.physicalSize = const Size(440, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(home: LessonRunnerScreen(lessonId: lessonId)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the runner reaches a real text-Match, auto-grades, and advances',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spine3),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c, 'lm1');

    const List<List<String>> pairs = <List<String>>[
      <String>['alpha', 'one'],
      <String>['bravo', 'two'],
      <String>['charlie', 'three'],
    ];

    bool sawMatch = false;
    // 3 typed items + 1 Match = 4 items; drive whichever surfaces.
    for (int i = 0; i < 8; i++) {
      if (find.text('Lesson complete!').evaluate().isNotEmpty) break;
      if (find.byType(MatchExercise).evaluate().isNotEmpty) {
        sawMatch = true;
        // Footer offers Skip only — Match has no Check button.
        expect(find.text('Check'), findsNothing);
        // Resolve every pair correctly (no mismatch -> onGraded(true)).
        for (final List<String> pr in pairs) {
          await tester.tap(find.text(pr[0]));
          await tester.pump();
          await tester.tap(find.text(pr[1]));
          await tester.pump();
        }
        await tester.pumpAndSettle();
        expect(find.text('✓ Correct!'), findsOneWidget); // graded all-correct
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        continue;
      }
      // A typed item — any non-empty answer advances it (correctness covered
      // elsewhere; here we only need to REACH the Match).
      await tester.enterText(
          find.byKey(const ValueKey<String>('lesson-input')), 'x');
      await tester.pump();
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }

    expect(sawMatch, isTrue); // the Match really surfaced from real content
    expect(find.text('Lesson complete!'), findsOneWidget);
    // The Match folded a real review + the lesson awarded real XP.
    final LearnerSnapshot snap = c.read(learnerControllerProvider);
    expect(snap.lessonsCompleted, 1);
    expect(snap.xpTotal, greaterThan(0));
  });

  testWidgets('below the 3-pair floor, NO Match is served (only the typed items)',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spine2),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c, 'lo1');

    // Walk both typed items to completion; a Match must never appear.
    for (int i = 0; i < 6 && find.text('Lesson complete!').evaluate().isEmpty; i++) {
      expect(find.byType(MatchExercise), findsNothing);
      await tester.enterText(
          find.byKey(const ValueKey<String>('lesson-input')), 'x');
      await tester.pump();
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Lesson complete!'), findsOneWidget);
    expect(find.byType(MatchExercise), findsNothing);
  });
}
