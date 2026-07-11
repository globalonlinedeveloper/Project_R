import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/lesson/lesson_runner_screen.dart';

// Q-4 (screen review 2026-07 §2): exercise option tiles announce to screen
// readers as labelled buttons — closing the register's only Semantics gap
// (word-bank RatelWordTile + authored-MCQ text tiles). Pick-pic
// (RatelOptionCard) and Match already carry the convention.

const CourseSpine _spineMcq = CourseSpine(courseCode: 'en', units: <CourseUnit>[
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

void main() {
  testWidgets('word-bank tile announces as a labelled button',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RatelWordTile(word: 'pan', onTap: () {}),
      ),
    ));
    expect(
      tester.getSemantics(find.byType(RatelWordTile)),
      isSemantics(isButton: true, label: 'pan', hasTapAction: true),
    );
    handle.dispose();
  });

  testWidgets('used word-bank tile keeps its label (still announced)',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: RatelWordTile(word: 'agua', used: true),
      ),
    ));
    expect(
      tester.getSemantics(find.byType(RatelWordTile)),
      isSemantics(isButton: true, label: 'agua'),
    );
    handle.dispose();
  });

  testWidgets('authored-MCQ tiles announce button + selection state',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineMcq),
    ]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: LessonRunnerScreen(lessonId: 'l1')),
    ));
    await tester.pumpAndSettle();

    // Idle: a labelled, unselected button.
    expect(
      tester.getSemantics(find.byKey(const ValueKey<String>('lesson-mcq-0'))),
      isSemantics(isButton: true, isSelected: false),
    );
    // Picked: the same tile announces selected.
    await tester.tap(find.text(
        tester.widget<Text>(find.descendant(
          of: find.byKey(const ValueKey<String>('lesson-mcq-0')),
          matching: find.byType(Text),
        )).data!,
    ));
    await tester.pump();
    expect(
      tester.getSemantics(find.byKey(const ValueKey<String>('lesson-mcq-0'))),
      isSemantics(isButton: true, isSelected: true),
    );
    handle.dispose();
  });
}
