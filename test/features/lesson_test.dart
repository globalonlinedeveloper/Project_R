import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/app/router.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/lesson/lesson_runner_screen.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

// The §4.7 lesson runner. REAL CAT/IRT/θ selection + ability fold; finishing
// awards real XP + saves real words. (H2) When launched with a lessonId the
// runner serves the SELECTED content lesson's REAL authored exercises as TYPED
// answers (prompt + accepted + normalization flags from the ContentBatch); with
// NO lesson it falls back to the hand-authored adaptive bank (pick + word-bank).
// No mockup numbers, no faked engine output. [R-L3·R-D13·R-G2·R-I1·R-G9·R-L19·R-B8]

/// Pump the runner alone on a TALL surface so the bottom CTA / feedback panel
/// is laid out on-screen (no below-the-fold tap misses). No lessonId ⇒ the
/// hand-authored fallback bank.
Future<void> _pump(WidgetTester tester, ProviderContainer c) async {
  tester.view.physicalSize = const Size(440, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: const MaterialApp(home: LessonRunnerScreen()),
  ));
  await tester.pumpAndSettle();
}

/// Pump the runner for a specific CONTENT lesson, with the spine injected.
Future<void> _pumpContent(
    WidgetTester tester, ProviderContainer c, String lessonId) async {
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

/// Minimal content-free spine so Home renders one active node to start from
/// (its single lesson carries one authored exercise).
const CourseSpine _spine = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(section: 'SECTION 1 · LEVEL A1', title: 'Level A1', lessons: <CourseLesson>[
    CourseLesson(id: 'l1', title: 'Saludos', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(id: 'i1', exerciseType: 'mcq', prompt: 'hi', accepted: <String>['hola']),
    ]),
  ]),
]);

/// A single-exercise content lesson — deterministic served item — carrying the
/// authored normalization flags so the typed grader can be exercised exactly.
const CourseSpine _contentSpine = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(section: 'SECTION 1 · LEVEL A1', title: 'Level A1', lessons: <CourseLesson>[
    CourseLesson(id: 'lc1', title: 'Saludos', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(
        id: 'c1',
        exerciseType: 'translate',
        prompt: 'Say hello in Spanish',
        accepted: <String>['hola'],
        irtB: -2.0,
        stripDiacritics: true,
      ),
    ]),
  ]),
]);

ProviderContainer _contentContainer() {
  return ProviderContainer(overrides: <Override>[
    courseSpineProvider.overrideWithValue(_contentSpine),
  ]);
}

void main() {
  test('/daily-quiz is removed from the coming-soon stubs (route promoted)', () {
    expect(
      kComingSoonRoutes.any((ComingSoonRoute r) => r.path == '/daily-quiz'),
      isFalse,
    );
  });

  testWidgets('Home → Start lesson opens the REAL runner serving the authored item',
      (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(_spine),
        settingsStoreProvider.overrideWithValue(
            InMemorySettingsStore(const AppSettings(reduceMotion: true))),
      ],
      child: const RatelApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('home-active-node')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('screen-lesson')), findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);
    // The real authored prompt + a typed answer surface (content has no
    // distractors → no fabricated option cards).
    expect(find.byType(RatelProgressBar), findsWidgets);
    expect(find.byKey(const ValueKey<String>('lesson-input')), findsOneWidget);
    expect(find.text('hi'), findsOneWidget);
  });

  testWidgets('a correct pick shows the green "Nicely done!" feedback (fallback bank)',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    await _pump(tester, c);

    // First served item is the lowest-b pick item; option 0 is correct.
    await tester.tap(find.byKey(const ValueKey<String>('lesson-opt-0')));
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(find.text('✓ Nicely done!'), findsOneWidget);
    expect(find.text('✕ Not quite'), findsNothing);
  });

  testWidgets('a wrong pick shows the coral "Not quite" + reveals the answer (fallback bank)',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    await _pump(tester, c);

    await tester.tap(find.byKey(const ValueKey<String>('lesson-opt-1')));
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(find.text('✕ Not quite'), findsOneWidget);
    expect(find.textContaining('Answer:'), findsOneWidget);
  });

  testWidgets('completing the lesson records REAL engine state (XP / lessons / words)',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    await _pump(tester, c);

    // Walk the whole adaptive lesson: answer current (correct for pick / any
    // tile for word-bank) → Check → Continue, until the complete screen.
    for (int i = 0;
        i < 14 && find.text('Lesson complete!').evaluate().isEmpty;
        i++) {
      final Finder pick = find.byType(RatelOptionCard);
      if (pick.evaluate().isNotEmpty) {
        await tester.tap(pick.first); // index 0 = correct
      } else {
        await tester.tap(find.byType(RatelWordTile).first);
      }
      await tester.pump();
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Lesson complete!'), findsOneWidget);
    // REAL counters moved through the engine — not the mockup's 88 / 412.
    final LearnerSnapshot snap = c.read(learnerControllerProvider);
    expect(snap.lessonsCompleted, 1);
    expect(snap.xpTotal, 20);
    expect(c.read(savedWordsControllerProvider).count, greaterThan(0));
  });

  // ---- (H2) content-driven path: REAL authored exercises ----

  testWidgets('a content lesson serves the REAL authored prompt as a typed exercise',
      (WidgetTester tester) async {
    final ProviderContainer c = _contentContainer();
    addTearDown(c.dispose);
    await _pumpContent(tester, c, 'lc1');

    expect(find.byKey(const ValueKey<String>('screen-lesson')), findsOneWidget);
    expect(find.text('Say hello in Spanish'), findsOneWidget); // authored prompt
    expect(find.byKey(const ValueKey<String>('lesson-input')), findsOneWidget);
    // No distractors are authored → never fabricate a multiple-choice surface.
    expect(find.byType(RatelOptionCard), findsNothing);
  });

  testWidgets('a correct typed answer (normalized per the authored flags) shows green',
      (WidgetTester tester) async {
    final ProviderContainer c = _contentContainer();
    addTearDown(c.dispose);
    await _pumpContent(tester, c, 'lc1');

    // "Hóla" folds case + strips diacritics → "hola" == the accepted answer.
    await tester.enterText(
        find.byKey(const ValueKey<String>('lesson-input')), 'Hóla');
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(find.text('✓ Nicely done!'), findsOneWidget);
    expect(find.text('✕ Not quite'), findsNothing);
  });

  testWidgets('a wrong typed answer shows coral + reveals the authored answer',
      (WidgetTester tester) async {
    final ProviderContainer c = _contentContainer();
    addTearDown(c.dispose);
    await _pumpContent(tester, c, 'lc1');

    await tester.enterText(
        find.byKey(const ValueKey<String>('lesson-input')), 'adios');
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(find.text('✕ Not quite'), findsOneWidget);
    expect(find.textContaining('Answer: hola'), findsOneWidget);
  });

  testWidgets('completing a content lesson records REAL XP + saves the practised word',
      (WidgetTester tester) async {
    final ProviderContainer c = _contentContainer();
    addTearDown(c.dispose);
    await _pumpContent(tester, c, 'lc1');

    await tester.enterText(
        find.byKey(const ValueKey<String>('lesson-input')), 'hola');
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue')); // last item → finish
    await tester.pumpAndSettle();

    expect(find.text('Lesson complete!'), findsOneWidget);
    final LearnerSnapshot snap = c.read(learnerControllerProvider);
    expect(snap.lessonsCompleted, 1);
    expect(snap.xpTotal, 20);
    // The single-token accepted answer ("hola") is intaken to the practice hub.
    expect(c.read(savedWordsControllerProvider).count, greaterThan(0));
  });
}
