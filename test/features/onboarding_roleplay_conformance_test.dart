import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/onboarding/onboarding_screen.dart';
import 'package:ratel/features/roleplay/roleplay_screen.dart';

/// UXA S116 — F-9/F-10 onboarding + roleplay polish conformance (§11).
///  F-9  Onboarding language step is a 3-column grid of vertical flag cards
///       (owner bundle Ratel App.dc.html:1376 — grid-template-columns 1fr 1fr 1fr).
///  F-10 Roleplay "Live Roleplay" entry title is single-line ellipsized so the
///       trailing PRO chip can never crowd it (mirrors the L7 overflow guards).
///  F-8  honest-no-fix PIN: the bare 🧭 emoji IS the design (no medallion /
///       gold vector) — a regression to custom art turns this red.

CourseSpine _spine(int n) => CourseSpine(
      courseCode: 'en',
      units: const <CourseUnit>[],
      roleplays: <CourseScenario>[
        for (int i = 0; i < n; i++)
          CourseScenario(
            id: 'r$i',
            kind: 'roleplay',
            title: 'Scene $i',
            cefr: 'A1',
            scenes: const <CourseScene>[
              CourseScene(sceneId: 's0', speaker: 'ratel', line: 'Hola'),
            ],
          ),
      ],
    );

Future<void> _pump(WidgetTester t, Widget screen, Size size,
    {List<Override> overrides = const <Override>[]}) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(ProviderScope(
    overrides: overrides,
    child: MaterialApp(theme: RatelTheme.light(), home: screen),
  ));
  await t.pump();
  await t.pump(const Duration(milliseconds: 50));
}

Future<void> _toLanguageStep(WidgetTester t) async {
  await t.tap(find.text('Get started'));
  await t.pump();
  await t.pump(const Duration(milliseconds: 50));
}

void main() {
  group('UXA F-9/F-10 (S116)', () {
    testWidgets('F-9: language grid is 3 columns of vertical flag cards',
        (WidgetTester t) async {
      await _pump(t, const OnboardingScreen(), const Size(460, 1400));
      await _toLanguageStep(t);
      final GridView grid = t.widget<GridView>(find.byType(GridView));
      final SliverGridDelegateWithFixedCrossAxisCount delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 3,
          reason: 'design 1fr 1fr 1fr (Ratel App.dc.html:1376)');
      expect(delegate.childAspectRatio, lessThan(1.2),
          reason: 'vertical flag-over-name cards, not wide rows');
      // S144: the app ships a single English course today, so the language
      // grid offers English only until a multi-course picker lands.
      expect(find.text('English'), findsOneWidget, reason: 'English card renders');
    });

    testWidgets('F-10: Live Roleplay entry title is single-line ellipsized',
        (WidgetTester t) async {
      await _pump(t, const RoleplayScreen(), const Size(360, 1200),
          overrides: <Override>[
            courseSpineProvider.overrideWithValue(_spine(2)),
          ]);
      final Text title = t.widget<Text>(find.text('Live Roleplay'));
      expect(title.maxLines, 1);
      expect(title.overflow, TextOverflow.ellipsis);
      expect(t.takeException(), isNull);
    });

    testWidgets('F-8 honest: placement compass stays the bare 🧭 emoji',
        (WidgetTester t) async {
      await _pump(t, const OnboardingScreen(), const Size(460, 1400));
      await _toLanguageStep(t); // → language
      for (int i = 0; i < 3; i++) {
        await t.tap(find.text('Continue')); // → reason → goal → placement
        await t.pump();
        await t.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('🧭'), findsOneWidget);
    });

    testWidgets('gauntlet — onboarding language step @430/460/800 no overflow',
        (WidgetTester t) async {
      for (final double w in <double>[430, 460, 800]) {
        await _pump(t, OnboardingScreen(key: ValueKey<double>(w)), Size(w, 1400));
        await _toLanguageStep(t);
        expect(t.takeException(), isNull, reason: 'language step @$w');
      }
    });

    testWidgets('gauntlet — roleplay list @360/430 no overflow',
        (WidgetTester t) async {
      for (final double w in <double>[360, 430]) {
        await _pump(t, const RoleplayScreen(), Size(w, 1600),
            overrides: <Override>[
              courseSpineProvider.overrideWithValue(_spine(4)),
            ]);
        expect(t.takeException(), isNull, reason: 'roleplay @$w');
      }
    });
  });
}
