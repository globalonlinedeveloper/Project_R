import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Lagoon-night backdrop -- a glowing moon over a dark sea with twinkling stars,
/// moonlit water glints, bioluminescent motes, palm silhouettes and drifting
/// fireflies.
///
/// Ported from the design `drawLagoon` (`Ratel App.dc.html` L2758). The distant
/// island / drifting clouds / mist bands are omitted; the moon, glints, glow
/// motes, palms and fireflies carry the scene.
void paintLagoon(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;
  final double seaTop = h * 0.5;
  final Offset moon = Offset(w * 0.68, h * 0.18);

  // Twinkling stars (upper sky).
  final Paint star = Paint();
  for (int i = 0; i < 30; i++) {
    final double fxk = frac(i * 0.61803398875);
    final double fy = frac(i * 0.75487766625 + 0.1);
    final double r = 0.5 + frac(i * 0.317) * 1;
    final double tw = 0.3 + 0.7 * math.sin(tau + fxk * 6.28).abs();
    star.color = const Color(0xFFDFEAFF).withValues(alpha: tw);
    canvas.drawCircle(Offset(fxk * w, fy * h * 0.45), r, star);
  }

  // Moon: soft halo + two-tone core.
  sunHalo(canvas, size, moon, 90, const Color(0x80DCEBFF));
  canvas.drawCircle(
      moon,
      22,
      Paint()
        ..shader = RadialGradient(
          colors: const <Color>[Color(0xFFFBFDFF), Color(0xFFCFE0F2)],
        ).createShader(Rect.fromCircle(center: moon.translate(-7, -7), radius: 22)));

  // Sea (fades in from the horizon).
  final Paint sea = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[p.page.withValues(alpha: 0), p.page.withValues(alpha: 0.4)],
    ).createShader(Rect.fromLTWH(0, seaTop - 40, w, h - seaTop + 40));
  canvas.drawRect(Rect.fromLTWH(0, seaTop - 40, w, h - seaTop + 40), sea);

  // Moonlit water glints (drifting specks).
  final Paint glint = Paint();
  for (int i = 0; i < 40; i++) {
    final double fxk = frac(i * 0.61803398875 + 0.2);
    final double fy = frac(i * 0.75487766625 + 0.5);
    final double y = seaTop + fy * (h - seaTop);
    final double depth = (y - seaTop) / (h - seaTop);
    final double x = wrap(fxk * w + t * w * 0.2, w + 14) - 7;
    final double a =
        (0.04 + 0.07 * math.sin(tau + fxk * 6.28).abs()) * (0.45 + depth * 0.7);
    glint.color = const Color(0xFFC4ECEF).withValues(alpha: a);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(x, y), width: 4 + depth * 9, height: 0.8 + depth * 0.7),
        glint);
  }

  // Bioluminescent glow motes.
  for (int i = 0; i < 24; i++) {
    final double fxk = frac(i * 0.61803398875 + 0.33);
    final double fy = frac(i * 0.75487766625 + 0.2);
    final double r = 0.8 + frac(i * 0.317) * 1.4;
    final double x = fxk * w;
    final double y = seaTop + 20 + fy * (h - seaTop - 20);
    final double tw = 0.3 + 0.7 * math.sin(tau + fxk * 6.28).abs();
    canvas.drawCircle(Offset(x, y), r * 2.6, Paint()..color = p.good.withValues(alpha: tw * 0.25));
    canvas.drawCircle(Offset(x, y), r, Paint()..color = p.good.withValues(alpha: tw * 0.8));
  }

  // Palm silhouettes.
  final List<List<double>> palms = <List<double>>[
    <double>[0.1, 1, 80], <double>[0.92, -1, 70],
  ];
  for (final List<double> pm in palms) {
    canvas.save();
    canvas.translate(pm[0] * w, h);
    canvas.scale(pm[1], 1);
    canvas.rotate(math.sin(tau) * 0.04);
    final double hh = pm[2];
    final Paint dark = Paint()..color = p.ink.withValues(alpha: 0.7);
    canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(12, -hh * 0.5, 20, -hh),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = p.ink.withValues(alpha: 0.7));
    for (int f = 0; f < 6; f++) {
      canvas.save();
      canvas.translate(20, -hh);
      canvas.rotate(-1.2 + f * 0.42);
      canvas.drawOval(
          Rect.fromCenter(center: const Offset(22, 0), width: 48, height: 10), dark);
      canvas.restore();
    }
    canvas.restore();
  }

  // Drifting fireflies near the palms.
  for (int i = 0; i < 10; i++) {
    final double fxk = frac(i * 0.61803398875);
    final bool left = i.isEven;
    final double bx = (left ? 0.1 : 0.92) * w + (left ? 22 : -22);
    final double by = h - 26 - fxk * 64;
    final double x = bx + math.cos(tau + fxk * 6.28) * 18 + math.sin(tau * 0.7 + fxk) * 6;
    final double y = by + math.sin(tau + fxk * 6.28) * 12;
    final double bl = 0.2 + 0.8 * math.pow(math.sin(tau * 1.5 + fxk * 6.28).abs(), 2).toDouble();
    canvas.drawCircle(Offset(x, y), 3, Paint()..color = const Color(0xFFE2F6A0).withValues(alpha: bl * 0.45));
    canvas.drawCircle(Offset(x, y), 1.3, Paint()..color = const Color(0xFFF4FFD2).withValues(alpha: bl));
  }
}
