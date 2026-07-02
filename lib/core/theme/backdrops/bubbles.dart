import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Ocean backdrop — rising bubble rings beneath a few drifting light shafts.
///
/// Ported from the design `bubbles` particle loop (`Ratel App.dc.html`, L3094)
/// plus the light-ray layer of `drawOcean` (L2371). Bubbles rise (`p.y -= …`),
/// sway on a sine, wrap at the top, and are drawn as thin stroked rings. The
/// full `drawOcean` marine life (fish / jellyfish / kelp / whale) is a Complex
/// scene and is NOT ported in this batch; the light shafts are kept because
/// they carry most of the "underwater" read for cheap.
void paintBubbles(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;

  // --- Light shafts (3 slow-swaying columns), additive-ish soft fills. ---
  final List<double> shaftX = <double>[w * 0.24, w * 0.52, w * 0.80];
  final List<double> shaftWd = <double>[64, 96, 72];
  final List<double> shaftPh = <double>[0, 1.6, 3.2];
  for (int s = 0; s < shaftX.length; s++) {
    final double sway = math.sin(t * math.pi * 2 + shaftPh[s]) * 26;
    final double x0 = shaftX[s] - shaftWd[s] / 2;
    final double x1 = shaftX[s] + shaftWd[s] / 2;
    final Path shaft = Path()
      ..moveTo(x0, 0)
      ..lineTo(x1, 0)
      ..lineTo(x1 + sway, h)
      ..lineTo(x0 + sway, h)
      ..close();
    final Paint shaftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[
          p.accent.withValues(alpha: 0.0),
          p.accent.withValues(alpha: 0.10),
          p.accent.withValues(alpha: 0.0),
        ],
        stops: const <double>[0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(x0, 0, shaftWd[s] + sway.abs(), h));
    canvas.drawPath(shaft, shaftPaint);
  }

  // --- Rising bubbles ---
  const int count = 30;
  final Paint ring = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..color = p.good.withValues(alpha: 0.40);

  for (int i = 0; i < count; i++) {
    final double fx = _frac(i * 0.61803398875);
    final double r = 0.6 + _frac(i * 0.317 + 0.2) * 2.0; // 0.6..2.6
    final double phase = fx * math.pi * 2;
    // Rise: bigger bubbles rise a touch faster (like the design's r*.05 term).
    final double speed = 1.0 + r * 0.12;
    final double up = _frac(fx + t * speed);
    final double y = (1 - up) * (h + 20) - 10; // top-wrapping rise
    final double x = fx * w + math.sin(t * math.pi * 2 + phase) * 12;
    canvas.drawCircle(Offset(x, y), r * 2.4, ring);
  }
}

double _frac(double v) => v - v.floorToDouble();
