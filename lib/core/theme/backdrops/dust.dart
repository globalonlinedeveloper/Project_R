import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Savanna backdrop — warm dust motes drifting slowly to the right.
///
/// Ported from the design `dust` particle loop (`Ratel App.dc.html`, L3093):
/// each speck moves right (`p.x += .25`), bobs vertically on a slow sine, wraps
/// at the right edge, and is drawn as a soft warm dot at ~28% opacity. The
/// design's richer `drawSavanna` scene (sun, acacia, grass) is intentionally
/// NOT ported here — this batch keeps `dust` a pure, cheap particle field
/// faithful to what actually reads on screen behind the app.
void paintDust(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;

  const int count = 30;
  // Warm dust: prefer the world gold, fall back is implicit via palette.
  final Color base = p.gold;
  final Paint paint = Paint()..style = PaintingStyle.fill;

  for (int i = 0; i < count; i++) {
    // Deterministic per-index seeding (no RNG) so frames are pure.
    final double fx = _frac(i * 0.61803398875);
    final double fy = _frac(i * 0.75487766625 + 0.37);
    final double r = 0.6 + _frac(i * 0.395 + 0.11) * 2.0; // 0.6..2.6
    final double phase = fx * math.pi * 2;

    // Rightward drift: full-width travel over the loop, offset per particle.
    final double travel = _frac(fx + t);
    final double x = travel * (w + 8) - 4;
    // Gentle vertical bob layered on the seeded band.
    final double bob = math.sin(t * math.pi * 2 + phase) * (h * 0.02);
    final double y = fy * h + bob;

    paint.color = base.withValues(alpha: 0.28);
    canvas.drawCircle(Offset(x, y), r * 1.4, paint);
  }
}

double _frac(double v) => v - v.floorToDouble();
