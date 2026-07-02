import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Forest backdrop -- wandering, softly pulsing fireflies under two swaying
/// god-ray light shafts.
///
/// Ported from the design `fireflies` particle loop (`Ratel App.dc.html`,
/// L3095) plus the two soft light `rays` of `drawForest` (L2385/L2392). Each
/// firefly drifts on a slow Lissajous path around a seeded home point and
/// pulses (`gl = .4 + .6*|sin|`), drawn as a soft glow disc + a bright core in
/// the canonical firefly yellow-green. The god-rays are cheap gradient wedges
/// that sway with `t`. The design's denser `drawForest` tree/mist/bird scenery
/// is scene furniture, not ported in this particle-focused batch.
void paintFireflies(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;

  final double tau = t * math.pi * 2;

  // Two swaying god-ray shafts (soft themed green, top -> mid).
  const List<double> rayX = <double>[0.30, 0.64];
  const List<double> rayW = <double>[74, 58];
  for (int i = 0; i < rayX.length; i++) {
    final double cx = rayX[i] * w;
    final double half = rayW[i] / 2;
    final double sway = math.sin(tau + i * 2.1) * 18;
    final double botY = h * 0.85;
    final Path ray = Path()
      ..moveTo(cx - half, 0)
      ..lineTo(cx + half, 0)
      ..lineTo(cx + half + sway, botY)
      ..lineTo(cx - half + sway, botY)
      ..close();
    final Paint rayPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          p.good.withValues(alpha: 0.10),
          p.good.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, botY));
    canvas.drawPath(ray, rayPaint);
  }

  // Fireflies: drift + pulse (deterministic, index-seeded -- no RNG).
  const int count = 28;
  const Color glowC = Color(0xFFDFF77A);
  const Color coreC = Color(0xFFEAFF8A);
  final Paint paint = Paint()..style = PaintingStyle.fill;
  for (int i = 0; i < count; i++) {
    final double fx = _frac(i * 0.61803398875);
    final double fy = _frac(i * 0.75487766625 + 0.19);
    final double phase = fx * math.pi * 2;
    final double x = fx * w + math.cos(tau + phase) * (w * 0.04);
    final double y = fy * h + math.sin(tau * 0.8 + phase * 1.3) * (h * 0.04);
    final double gl = 0.4 + 0.6 * math.sin(tau * 2 + phase).abs();
    paint.color = glowC.withValues(alpha: gl * 0.4);
    canvas.drawCircle(Offset(x, y), 4.6, paint);
    paint.color = coreC.withValues(alpha: gl);
    canvas.drawCircle(Offset(x, y), 1.8, paint);
  }
}

double _frac(double v) => v - v.floorToDouble();
