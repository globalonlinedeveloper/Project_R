import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

/// Neon City backdrop — a receding synthwave perspective grid with a scatter of
/// twinkling points.
///
/// Ported from the design `grid` branch of `drawSky` (`Ratel App.dc.html`,
/// L3031) plus its `grid` twinkle particles (L3097). Horizontal lines start at
/// the horizon (`h*.52`) and march downward on a looping offset, fading toward
/// the horizon; perspective lines fan from the vanishing point to the bottom
/// edge. The design's separate `drawNeon` city scene (moon, skyline, flying
/// cars) is a Moderate scene layer and is NOT ported here — this is the
/// self-contained procedural grid the brief asked for, and it validates a
/// non-particle painter.
void paintGrid(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;

  final double horizon = h * 0.52;
  final double span = h - horizon;

  // --- Receding horizontal lines ---
  const double gap = 40;
  final double off = _frac(t) * gap; // one row of travel per loop
  final Paint line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  for (int i = 0; i < 14; i++) {
    final double y = horizon + i * gap + off;
    if (y > h) continue;
    final double fade = (1 - (y - horizon) / span).clamp(0.0, 1.0);
    line.color = p.accent.withValues(alpha: 0.16 * fade);
    canvas.drawLine(Offset(0, y), Offset(w, y), line);
  }

  // --- Perspective (vanishing-point) lines ---
  final double cx = w / 2;
  line.color = p.accent.withValues(alpha: 0.5 * 0.16 + 0.08);
  for (int i = -7; i <= 7; i++) {
    canvas.drawLine(
      Offset(cx, horizon),
      Offset(cx + i * 70, h),
      line..color = p.accent.withValues(alpha: 0.14),
    );
  }

  // --- Twinkling points above the horizon ---
  const int count = 40;
  final Paint dot = Paint()..style = PaintingStyle.fill;
  for (int i = 0; i < count; i++) {
    final double fx = _frac(i * 0.61803398875);
    final double fy = _frac(i * 0.75487766625 + 0.19);
    final double r = 0.6 + _frac(i * 0.317 + 0.07) * 2.0;
    final double phase = fx * math.pi * 2;
    final double tw = 0.4 + 0.5 * math.sin(t * math.pi * 2 + phase).abs();
    final double x = fx * w;
    final double y = fy * horizon; // stay above the horizon
    dot.color = p.accent2.withValues(alpha: tw);
    canvas.drawCircle(Offset(x, y), r, dot);
  }
}

double _frac(double v) => v - v.floorToDouble();
