import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Lavender backdrop -- a warm sun over a purple lavender field with a distant
/// tree line, a few bees and drifting, twinkling pollen.
///
/// Ported from the design `drawLavender` (`Ratel App.dc.html` L2698): sun
/// halo + core, a wavy horizon tree line, the field gradient (themed purples),
/// wandering bees and rising pollen.
void paintLavender(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;
  final double hz = h * 0.44;

  sunHalo(canvas, size, Offset(w * 0.74, h * 0.2), 140,
      p.gold.withValues(alpha: 0.5),
      coreR: 28, core: const Color(0xF2FFF6E0));

  // Distant tree line at the horizon.
  final Path trees = Path()..moveTo(0, hz + 2);
  for (double x = 0; x <= w; x += 16) {
    final double y = hz -
        4 -
        (math.sin(x * 0.011 + 1) * 0.5 + 0.5) * 11 -
        (math.sin(x * 0.033) * 0.5 + 0.5) * 5;
    trees.lineTo(x, y);
  }
  trees
    ..lineTo(w, hz + 2)
    ..close();
  canvas.drawPath(trees, Paint()..color = p.muted.withValues(alpha: 0.55));

  // Lavender field gradient.
  final Paint field = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[
        p.bg2.withValues(alpha: 0.97),
        p.accent.withValues(alpha: 0.97),
        p.accent2.withValues(alpha: 0.99),
      ],
      stops: const <double>[0, 0.18, 1],
    ).createShader(Rect.fromLTWH(0, hz, w, h - hz));
  canvas.drawRect(Rect.fromLTWH(0, hz, w, h - hz), field);

  final double deep = h - hz;

  // Wandering bees.
  for (int i = 0; i < 4; i++) {
    final double phase = frac(i * 0.61803398875) * math.pi * 2;
    final double x = wrap(
            frac(i * 0.4 + 0.1) * w +
                math.cos(tau + phase) * (w * 0.2) +
                t * w * 0.2,
            w + 16) -
        8;
    final double y = hz +
        6 +
        frac(i * 0.53 + 0.2) * deep * 0.7 +
        math.sin(tau * 2 + phase) * 6;
    final double fw = math.sin(tau * 8 + phase).abs();
    final Paint wing = Paint()..color = p.surface.withValues(alpha: 0.5);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(x - 1.8, y - 1), width: 2 + fw * 3, height: 2.2),
        wing);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(x + 1.8, y - 1), width: 2 + fw * 3, height: 2.2),
        wing);
    canvas.drawCircle(Offset(x, y), 1.9, Paint()..color = p.text.withValues(alpha: 0.85));
  }

  // Rising, twinkling pollen.
  final Paint pollen = Paint();
  for (int i = 0; i < 24; i++) {
    final double fxk = frac(i * 0.61803398875 + 0.13);
    final double fy = frac(i * 0.75487766625 + 0.2);
    final double r = 0.6 + frac(i * 0.317 + 0.05) * 1.4;
    final double y = h - frac(fy + t * (0.5 + (i % 3) * 0.2)) * (h - hz + 20);
    final double x = fxk * w + math.sin(tau + fxk * 6.28) * (w * 0.03);
    final double tw = 0.28 + 0.4 * (0.5 + 0.5 * math.sin(tau + fxk * 6.28));
    pollen.color = p.surface.withValues(alpha: tw);
    canvas.drawCircle(Offset(x, y), r, pollen);
  }
}
