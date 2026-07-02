import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Sandstorm backdrop -- a dim sun behind driving sand: hazy dune ridges, a
/// sweeping dust wall, diagonal sand streaks and driving grains.
///
/// Ported from the design `drawSandstorm` (`Ratel App.dc.html` L2900). The
/// tumbleweeds + grass tufts are omitted; the sun, dunes, sweeping wall,
/// streaks and grains carry the storm.
void paintSandstorm(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;
  final double hz = h * 0.6;

  // Dim hazy sun.
  sunHalo(canvas, size, Offset(w * 0.5, h * 0.22), 90,
      p.gold.withValues(alpha: 0.4),
      coreR: 24, core: p.accent2.withValues(alpha: 0.55));

  // Dune silhouettes (sine profiles, warm browns).
  void dune(double by, double amp, Color col, double pho) {
    final Path d = Path()
      ..moveTo(0, h)
      ..lineTo(0, by);
    for (double x = 0; x <= w; x += 12) {
      d.lineTo(
          x, by + math.sin(x * 0.012 + pho) * amp + math.sin(x * 0.03 + pho * 2) * amp * 0.3);
    }
    d
      ..lineTo(w, by)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(d, Paint()..color = col);
  }

  dune(hz + 8, 10, p.muted.withValues(alpha: 0.55), 0.5);
  dune(h * 0.665, 14, p.accent.withValues(alpha: 0.72), 2.1);
  dune(h * 0.75, 16, p.accent2.withValues(alpha: 0.92), 4.0);

  // Diagonal sand streaks (driving left-down).
  final Paint streak = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  for (int i = 0; i < 14; i++) {
    final double fxk = frac(i * 0.61803398875);
    final double len = 30 + frac(i * 0.317) * 60;
    final double sx = wrap(fxk * (w + len) - t * (w + len) * (1 + fxk), w + len) - len;
    final double sy = h * 0.3 + frac(i * 0.53 + 0.1) * h * 0.45;
    final double a = 0.05 + frac(i * 0.19) * 0.12;
    streak.shader = LinearGradient(
      colors: <Color>[
        p.gold.withValues(alpha: 0),
        p.gold.withValues(alpha: a),
        p.gold.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromLTWH(sx, sy, len, 2));
    canvas.drawLine(Offset(sx, sy), Offset(sx + len, sy + len * 0.13), streak);
  }

  // Sweeping dust wall.
  final double wallX = wrap(w * 1.3 - t * w * 2, w * 2) - w * 0.7;
  final Paint wall = Paint()
    ..shader = LinearGradient(
      colors: <Color>[
        p.accent.withValues(alpha: 0),
        p.accent.withValues(alpha: 0.15),
        p.accent.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromLTWH(wallX - w * 0.7, 0, w, h));
  canvas.drawRect(Rect.fromLTWH(wallX - w * 0.7, 0, w, h), wall);

  // Driving sand grains.
  final Paint grain = Paint()..color = p.gold.withValues(alpha: 0.3);
  for (int i = 0; i < 50; i++) {
    final double fxk = frac(i * 0.61803398875);
    final double fy = frac(i * 0.75487766625 + 0.2);
    final double r = 0.6 + frac(i * 0.317) * 1.6;
    final double x = wrap(fxk * w - t * w * (1 + fxk * 1.4), w + 8) - 4;
    final double y = fy * h + math.sin(tau + fxk * 6.28) * (h * 0.03);
    canvas.drawCircle(Offset(x, y), r, grain);
  }
}
