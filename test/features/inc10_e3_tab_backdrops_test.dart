import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// INC-10 E3 — extend E1's Home backdrop reveal to the other four primary tabs.
///
/// ROOT CAUSE (fixed here): Library / Leagues / Quests / Profile each painted an
/// OPAQUE `Container(color: palette.cream)` as their keyed tab root
/// (`tab-library` / `tab-leagues` / `tab-quests` / `tab-profile`). For every
/// backdrop world the palette `cream` (= `world.palette.bg`, e.g. Ocean
/// 0xFF073143) is fully opaque, so that root occluded the app-wide animated
/// `WorldBackdrop` — exactly the bug E1 fixed for Home. The fix makes each root
/// transparent for any world with a registered backdrop painter (derived the
/// same way `ratel_app.dart` derives `hasBackdrop`), revealing the translucent
/// readable scaffold + the animated field beneath. Daylight (backdrop `none`)
/// keeps its solid cream — no transparency regression, no new scrim needed
/// (`RatelTheme.world()` already tints the shell scaffold to 80% for backdrop
/// worlds, which is the readability floor Home/Space rely on).
///
/// Assertions are on the WIDGET TREE / decoration only (no painter pixels): the
/// resolved background color of each keyed tab root is `Colors.transparent`
/// under a backdrop world, and the opaque light-palette cream under Daylight.
///
/// NEGATIVE CONTROL (verified while building this test): with the four source
/// hunks reverted (each root back to `color: … cream` unconditionally), EVERY
/// "backdrop world → transparent" assertion FAILS (the root stays opaque cream)
/// while the Daylight assertions still PASS. Restoring the hunks makes all
/// assertions pass again — so this test genuinely gates the fix rather than
/// passing vacuously. (Result recorded in INC10_E3_PROGRESS.md.)

/// A minimal 1-lesson spine so the Home tab (the default landing tab) renders a
/// real, deterministic path and `pumpAndSettle` returns before we navigate.
const CourseSpine _testSpine = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(
      section: 'SECTION 1 · LEVEL A1',
      title: 'Level A1',
      lessons: <CourseLesson>[
        CourseLesson(
            id: 'l_greet',
            title: 'Saludos',
            cefr: 'A1',
            exercises: <CourseExercise>[
              CourseExercise(
                  id: 'i1',
                  exerciseType: 'mcq',
                  prompt: 'Say hello',
                  accepted: <String>['hola']),
            ]),
      ]),
]);

/// Pump the real app shell re-skinned for [world]. Overriding the settings store
/// drives BOTH the applied theme (`RatelTheme.world(world)`, so `context.palette`
/// resolves to that world's cream) AND `activeWorldProvider` (so each screen's
/// `hasBackdrop` derives correctly) from a single source — exactly as production
/// wires it. `reduceMotion: true` idles the `WorldBackdrop` + path tickers so
/// `pumpAndSettle` settles (E1's harness).
Widget _app({required WorldTheme world}) => ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(_testSpine),
        settingsStoreProvider.overrideWithValue(InMemorySettingsStore(
            AppSettings(worldTheme: world, reduceMotion: true))),
      ],
      child: const RatelApp(),
    );

/// Navigate the shell to the tab whose bottom-nav label is [label] and settle.
Future<void> _toTab(WidgetTester tester,
    {required WorldTheme world, required String label}) async {
  await tester.pumpWidget(_app(world: world));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The keyed tab root's resolved background color. A `Container(color:)`
/// collapses to a color-only Container, so read `.color`; if a later refactor
/// wraps it in a `BoxDecoration`, fall back to `decoration.color`. (Same read
/// E1 uses.)
Color? _rootColor(WidgetTester tester, String key) {
  final Container c =
      tester.widget<Container>(find.byKey(ValueKey<String>(key)));
  final Decoration? d = c.decoration;
  if (d is BoxDecoration) return d.color;
  return c.color;
}

/// (nav label, keyed-root id) for each of the four E3 tabs.
const List<List<String>> _tabs = <List<String>>[
  <String>['Library', 'tab-library'],
  <String>['Leagues', 'tab-leagues'],
  <String>['Quests', 'tab-quests'],
  <String>['Profile', 'tab-profile'],
];

void main() {
  // Give each screen a tall viewport so lazy lists build their keyed root and
  // pumpAndSettle is stable (mirrors the per-screen tests' sizing).
  setUp(() {});

  group('backdrop world (Ocean) — every tab root is transparent', () {
    for (final List<String> t in _tabs) {
      final String label = t[0];
      final String key = t[1];
      testWidgets(
          '$label root ($key) is Colors.transparent under Ocean, revealing the '
          'app-wide WorldBackdrop', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(440, 2600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await _toTab(tester, world: WorldTheme.ocean, label: label);

        // The tab actually rendered.
        expect(find.byKey(ValueKey<String>(key)), findsOneWidget);
        // The app-wide animated field is mounted and is an ancestor of this
        // tab root, so it paints behind it (Ocean has a `bubbles` painter).
        expect(find.byType(WorldBackdrop), findsOneWidget);
        expect(
            find.ancestor(
                of: find.byKey(ValueKey<String>(key)),
                matching: find.byType(WorldBackdrop)),
            findsOneWidget);
        // The root no longer occludes it.
        expect(_rootColor(tester, key), Colors.transparent);
      });
    }
  });

  group('Daylight (backdrop none) — every tab root keeps opaque cream', () {
    for (final List<String> t in _tabs) {
      final String label = t[0];
      final String key = t[1];
      testWidgets(
          '$label root ($key) stays opaque light cream under Daylight (no '
          'WorldBackdrop, no transparency regression)',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(440, 2600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await _toTab(tester, world: WorldTheme.light, label: label);

        expect(find.byKey(ValueKey<String>(key)), findsOneWidget);
        // Daylight registers no backdrop painter -> no app-wide field at all.
        expect(find.byType(WorldBackdrop), findsNothing);
        // The root keeps the solid opaque cream neutral.
        final Color? c = _rootColor(tester, key);
        expect(c, isNotNull);
        expect(c, RatelPalette.light.cream);
        expect(c!.a, greaterThan(0.99)); // fully opaque
      });
    }
  });

  testWidgets(
      'world-generic: Library root is also transparent under Forest (a '
      'DIFFERENT backdrop world) — the fix is not Ocean-special',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _toTab(tester, world: WorldTheme.forest, label: 'Library');

    expect(find.byType(WorldBackdrop), findsOneWidget);
    expect(_rootColor(tester, 'tab-library'), Colors.transparent);
  });
}
