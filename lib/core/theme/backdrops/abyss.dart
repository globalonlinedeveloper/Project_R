import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Deep-sea (abyss) backdrop -- a faint surface glow high above, rising
/// bioluminescent glow motes and slowly drifting, pulsing jellyfish trailing
/// wavy tentacles.
///
/// Ported from the design `drawAbyss` (`Ratel App.dc.html` L2645). The rare
/// roving anglerfish (a timed spawn) is omitted; the glow motes + jellyfish
/// carry the abyss. Colors are the world's cyan/mint accents; every actor is
/// index-seeded and driven by `t`.
void paintAbyss(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;

  // Faint surface light filtering down over the top half.
  final Rect top = Rect.fromLTWH(0, 0, w, h * 0.5);
  canvas.drawRect(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            p.accent.withValues(alpha: 0.12),
            p.accent.withValues(alpha: 0),
          ],
        ).createShader(top));

  // Rising bioluminescent glow motes (halo + core, twinkling).
  for (int i = 0; i < 30; i++) {
    final double fx = frac(i * 0.61803398875);
    final double fy = frac(i * 0.75487766625 + 0.1);
    final double r = 0.6 + frac(i * 0.317) * 1.4;
    final double y = h - wrap(fy * h + t * h * 0.28, h + 6);
    final double x = fx * w;
    final double tw = 0.3 + 0.7 * math.sin(tau + fx * 6.28).abs();
    final Color c = i.isEven ? p.accent : p.good;
    canvas.drawCircle(
        Offset(x, y), r * 2.6, Paint()..color = c.withValues(alpha: tw * 0.3));
    canvas.drawCircle(
        Offset(x, y), r, Paint()..color = c.withValues(alpha: tw));
  }

  // Drifting, pulsing jellyfish.
  final List<Color> jc = <Color>[p.accent, p.good, p.gold];
  for (int i = 0; i < 3; i++) {
    final double fx = frac(i * 0.61803398875 + 0.2);
    final double fy = frac(i * 0.75487766625 + 0.3);
    final double jr = 10 + frac(i * 0.317) * 8;
    final double ph = tau + fx * 6.28;
    final double y = h + 30 - wrap(fy * (h + 60) + t * h * 0.5, h + 60);
    final double x = fx * w + math.sin(ph * 0.5) * 12;
    final double pl = 0.85 + 0.15 * math.sin(ph);
    final Color c = jc[i];
    canvas.save();
    canvas.translate(x, y);
    // Bell (upper half-oval).
    final Rect br = Rect.fromCircle(center: Offset.zero, radius: jr * 1.3);
    canvas.drawPath(
        Path()
          ..addArc(
              Rect.fromCenter(
                  center: Offset.zero,
                  width: jr * 2 * pl,
                  height: jr * 1.6 * pl),
              math.pi,
              math.pi),
        Paint()
          ..shader = RadialGradient(colors: <Color>[
            c.withValues(alpha: 0.6),
            c.withValues(alpha: 0),
          ]).createShader(br));
    // Tentacles.
    final Paint tent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = c.withValues(alpha: 0.4);
    for (int k = 0; k < 5; k++) {
      final double tx = -jr * 0.5 + k * (jr * 0.25);
      final Path path = Path()..moveTo(tx, 0);
      for (int s = 1; s <= 4; s++) {
        path.lineTo(tx + math.sin(tau + s + k) * 3, s * 6);
      }
      canvas.drawPath(path, tent);
    }
    canvas.restore();
  }
}
