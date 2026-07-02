import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Tropical-beach backdrop -- a bright sun over a calm sea with a bobbing
/// sailboat, gliding gulls, swaying palms and sparkling water.
///
/// Ported from the design `drawBeach` (`Ratel App.dc.html` L2566) via the
/// shared sun/bird primitives; the sea tint comes from the world `page` color.
void paintBeach(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;
  final double seaTop = h * 0.5;

  sunHalo(canvas, size, Offset(w * 0.5, h * 0.26), 150,
      p.gold.withValues(alpha: 0.5),
      coreR: 32, core: const Color(0xF2FFF6D6));

  // Sea.
  canvas.drawRect(Rect.fromLTWH(0, seaTop, w, h - seaTop),
      Paint()..color = p.page.withValues(alpha: 0.4));

  // Bobbing sailboat.
  final double bx = wrap(t * (w + 60), w + 60) - 30;
  final double by = seaTop - 2 + math.sin(tau) * 1.5;
  canvas.save();
  canvas.translate(bx, by);
  canvas.drawPath(
      Path()
        ..moveTo(-12, 0)
        ..lineTo(12, 0)
        ..lineTo(7, 7)
        ..lineTo(-7, 7)
        ..close(),
      Paint()..color = p.text.withValues(alpha: 0.6));
  final Paint sail = Paint()..color = p.surface.withValues(alpha: 0.75);
  canvas.drawPath(
      Path()
        ..moveTo(1, -22)
        ..lineTo(1, -2)
        ..lineTo(12, -2)
        ..close(),
      sail);
  canvas.drawPath(
      Path()
        ..moveTo(-1, -18)
        ..lineTo(-1, -2)
        ..lineTo(-10, -2)
        ..close(),
      sail);
  canvas.restore();

  // Gulls.
  final Paint gull = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4
    ..color = p.text.withValues(alpha: 0.5);
  for (int i = 0; i < 4; i++) {
    final double x = wrap(frac(i * 0.23 + 0.2) * w + t * (w + 20), w + 20) - 10;
    final double y = h * 0.15 + i * 6 + math.sin(tau * 4 + i) * 2;
    birdV(canvas, x, y, 4, math.sin(tau * 4 + i) * 1.2, gull);
  }

  // Swaying palms.
  final List<List<double>> palms = <List<double>>[
    <double>[0.12, 1, 96], <double>[0.9, -1, 84],
  ];
  for (final List<double> pm in palms) {
    canvas.save();
    canvas.translate(pm[0] * w, h);
    canvas.scale(pm[1], 1);
    canvas.rotate(math.sin(tau) * 0.05);
    final double hh = pm[2];
    canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(12, -hh * 0.5, 20, -hh),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = p.text.withValues(alpha: 0.6));
    final Paint frond = Paint()..color = p.good.withValues(alpha: 0.6);
    for (int f = 0; f < 6; f++) {
      canvas.save();
      canvas.translate(20, -hh);
      canvas.rotate(-1.2 + f * 0.42 + math.sin(tau + f) * 0.05);
      canvas.drawOval(
          Rect.fromCenter(center: const Offset(22, 0), width: 48, height: 10),
          frond);
      canvas.restore();
    }
    canvas.restore();
  }

  // Twinkling water sparkle.
  final Paint spark = Paint();
  for (int i = 0; i < 20; i++) {
    final double fxk = frac(i * 0.61803398875);
    final double fy = frac(i * 0.75487766625 + 0.5);
    final double phase = fxk * math.pi * 2;
    final double tw = 0.85 * math.sin(tau + phase).abs();
    spark.color = const Color(0xFFEAFFFF).withValues(alpha: tw * 0.55);
    canvas.drawCircle(Offset(fxk * w, seaTop + fy * (h - seaTop)),
        0.6 + frac(i * 0.317) * 1.2, spark);
  }
}
