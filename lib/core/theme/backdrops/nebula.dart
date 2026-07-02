import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Nebula backdrop -- four layered, softly pulsing nebula cloud regions over a
/// parallax starfield with a few bright diffraction-spiked stars and a small
/// tilted spiral galaxy.
///
/// Ported from the design `drawNebula` (`Ratel App.dc.html` L2863). The dust
/// lanes and the occasional shooting star (rare timed actor) are omitted; the
/// clouds, stars and galaxy carry the scene. The multi-hue cloud lobes keep the
/// design's intrinsic hues (nebulae are inherently many-coloured); the stars +
/// halos use the world's bright text/gold accents. Every actor is index-seeded
/// and driven by `t` -- no RNG, so a frame is pure.
void paintNebula(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;

  // Four nebula cloud regions: x, y (fractions), radius, base hue.
  const List<List<double>> regions = <List<double>>[
    <double>[0.34, 0.32, 155, 285],
    <double>[0.70, 0.50, 175, 230],
    <double>[0.50, 0.80, 150, 322],
    <double>[0.18, 0.62, 95, 190],
  ];
  for (int ri = 0; ri < regions.length; ri++) {
    final double rx = regions[ri][0] * w, ry = regions[ri][1] * h;
    final double rr = regions[ri][2], baseHue = regions[ri][3];
    for (int i = 0; i < 8; i++) {
      final int k = ri * 8 + i;
      final double s1 = frac(k * 0.61803398875);
      final double s2 = frac(k * 0.75487766625 + 0.2);
      final double s3 = frac(k * 0.317 + 0.1);
      final double amp = 5 + s1 * 11, ph = s2 * 6.28;
      final double cx = rx + (s1 * 2 - 1) * rr * 0.6 + math.sin(tau + ph) * amp;
      final double cy =
          ry + (s2 * 2 - 1) * rr * 0.55 + math.cos(tau * 0.8 + ph) * amp * 0.7;
      final double rad = rr * (0.3 + s3 * 0.42);
      final double a = 0.05 + s3 * 0.07;
      final double hue = (baseHue + (s1 * 32 - 16)) % 360;
      final Rect cr = Rect.fromCircle(center: Offset(cx, cy), radius: rad);
      canvas.drawCircle(
          Offset(cx, cy),
          rad,
          Paint()
            ..shader = RadialGradient(colors: <Color>[
              HSLColor.fromAHSL(a, hue, 0.8, 0.62).toColor(),
              HSLColor.fromAHSL(a * 0.45, hue, 0.8, 0.54).toColor(),
              HSLColor.fromAHSL(0, hue, 0.8, 0.5).toColor(),
            ], stops: const <double>[0, 0.55, 1]).createShader(cr));
    }
  }

  // Small tilted spiral galaxy (top-right), slowly rotating.
  final double gx = 0.78 * w, gy = 0.21 * h;
  canvas.save();
  canvas.translate(gx, gy);
  canvas.rotate(-0.5 + tau * 0.05);
  canvas.scale(1, 0.42);
  for (int arm = 0; arm < 2; arm++) {
    for (int i = 2; i < 40; i++) {
      final double ang = i * 0.26 + arm * math.pi, rad = i * 0.95;
      final double a = math.max(0.0, 0.5 - i * 0.011);
      canvas.drawCircle(
          Offset(math.cos(ang) * rad, math.sin(ang) * rad),
          2.2,
          Paint()
            ..color =
                HSLColor.fromAHSL(a, arm == 0 ? 210 : 280, 0.85, 0.8).toColor());
    }
  }
  canvas.restore();
  final Rect gcr = Rect.fromCircle(center: Offset(gx, gy), radius: 7);
  canvas.drawCircle(
      Offset(gx, gy),
      7,
      Paint()
        ..shader = RadialGradient(colors: <Color>[
          p.gold.withValues(alpha: 0.9),
          p.gold.withValues(alpha: 0),
        ]).createShader(gcr));

  // Parallax starfield (index-seeded twinkle).
  final Paint star = Paint();
  for (int i = 0; i < 90; i++) {
    final double fx = frac(i * 0.61803398875);
    final double fy = frac(i * 0.75487766625);
    final double r = 0.3 + frac(i * 0.317) * 0.6;
    final double a = 0.25 + frac(i * 0.19) * 0.35;
    final double tw = a * (0.55 + 0.45 * math.sin(tau + fx * 6.28));
    star.color = p.text.withValues(alpha: tw.clamp(0.0, 1.0));
    canvas.drawCircle(Offset(fx * w, fy * h), r, star);
  }

  // A few bright stars with halos + diffraction spikes.
  const List<List<double>> bright = <List<double>>[
    <double>[0.22, 0.20],
    <double>[0.80, 0.30],
    <double>[0.60, 0.16],
    <double>[0.30, 0.72],
    <double>[0.86, 0.66],
    <double>[0.46, 0.50],
  ];
  for (int i = 0; i < bright.length; i++) {
    final double bx = bright[i][0] * w, by = bright[i][1] * h;
    final double tw = 0.7 + 0.3 * math.sin(tau + i);
    final double rr = (1.6 + i * 0.1) * tw;
    final Rect hr = Rect.fromCircle(center: Offset(bx, by), radius: rr * 5);
    canvas.drawCircle(
        Offset(bx, by),
        rr * 5,
        Paint()
          ..shader = RadialGradient(colors: <Color>[
            p.text.withValues(alpha: 0.5 * tw),
            p.text.withValues(alpha: 0),
          ]).createShader(hr));
    canvas.drawCircle(Offset(bx, by), rr, Paint()..color = p.text);
    final double gl = rr * 6, a = 0.45 * tw;
    final Paint spike = Paint()
      ..strokeWidth = 1
      ..color = p.text.withValues(alpha: a);
    canvas.drawLine(Offset(bx - gl, by), Offset(bx + gl, by), spike);
    canvas.drawLine(Offset(bx, by - gl), Offset(bx, by + gl), spike);
  }
}
