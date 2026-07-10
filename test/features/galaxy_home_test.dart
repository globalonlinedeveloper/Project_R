import 'dart:ui' show PictureRecorder;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/features/home/galaxy_path.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// G2 evidence — Galaxy Home (R-WT4). When the Space world-theme is active the
/// Home learning path re-skins into a galaxy (a [GalaxyPathPainter] orbital
/// backdrop, [GalaxyPlanet] nodes, a [PodTraveller] at the current node);
/// Classic is untouched. The re-skin is a pure VISUAL layer over the SAME real
/// path — states + positions are identical, so nothing about progress is faked.
const CourseSpine _testSpine = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(section: 'SECTION 1 · LEVEL A1', title: 'Level A1', lessons: <CourseLesson>[
    CourseLesson(id: 'l_greet', title: 'Saludos', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(id: 'i1', exerciseType: 'mcq', prompt: 'Say hello', accepted: <String>['hola']),
    ]),
    CourseLesson(id: 'l_food', title: 'Comida', cefr: 'A1', exercises: <CourseExercise>[
      CourseExercise(id: 'i2', exerciseType: 'mcq', prompt: 'the apple', accepted: <String>['la manzana']),
    ]),
  ]),
  CourseUnit(section: 'SECTION 2 · LEVEL A2', title: 'Level A2', lessons: <CourseLesson>[
    CourseLesson(id: 'l_present', title: 'Presente simple', cefr: 'A2', exercises: <CourseExercise>[
      CourseExercise(id: 'i4', exerciseType: 'translate', prompt: 'She reads', accepted: <String>['ella lee']),
    ]),
  ]),
]);

bool _hasGalaxyPath(WidgetTester t) => t
    .widgetList(find.byType(CustomPaint))
    .any((Widget w) => (w as CustomPaint).painter is GalaxyPathPainter);

Widget _app({required WorldTheme world, bool reduceMotion = false}) =>
    ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(_testSpine),
        settingsStoreProvider.overrideWithValue(InMemorySettingsStore(
            AppSettings(worldTheme: world, reduceMotion: reduceMotion))),
      ],
      child: const RatelApp(),
    );

void main() {
  group('Galaxy planet colours', () {
    test('cycle deterministically through the brand accents', () {
      expect(galaxyPlanetColor(0), galaxyPlanetColor(6)); // 6-colour cycle
      expect(galaxyPlanetColor(0) == galaxyPlanetColor(1), isFalse);
    });
  });

  group('Galaxy painters paint safely', () {
    test('GalaxyPathPainter + PodPainter + PlanetRingPainter render + repaint', () {
      final PictureRecorder rec = PictureRecorder();
      final Canvas canvas = Canvas(rec);
      const GalaxyPathPainter p = GalaxyPathPainter(
        ax: 0.5, prevAx: 0.0, nextAx: -0.5,
        hasPrev: true, hasNext: true, nodeSize: 64, done: false, seed: 3,
      );
      p.paint(canvas, const Size(360, 104));
      p.paint(canvas, Size.zero); // empty size is a safe no-op
      expect(
          p.shouldRepaint(const GalaxyPathPainter(
              ax: 0.5, prevAx: 0.0, nextAx: -0.5,
              hasPrev: true, hasNext: true, nodeSize: 64, done: false, seed: 3)),
          isFalse);
      expect(
          p.shouldRepaint(const GalaxyPathPainter(
              ax: 0.5, prevAx: 0.0, nextAx: -0.5,
              hasPrev: true, hasNext: true, nodeSize: 64, done: true, seed: 3)),
          isTrue);
      const PodPainter().paint(canvas, const Size(40, 40));
      const PlanetRingPainter(color: Color(0xFF16A085), radius: 64)
          .paint(canvas, const Size(118, 90));
    });
  });

  testWidgets('Space re-skins Home as a galaxy: orbital path + pod traveller',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(world: WorldTheme.space, reduceMotion: true));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('tab-home')), findsOneWidget);
    expect(_hasGalaxyPath(tester), isTrue); // CustomPainter backdrop + path
    expect(find.byKey(const ValueKey<String>('home-galaxy-pod')),
        findsOneWidget); // pod traveller at the current node
    expect(find.text('START'), findsOneWidget); // one active node, real state
  });

  testWidgets('Classic keeps the original path (no galaxy painter / no pod)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(world: WorldTheme.classic, reduceMotion: true));
    await tester.pumpAndSettle();
    expect(_hasGalaxyPath(tester), isFalse);
    expect(
        find.byKey(const ValueKey<String>('home-galaxy-pod')), findsNothing);
    expect(find.text('START'), findsOneWidget); // same real active node
  });

  testWidgets('galaxy active planet still opens the REAL lesson preview (§4.6)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(world: WorldTheme.space, reduceMotion: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('home-active-node')));
    await tester.pumpAndSettle();
    expect(find.text('Saludos'), findsOneWidget); // real first lesson title
    expect(find.textContaining('1 quick exercise'), findsOneWidget);
    expect(find.text('Start lesson'), findsOneWidget);
  });
}
