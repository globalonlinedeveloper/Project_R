import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Desert backdrop -- a hazy sun over rolling dune ridges, a few circling birds
/// and warm drifting dust.
///
/// Ported from the design `drawDesert` (`Ratel App.dc.html` L2504): sun
/// halo + core, three ridge-noise dune silhouettes, circling birds and
/// rightward-drifting dust, using the shared deterministic ridge/sun/bird
/// primitives. The cactus/tumbleweed props are scene furniture, not ported.
void paintDunes(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;

  sunHalo(canvas, size, Offset(w * 0.5, h * 0.2), 160,
      p.gold.withValues(alpha: 0.34),
      coreR: 34, core: const Color(0xF2FFECB4));

  // Three dune ridges, back (light) -> front (dark), themed sand tones.
  final List<List<double>> dunes = <List<double>>[
    <double>[0.62, 18], <double>[0.74, 24], <double>[0.86, 30],
  ];
  final List<Color> tone = <Color>[
    p.gold.withValues(alpha: 0.50),
    p.accent.withValues(alpha: 0.62),
    p.accent2.withValues(alpha: 0.80),
  ];
  for (int i = 0; i < dunes.length; i++) {
    ridgeFill(canvas, size,
        baseY: h * dunes[i][0], amp: dunes[i][1], seed: 31 + i,
        segW: 200, oct2: 0.16, color: tone[i]);
  }

  // Circling birds high up.
  final Paint bird = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4
    ..color = p.text.withValues(alpha: 0.5);
  for (int i = 0; i < 3; i++) {
    final double a = tau + i * 2.1;
    final double bx = w * 0.32 + math.cos(a) * (60 + i * 20);
    final double by = h * 0.22 + math.sin(a) * (30 + i * 10);
    birdV(canvas, bx, by, 5, math.sin(tau * 3 + i) * 1.5, bird);
  }

  // Warm drifting dust.
  final Paint dust = Paint()..color = p.gold.withValues(alpha: 0.24);
  for (int i = 0; i < 22; i++) {
    final double fxk = frac(i * 0.61803398875);
    final double fy = frac(i * 0.75487766625 + 0.3);
    final double r = 0.6 + frac(i * 0.317 + 0.1) * 1.3;
    final double x = frac(fxk + t) * (w + 8) - 4;
    final double y = fy * h + math.sin(tau + fxk * 6.28) * (h * 0.02);
    canvas.drawCircle(Offset(x, y), r, dust);
  }
}
