import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Rainforest backdrop -- a swaying god-ray through the canopy, a thin waterfall
/// into a glowing pool, a pair of parrots crossing, an arc of overhead leaves and
/// rising spores.
///
/// Ported from the design `drawJungle` (`Ratel App.dc.html` L2624). Colors come
/// from the world's green accents (ray/canopy/spores) with warm parrots; every
/// actor is index-seeded and driven by `t`.
void paintJungle(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;

  // God-ray shaft (sways at the base).
  final double rx = w * 0.4, rw = 80;
  final double sway = math.sin(tau) * 22;
  final Rect rr = Rect.fromLTWH(0, 0, w, h * 0.8);
  canvas.drawPath(
      Path()
        ..moveTo(rx - rw / 2, 0)
        ..lineTo(rx + rw / 2, 0)
        ..lineTo(rx + rw / 2 + sway, h * 0.8)
        ..lineTo(rx - rw / 2 + sway, h * 0.8)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            p.accent.withValues(alpha: 0.12),
            p.accent.withValues(alpha: 0),
          ],
        ).createShader(rr));

  // Waterfall band + falling drops + pool glow.
  final double wx = w * 0.84, wtop = h * 0.08, wbot = h * 0.64;
  canvas.drawRect(Rect.fromLTWH(wx - 14, wtop, 28, wbot - wtop),
      Paint()..color = p.text.withValues(alpha: 0.14));
  final Paint drop = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4
    ..color = p.text.withValues(alpha: 0.4);
  for (int i = 0; i < 18; i++) {
    final double sp = 0.012 + frac(i * 0.317) * 0.02;
    final double pr = frac(i * 0.61803398875 + t * (sp * 40 + 0.6));
    final double yy = wtop + (wbot - wtop) * pr;
    final double xx = wx - 12 + math.sin(pr * 30 + wx) * 10;
    canvas.drawLine(Offset(xx, yy), Offset(xx, yy + 10), drop);
  }
  final Rect pr2 = Rect.fromCircle(center: Offset(wx, wbot), radius: 30);
  canvas.drawOval(
      Rect.fromCenter(center: Offset(wx, wbot), width: 60, height: 16),
      Paint()
        ..shader = RadialGradient(colors: <Color>[
          p.text.withValues(alpha: 0.3),
          p.text.withValues(alpha: 0),
        ]).createShader(pr2));

  // Two parrots crossing (one each way), flapping.
  final List<Color> parrotC = <Color>[p.bad, p.gold];
  for (int i = 0; i < 2; i++) {
    final int dir = i == 0 ? 1 : -1;
    final double y = h * 0.24 + i * h * 0.14;
    final double base = frac(i * 0.61803398875 + t * (0.7 + i * 0.2));
    final double x = dir > 0 ? base * (w + 24) - 12 : w + 12 - base * (w + 24);
    final double flap = math.sin(tau * 3 + x * 0.1) * 4;
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(dir.toDouble(), 1);
    final Paint body = Paint()..color = parrotC[i];
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 12, height: 6), body);
    canvas.drawPath(
        Path()
          ..moveTo(-2, 0)
          ..lineTo(-8, -6 - flap)
          ..lineTo(-2, -2)
          ..close(),
        body);
    canvas.drawPath(
        Path()
          ..moveTo(6, -1)
          ..lineTo(11, 0)
          ..lineTo(6, 2)
          ..close(),
        body);
    canvas.restore();
  }

  // Overhead canopy leaves (static semicircle arcs along the top).
  final Paint canopy = Paint()..color = p.ink.withValues(alpha: 0.7);
  for (int i = 0; i < 6; i++) {
    final double cx = w * (i / 5);
    final double cr = 30 + frac(i * 0.317) * 24;
    canvas.drawPath(
        Path()..addArc(Rect.fromCircle(center: Offset(cx, 0), radius: cr), 0, math.pi),
        canopy);
  }

  // Rising spores.
  for (int i = 0; i < 18; i++) {
    final double fx = frac(i * 0.61803398875 + 0.05);
    final double fy = frac(i * 0.75487766625 + 0.2);
    final double r = 0.8 + frac(i * 0.317) * 1.3;
    final double y = h - wrap(fy * h + t * h * 0.35, h + 6);
    final double x = fx * w + math.sin(tau + fx * 6.28) * 5;
    canvas.drawCircle(
        Offset(x, y), r, Paint()..color = p.good.withValues(alpha: 0.4));
  }
}
