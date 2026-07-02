import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Candy backdrop — tumbling confetti sprinkles falling with a gentle sway.
///
/// Ported from the design `sprinkles` particle loop (`Ratel App.dc.html`,
/// L3096): each sprinkle falls (`p.y += .5`), sways horizontally, spins
/// (`p.ph += .02`), and is drawn as a small rotated capsule/rect at ~70%
/// opacity. Colors cycle a bright candy set built from the world palette
/// accents (design uses a fixed 5-color candy array; we source ours from `p`
/// so the sprinkles re-tint per world). The `drawCandy` scenery (balloon,
/// clouds, arch) is not part of this pure particle port.
void paintSprinkles(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;

  const int count = 34;
  // Bright candy cycle from the palette (accent/gold/good/accent2/bad).
  final List<Color> candy = <Color>[
    p.accent,
    p.gold,
    p.good,
    p.accent2,
    p.bad,
  ];

  final Paint paint = Paint()..style = PaintingStyle.fill;

  for (int i = 0; i < count; i++) {
    final double fx = _frac(i * 0.61803398875);
    final double phase0 = _frac(i * 0.317 + 0.13) * math.pi * 2;
    // Fall: top-to-bottom over the loop, offset per particle.
    final double fall = _frac(fx + t);
    final double y = fall * (h + 12) - 6;
    final double x = fx * w + math.sin(t * math.pi * 2 + phase0) * 8;
    // Spin — a slow rotation over the loop plus the seeded phase.
    final double angle = phase0 + t * math.pi * 2;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    paint.color = candy[i % candy.length].withValues(alpha: 0.70);
    canvas.drawRect(const Rect.fromLTWH(-1.4, -3.4, 2.8, 6.8), paint);
    canvas.restore();
  }
}

double _frac(double v) => v - v.floorToDouble();
