import 'dart:math' as math;

import 'package:flutter/rendering.dart';

/// Shared deterministic primitives for the animated theme backdrops
/// (`lib/core/theme/backdrops/`). Every helper is a PURE function of its inputs
/// (index/seed + phase `t`), never RNG, so painters stay repaint-clean and the
/// reduce-motion floor can render a still frame at `t = 0`. Introduced with the
/// Wave-3 "richer moderate scene" batch to factor out the recurring
/// rolling-silhouette, drifting-cloud, flocking-bird and sun-halo primitives
/// the design scenes share (drawDesert/drawMeadow/drawDawn/drawBeach + ridgeY).

/// Fractional part in `[0, 1)`.
double frac(double v) => v - v.floorToDouble();

/// Positive modulo into `[0, span)`.
double wrap(double v, double span) {
  final double r = v % span;
  return r < 0 ? r + span : r;
}

double _hash(int i, int seed) {
  final double s = math.sin((i * 127.1 + seed * 311.7) * 0.99998) * 43758.5453;
  return s - s.floorToDouble();
}

double _smooth(double u) => u * u * (3 - 2 * u);

/// Value-noise ridge height in ~`[-1, 1]` at horizontal position [x], sampled
/// from a per-[seed] control lattice of spacing [segW] plus a finer octave
/// weighted by [oct2]. Mirrors the design `ridgeY` helper but seeded
/// deterministically (no RNG) so the profile is reproducible per frame.
double ridgeAt(int seed, double x, double segW, double oct2) {
  double octave(double seg, int salt) {
    final double s = x / seg;
    final int i = s.floor();
    final double f = s - i;
    final double a = _hash(i, seed + salt);
    final double b = _hash(i + 1, seed + salt);
    return a + (b - a) * _smooth(f);
  }

  final double v = octave(segW, 0) * 0.8 + octave(segW * 0.45, 97) * oct2;
  return (v / (0.8 + oct2) - 0.5) * 2;
}

/// Fills a rolling-silhouette band from [baseY] (rippled by [ridgeAt]) down to
/// the bottom edge, in [color].
void ridgeFill(
  Canvas canvas,
  Size size, {
  required double baseY,
  required double amp,
  required int seed,
  required Color color,
  double segW = 160,
  double oct2 = 0.3,
  double step = 12,
}) {
  final double w = size.width, h = size.height;
  final Path p = Path()
    ..moveTo(0, h)
    ..lineTo(0, baseY);
  for (double x = 0; x <= w; x += step) {
    p.lineTo(x, baseY + ridgeAt(seed, x, segW, oct2) * amp);
  }
  p
    ..lineTo(w, baseY + ridgeAt(seed, w, segW, oct2) * amp)
    ..lineTo(w, h)
    ..close();
  canvas.drawPath(p, Paint()..color = color);
}

/// A soft full-bleed sun/moon [tint] halo centred at [c], plus an optional
/// solid bright [core] disc of radius [coreR].
void sunHalo(Canvas canvas, Size size, Offset c, double radius, Color tint,
    {double? coreR, Color? core}) {
  final Paint halo = Paint()
    ..shader = RadialGradient(
      colors: <Color>[tint, tint.withValues(alpha: 0)],
    ).createShader(Rect.fromCircle(center: c, radius: radius));
  canvas.drawRect(Offset.zero & size, halo);
  if (coreR != null && core != null) {
    canvas.drawCircle(c, coreR, Paint()..color = core);
  }
}

/// A drifting soft cloud — a row of overlapping radial-gradient puffs centred at
/// [c], scaled by [r], in [color]. The puff silhouette is deterministic per
/// [seed].
void softCloud(Canvas canvas, Offset c, double r, Color color, {int seed = 0}) {
  const int puffs = 5;
  for (int i = 0; i < puffs; i++) {
    final double u = (i / (puffs - 1)) * 2 - 1;
    final double rr = r * (0.55 + 0.55 * (1 - u.abs()) + _hash(i, seed) * 0.12);
    final double px = c.dx + u * r * 1.5;
    final double py = c.dy - rr * 0.35 * (1 - u.abs());
    final Paint blob = Paint()
      ..shader = RadialGradient(
        colors: <Color>[color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: Offset(px, py), radius: rr));
    canvas.drawCircle(Offset(px, py), rr, blob);
  }
}

/// A little "V" bird/gull silhouette centred at ([x], [y]) with wing span [sz],
/// wings raised by [flap] px, stroked with [stroke].
void birdV(Canvas canvas, double x, double y, double sz, double flap, Paint stroke) {
  final Path p = Path()
    ..moveTo(x - sz, y)
    ..quadraticBezierTo(x, y - sz * 0.55 + flap, x, y + flap * 0.4)
    ..quadraticBezierTo(x, y - sz * 0.55 + flap, x + sz, y);
  canvas.drawPath(p, stroke);
}
