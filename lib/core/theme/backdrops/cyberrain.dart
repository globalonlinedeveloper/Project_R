import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Cyber-rain backdrop -- a neon skyline under driving diagonal rain: dark
/// building blocks with a cyan edge-glow, flickering neon signs, bright rain
/// streaks and a cyan->magenta floor glow.
///
/// Ported from the design `drawCyberRain` (`Ratel App.dc.html` L2635). The
/// per-building/sign/rain RNG seeds become deterministic index seeds and all
/// motion derives from `t`; colors come from the world's pink accent + cyan
/// good.
void paintCyberRain(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;

  // Skyline: 9 dark building blocks with a cyan edge stroke (deterministic h).
  final Paint block = Paint()..color = p.page.withValues(alpha: 0.85);
  final Paint edge = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = p.good.withValues(alpha: 0.4);
  final double bw = (w / 8) * 0.95;
  for (int i = 0; i < 9; i++) {
    final double bh = 60 + ((i * 37) % 5) * 26;
    final double x = i * (w / 8);
    final double top = h - bh;
    canvas.drawRect(Rect.fromLTWH(x, top, bw, bh), block);
    canvas.drawRect(Rect.fromLTWH(x + 0.5, top + 0.5, bw - 1, bh), edge);
  }

  // Flickering neon signs (alternating pink accent / cyan good).
  for (int i = 0; i < 5; i++) {
    final double fx = frac(i * 0.61803398875);
    final double x = fx * w;
    final double y = h * 0.4 + frac(i * 0.317 + 0.1) * h * 0.28;
    final double sw = 8 + frac(i * 0.53) * 14;
    final double sh = 18 + frac(i * 0.19 + 0.2) * 30;
    final Color c = i.isEven ? p.accent : p.good;
    final double fl = 0.55 + 0.45 * math.sin(tau + fx * 6.28).abs();
    canvas.drawRect(
        Rect.fromLTWH(x, y, sw, sh), Paint()..color = c.withValues(alpha: fl));
  }

  // Diagonal rain streaks (fall + drift right), deterministic wrap by t.
  final Paint rain = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..strokeCap = StrokeCap.round
    ..color = p.text.withValues(alpha: 0.4);
  for (int i = 0; i < 70; i++) {
    final double fx = frac(i * 0.61803398875);
    final double fy = frac(i * 0.75487766625 + 0.2);
    final double sp = 0.5 + frac(i * 0.317);
    final double y = wrap(fy * h + t * h * (1.4 + sp), h + 20) - 10;
    final double x = wrap(fx * w + t * w * 0.45, w);
    canvas.drawLine(Offset(x, y), Offset(x - 3, y - 12), rain);
  }

  // Floor glow: cyan -> magenta bottom band.
  final Rect fr = Rect.fromLTWH(0, h - 44, w, 44);
  canvas.drawRect(
      fr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            p.good.withValues(alpha: 0),
            p.accent.withValues(alpha: 0.14),
          ],
        ).createShader(fr));
}
