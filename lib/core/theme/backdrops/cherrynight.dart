import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Cherry-blossom night backdrop -- a hazy moon and twinkling stars above two
/// arching blossom branches strung with softly-glowing paper lanterns, while
/// pale petals tumble down.
///
/// Ported from the design `drawCherryNight` (`Ratel App.dc.html` L2923). The
/// design bakes the near-static moon+branch+blossom layer to an offscreen canvas
/// as a per-frame-redraw optimisation; here the layer is drawn directly each
/// frame (Skia handles it), so the painter stays a pure function of `(size, p,
/// t)` with no cached state. Blossom/lantern/moon tints come from the world
/// palette; every actor is index-seeded and driven by `t`.
void paintCherryNight(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;

  // Twinkling stars (upper half).
  for (int i = 0; i < 38; i++) {
    final double fx = frac(i * 0.61803398875);
    final double fy = frac(i * 0.75487766625) * 0.5;
    final double r = 0.5 + frac(i * 0.317) * 1.1;
    final double a = 0.3 + 0.7 * math.sin(tau + fx * 6.28).abs();
    canvas.drawCircle(
        Offset(fx * w, fy * h), r, Paint()..color = p.text.withValues(alpha: a));
  }

  // Moon (glow + disc + maria).
  final Offset moon = Offset(w * 0.72, h * 0.2);
  canvas.drawCircle(
      moon,
      72,
      Paint()
        ..shader = RadialGradient(colors: <Color>[
          p.text.withValues(alpha: 0.45),
          p.text.withValues(alpha: 0.15),
          p.text.withValues(alpha: 0),
        ], stops: const <double>[0, 0.5, 1]).createShader(
            Rect.fromCircle(center: moon, radius: 72)));
  canvas.drawCircle(moon, 20, Paint()..color = p.text.withValues(alpha: 0.96));
  final Paint maria = Paint()..color = p.muted.withValues(alpha: 0.35);
  for (final List<double> c in <List<double>>[
    <double>[-6, -3, 4],
    <double>[5, 2, 3],
    <double>[-2, 6, 2.4]
  ]) {
    canvas.drawCircle(Offset(moon.dx + c[0], moon.dy + c[1]), c[2], maria);
  }

  Offset qpt(double cx, double cy, double ex, double ey, double u) {
    final double v = 1 - u;
    return Offset(2 * v * u * cx + u * u * ex, 2 * v * u * cy + u * u * ey);
  }

  void bloom(double cx, double cy, double sz, bool pale) {
    final Paint pet = Paint()
      ..color = pale ? p.text.withValues(alpha: 0.95) : p.accent.withValues(alpha: 0.92);
    for (int k = 0; k < 5; k++) {
      final double a = k * 1.2566 + 0.3;
      final double px = cx + math.cos(a) * sz * 1.1, py = cy + math.sin(a) * sz * 1.1;
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(a);
      canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: sz * 1.56, height: sz * 2.1), pet);
      canvas.restore();
    }
    canvas.drawCircle(Offset(cx, cy), sz * 0.5, Paint()..color = p.gold.withValues(alpha: 0.95));
  }

  const double c1x = 88, c1y = 26, ex = 178, ey = 46;

  void branch(double bx, int dir) {
    canvas.save();
    canvas.translate(bx, 0);
    canvas.scale(dir.toDouble(), 1);
    const int segs = 10;
    for (int i = 0; i < segs; i++) {
      final double u0 = i / segs, u1 = (i + 1) / segs;
      final Offset p0 = qpt(c1x, c1y, ex, ey, u0), p1 = qpt(c1x, c1y, ex, ey, u1);
      canvas.drawLine(
          p0,
          p1,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 4.2 * (1 - u0 * 0.78)
            ..color = p.ink.withValues(alpha: 0.7));
    }
    for (final List<double> tw in <List<double>>[
      <double>[0.5, -0.55, 30],
      <double>[0.74, 0.5, 24]
    ]) {
      final Offset a = qpt(c1x, c1y, ex, ey, tw[0]);
      final double tx = a.dx + math.cos(tw[1]) * tw[2], ty = a.dy + math.sin(tw[1]) * tw[2];
      canvas.drawPath(
          Path()
            ..moveTo(a.dx, a.dy)
            ..quadraticBezierTo((a.dx + tx) / 2, (a.dy + ty) / 2 - 4, tx, ty),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..color = p.ink.withValues(alpha: 0.6));
      bloom(tx, ty, 3.2, false);
      bloom(tx + 4, ty + 2, 2.6, true);
    }
    const List<double> clusters = <double>[0.24, 0.42, 0.60, 0.78, 0.93];
    for (int ci = 0; ci < clusters.length; ci++) {
      final Offset a = qpt(c1x, c1y, ex, ey, clusters[ci]);
      final double ax = a.dx, ay = a.dy + (frac(ci * 0.61803398875) * 2 - 1) * 5;
      final int n = 3 + (frac(ci * 0.317) * 2).floor();
      final double szf = 0.85 + frac(ci * 0.53) * 0.35;
      final double seed = frac(ci * 0.71) * 6.28;
      for (int k = 0; k < n; k++) {
        final double ang = seed + k * 2.0, rr = 4 + k * 3.0 * szf;
        bloom(ax + math.cos(ang) * rr, ay + math.sin(ang) * rr - 2,
            (3.4 - k * 0.25) * szf, k % 3 == 0);
      }
    }
    canvas.restore();
  }

  branch(0, 1);
  branch(w, -1);

  // Paper lanterns (glow + cord, swaying).
  void lantern(double bx, int dir, double u, double cord, double phase) {
    canvas.save();
    canvas.translate(bx, 0);
    canvas.scale(dir.toDouble(), 1);
    final double v = 1 - u;
    final double ax = 2 * v * u * c1x + u * u * ex, ay = 2 * v * u * c1y + u * u * ey;
    final double lx = ax + math.sin(tau + phase) * 4, ly = ay + cord;
    canvas.drawLine(Offset(ax, ay), Offset(lx, ly),
        Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = p.ink.withValues(alpha: 0.5));
    final double gl = 0.72 + 0.28 * math.sin(tau + phase);
    canvas.drawCircle(
        Offset(lx, ly + 8),
        13,
        Paint()
          ..shader = RadialGradient(colors: <Color>[
            p.gold.withValues(alpha: 0.8 * gl),
            p.gold.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: Offset(lx, ly + 8), radius: 13)));
    canvas.drawOval(Rect.fromCenter(center: Offset(lx, ly + 8), width: 14, height: 18),
        Paint()..color = p.gold.withValues(alpha: gl));
    canvas.restore();
  }

  lantern(0, 1, 0.52, 34, 0.4);
  lantern(w, -1, 0.44, 30, 1.1);
  lantern(w, -1, 0.74, 40, 2.7);

  // Falling petals (tumble + wind wobble).
  for (int i = 0; i < 24; i++) {
    final double d = frac(i * 0.61803398875);
    final double fy = frac(i * 0.75487766625);
    final double r = 1.6 + d * 2.2;
    final double sw = tau + frac(i * 0.317) * 6.28;
    final double y = wrap(fy * h + t * h * (0.45 + d * 0.85), h + 20) - 10;
    final double x = frac(i * 0.53) * w + math.sin(sw) * (4 + d * 5);
    final double tumble = math.cos(tau + frac(i * 0.19) * 6.28);
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(sw * 0.5);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset.zero,
            width: r * (0.3 + 0.7 * tumble.abs()) * 2,
            height: r * 1.7 * 2),
        Paint()
          ..color = (frac(i * 0.11) < 0.28 ? p.text : p.accent)
              .withValues(alpha: 0.5 + d * 0.45));
    canvas.restore();
  }
}
