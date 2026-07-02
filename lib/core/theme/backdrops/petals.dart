import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Cherry-blossom backdrop — petals fluttering down with a tumbling, wind-blown
/// drift, under a soft blossom-light glow.
///
/// Ported from the design `petals` particle loop (`Ratel App.dc.html`, L3100)
/// plus the soft radial glow of `drawSakura` (L2461). Each petal falls, drifts
/// on a horizontal sine of amplitude `~7 + r*2.2`, eases toward the shared wind
/// (`sky.windX`), spins slowly, and is drawn as a rotated ellipse
/// (`r*1.0 x r*2.1`) at ~82% opacity in one of two pinks. The design's blossom
/// BRANCHES are decorative scene furniture (part of `drawSakura`) and are not
/// ported in this particle-focused batch; the glow is kept for atmosphere.
void paintPetals(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;

  // Soft top-right blossom glow (design radial at w*.8, h*.14, r 130).
  final Offset glowC = Offset(w * 0.8, h * 0.14);
  const double glowR = 130;
  final Paint glow = Paint()
    ..shader = RadialGradient(
      colors: <Color>[
        p.surface.withValues(alpha: 0.45),
        p.surface.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: glowC, radius: glowR));
  canvas.drawCircle(glowC, glowR, glow);

  // Deterministic breeze from t (design's gentle double-sine, no gusts).
  final double wind =
      math.sin(t * math.pi * 2) * 10 + math.sin(t * math.pi * 2 * 1.7 + 1.3) * 5;

  const int count = 30;
  final Paint paint = Paint()..style = PaintingStyle.fill;
  final Color petalA = p.accent; // themed pink
  final Color petalB = p.accent2;

  for (int i = 0; i < count; i++) {
    final double fx = _frac(i * 0.61803398875);
    final double r = 0.6 + _frac(i * 0.317 + 0.41) * 2.4; // 0.6..3.0
    final double phase = fx * math.pi * 2;
    final double amp = 7 + r * 2.2;

    final double speed = 0.85 + _frac(i * 0.213 + 0.05) * 0.4;
    final double fall = _frac(fx + t * speed);
    final double y = fall * (h + 16) - 8;

    final double sw = phase + t * math.pi * 2; // tumble / sway phase
    double x = fx * w + math.sin(sw) * amp + wind;
    x = _wrap(x, w + 20) - 10;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(sw * 0.6);
    paint.color = (i.isOdd ? petalA : petalB).withValues(alpha: 0.82);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 2.0, height: r * 4.2),
      paint,
    );
    canvas.restore();
  }
}

double _frac(double v) => v - v.floorToDouble();

double _wrap(double v, double span) {
  double r = v % span;
  if (r < 0) r += span;
  return r;
}
