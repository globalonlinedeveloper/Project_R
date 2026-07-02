import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Winter backdrop — soft snowflakes falling with a wind-driven drift.
///
/// Ported from the design `snow` particle loop (`Ratel App.dc.html`, L3099):
/// each flake falls (`p.y += .5 + p.r*.3`), sways on a sine PLUS the shared
/// `sky.windX` breeze, wraps on all edges, and is drawn as a plain white dot at
/// ~90% opacity. Our contract passes only `t`, so the shared wind is
/// reconstructed deterministically from `t` here (the design's gentle-breeze
/// double-sine, minus its random gusts) — keeping the frame a pure function of
/// `t`. The `drawWinter` mountain/pine scenery is a separate scene layer, not
/// part of this particle port.
void paintSnow(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;

  // Deterministic breeze reconstructed from t (design: gentle double-sine).
  final double wind =
      math.sin(t * math.pi * 2) * 8 + math.sin(t * math.pi * 2 * 1.7 + 1.3) * 4;

  const int count = 70;
  final Paint flake = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.90);

  for (int i = 0; i < count; i++) {
    final double fx = _frac(i * 0.61803398875);
    final double r = 0.6 + _frac(i * 0.317 + 0.29) * 2.0; // 0.6..2.6
    final double phase = fx * math.pi * 2;
    // Fall speed rises slightly with flake size (design: .5 + r*.3).
    final double speed = 0.7 + r * 0.15;
    final double fall = _frac(fx + t * speed);
    final double y = fall * (h + 12) - 6;
    // Sway (per-flake sine) + shared wind drift, wrapped across width.
    final double sway = math.sin(t * math.pi * 2 + phase) * 6;
    double x = fx * w + sway + wind;
    x = _wrap(x, w + 12) - 6;
    canvas.drawCircle(Offset(x, y), r * 1.25, flake);
  }
}

double _frac(double v) => v - v.floorToDouble();

double _wrap(double v, double span) {
  double r = v % span;
  if (r < 0) r += span;
  return r;
}
