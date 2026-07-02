import 'dart:ui' show PictureRecorder;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/core/theme/backdrop_paint.dart';
import 'package:ratel/core/theme/backdrop_registry.dart';
import 'package:ratel/core/theme/world_backdrop.dart';
import 'package:ratel/core/theme/world_registry.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Wave-3B backdrops (reef/lagoon/sandstorm) complete the SPEC wave-3 set: each
/// paints safely across the loop phase with its OWN world palette and the
/// reduce-motion HARD floor settles. No dummy data -- palettes are the ported
/// design registry. Evidence for R-WT1 (backdrop layer) + R-WT5 (reduce-motion
/// floor).
void main() {
  const Map<String, String> waveThreeB = <String, String>{
    'reef': 'reef',
    'lagoon': 'lagoon',
    'sandstorm': 'sandstorm',
  };

  test('registry contains the 3 wave-3B painters', () {
    for (final String id in waveThreeB.keys) {
      expect(kBackdropPainters.containsKey(id), isTrue, reason: id);
    }
    // Exact-set count is gated once in staged_renderers_test; assert a lower
    // bound so later waves don't force edits here.
    expect(kBackdropPainters.length, greaterThanOrEqualTo(20));
  });

  test('each wave-3B painter paints without throwing across the phase', () {
    final PictureRecorder rec = PictureRecorder();
    final Canvas canvas = Canvas(rec);
    waveThreeB.forEach((String id, String worldId) {
      final WorldPalette p = kThemeWorlds[worldId]!.palette;
      final BackdropPaint paint = kBackdropPainters[id]!;
      for (final double t in <double>[0.0, 0.17, 0.5, 0.83, 0.99]) {
        paint(canvas, const Size(390, 780), p, t);
      }
      paint(canvas, Size.zero, p, 0.0); // empty size is a safe no-op
    });
  });

  testWidgets('WorldBackdrop honors the reduce-motion floor for a wave-3B world',
      (WidgetTester tester) async {
    final ThemeWorld lagoon = kThemeWorlds['lagoon']!;
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: WorldBackdrop(
            world: lagoon, child: const SizedBox(width: 20, height: 20)),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(WorldBackdrop), findsOneWidget);
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: WorldBackdrop(
            world: lagoon, child: const SizedBox(width: 20, height: 20)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byType(WorldBackdrop), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
