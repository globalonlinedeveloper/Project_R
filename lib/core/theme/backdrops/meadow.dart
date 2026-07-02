import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Meadow backdrop -- a sunny sky with drifting clouds over rolling green hills,
/// fluttering butterflies and floating seeds.
///
/// Ported from the design `drawMeadow` (`Ratel App.dc.html` L2530): sun
/// glow + core, drifting clouds, two ridge-noise hills, butterflies and
/// floating seeds, via the shared ridge/cloud/sun primitives. The swaying
/// flower row is simplified out to keep this a single cheap painter.
void paintMeadow(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;

  sunHalo(canvas, size, Offset(w * 0.74, h * 0.2), 150,
      p.gold.withValues(alpha: 0.5),
      coreR: 30, core: const Color(0xF2FFF8D2));

  // Two drifting clouds.
  for (int i = 0; i < 2; i++) {
    final double cx =
        wrap(frac(i * 0.42 + 0.1) * w + t * (w + 160) * (0.4 + i * 0.2),
                w + 160) -
            80;
    softCloud(canvas, Offset(cx, h * (0.12 + i * 0.1)), 34 + i * 6,
        p.surface.withValues(alpha: 0.5),
        seed: i * 7);
  }

  // Two rolling hills.
  ridgeFill(canvas, size,
      baseY: h * 0.66, amp: 16, seed: 11, segW: 140, oct2: 0.32,
      color: p.accent.withValues(alpha: 0.5));
  ridgeFill(canvas, size,
      baseY: h * 0.78, amp: 16, seed: 23, segW: 140, oct2: 0.32,
      color: p.accent2.withValues(alpha: 0.66));

  // Fluttering butterflies.
  final List<Color> bfly = <Color>[p.accent, p.gold, p.good];
  for (int i = 0; i < 4; i++) {
    final double phase = frac(i * 0.61803398875) * math.pi * 2;
    final double x = wrap(
            frac(i * 0.37 + 0.2) * w +
                math.sin(tau + phase) * (w * 0.12) +
                t * w * 0.15,
            w + 20) -
        10;
    final double y = h * 0.3 +
        frac(i * 0.53 + 0.1) * h * 0.38 +
        math.sin(tau * 1.3 + phase) * 8;
    final double flap = math.sin(tau * 6 + phase).abs();
    final Paint wing = Paint()..color = bfly[i % bfly.length].withValues(alpha: 0.8);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(x - 3, y), width: 6, height: 5 * flap + 2),
        wing);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(x + 3, y), width: 6, height: 5 * flap + 2),
        wing);
  }

  // Floating seeds.
  final Paint seed = Paint()..color = p.surface.withValues(alpha: 0.5);
  for (int i = 0; i < 18; i++) {
    final double fxk = frac(i * 0.61803398875 + 0.05);
    final double fy = frac(i * 0.75487766625 + 0.4);
    final double r = 1 + frac(i * 0.317 + 0.2) * 1.4;
    final double x = frac(fxk + t * 0.6) * (w + 8) - 4;
    final double y = fy * h + math.sin(tau + fxk * 6.28) * (h * 0.03);
    canvas.drawCircle(Offset(x, y), r, seed);
  }
}
