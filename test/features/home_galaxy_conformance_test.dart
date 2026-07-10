import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/home/galaxy_path.dart';
import 'package:ratel/features/home/path_node.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

// UXA §4.1 Home galaxy-skin conformance — A-1 / A-6 / A-13 (S115-L9).
// Owner bundle `scraps/b-home.png` + SPEC_HOME_PATH A2/A5/D5:
//  - A-6: the START bubble background is var(--accent) = teal in EVERY theme
//         (SPEC_HOME_PATH A5) — the galaxy pill was amber, now teal (matching
//         the already-teal ported PathTraveller pill).
//  - A-1: node sizes are active 64 / others 56 (A2/D5) — the galaxy planets
//         were 84/64, now match the ported LearningPathView proportions.
//  - A-13: the two plain node impls unify onto the ported PathNode. Classic
//          renders PathNode; Space renders GalaxyPlanet; the dead Classic
//          `_nodeCircle` (an unreachable duplicate circle) is removed.
const CourseSpine _spine = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(section: 'SECTION 1 · LEVEL A1', title: 'Level A1', lessons: <CourseLesson>[
    CourseLesson(id: 'l_greet', title: 'Saludos', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(id: 'i1', exerciseType: 'mcq', prompt: 'hi', accepted: <String>['hola']),
    ]),
    CourseLesson(id: 'l_food', title: 'Comida', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(id: 'i2', exerciseType: 'mcq', prompt: 'apple', accepted: <String>['la manzana']),
    ]),
  ]),
]);

Widget _app(WorldTheme world) => ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(_spine),
        settingsStoreProvider.overrideWithValue(InMemorySettingsStore(
            AppSettings(worldTheme: world, reduceMotion: true))),
      ],
      child: const RatelApp(),
    );

Future<void> _pump(WidgetTester tester, WorldTheme world,
    {Size size = const Size(460, 1400)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_app(world));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('A-6: galaxy START pill uses the teal accent (not amber)',
      (WidgetTester tester) async {
    await _pump(tester, WorldTheme.space);
    final Finder start = find.text('START');
    expect(start, findsOneWidget);
    final Container pill = tester.widget<Container>(
        find.ancestor(of: start, matching: find.byType(Container)).first);
    final BoxDecoration deco = pill.decoration! as BoxDecoration;
    expect(deco.color, RatelColors.teal);
    expect(deco.color == RatelColors.amber, isFalse);
  });

  testWidgets('A-1: galaxy planet proportions are 64 (active) / 56 (others)',
      (WidgetTester tester) async {
    await _pump(tester, WorldTheme.space);
    final List<GalaxyPlanet> planets =
        tester.widgetList<GalaxyPlanet>(find.byType(GalaxyPlanet)).toList();
    expect(planets.length, greaterThanOrEqualTo(2));
    expect(planets.any((GalaxyPlanet p) => p.size == 64), isTrue); // active
    expect(planets.any((GalaxyPlanet p) => p.size == 56), isTrue); // others
    // the old 84/64 proportions are gone
    expect(planets.any((GalaxyPlanet p) => p.size == 84), isFalse);
    expect(planets.every((GalaxyPlanet p) => p.size == 64 || p.size == 56),
        isTrue);
  });

  testWidgets('A-13a: Space skin renders GalaxyPlanet nodes (not the ported PathNode)',
      (WidgetTester tester) async {
    await _pump(tester, WorldTheme.space);
    expect(find.byType(GalaxyPlanet), findsWidgets);
    expect(find.byType(PathNode), findsNothing); // space skin = planets
  });

  testWidgets('A-13b: Classic skin renders the ported PathNode (not GalaxyPlanet)',
      (WidgetTester tester) async {
    await _pump(tester, WorldTheme.classic);
    expect(find.byType(PathNode), findsWidgets); // classic = the ported node
    expect(find.byType(GalaxyPlanet), findsNothing); // the dead _nodeCircle is gone
  });

  for (final double w in <double>[430, 460, 800]) {
    testWidgets(
        'layout gauntlet @${w.toInt()}px — galaxy home lays out with no overflow',
        (WidgetTester tester) async {
      await _pump(tester, WorldTheme.space, size: Size(w, 1400));
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey<String>('tab-home')), findsOneWidget);
    });
  }
}
