import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// INC-10 E2 — the Home learning-path "traveller" must render the ACTIVE
/// world's authored vehicle (e.g. Ocean = Submarine, Forest = Leaf glider), not
/// the single hard-coded honey-badger it used for every world.
///
/// ROOT CAUSE (fixed here): `LearningPathView` always built
/// `PathTraveller(size: …)` — a badger `CustomPaint` — ignoring each world's
/// `vehicle:` string in `kThemeWorlds`. The fix threads
/// `worldVehicleGlyph(world.id)` (a new `worldId → emoji` map colocated with the
/// registry, derived from the real vehicle names) into `LearningPathView` →
/// `PathTraveller`, which now paints that glyph — keyed `home-vehicle-<id>` —
/// in place of the badger, keeping the same reduce-motion-gated bob + START
/// pill. Galaxy keeps its bespoke `PodTraveller` (already the Star-pod vehicle).
///
/// NEGATIVE CONTROL (by construction): before the fix there was no
/// `home-vehicle-*` node and no vehicle glyph on Home for ANY world — every
/// world painted the badger. Reverting the three source hunks removes the
/// `vehicleGlyph` thread, so `PathTraveller` returns to the badger branch and
/// every assertion below (glyph text + keyed node) fails. Thus a passing run
/// proves the per-world vehicle actually renders.
///
/// Assertions are on the WIDGET TREE / text only (no painter pixels).
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
        // Reduce motion ON -> no path/backdrop tickers, so pumpAndSettle settles
        // and the traveller renders in its static branch.
        settingsStoreProvider.overrideWithValue(InMemorySettingsStore(
            AppSettings(worldTheme: world, reduceMotion: true))),
      ],
      child: const RatelApp(),
    );

void main() {
  testWidgets(
      'Ocean Home renders the Submarine vehicle glyph as the traveller '
      '(keyed home-vehicle-ocean), replacing the hard-coded badger',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(world: WorldTheme.ocean));
    await tester.pumpAndSettle();

    // The real, content-driven Classic path renders (not the empty state).
    expect(find.byKey(const ValueKey<String>('tab-home')), findsOneWidget);
    expect(find.text('START'), findsOneWidget);

    // Ocean's vehicle is "Submarine" -> the mapped glyph, rendered as the
    // per-world traveller node.
    final String oceanGlyph = worldVehicleGlyph('ocean')!;
    expect(oceanGlyph, '🤿'); // guards the map value the UI relies on
    expect(find.byKey(const ValueKey<String>('home-vehicle-ocean')),
        findsOneWidget);
    expect(find.text(oceanGlyph), findsOneWidget);

    // And NOT a different world's glyph (the badger left no vehicle glyph at
    // all; here we also confirm Ocean isn't showing Forest's leaf).
    expect(find.text(worldVehicleGlyph('forest')!), findsNothing);
  });

  testWidgets(
      'Forest Home shows a DIFFERENT vehicle glyph (Leaf glider) — the '
      'traveller is per-world, not one shared sprite',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(world: WorldTheme.forest));
    await tester.pumpAndSettle();

    expect(find.text('START'), findsOneWidget);

    final String forestGlyph = worldVehicleGlyph('forest')!;
    expect(forestGlyph, '🍃');
    // Ocean and Forest map to different glyphs -> the traveller changes per
    // world (the core E2 guarantee).
    expect(forestGlyph, isNot(worldVehicleGlyph('ocean')));

    expect(find.byKey(const ValueKey<String>('home-vehicle-forest')),
        findsOneWidget);
    expect(find.text(forestGlyph), findsOneWidget);
    // The other world's vehicle must NOT be on Forest's Home.
    expect(find.text(worldVehicleGlyph('ocean')!), findsNothing);
  });

  testWidgets(
      'Daylight (free, no backdrop) still renders its Scooter vehicle glyph — '
      'the fix covers the default world too, not only backdrop worlds',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(world: WorldTheme.light));
    await tester.pumpAndSettle();

    expect(find.text('START'), findsOneWidget);
    final String lightGlyph = worldVehicleGlyph('light')!;
    expect(lightGlyph, '🛵'); // Scooter
    expect(find.byKey(const ValueKey<String>('home-vehicle-light')),
        findsOneWidget);
    expect(find.text(lightGlyph), findsOneWidget);
  });

  testWidgets(
      'Space (galaxy) keeps its bespoke PodTraveller and gets NO vehicle-glyph '
      'node — galaxy is intentionally excluded from the glyph mapping',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(world: WorldTheme.space));
    await tester.pumpAndSettle();

    // Galaxy is absent from the glyph map -> falls back to its own pod.
    expect(worldVehicleGlyph('galaxy'), isNull);
    // The galaxy pod marker is present...
    expect(find.byKey(const ValueKey<String>('home-galaxy-pod')),
        findsOneWidget);
    // ...and the Classic per-world vehicle node is NOT used on the galaxy path.
    expect(find.byKey(const ValueKey<String>('home-vehicle-galaxy')),
        findsNothing);
  });
}
