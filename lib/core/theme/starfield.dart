import 'dart:math';

import 'package:flutter/material.dart';

import 'tokens.dart';

/// A deterministic, STATIC starfield backdrop for the Space world-theme
/// (R-WT1 / R-WT2, S66 · G1). Seeded so the star layout is stable across
/// rebuilds (no flicker); painted app-wide behind the translucent scaffolds in
/// `RatelApp`. Motion / twinkle + tier-gated FX are a later increment (R-WT7) —
/// this layer is static, so it is inherently reduce-motion safe.
class StarfieldPainter extends CustomPainter {
  const StarfieldPainter({this.seed = 7, this.count = 150});

  /// Seed for the deterministic star layout.
  final int seed;

  /// Number of small stars.
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final Rect rect = Offset.zero & size;
    // A faint nebula wash gives the field some depth.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0x223A2E6B), Color(0x00000000), Color(0x2210204A)],
        ).createShader(rect),
    );
    final Random rng = Random(seed);
    final Paint star = Paint();
    for (int i = 0; i < count; i++) {
      final double x = rng.nextDouble() * size.width;
      final double y = rng.nextDouble() * size.height;
      final double r = 0.4 + rng.nextDouble() * 1.3;
      final double op = 0.25 + rng.nextDouble() * 0.6;
      canvas.drawCircle(Offset(x, y), r,
          star..color = RatelColors.spaceStar.withValues(alpha: op));
    }
    // A few brighter glow stars.
    final Random g = Random(seed * 31 + 1);
    for (int i = 0; i < 6; i++) {
      final double x = g.nextDouble() * size.width;
      final double y = g.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 2.4,
          Paint()..color = RatelColors.spaceStar.withValues(alpha: 0.9));
      canvas.drawCircle(Offset(x, y), 6,
          Paint()..color = RatelColors.spaceStar.withValues(alpha: 0.12));
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.count != count;
}
