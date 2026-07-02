import 'dart:ui' show PictureRecorder;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/core/theme/backdrop_paint.dart';
import 'package:ratel/core/theme/backdrop_registry.dart';
import 'package:ratel/core/theme/backdrops/backdrop_fx.dart' as fx;
import 'package:ratel/core/theme/world_backdrop.dart';
import 'package:ratel/core/theme/world_registry.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Wave-3 richer-moderate backdrops (desert/meadow/dawn/beach/lavender): each
/// paints safely across the loop phase with its OWN world palette, the shared
/// scene helpers are deterministic, and the reduce-motion HARD floor settles.
/// No dummy data -- palettes are the ported design registry. Evidence for
/// R-WT1 (backdrop layer) + R-WT5 (reduce-motion floor).
void main() {
  // painter id -> the world whose palette drives it.
  const Map<String, String> waveThree = <String, String>{
    'dunes': 'desert',
    'meadow': 'meadow',
    'dawn': 'dawn',
    'beach': 'beach',
    'lavender': 'lavender',
  };

  test('registry contains the 5 wave-3 painters', () {
    for (final String id in waveThree.keys) {
      expect(kBackdropPainters.containsKey(id), isTrue, reason: id);
    }
    // Exact-set count is gated once in staged_renderers_test; per-wave tests
    // assert presence + a lower bound so later waves don't force edits here.
    expect(kBackdropPainters.length, greaterThanOrEqualTo(17));
  });

  test('shared ridgeAt is deterministic + seed-varying + bounded', () {
    // Same (seed,x) -> identical; different seed -> (generally) different.
    expect(fx.ridgeAt(3, 120, 160, 0.3), fx.ridgeAt(3, 120, 160, 0.3));
    expect(fx.ridgeAt(3, 120, 160, 0.3) == fx.ridgeAt(9, 120, 160, 0.3), isFalse);
    for (double x = 0; x <= 400; x += 37) {
      final double v = fx.ridgeAt(5, x, 150, 0.3);
      expect(v.isFinite, isTrue);
      expect(v.abs() <= 1.2, isTrue, reason: 'x=$x -> $v');
    }
  });

  test('each wave-3 painter paints without throwing across the phase', () {
    final PictureRecorder rec = PictureRecorder();
    final Canvas canvas = Canvas(rec);
    waveThree.forEach((String id, String worldId) {
      final WorldPalette p = kThemeWorlds[worldId]!.palette;
      final BackdropPaint paint = kBackdropPainters[id]!;
      for (final double t in <double>[0.0, 0.17, 0.5, 0.83, 0.99]) {
        paint(canvas, const Size(390, 780), p, t);
      }
      paint(canvas, Size.zero, p, 0.0); // empty size is a safe no-op
    });
  });

  testWidgets('WorldBackdrop honors the reduce-motion floor for a wave-3 world',
      (WidgetTester tester) async {
    final ThemeWorld beach = kThemeWorlds['beach']!;
    // HARD floor: disableAnimations => no ticker => pumpAndSettle terminates.
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: WorldBackdrop(
            world: beach, child: const SizedBox(width: 20, height: 20)),
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
            world: beach, child: const SizedBox(width: 20, height: 20)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byType(WorldBackdrop), findsOneWidget);
    await tester.pumpWidget(const SizedBox()); // dispose the ticker cleanly
  });
}
