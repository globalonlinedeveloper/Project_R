import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/library/library_screen.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// INC-1 semantic fixes — proves the design-conformance corrections shipped as
/// one increment:
///   (a) the Leagues + Quests top-bar flag is DERIVED from the active course
///       (mirrors Home), never the old hard-coded 🇬🇧 EN (AUDIT D-L8/Q7);
///   (b) the AI-Tutor / Library card subtitle renders the canonical copy
///       "Talk · Chat · Roleplay — live with Ratel" (AUDIT L-2);
///   (c) the Profile banner ring + Progress hero ring show COURSE COMPLETION
///       (lessons done / total) with a "SPANISH · YOUR LEVEL" eyebrow on
///       Progress (AUDIT D-P4/D-R1), not daily XP.
///
/// Harness mirrors home_test / ui_locale_i18n_test: a content-free [CourseSpine]
/// override drives the real screens through the real nav shell; reduce-motion is
/// forced so the animated learning path settles under pumpAndSettle.

/// A Japanese course — its derived flag (🇯🇵 / JA) is visibly distinct from the
/// old hard-coded 🇬🇧 EN, so the assertions are unambiguous.
const CourseSpine _jaSpine = CourseSpine(courseCode: 'ja', units: <CourseUnit>[
  CourseUnit(
      section: 'SECTION 1 · LEVEL A1',
      title: 'Level A1',
      lessons: <CourseLesson>[
        CourseLesson(id: 'l1', title: 'あいさつ', cefr: 'A1', exercises: <CourseExercise>[
          CourseExercise(
              id: 'i1', exerciseType: 'mcq', prompt: 'Say hi', accepted: <String>['こんにちは']),
        ]),
      ]),
]);

/// A Spanish course with a KNOWN total of 4 authored lessons, so the completion
/// ring denominator is deterministic (N/4).
const CourseSpine _esSpine = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(
      section: 'SECTION 1 · LEVEL A1',
      title: 'Level A1',
      lessons: <CourseLesson>[
        CourseLesson(id: 'l1', title: 'Saludos', cefr: 'A1', exercises: <CourseExercise>[
          CourseExercise(
              id: 'i1', exerciseType: 'mcq', prompt: 'hi', accepted: <String>['hola']),
        ]),
        CourseLesson(id: 'l2', title: 'Comida', cefr: 'A1', exercises: <CourseExercise>[
          CourseExercise(
              id: 'i2', exerciseType: 'mcq', prompt: 'apple', accepted: <String>['manzana']),
        ]),
        CourseLesson(id: 'l3', title: 'Familia', cefr: 'A2', exercises: <CourseExercise>[
          CourseExercise(
              id: 'i3', exerciseType: 'mcq', prompt: 'mother', accepted: <String>['madre']),
        ]),
        CourseLesson(id: 'l4', title: 'Viaje', cefr: 'A2', exercises: <CourseExercise>[
          CourseExercise(
              id: 'i4', exerciseType: 'mcq', prompt: 'train', accepted: <String>['tren']),
        ]),
      ]),
]);

Widget _appWith(CourseSpine spine) => ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(spine),
        settingsStoreProvider.overrideWithValue(
            InMemorySettingsStore(const AppSettings(reduceMotion: true))),
      ],
      child: const RatelApp(),
    );

void main() {
  // ── (a) course-derived flag on Leagues + Quests ──────────────────────────
  testWidgets('Leagues top bar flag is DERIVED from the course, not hard-coded EN',
      (WidgetTester tester) async {
    await tester.pumpWidget(_appWith(_jaSpine));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leagues'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('tab-leagues')), findsOneWidget);
    // The Japanese course flag + code render (mirrors Home's derivation).
    expect(find.text('🇯🇵'), findsOneWidget);
    expect(find.text('JA'), findsOneWidget);
    // The old hard-coded English flag/code must be gone.
    expect(find.text('🇬🇧'), findsNothing);
    expect(find.text('EN'), findsNothing);
  });

  testWidgets('Quests top bar flag is DERIVED from the course, not hard-coded EN',
      (WidgetTester tester) async {
    await tester.pumpWidget(_appWith(_jaSpine));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quests'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('tab-quests')), findsOneWidget);
    expect(find.text('🇯🇵'), findsOneWidget);
    expect(find.text('JA'), findsOneWidget);
    expect(find.text('🇬🇧'), findsNothing);
    expect(find.text('EN'), findsNothing);
  });

  // ── (b) AI-Tutor / Library card canonical copy ───────────────────────────
  testWidgets('Library AI-Tutor card shows the canonical "live with Ratel" subtitle',
      (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(_esSpine),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LibraryScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    // Canonical copy (design #17); the stale "…writing feedback" line is gone.
    expect(find.text('Talk · Chat · Roleplay — live with Ratel'), findsOneWidget);
    expect(find.textContaining('writing feedback'), findsNothing);
  });

  // ── (c) rings → course completion + eyebrow ──────────────────────────────
  testWidgets('Profile banner ring shows course completion (lessons done / total), not daily XP',
      (WidgetTester tester) async {
    await tester.pumpWidget(_appWith(_esSpine));
    await tester.pumpAndSettle();

    // Seed a real progress precondition on the guest snapshot: complete 2 of the
    // 4 authored lessons (recordLessonComplete is synchronous; guest = no
    // hydration to clobber it).
    final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(RatelApp)));
    container.read(learnerControllerProvider.notifier)
      ..recordLessonComplete()
      ..recordLessonComplete();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // The banner ring center now reads completion "2/4" (course N/total), the
    // D-P4 fix — NOT the daily-XP "x/20 XP" it showed before.
    expect(find.text('2/4'), findsWidgets);
  });

  testWidgets('Progress hero ring shows completion + the "SPANISH" eyebrow (CEFR hidden)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_appWith(_esSpine));
    await tester.pumpAndSettle();

    final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(RatelApp)));
    container.read(learnerControllerProvider.notifier)
      ..recordLessonComplete()
      ..recordLessonComplete()
      ..recordLessonComplete();
    await tester.pumpAndSettle();

    // Navigate Profile → Progress via the "View progress →" banner.
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View progress →'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('screen-progress')), findsOneWidget);
    // D-R1 eyebrow: the active course language only (CEFR hidden, S161 INC-P2).
    expect(find.text('SPANISH'), findsOneWidget);
    // D-R1 ring: course completion "3/4", not the daily-XP ring.
    expect(find.text('3/4'), findsWidgets);
  });
}
