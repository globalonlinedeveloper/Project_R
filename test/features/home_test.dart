import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// A small content-FREE spine standing in for the projected ContentBatch, so the
/// Home widget test never touches the codegen content layer (it stays in the
/// local gate). Mirrors the real projection shape: lessons grouped into CEFR
/// units, each lesson carrying real exercises.
const CourseSpine _testSpine = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(section: 'SECTION 1 · LEVEL A1', title: 'Level A1', lessons: <CourseLesson>[
    CourseLesson(id: 'l_greet', title: 'Saludos', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(id: 'i1', exerciseType: 'mcq', prompt: 'Say hello', accepted: <String>['hola']),
    ]),
    CourseLesson(id: 'l_food', title: 'Comida', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(id: 'i2', exerciseType: 'mcq', prompt: 'the apple', accepted: <String>['la manzana']),
      CourseExercise(id: 'i3', exerciseType: 'translate', prompt: 'I eat bread', accepted: <String>['como pan']),
    ]),
  ]),
  CourseUnit(section: 'SECTION 2 · LEVEL A2', title: 'Level A2', lessons: <CourseLesson>[
    CourseLesson(id: 'l_present', title: 'Presente simple', cefr: 'A2', exercises: <CourseExercise>[
      CourseExercise(id: 'i4', exerciseType: 'translate', prompt: 'She reads', accepted: <String>['ella lee']),
    ]),
  ]),
]);

Widget _appWith(CourseSpine spine) => ProviderScope(
      overrides: <Override>[courseSpineProvider.overrideWithValue(spine)],
      child: const RatelApp(),
    );

void main() {
  testWidgets('Home renders the content-driven path; node 0 active (real lessonsCompleted=0)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_appWith(_testSpine));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('tab-home')), findsOneWidget);
    // The current unit banner shows the real (projected) unit title + section.
    expect(find.textContaining('Level A1'), findsWidgets);
    // Exactly one START bubble — on the single active node (cold-start).
    expect(find.text('START'), findsOneWidget);
  });

  testWidgets('tapping the active node opens the lesson-preview with REAL lesson + exercise count (§4.6)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_appWith(_testSpine));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('home-active-node')));
    await tester.pumpAndSettle();
    expect(find.text('Saludos'), findsOneWidget); // real first lesson title
    expect(find.textContaining('1 exercise'), findsOneWidget); // real authored count
    expect(find.text('Start lesson'), findsOneWidget);
  });

  testWidgets('with NO course wired the path shows an HONEST empty state (never a fake curriculum)',
      (WidgetTester tester) async {
    // No override → courseSpineProvider default = CourseSpine.empty.
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('home-empty')), findsOneWidget);
    expect(find.textContaining('getting ready'), findsOneWidget);
    expect(find.text('START'), findsNothing); // no fabricated path
  });
}
