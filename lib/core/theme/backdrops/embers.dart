import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Volcano backdrop -- glowing embers rising and flickering as they drift up.
///
/// Ported from the design `embers` particle loop (`Ratel App.dc.html`, L3103):
/// each ember rises, sways on a sine, and flickers (`fl = .45 + .55*|sin|`),
/// drawn as a soft glow disc + a hot core in alternating warm accents. Rising
/// motion is derived from the looping phase so it seams at `t = 0/1`.
void paintEmbers(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;

  final double tau = t * math.pi * 2;
  const int count = 42;
  final Paint paint = Paint()..style = PaintingStyle.fill;

  for (int i = 0; i < count; i++) {
    final double fx = _frac(i * 0.61803398875);
    final double fy = _frac(i * 0.75487766625 + 0.29);
    final double r = 1.0 + _frac(i * 0.317 + 0.13) * 1.6; // 1.0..2.6
    final double phase = fy * math.pi * 2;
    // Integer rise multiplier keeps the upward loop seamless.
    final double speed = 1 + (i % 3).toDouble();
    final double rise = _frac(fy + t * speed);
    final double y = (1 - rise) * (h + 16) - 8; // bottom -> top
    final double x = fx * w + math.sin(tau + phase) * 10;
    final double fl = 0.45 + 0.55 * math.sin(tau * 2 + phase).abs();
    final Color ec = (i % 3 != 0) ? p.accent : p.gold;
    paint.color = ec.withValues(alpha: fl * 0.32);
    canvas.drawCircle(Offset(x, y), r * 2.1, paint);
    paint.color = ec.withValues(alpha: fl * 0.9);
    canvas.drawCircle(Offset(x, y), r * 0.85, paint);
  }
}

double _frac(double v) => v - v.floorToDouble();
