import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/lesson/lesson_runner_screen.dart';
import 'package:ratel/features/settings/settings_screen.dart';
import 'package:ratel/features/themes/themes_screen.dart';

// M-1 (screen review 2026-07 §2): font-scale gauntlet @200%.
// Every named surface (Settings / Themes / BottomNav / Lesson) must lay out
// without RenderFlex overflow when the OS text scale is doubled. Overflows
// surface as FlutterErrors, which fail the pump; we also assert
// takeException() == null so a soft failure cannot slip through.

const double kScale = 2.0;

Widget _scaled(Widget home) {
  return ProviderScope(
    child: MaterialApp(
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(kScale)),
        child: child!,
      ),
      home: home,
    ),
  );
}

Future<void> _pumpScaled(
  WidgetTester tester,
  Widget home, {
  double width = 430,
  double height = 4200,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_scaled(home));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

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

void main() {
  testWidgets('M-1: Settings lays out at 200% text scale (430px)',
      (WidgetTester tester) async {
    await _pumpScaled(tester, const SettingsScreen());
    expect(find.text('High contrast'), findsOneWidget);
  });

  testWidgets('M-1: Themes lays out at 200% text scale (430px)',
      (WidgetTester tester) async {
    await _pumpScaled(tester, const ThemesScreen());
  });

  testWidgets('M-1: BottomNav lays out at 200% text scale (430 & 360px)',
      (WidgetTester tester) async {
    for (final double w in <double>[430, 360]) {
      await _pumpScaled(
        tester,
        Scaffold(
          key: ValueKey<double>(w),
          body: const SizedBox.expand(),
          bottomNavigationBar:
              RatelBottomNav(currentIndex: 0, onTap: (_) {}),
        ),
        width: w,
        height: 900,
      );
      expect(find.text('Profile'), findsOneWidget, reason: 'w=$w');
    }
  });

  testWidgets('M-1: Lesson exercise + result lay out at 200% (430px)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 4200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spine),
    ]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(kScale)),
          child: child!,
        ),
        home: const LessonRunnerScreen(lessonId: 'l1'),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'exercise view');
    // Drive to the result surface.
    await tester.tap(find.text('RIGHT'));
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'result view');
  });
}
