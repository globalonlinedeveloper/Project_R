import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/lesson/lesson_runner_screen.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

// UXA §4.6 lesson-runner polish conformance — C-2 / C-4 / C-5 / C-6.
// Anchored to the OWNER BUNDLE `Ratel App.dc.html` (design source of truth):
//  - preview meta  L3272: 'Lesson '+lessonNo+' of '+lessons+' · 8 quick exercises.'  → C-2 ("quick", NO CEFR)
//  - sheet chip    L1741: outlined neutral ink pill (no solid green fill)             → C-4 (neutral, unfilled)
//  - lesson header L403:  <div ...height:15px...> progress track                      → C-5 (15px; the register's
//                          "~8px" was an audit error — 8px bars live on OTHER screens)
//  - solutionText  L2166: ex.options[ex.correct].t, and a pick option is {t:'🍎',l:'manzana'}
//                          so `.t` == the EMOJI                                        → C-6 (reveal emoji-only)

// Single unit / single lesson / single exercise so the preview meta is a
// deterministic "Lesson 1 of 1 · 1 quick exercise." with cefr 'A2' — and 'A2'
// appears NOWHERE else (node.cefr is consumed ONLY by the preview meta).
const CourseSpine _spine = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(section: 'SECTION 1 · LEVEL A1', title: 'Level A1', lessons: <CourseLesson>[
    CourseLesson(id: 'l1', title: 'Saludos', cefr: 'A2', exercises: <CourseExercise>[
      CourseExercise(id: 'i1', exerciseType: 'mcq', prompt: 'hi', accepted: <String>['hola']),
    ]),
  ]),
]);

Widget _home() => ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(_spine),
        settingsStoreProvider.overrideWithValue(
            InMemorySettingsStore(const AppSettings(reduceMotion: true))),
      ],
      child: const RatelApp(),
    );

Future<void> _openPreview(WidgetTester tester, {Size size = const Size(460, 1400)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_home());
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey<String>('home-active-node')));
  await tester.pumpAndSettle();
}

Future<void> _pumpRunner(WidgetTester tester, {Size size = const Size(440, 2200)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final ProviderContainer c = ProviderContainer();
  addTearDown(c.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: const MaterialApp(home: LessonRunnerScreen()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('C-2: preview meta reads "K quick exercises" and DROPS the CEFR suffix',
      (WidgetTester tester) async {
    await _openPreview(tester);
    // "quick" copy + trailing period right after "exercise" ⇒ no "· A2" suffix.
    expect(find.textContaining('Lesson 1 of 1'), findsOneWidget);
    expect(find.textContaining('1 quick exercise.'), findsOneWidget);
    // The lesson CEFR is consumed ONLY by the (now-trimmed) preview meta.
    expect(find.textContaining('A2'), findsNothing);
  });

  testWidgets('C-4: the +20 XP chip is a NEUTRAL tinted chip, not a solid green pill',
      (WidgetTester tester) async {
    await _openPreview(tester);
    final RatelChip chip =
        tester.widget<RatelChip>(find.widgetWithText(RatelChip, '+20 XP'));
    expect(chip.tone, RatelChipTone.neutral);
    expect(chip.filled, isFalse);
  });

  testWidgets('C-5: the lesson header progress bar is 15px (design L403), not the default 14/register 8',
      (WidgetTester tester) async {
    await _pumpRunner(tester);
    final RatelProgressBar bar =
        tester.widget<RatelProgressBar>(find.byType(RatelProgressBar).first);
    expect(bar.height, 15);
  });

  testWidgets('C-6: a wrong pick reveals the correct answer EMOJI-only (no label word)',
      (WidgetTester tester) async {
    await _pumpRunner(tester);
    // First served fallback item is a pick-picture; option 0 is correct, so
    // tapping option 1 is wrong and reveals option 0's glyph.
    await tester.tap(find.byKey(const ValueKey<String>('lesson-opt-1')));
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    final Finder answer = find.textContaining('Answer:');
    expect(answer, findsOneWidget);
    final String data = tester.widget<Text>(answer).data!;
    final String revealed = data.substring(data.indexOf('Answer:') + 'Answer:'.length);
    expect(RegExp(r'[A-Za-z]').hasMatch(revealed), isFalse,
        reason: 'pick reveal must be emoji-only (design .t == emoji); got "$data"');
  });

  for (final double w in <double>[460, 800]) {
    testWidgets('layout gauntlet @${w.toInt()}px — lesson runner lays out with no overflow',
        (WidgetTester tester) async {
      await _pumpRunner(tester, size: Size(w, 1200));
      expect(tester.takeException(), isNull);
      expect(find.byType(RatelProgressBar), findsWidgets);
      expect(find.text('Check'), findsOneWidget);
    });
  }
}
