import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/auth/welcome_screen.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/library/library_screen.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

// UXA S125 — owner-gated copy-polish conformance (register C-1 / C-3 / F-7 / B-5).
// Owner decisions (S125 batched AskUserQuestion):
//  C-1  ADD '−1 ⚡ energy' beside '+20 XP' in the lesson preview sheet (owner
//       bundle `Ratel App.dc.html:3272` chips = ['−1 ⚡ energy','+20 XP'];
//       energy stays display-only/non-blocking — S60/R-I3, zero behavior change).
//  C-3  correct-feedback title → '✓ Nicely done!' (design :2168-9 renders icon
//       '✓' + title 'Nicely done!'; '✕ Not quite' already conformed). The new
//       copy is LOCKED by the existing lesson/story/podcast/watch/roleplay tests.
//  F-7  owner: the AUTH-1 Welcome copy (S112) is CANONICAL for first-run —
//       pinned here; the §4.11 onboarding copy must NOT appear on the gate.
//  B-5  owner: KEEP the Library standalone Roleplay card — presence pinned.

const CourseSpine _spine = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(
      section: 'SECTION 1 · LEVEL A1',
      title: 'Level A1',
      lessons: <CourseLesson>[
        CourseLesson(id: 'l1', title: 'Saludos', cefr: 'A2',
            exercises: <CourseExercise>[
              CourseExercise(id: 'i1', exerciseType: 'mcq', prompt: 'hi',
                  accepted: <String>['hola']),
            ]),
      ]),
]);

Future<void> _openPreview(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
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
}

void main() {
  testWidgets('C-1: preview sheet shows −1 ⚡ energy beside +20 XP (design order)',
      (WidgetTester tester) async {
    await _openPreview(tester, 460);
    expect(find.widgetWithText(RatelChip, '−1 ⚡ energy'), findsOneWidget);
    expect(find.widgetWithText(RatelChip, '+20 XP'), findsOneWidget);
    // Design :3272 order — energy chip sits LEFT of the XP chip.
    expect(
        tester.getTopLeft(find.text('−1 ⚡ energy')).dx <
            tester.getTopLeft(find.text('+20 XP')).dx,
        isTrue);
  });

  testWidgets('C-1 gauntlet: sheet stays clean at 430 with both chips',
      (WidgetTester tester) async {
    await _openPreview(tester, 430);
    expect(find.widgetWithText(RatelChip, '−1 ⚡ energy'), findsOneWidget);
    expect(find.widgetWithText(RatelChip, '+20 XP'), findsOneWidget);
  });

  testWidgets('F-7: the AUTH-1 Welcome copy is canonical (owner, S125)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(460, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(theme: RatelTheme.light(), home: const WelcomeScreen()),
    ));
    await tester.pump();
    expect(find.text('Welcome to Ratel'), findsOneWidget);
    expect(find.textContaining('pick how you want to start'), findsOneWidget);
    expect(find.text('Create free account'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
    // The §4.11 onboarding copy is NOT the gate copy (owner kept AUTH-1):
    expect(find.text("Hi, I'm Ratel!"), findsNothing);
    expect(find.text('Get started'), findsNothing);
  });

  testWidgets('B-5: Library KEEPS the standalone Roleplay card (owner, S125)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(460, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: LibraryScreen()),
    ));
    await tester.pump();
    expect(find.text('Roleplay'), findsOneWidget);
    expect(find.text('Practice replies — graded, always free'), findsOneWidget);
  });
}
