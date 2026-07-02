import 'dart:ui' show PictureRecorder;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/core/theme/backdrop_paint.dart';
import 'package:ratel/core/theme/backdrop_registry.dart';
import 'package:ratel/core/theme/world_backdrop.dart';
import 'package:ratel/core/theme/world_registry.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Wave-4b backdrops (jungle/abyss/thunder) continue the SPEC wave-4 "complex
/// set": each paints safely across the loop phase with its OWN world palette
/// (thunder fires its two deterministic lightning strikes mid-loop and is calm
/// at the seam) and the reduce-motion HARD floor settles. No dummy data --
/// palettes are the ported design registry. Evidence for R-WT1 + R-WT5.
void main() {
  const Map<String, String> waveFourB = <String, String>{
    'jungle': 'jungle',
    'abyss': 'abyss',
    'thunder': 'thunder',
  };

  test('registry contains the 3 wave-4b painters', () {
    for (final String id in waveFourB.keys) {
      expect(kBackdropPainters.containsKey(id), isTrue, reason: id);
    }
    expect(kBackdropPainters.length, greaterThanOrEqualTo(26));
  });

  test('each wave-4b painter paints without throwing across the phase', () {
    final PictureRecorder rec = PictureRecorder();
    final Canvas canvas = Canvas(rec);
    waveFourB.forEach((String id, String worldId) {
      final WorldPalette p = kThemeWorlds[worldId]!.palette;
      final BackdropPaint paint = kBackdropPainters[id]!;
      // Include the lightning-strike phases (0.30 / 0.72) explicitly.
      for (final double t in <double>[0.0, 0.3, 0.5, 0.72, 0.99]) {
        paint(canvas, const Size(390, 780), p, t);
      }
      paint(canvas, Size.zero, p, 0.0); // empty size is a safe no-op
    });
  });

  testWidgets('WorldBackdrop honors the reduce-motion floor for a wave-4b world',
      (WidgetTester tester) async {
    final ThemeWorld thunder = kThemeWorlds['thunder']!;
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: WorldBackdrop(
            world: thunder, child: const SizedBox(width: 20, height: 20)),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(WorldBackdrop), findsOneWidget);
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: WorldBackdrop(
            world: thunder, child: const SizedBox(width: 20, height: 20)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byType(WorldBackdrop), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
