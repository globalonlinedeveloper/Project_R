import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Dawn backdrop -- a soft warm sunrise: accent-tinted halo, layered hazy hills,
/// drifting clouds, a small flock of birds, low mist and rising motes.
///
/// Ported from the design `drawDawn` (`Ratel App.dc.html` L2552) via the shared
/// ridge/cloud/bird/sun primitives.
void paintDawn(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;
  final double sx = w * 0.5, sy = h * 0.42;

  sunHalo(canvas, size, Offset(sx, sy), math.max(w, h) * 0.6,
      p.accent.withValues(alpha: 0.4));

  // Layered hazy hills (warm, atmospheric perspective).
  final List<List<double>> hills = <List<double>>[
    <double>[0.72, 9], <double>[0.81, 14], <double>[0.90, 19],
  ];
  final List<Color> tone = <Color>[
    p.gold.withValues(alpha: 0.30),
    p.accent.withValues(alpha: 0.40),
    p.accent2.withValues(alpha: 0.54),
  ];
  for (int i = 0; i < hills.length; i++) {
    ridgeFill(canvas, size,
        baseY: h * hills[i][0], amp: hills[i][1], seed: 41 + i,
        segW: 150 - i * 20, oct2: 0.3, color: tone[i]);
  }

  canvas.drawCircle(Offset(sx, sy), 38, Paint()..color = const Color(0xF2FFF0D7));

  // Drifting clouds.
  for (int i = 0; i < 3; i++) {
    final double cx =
        wrap(frac(i * 0.31 + 0.1) * w + t * (w + 160) * (0.3 + i * 0.15),
                w + 160) -
            80;
    softCloud(canvas, Offset(cx, h * (0.1 + i * 0.09)), 32 + i * 5,
        p.surface.withValues(alpha: 0.45),
        seed: i * 5 + 1);
  }

  // Flocking birds.
  final Paint bird = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4
    ..color = p.text.withValues(alpha: 0.5);
  for (int i = 0; i < 5; i++) {
    final double x = wrap(frac(i * 0.19 + 0.2) * w + t * (w + 20), w + 20) - 10;
    final double y = h * 0.2 + i * 6 + math.sin(tau * 4 + i) * 2;
    birdV(canvas, x, y, 4, math.sin(tau * 4 + i) * 1.2, bird);
  }

  // Low mist bands.
  for (int i = 0; i < 2; i++) {
    final double my = h * (0.7 + i * 0.12);
    final double mx = math.sin(tau + i * 2) * 20;
    final Paint mist = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          p.surface.withValues(alpha: 0),
          p.surface.withValues(alpha: 0.16),
          p.surface.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, my - 20, w, 40));
    canvas.drawRect(Rect.fromLTWH(mx - 30, my - 20, w + 60, 40), mist);
  }

  // Rising motes.
  final Paint mote = Paint()..color = p.surface.withValues(alpha: 0.4);
  for (int i = 0; i < 16; i++) {
    final double fxk = frac(i * 0.61803398875 + 0.07);
    final double fy = frac(i * 0.75487766625 + 0.2);
    final double r = 0.6 + frac(i * 0.317 + 0.1) * 1.2;
    final double y = (1 - frac(fy + t * 0.5)) * h;
    final double x = fxk * w + math.sin(tau + fxk * 6.28) * 6;
    canvas.drawCircle(Offset(x, y), r, mote);
  }
}
