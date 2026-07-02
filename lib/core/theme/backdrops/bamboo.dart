import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Bamboo-grove backdrop -- soft daylight shafts filtering through a swaying
/// grove of segmented bamboo culms, with fluttering leaves and rising pollen
/// motes.
///
/// Ported from the design `drawBamboo` (`Ratel App.dc.html` L2713). The heavy
/// furniture -- the resting panda, drifting mist banks and out-of-focus overhead
/// canopy -- is omitted; the core scene (light + far/near stalks + leaves +
/// motes) carries the grove. Culm greens are the world's own accents, so the
/// grove re-tints per palette; every actor is index-seeded and driven by `t`.
void paintBamboo(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;

  // Soft daylight shafts filtering through the grove.
  for (int i = 0; i < 2; i++) {
    final double cx = w * (i == 0 ? 0.30 : 0.62) + math.sin(tau + i * 2) * 8;
    final Rect r = Rect.fromLTWH(cx - 30, 0, 125, h * 0.85);
    final Path shaft = Path()
      ..moveTo(cx - 30, 0)
      ..lineTo(cx + 30, 0)
      ..lineTo(cx + 95, h * 0.85)
      ..lineTo(cx + 35, h * 0.85)
      ..close();
    canvas.drawPath(
        shaft,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              p.good.withValues(alpha: 0.06),
              p.good.withValues(alpha: 0),
            ],
          ).createShader(r));
  }

  // A single lens-shaped bamboo leaf, tip along +x.
  void leaf(double len, Color col) {
    final double wd = len * 0.32;
    canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(len * 0.45, -wd, len, 0)
          ..quadraticBezierTo(len * 0.45, wd, 0, 0),
        Paint()..color = col);
  }

  // Bamboo culms: a dim far layer then a bright near layer, segmented + swaying.
  void stalks(int n, bool near) {
    final double baseA = near ? 0.96 : 0.5;
    final Color dark = p.ink.withValues(alpha: baseA);
    final Color light = p.accent.withValues(alpha: baseA);
    final Color mid = p.accent2.withValues(alpha: baseA);
    for (int i = 0; i < n; i++) {
      final double fx = frac(i * 0.61803398875 + (near ? 0.13 : 0.0));
      final double x0 = w * (i + 0.5) / n + (fx - 0.5) * w * 0.05;
      final double bw = near ? 13 + fx * 6 : 6 + fx * 3;
      final double segH = h * (near ? 0.18 : 0.16);
      final double sway = math.sin(tau + fx * 6.28) * (near ? 9 : 6);
      final int segs = (h / segH).ceil() + 1;
      for (int s = 0; s < segs; s++) {
        final double yB = h - s * segH, yT = h - (s + 1) * segH;
        final double xB = x0 + sway * (s / segs) * 0.5;
        final double xT = x0 + sway * ((s + 1) / segs) * 0.5;
        final Rect gr = Rect.fromLTWH(xT - bw / 2, yT, bw, segH);
        canvas.drawPath(
            Path()
              ..moveTo(xB - bw / 2, yB)
              ..lineTo(xB + bw / 2, yB)
              ..lineTo(xT + bw / 2, yT)
              ..lineTo(xT - bw / 2, yT)
              ..close(),
            Paint()
              ..shader = LinearGradient(
                colors: <Color>[dark, light, mid, dark],
                stops: const <double>[0, 0.32, 0.5, 1],
              ).createShader(gr));
        // Node ring at the segment top.
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(xT, yT), width: bw * 1.2, height: bw * 0.52),
            Paint()..color = dark);
      }
    }
  }

  stalks(6, false);
  stalks(5, true);

  // Fluttering leaves drifting down (tumble + wind wobble).
  for (int i = 0; i < 13; i++) {
    final double fx = frac(i * 0.61803398875);
    final double fy = frac(i * 0.75487766625 + 0.1);
    final double len = 9 + frac(i * 0.317) * 5;
    final double flut = tau + fx * 6.28;
    final double y = wrap(fy * h + t * h * 0.6, h + 12) - 6;
    final double x = fx * w + math.sin(flut) * (5 + fx * 5);
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(flut * 0.3 + math.sin(flut) * 0.5);
    canvas.scale(1, 0.5 + 0.5 * math.cos(flut).abs());
    leaf(len, p.accent.withValues(alpha: 0.55));
    canvas.restore();
  }

  // Rising pollen / dust motes catching the light.
  for (int i = 0; i < 18; i++) {
    final double fx = frac(i * 0.61803398875 + 0.05);
    final double fy = frac(i * 0.75487766625 + 0.3);
    final double r = 0.6 + frac(i * 0.317) * 1.5;
    final double y = h - wrap(fy * h + t * h * 0.2, h + 8);
    final double x = fx * w + math.sin(tau + fx * 6.28) * 6;
    final double a = 0.22 + 0.45 * math.sin(tau + fx * 6.28).abs();
    canvas.drawCircle(
        Offset(x, y), r, Paint()..color = p.gold.withValues(alpha: a));
  }
}
