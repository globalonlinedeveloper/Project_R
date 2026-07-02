import 'dart:ui' show PictureRecorder;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/core/theme/backdrop_paint.dart';
import 'package:ratel/core/theme/backdrop_registry.dart';
import 'package:ratel/core/theme/world_backdrop.dart';
import 'package:ratel/core/theme/world_registry.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Wave-2 animated backdrops (forest/storm/autumn/aurora/volcano/sunset): each
/// paints safely across the loop phase with its OWN world palette, and the
/// reduce-motion HARD floor still settles. No dummy data -- palettes are the
/// ported design registry. Evidence for R-WT1 (backdrop layer) + R-WT5
/// (reduce-motion floor).
void main() {
  // painter id -> the world whose palette drives it.
  const Map<String, String> waveTwo = <String, String>{
    'fireflies': 'forest',
    'rain': 'storm',
    'leaves': 'autumn',
    'nlights': 'aurora',
    'embers': 'volcano',
    'sunset': 'sunset',
  };

  test('registry contains the 6 wave-2 painters (12 total)', () {
    for (final String id in waveTwo.keys) {
      expect(kBackdropPainters.containsKey(id), isTrue, reason: id);
    }
    expect(kBackdropPainters.length, 12);
  });

  test('each wave-2 painter paints without throwing across the phase', () {
    final PictureRecorder rec = PictureRecorder();
    final Canvas canvas = Canvas(rec);
    waveTwo.forEach((String id, String worldId) {
      final WorldPalette p = kThemeWorlds[worldId]!.palette;
      final BackdropPaint paint = kBackdropPainters[id]!;
      for (final double t in <double>[0.0, 0.17, 0.5, 0.83, 0.99]) {
        paint(canvas, const Size(390, 780), p, t);
      }
      paint(canvas, Size.zero, p, 0.0); // empty size is a safe no-op
    });
  });

  testWidgets('WorldBackdrop honors the reduce-motion floor for a wave-2 world',
      (WidgetTester tester) async {
    final ThemeWorld volcano = kThemeWorlds['volcano']!;
    // HARD floor: disableAnimations => no ticker => pumpAndSettle terminates.
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: WorldBackdrop(
            world: volcano, child: const SizedBox(width: 20, height: 20)),
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
            world: volcano, child: const SizedBox(width: 20, height: 20)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byType(WorldBackdrop), findsOneWidget);
    await tester.pumpWidget(const SizedBox()); // dispose the ticker cleanly
  });
}
