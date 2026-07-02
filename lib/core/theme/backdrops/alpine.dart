import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Alpine backdrop -- a warm sun over drifting clouds and three depth-shaded,
/// procedurally-ridged mountain ranges, a hazy forested valley of swaying
/// conifers, soaring eagles and gentle drifting snow.
///
/// Ported from the design `drawAlpine` (`Ratel App.dc.html` L2656). The design's
/// per-frame random control-point ridges are replaced by the shared
/// deterministic [ridgeAt] value-noise (reused from `backdrop_fx`), and the sun,
/// clouds and eagles reuse [sunHalo]/[softCloud]/[birdV]. The heavy per-segment
/// directional ridge-lighting is dropped in favour of a crest->base vertical
/// gradient. Range/valley tones come from the world palette; every actor is
/// index-seeded and driven by `t`.
void paintAlpine(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;

  // Sun + soft glow.
  sunHalo(canvas, size, Offset(w * 0.80, h * 0.15), 150,
      p.gold.withValues(alpha: 0.5),
      coreR: 24, core: const Color(0xF2FFFDF0));

  // Wispy drifting clouds.
  for (int i = 0; i < 3; i++) {
    final double sp = 0.04 + frac(i * 0.317) * 0.05;
    final double cx = wrap(frac(i * 0.61803398875) * w + t * w * sp * 5, w + 200) - 100;
    final double cy = h * (0.12 + i * 0.06);
    softCloud(canvas, Offset(cx, cy), 40 + i * 6.0,
        const Color(0x66FFFFFF), seed: i * 5);
  }

  // Three depth-shaded procedurally-ridged ranges (far -> near).
  void range(double baseY, double amp, int seed, double segW, double oct2,
      Color crest, Color base) {
    double minY = h;
    final Path path = Path()..moveTo(0, h);
    for (double x = 0; x <= w; x += 5) {
      final double y = baseY - ridgeAt(seed, x, segW, oct2) * amp;
      if (y < minY) minY = y;
      path.lineTo(x, y);
    }
    path
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[crest, base, base],
            stops: const <double>[0, 0.45, 1],
          ).createShader(Rect.fromLTWH(0, minY, w, h - minY)));
  }

  range(h * 0.50, 46, 1, 150, 0.20, p.border.withValues(alpha: 0.58),
      p.muted.withValues(alpha: 0.55));
  range(h * 0.55, 60, 2, 108, 0.27, p.muted.withValues(alpha: 0.84),
      p.accent2.withValues(alpha: 0.80));
  range(h * 0.62, 74, 3, 84, 0.30, p.accent2.withValues(alpha: 0.98),
      p.text.withValues(alpha: 0.99));

  // Hazy forested valley slope.
  final double fyf = h * 0.575;
  final Path valley = Path()
    ..moveTo(0, h)
    ..lineTo(0, fyf);
  for (double x = 0; x <= w; x += 12) {
    final double y = fyf -
        (math.sin(x * 0.018 + tau) * 0.5 + 0.5) * 15 -
        (math.sin(x * 0.052 + tau * 1.7) * 0.5 + 0.5) * 6;
    valley.lineTo(x, y);
  }
  valley
    ..lineTo(w, h)
    ..close();
  canvas.drawPath(valley, Paint()..color = p.muted.withValues(alpha: 0.42));

  // Mist band.
  for (int i = 0; i < 5; i++) {
    final double r = 90 + frac(i * 0.317) * 90;
    final double mx = wrap(frac(i * 0.61803398875) * w + t * w * 0.05 * 5, w + 2 * r) - r;
    final double my = h * (0.55 + frac(i * 0.53) * 0.08);
    final Rect mr = Rect.fromCircle(center: Offset(mx, my), radius: r);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(mx, my), width: r * 2, height: r * 0.8),
        Paint()
          ..shader = RadialGradient(colors: <Color>[
            const Color(0x1AE4EEF6),
            const Color(0x00E4EEF6),
          ]).createShader(mr));
  }

  // Conifers along the valley, swaying.
  final double fyn = h * 0.64;
  void fir(double cx, double by, double ht, Color col, double sway) {
    final double wd = ht * 0.34;
    for (int i = 0; i < 3; i++) {
      final double bY = by - ht * 0.25 * i, tY = by - ht * (0.5 + 0.25 * i);
      final double tw = wd * (1 - 0.26 * i);
      final double sT = sway * ((by - tY) / ht), sB = sway * ((by - bY) / ht);
      canvas.drawPath(
          Path()
            ..moveTo(cx + sT, tY)
            ..lineTo(cx + tw + sB, bY)
            ..lineTo(cx - tw + sB, bY)
            ..close(),
          Paint()..color = col);
    }
  }

  int fi = 0;
  for (double x = -8; x < w + 24; x += 13) {
    final bool near = frac(fi * 0.61803398875) < 0.55;
    final double ht = near ? 24 + frac(fi * 0.317) * 26 : 14 + frac(fi * 0.53) * 16;
    final double dy = near ? 2 + frac(fi * 0.19) * 8 : -6 - frac(fi * 0.11) * 8;
    final double sway = math.sin(tau + fi) * 1.6;
    fir(x + frac(fi * 0.71) * 6, fyn + dy, ht,
        near ? p.text.withValues(alpha: 0.92) : p.muted.withValues(alpha: 0.62),
        sway);
    fi++;
  }

  // Soaring eagles.
  final Paint wing = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round
    ..color = p.text.withValues(alpha: 0.5);
  for (int i = 0; i < 2; i++) {
    final double sp = 0.28 + frac(i * 0.317) * 0.3;
    final double x = wrap(frac(i * 0.61803398875) * w + t * w * sp * 5, w + 28) - 14;
    final double y = h * 0.18 + frac(i * 0.53) * h * 0.2 + math.sin(tau * 2 + i) * 6;
    birdV(canvas, x, y, 7 + frac(i * 0.19) * 4, math.sin(tau * 3 + i) * 3, wing);
  }

  // Gentle drifting snow.
  for (int i = 0; i < 14; i++) {
    final double fx = frac(i * 0.61803398875 + 0.03);
    final double fy = frac(i * 0.75487766625);
    final double r = 0.7 + frac(i * 0.317) * 1.1;
    final double y = wrap(fy * h + t * h * (0.3 + r * 0.15), h + 8) - 4;
    final double x = fx * w + math.sin(tau + fx * 6.28) * 8;
    canvas.drawCircle(Offset(x, y), r, Paint()..color = const Color(0xB3FFFFFF));
  }
}
