import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Aurora backdrop -- three waving northern-lights ribbons over a field of
/// twinkling stars.
///
/// Ported from the design `nlights` band block (`Ratel App.dc.html`, L3038)
/// plus its twinkle particles (L3102). Each ribbon is a wavy filled band with a
/// soft vertical gradient in a signature aurora hue (green / teal / violet);
/// the stars twinkle via `|sin|`. Band motion is driven by the looping phase so
/// it seams cleanly at `t = 0/1`.
void paintNlights(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;

  final double tau = t * math.pi * 2;

  // Three aurora ribbons (signature hues: green, teal, violet).
  const List<double> hues = <double>[152, 176, 265];
  for (int b = 0; b < 3; b++) {
    final double baseY = h * 0.10 + b * h * 0.05;
    final Path band = Path()..moveTo(0, 0);
    for (double x = 0; x <= w; x += 8) {
      final double y = baseY +
          math.sin(x * 0.012 + tau + b * 1.3) * 24 +
          math.sin(x * 0.032 + tau * 1.6) * 11;
      band.lineTo(x, y);
    }
    band
      ..lineTo(w, 0)
      ..close();
    final Paint fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          HSLColor.fromAHSL(0.0, hues[b], 0.85, 0.62).toColor(),
          HSLColor.fromAHSL(0.20, hues[b], 0.85, 0.60).toColor(),
          HSLColor.fromAHSL(0.0, hues[b], 0.85, 0.60).toColor(),
        ],
        stops: const <double>[0.0, 0.42, 1.0],
      ).createShader(Rect.fromLTWH(0, baseY - 46, w, 176));
    canvas.drawPath(band, fill);
  }

  // Twinkling stars.
  const int count = 80;
  const Color starC = Color(0xFFDCE7FF);
  final Paint dot = Paint()..style = PaintingStyle.fill;
  for (int i = 0; i < count; i++) {
    final double fx = _frac(i * 0.61803398875);
    final double fy = _frac(i * 0.75487766625 + 0.11);
    final double r = 0.5 + _frac(i * 0.317 + 0.07) * 1.1;
    final double phase = fx * math.pi * 2;
    final double tw = 0.3 + 0.7 * math.sin(tau + phase).abs();
    dot.color = starC.withValues(alpha: tw * 0.85);
    canvas.drawCircle(Offset(fx * w, fy * h), r, dot);
  }
}

double _frac(double v) => v - v.floorToDouble();
