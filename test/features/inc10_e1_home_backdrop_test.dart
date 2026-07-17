import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// INC-10 E1 — the Home learning path must reveal EVERY world's app-wide
/// animated [WorldBackdrop], not just Space's starfield.
///
/// ROOT CAUSE (fixed here): Home painted an OPAQUE `Container(color: cream)`
/// over the translucent scaffold + app-wide `WorldBackdrop`. For backdrop worlds
/// whose palette `cream` (= `world.palette.bg`) is opaque (e.g. Ocean 0xFF073143)
/// this occluded the animated field; Space only showed through because its
/// hand-tuned `spaceBg` cream is translucent (0xCC...). The fix makes the Home
/// root background transparent for any world with a registered backdrop painter,
/// so the field shows through uniformly -- while Daylight (backdrop `none`)
/// keeps its solid cream.
///
/// These assertions are on the WIDGET TREE / decoration only (no painter
/// pixels): the app-wide `WorldBackdrop` is an ancestor of the Home path, and
/// the Home root `Container` background is transparent for Ocean but opaque
/// cream for Daylight.
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

Widget _app({required WorldTheme world}) => ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(_testSpine),
        // Reduce motion ON -> WorldBackdrop starts no ticker (its hard floor)
        // and the path tickers idle, so pumpAndSettle settles.
        settingsStoreProvider.overrideWithValue(InMemorySettingsStore(
            AppSettings(worldTheme: world, reduceMotion: true))),
      ],
      child: const RatelApp(),
    );

/// The Home root `Container` (keyed `tab-home`) resolved decoration/color.
/// A `Container(color:)` collapses to a color-only Container in the tree, so
/// read the color off the keyed Container widget directly.
Color? _homeRootColor(WidgetTester tester) {
  final Container c = tester
      .widget<Container>(find.byKey(const ValueKey<String>('tab-home')));
  final Decoration? d = c.decoration;
  if (d is BoxDecoration) return d.color;
  return c.color;
}

void main() {
  testWidgets(
      'a backdrop world (Ocean): Home reveals the app-wide WorldBackdrop and '
      'its root background is transparent (no opaque cream occluder)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(world: WorldTheme.ocean));
    await tester.pumpAndSettle();

    // The real, content-driven path renders (not the empty state).
    expect(find.byKey(const ValueKey<String>('tab-home')), findsOneWidget);
    expect(find.text('START'), findsOneWidget);

    // The app-wide animated field is mounted AND is an ancestor of the Home
    // path -- so it paints BEHIND the path, exactly like Space.
    expect(find.byType(WorldBackdrop), findsOneWidget);
    expect(
        find.ancestor(
            of: find.byKey(const ValueKey<String>('tab-home')),
            matching: find.byType(WorldBackdrop)),
        findsOneWidget);

    // The Home root no longer paints an opaque occluding background: it is
    // transparent so the backdrop shows through.
    expect(_homeRootColor(tester), Colors.transparent);
  });

  testWidgets(
      'Daylight (backdrop none): Home keeps its solid opaque cream -- no '
      'WorldBackdrop, no transparency regression',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(world: WorldTheme.light));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('tab-home')), findsOneWidget);
    expect(find.text('START'), findsOneWidget);

    // Daylight has no registered backdrop painter -> no app-wide field.
    expect(find.byType(WorldBackdrop), findsNothing);

    // The Home root keeps the solid cream neutral (fully opaque) -- the fix
    // does NOT strip Daylight's background.
    final Color? c = _homeRootColor(tester);
    expect(c, isNotNull);
    expect(c, RatelPalette.light.cream);
    expect(c!.a, greaterThan(0.99)); // opaque
  });

  testWidgets(
      'another backdrop world (Forest) also reveals the backdrop -- the fix '
      'is world-generic, not Ocean-special',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(world: WorldTheme.forest));
    await tester.pumpAndSettle();

    expect(find.byType(WorldBackdrop), findsOneWidget);
    expect(_homeRootColor(tester), Colors.transparent);
  });
}
