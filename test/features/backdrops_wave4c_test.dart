import 'dart:ui' show PictureRecorder;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/core/theme/backdrop_paint.dart';
import 'package:ratel/core/theme/backdrop_registry.dart';
import 'package:ratel/core/theme/world_backdrop.dart';
import 'package:ratel/core/theme/world_registry.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Wave-4c backdrops (mars/alpine/cherrynight) close all but the last SPEC
/// wave-4 painter: the rover rig, the fractal-ridged alpine ranges (reusing the
/// shared `ridgeAt`) and the cherry-night blossom/lantern scene. Each paints
/// safely across the loop phase with its OWN world palette and the reduce-motion
/// HARD floor settles. No dummy data. Evidence for R-WT1 + R-WT5.
void main() {
  const Map<String, String> waveFourC = <String, String>{
    'mars': 'mars',
    'alpine': 'alpine',
    'cherrynight': 'cherrynight',
  };

  test('registry contains the 3 wave-4c painters', () {
    for (final String id in waveFourC.keys) {
      expect(kBackdropPainters.containsKey(id), isTrue, reason: id);
    }
    expect(kBackdropPainters.length, greaterThanOrEqualTo(29));
  });

  test('each wave-4c painter paints without throwing across the phase', () {
    final PictureRecorder rec = PictureRecorder();
    final Canvas canvas = Canvas(rec);
    waveFourC.forEach((String id, String worldId) {
      final WorldPalette p = kThemeWorlds[worldId]!.palette;
      final BackdropPaint paint = kBackdropPainters[id]!;
      for (final double t in <double>[0.0, 0.17, 0.5, 0.83, 0.99]) {
        paint(canvas, const Size(390, 780), p, t);
      }
      paint(canvas, Size.zero, p, 0.0); // empty size is a safe no-op
    });
  });

  testWidgets('WorldBackdrop honors the reduce-motion floor for a wave-4c world',
      (WidgetTester tester) async {
    final ThemeWorld alpine = kThemeWorlds['alpine']!;
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: WorldBackdrop(
            world: alpine, child: const SizedBox(width: 20, height: 20)),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(WorldBackdrop), findsOneWidget);
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: WorldBackdrop(
            world: alpine, child: const SizedBox(width: 20, height: 20)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byType(WorldBackdrop), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
