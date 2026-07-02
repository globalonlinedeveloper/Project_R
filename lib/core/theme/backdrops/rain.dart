import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Rainstorm backdrop -- fast diagonal rain streaks with periodic lightning
/// flashes.
///
/// Ported from the design `rain` particle loop (`Ratel App.dc.html`, L3098):
/// each drop falls quickly with a slight slant and the whole sky flashes on an
/// occasional lightning strike. Our contract passes only the looping phase `t`,
/// so the design's random lightning timer is reconstructed as two deterministic
/// flashes per loop (sharp onset, quick decay) -- keeping the frame a pure
/// function of `t`. The design's drifting `drawStorm` cloud bank is a separate
/// scene layer, not ported here.
void paintRain(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;

  // Lightning: two deterministic flashes per loop (t=.18, t=.66).
  double flash = 0;
  for (final double tc in const <double>[0.18, 0.66]) {
    final double k = _frac(t - tc);
    if (k < 0.05) flash = math.max(flash, (1 - k / 0.05) * 0.45);
  }
  if (flash > 0) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFD2E1FF).withValues(alpha: flash),
    );
  }

  // Rain streaks (deterministic, index-seeded).
  const int count = 100;
  final Paint drop = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.1
    ..color = p.accent.withValues(alpha: 0.42);
  for (int i = 0; i < count; i++) {
    final double fx = _frac(i * 0.61803398875);
    // Integer fall multiplier => several passes per loop, still seamless.
    final double speed = 6 + (i % 4).toDouble();
    final double fall = _frac(fx + t * speed);
    final double y = fall * (h + 26) - 13;
    final double x = fx * w + math.sin(t * math.pi * 2 + fx * 6.28) * 5;
    canvas.drawLine(Offset(x, y), Offset(x - 3, y - 13), drop);
  }
}

double _frac(double v) => v - v.floorToDouble();
