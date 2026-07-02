import 'dart:ui' show PictureRecorder;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/core/theme/backdrop_paint.dart';
import 'package:ratel/core/theme/backdrop_registry.dart';
import 'package:ratel/core/theme/world_backdrop.dart';
import 'package:ratel/core/theme/world_registry.dart';
import 'package:ratel/core/theme/world_theme.dart';
import 'package:ratel/features/lesson/renderers/match_exercise.dart';

/// WS3-C + WS4 (parallel-authored, banked before wiring): the 6 wave-1 animated
/// backdrops paint safely + honor the reduce-motion floor, and the text-Match
/// renderer grades real pairs. No dummy data — palettes are the ported design.
void main() {
  group('WS3-C backdrops', () {
    test('registry has exactly the 26 wave-1..4b painters', () {
      expect(kBackdropPainters.keys.toSet(), <String>{
        'dust', 'bubbles', 'sprinkles', 'snow', 'petals', 'grid', // wave-1
        'fireflies', 'rain', 'leaves', 'nlights', 'embers', 'sunset', // wave-2
        'dunes', 'meadow', 'dawn', 'beach', 'lavender', // wave-3
        'reef', 'lagoon', 'sandstorm', // wave-3B
        'cyberrain', 'bamboo', 'nebula', // wave-4a
        'jungle', 'abyss', 'thunder', // wave-4b
      });
    });

    test('every painter paints without throwing across the phase', () {
      final WorldPalette p = kThemeWorlds['ocean']!.palette;
      final PictureRecorder rec = PictureRecorder();
      final Canvas canvas = Canvas(rec);
      for (final BackdropPaint paint in kBackdropPainters.values) {
        for (final double t in <double>[0.0, 0.33, 0.99]) {
          paint(canvas, const Size(390, 780), p, t);
        }
        paint(canvas, Size.zero, p, 0.0); // empty size is a safe no-op
      }
    });

    testWidgets('WorldBackdrop: reduce-motion settles; animated builds a frame',
        (WidgetTester tester) async {
      final ThemeWorld ocean = kThemeWorlds['ocean']!;
      // HARD floor: disableAnimations => no ticker => pumpAndSettle terminates.
      await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: WorldBackdrop(
              world: ocean, child: const SizedBox(width: 20, height: 20)),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(WorldBackdrop), findsOneWidget);
      // Motion allowed: infinite repeat => pump ONE frame (never pumpAndSettle).
      await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: WorldBackdrop(
              world: ocean, child: const SizedBox(width: 20, height: 20)),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byType(WorldBackdrop), findsOneWidget);
      await tester.pumpWidget(const SizedBox()); // dispose the ticker cleanly
    });
  });

  group('WS4 text-Match renderer', () {
    testWidgets('grades all-correct after every pair is matched',
        (WidgetTester tester) async {
      bool? graded;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MatchExercise(
            pairs: const <MatchPair>[
              MatchPair('uno', 'one'),
              MatchPair('dos', 'two'),
              MatchPair('tres', 'three'),
            ],
            reduceMotion: true,
            onGraded: (bool ok) => graded = ok,
          ),
        ),
      ));
      await tester.pumpAndSettle();
      for (final List<String> pr in const <List<String>>[
        <String>['uno', 'one'],
        <String>['dos', 'two'],
        <String>['tres', 'three'],
      ]) {
        await tester.tap(find.text(pr[0]));
        await tester.pump();
        await tester.tap(find.text(pr[1]));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(graded, isTrue);
    });
  });
}
