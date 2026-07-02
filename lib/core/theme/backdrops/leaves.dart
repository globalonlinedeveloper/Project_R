import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Autumn backdrop -- leaves spinning and fluttering down under a soft warm sun
/// glow.
///
/// Ported from the design `leaves` particle loop (`Ratel App.dc.html`, L3101)
/// plus the warm radial glow of `drawAutumn` (L2481). Each leaf falls, drifts
/// on a sine plus the shared breeze, spins (`rotate`), and flutters by squashing
/// its vertical scale (`|sin|`), drawn as a rotated ellipse with a centre vein
/// in one of the world's warm accents. The design's hill/tree scenery is a
/// separate scene layer, not ported in this particle batch.
void paintLeaves(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;

  final double tau = t * math.pi * 2;

  // Soft warm sun glow (design radial at w*.3, h*.2, r 150).
  final Offset glowC = Offset(w * 0.3, h * 0.2);
  const double glowR = 150;
  final Paint glow = Paint()
    ..shader = RadialGradient(
      colors: <Color>[
        p.gold.withValues(alpha: 0.30),
        p.gold.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: glowC, radius: glowR));
  canvas.drawCircle(glowC, glowR, glow);

  // Deterministic breeze from t (design's gentle double-sine, no gusts).
  final double wind = math.sin(tau) * 9 + math.sin(tau * 1.7 + 1.3) * 4.5;

  const int count = 24;
  final List<Color> leafC = <Color>[p.accent, p.bad, p.gold, p.accent2];
  final Paint paint = Paint()..style = PaintingStyle.fill;
  final Paint vein = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.6
    ..color = const Color(0x66462308); // rgba(70,35,8,.4)

  for (int i = 0; i < count; i++) {
    final double fx = _frac(i * 0.61803398875);
    final double r = 1.0 + _frac(i * 0.317 + 0.23) * 2.2; // 1.0..3.2
    final double phase = fx * math.pi * 2;
    final double speed = 0.8 + _frac(i * 0.213 + 0.05) * 0.5;

    final double fall = _frac(fx + t * speed);
    final double y = fall * (h + 16) - 8;
    double x = fx * w + math.sin(tau + phase) * (7 + r) + wind;
    x = _wrap(x, w + 16) - 8;

    final double spin = phase + tau; // one turn per loop + seeded offset
    final double squash = math.max(0.3, math.sin(spin * 0.6).abs());

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(spin);
    canvas.scale(1, squash);
    paint.color = leafC[i % leafC.length].withValues(alpha: 0.84);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 2.4, height: r * 4.6),
      paint,
    );
    canvas.drawLine(Offset(0, -r * 2.1), Offset(0, r * 2.1), vein);
    canvas.restore();
  }
}

double _frac(double v) => v - v.floorToDouble();

double _wrap(double v, double span) {
  double r = v % span;
  if (r < 0) r += span;
  return r;
}
