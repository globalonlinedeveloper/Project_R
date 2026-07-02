import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Sunset backdrop -- a low warm sun with a soft halo, a small flock of birds
/// gliding across, and slow rising heat haze.
///
/// Ported from the design `sunset` inline block (`Ratel App.dc.html`, L3052)
/// plus its haze particles (L3104). The halo is tinted by the world accent; the
/// sun glow/core stay a fixed warm tint (a setting sun reads warm in every
/// palette), the birds glide right with a flapping wing curve, and the haze
/// motes rise slowly. Motion is derived from the looping phase so it seams at
/// `t = 0/1`.
void paintSunset(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;

  final double tau = t * math.pi * 2;
  final double sunX = w * 0.5, sunY = h * 0.32;

  // Warm halo, tinted by the world accent.
  final Paint halo = Paint()
    ..shader = RadialGradient(
      colors: <Color>[
        p.accent.withValues(alpha: 0.22),
        p.accent.withValues(alpha: 0.06),
        p.accent.withValues(alpha: 0.0),
      ],
      stops: const <double>[0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(
        center: Offset(sunX, sunY), radius: math.max(w, h) * 0.55));
  canvas.drawRect(Rect.fromLTWH(0, 0, w, h), halo);

  // Sun glow + warm core.
  final Paint glow = Paint()
    ..shader = RadialGradient(
      colors: const <Color>[
        Color(0xF2FFF6DC),
        Color(0xB3FFD08C),
        Color(0x00FFB878),
      ],
      stops: const <double>[0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(sunX, sunY), radius: 72));
  canvas.drawCircle(Offset(sunX, sunY), 72, glow);
  canvas.drawCircle(
      Offset(sunX, sunY), 30, Paint()..color = const Color(0xFFFFF4DC));

  // Birds gliding right with a flapping wing (dark plum silhouette).
  const int birds = 5;
  final Paint wing = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..color = const Color(0x8C3A2434);
  for (int i = 0; i < birds; i++) {
    final double fx = _frac(i * 0.61803398875);
    final double sz = 4 + _frac(i * 0.317 + 0.2) * 4;
    final double x = _wrap(fx * w + t * (w + 24), w + 24) - 12;
    final double y = h * 0.12 + _frac(i * 0.75 + 0.1) * h * 0.18;
    final double fyf = math.sin(tau * 6 + fx * 6.28) * 2;
    final Path bird = Path()
      ..moveTo(x - sz, y + fyf)
      ..quadraticBezierTo(x, y - sz * 0.55 + fyf, x, y + fyf * 0.6)
      ..quadraticBezierTo(x, y - sz * 0.55 + fyf, x + sz, y + fyf);
    canvas.drawPath(bird, wing);
  }

  // Slow rising heat haze.
  const int haze = 22;
  final Paint mote = Paint()..style = PaintingStyle.fill;
  for (int i = 0; i < haze; i++) {
    final double fx = _frac(i * 0.61803398875 + 0.41);
    final double fy = _frac(i * 0.75487766625 + 0.33);
    final double r = 0.8 + _frac(i * 0.317 + 0.07) * 1.4;
    final double rise = _frac(fy + t * (1 + (i % 2)));
    final double y = (1 - rise) * h;
    final double x = fx * w + math.sin(tau + fx * 6.28) * 8;
    mote.color = const Color(0xFFFFD9A8).withValues(alpha: 0.14);
    canvas.drawCircle(Offset(x, y), r * 1.2, mote);
  }
}

double _frac(double v) => v - v.floorToDouble();

double _wrap(double v, double span) {
  double r = v % span;
  if (r < 0) r += span;
  return r;
}
