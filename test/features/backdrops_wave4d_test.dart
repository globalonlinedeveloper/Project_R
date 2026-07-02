import 'dart:ui' show PictureRecorder;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/core/theme/backdrop_paint.dart';
import 'package:ratel/core/theme/backdrop_registry.dart';
import 'package:ratel/core/theme/world_backdrop.dart';
import 'package:ratel/core/theme/world_registry.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Wave-4d closes the backdrop epic: the animated `stars` galaxy field (R-WT7),
/// the last of the 31 worlds. It paints safely across the loop phase with the
/// galaxy palette and settles under the reduce-motion HARD floor. With it every
/// non-`light` world now has an animated painter. Evidence for R-WT1 + R-WT5 +
/// R-WT7.
void main() {
  test('registry contains the stars painter (>= 30 backdrops present)', () {
    expect(kBackdropPainters.containsKey('stars'), isTrue);
    expect(kBackdropPainters.length, greaterThanOrEqualTo(30));
    // galaxy's backdrop id resolves to a real painter now (no longer absent).
    expect(kBackdropPainters[kThemeWorlds['galaxy']!.backdrop], isNotNull);
  });

  test('paintStars paints without throwing across the phase (galaxy palette)',
      () {
    final WorldPalette p = kThemeWorlds['galaxy']!.palette;
    final BackdropPaint paint = kBackdropPainters['stars']!;
    final PictureRecorder rec = PictureRecorder();
    final Canvas canvas = Canvas(rec);
    for (final double t in <double>[0.0, 0.16, 0.25, 0.5, 0.7, 0.83, 0.99]) {
      paint(canvas, const Size(390, 780), p, t);
    }
    paint(canvas, Size.zero, p, 0.0); // empty size is a safe no-op
  });

  testWidgets('WorldBackdrop honors the reduce-motion floor for galaxy (stars)',
      (WidgetTester tester) async {
    final ThemeWorld galaxy = kThemeWorlds['galaxy']!;
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: WorldBackdrop(
            world: galaxy, child: const SizedBox(width: 20, height: 20)),
      ),
    ));
    await tester.pumpAndSettle(); // settles -> no repeating ticker under floor
    expect(find.byType(WorldBackdrop), findsOneWidget);
    // Motion allowed: a ticker runs; advance a fixed slice (never settle).
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: WorldBackdrop(
            world: galaxy, child: const SizedBox(width: 20, height: 20)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byType(WorldBackdrop), findsOneWidget);
    await tester.pumpWidget(const SizedBox()); // unmount -> dispose ticker
  });
}
