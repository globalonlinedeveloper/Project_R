import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Thunderhead backdrop -- a dark storm ceiling of drifting, depth-shaded cloud
/// clusters lit from within by intermittent branching lightning, with driving
/// rain and a faint breathing mist at the base.
///
/// Ported from the design `drawThunder` (`Ratel App.dc.html` L2783). The
/// design's random bolt timer is reconstructed deterministically: two strikes
/// per loop via a wrapped-phase pulse envelope (so a frame stays a pure function
/// of `t` and the loop seams at t=0/1, where the sky is calm). Cloud + bolt
/// geometry is index-seeded; storm tones come from the world palette.
void paintThunder(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;

  double hash(int i, int salt) {
    final double s = math.sin((i * 127.1 + salt * 311.7) * 0.9998) * 43758.5453;
    return s - s.floorToDouble();
  }

  // Storm ceiling: continuous dark base band.
  final Rect band = Rect.fromLTWH(0, 0, w, h * 0.32);
  canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            p.page.withValues(alpha: 0.92),
            p.page.withValues(alpha: 0),
          ],
        ).createShader(band));

  // Drifting cloud clusters (depth-shaded puffs).
  for (int c = 0; c < 6; c++) {
    final double sx = hash(c, 1);
    final double cy = h * (0.05 + hash(c, 2) * 0.12);
    final double drift = 0.04 + hash(c, 3) * 0.07;
    final double cx = wrap(sx * (w + 240) + t * w * drift * 6, w + 240) - 120;
    for (int j = 0; j < 8; j++) {
      final int k = c * 8 + j;
      final double dx = (hash(k, 4) * 2 - 1) * 95;
      final double dy = -34 + hash(k, 5) * 86;
      final double rad = 34 + hash(k, 6) * 40;
      final double kk = (dy + 34) / 86;
      final double a = 0.55 + hash(k, 7) * 0.35;
      final double x = cx + dx, y = cy + dy;
      final Color tone = Color.lerp(p.muted, p.page, kk)!;
      final Rect pr = Rect.fromCircle(center: Offset(x, y), radius: rad);
      canvas.drawCircle(
          Offset(x, y),
          rad,
          Paint()
            ..shader = RadialGradient(colors: <Color>[
              tone.withValues(alpha: a),
              tone.withValues(alpha: a * 0.45),
              tone.withValues(alpha: 0),
            ], stops: const <double>[0, 0.7, 1]).createShader(pr));
    }
  }

  // Lightning: two deterministic strikes per loop via a wrapped-phase pulse.
  double pulse(double centre, double wdt) {
    double d = (t - centre).abs();
    d = math.min(d, 1 - d);
    return d < wdt ? 1 - d / wdt : 0.0;
  }

  final double b0 = pulse(0.30, 0.06), b1 = pulse(0.72, 0.05);
  final double bloom = math.max(b0, b1);
  final bool lit = bloom > 0.45;
  final int strike = b0 >= b1 ? 0 : 1;
  final double bx = w * (strike == 0 ? 0.34 : 0.64);

  // Bloom lighting the clouds from within (additive-ish soft glow).
  if (bloom > 0) {
    final double by = h * 0.13, radius = h * 0.34 * (lit ? 1 : 0.7);
    final double peak = (lit ? 0.55 : 0.16) * bloom;
    final Rect gr = Rect.fromCircle(center: Offset(bx, by), radius: radius);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h * 0.42),
        Paint()
          ..shader = RadialGradient(colors: <Color>[
            p.accent.withValues(alpha: peak),
            p.accent.withValues(alpha: peak * 0.4),
            p.accent.withValues(alpha: 0),
          ], stops: const <double>[0, 0.5, 1]).createShader(gr));
  }
  if (lit) {
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h),
        Paint()..color = p.accent.withValues(alpha: 0.07));
    // The bolt: soft glow pass + bright core, zig-zag + one branch.
    final List<Offset> seg = <Offset>[Offset(bx, h * 0.14)];
    double cx = bx, cy = h * 0.14;
    for (int i = 0; i < 9; i++) {
      cx += (hash(i, strike * 17 + 1) - 0.5) * 46;
      cy += h * 0.05;
      seg.add(Offset(cx, cy));
    }
    final int si = 2 + (hash(0, strike + 9) * 3).floor();
    final int dir = hash(1, strike + 3) < 0.5 ? -1 : 1;
    final List<Offset> branch = <Offset>[seg[si]];
    double bx2 = seg[si].dx, by2 = seg[si].dy;
    for (int i = 0; i < 4; i++) {
      bx2 += dir * (14 + hash(i, strike + 21) * 28);
      by2 += h * 0.038;
      branch.add(Offset(bx2, by2));
    }
    void drawBolt(List<Offset> pts, double coreW, double glowW) {
      final Path path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (int i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = glowW
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = p.accent.withValues(alpha: 0.35));
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = coreW
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = p.text.withValues(alpha: 0.95));
    }

    drawBolt(seg, 2.6, 8);
    drawBolt(branch, 1.5, 5);
  }

  // Rain in front (fall + slight wind).
  final Paint rain = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = p.muted.withValues(alpha: 0.4);
  for (int i = 0; i < 80; i++) {
    final double fx = frac(i * 0.61803398875);
    final double fy = frac(i * 0.75487766625 + 0.2);
    final double sp = 0.5 + frac(i * 0.317);
    final double len = 9 + frac(i * 0.19) * 9;
    final double y = wrap(fy * h + t * h * (1.6 + sp), h + 24) - 12;
    final double x = wrap(fx * w + t * w * 0.5, w);
    canvas.drawLine(Offset(x, y), Offset(x - 4, y - len - 4), rain);
  }

  // Faint breathing mist at the base.
  final double ma = 0.12 + 0.05 * math.sin(t * math.pi * 2 * 0.5);
  final double mtop = h * (0.80 - 0.03 * math.sin(t * math.pi * 2 * 0.4 + 1));
  final Rect mr = Rect.fromLTWH(0, mtop, w, h - mtop);
  canvas.drawRect(
      mr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[
            p.muted.withValues(alpha: ma),
            p.muted.withValues(alpha: 0),
          ],
        ).createShader(mr));
}
