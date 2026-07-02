import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Coral-reef backdrop -- swaying light shafts through the water, drifting
/// clownfish, waving anemones, coral clusters and rising plankton.
///
/// Ported from the design `drawReef` (`Ratel App.dc.html` L2517). The
/// occasional turtle is a rare actor and is omitted; colors come from the
/// world's reef accents/teals.
void paintReef(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;

  // Swaying light-dapple shafts.
  for (int i = 0; i < 5; i++) {
    final double x = i * w / 4 + math.sin(tau + i) * 30;
    final Paint shaft = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[p.good.withValues(alpha: 0.10), p.good.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(x - 20, 0, 40, h));
    canvas.drawRect(Rect.fromLTWH(x - 20, 0, 40, h), shaft);
  }

  // Coral clusters on the sea floor.
  final List<Color> coralC = <Color>[p.accent, p.gold, p.good, p.accent2, p.accent];
  final List<double> coralX = <double>[0.12, 0.3, 0.6, 0.82, 0.46];
  for (int i = 0; i < coralX.length; i++) {
    final Paint c = Paint()..color = coralC[i].withValues(alpha: 0.5);
    canvas.save();
    canvas.translate(coralX[i] * w, h);
    canvas.drawRect(const Rect.fromLTWH(-3, -30, 6, 30), c);
    canvas.drawRect(const Rect.fromLTWH(-14, -22, 6, 22), c);
    canvas.drawRect(const Rect.fromLTWH(8, -26, 6, 26), c);
    canvas.drawCircle(const Offset(0, -30), 5, c);
    canvas.drawCircle(const Offset(-11, -22), 4, c);
    canvas.drawCircle(const Offset(11, -26), 4, c);
    canvas.restore();
  }

  // Waving anemones.
  final Paint anem = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round
    ..color = p.accent.withValues(alpha: 0.5);
  for (final double ax in <double>[0.22, 0.7]) {
    final double x0 = ax * w;
    for (int i = 0; i < 7; i++) {
      final double bx = x0 - 12 + i * 4;
      canvas.drawPath(
          Path()
            ..moveTo(bx, h)
            ..quadraticBezierTo(bx + math.sin(tau + i) * 6, h - 32,
                bx + math.sin(tau + i) * 9, h - 42),
          anem);
    }
  }

  // Drifting clownfish.
  for (int i = 0; i < 8; i++) {
    final double fxk = frac(i * 0.61803398875);
    final double sz = 3 + frac(i * 0.317 + 0.1) * 1.5;
    final double x = wrap(fxk * w + t * (w + 20) * (0.5 + fxk * 0.5), w + 20) - 10;
    final double y = h * 0.3 +
        frac(i * 0.53 + 0.2) * h * 0.48 +
        math.sin(tau * 2 + fxk * 6.28) * 2.2;
    canvas.save();
    canvas.translate(x, y);
    final Paint body = Paint()..color = p.accent;
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: sz * 3.4, height: sz * 2), body);
    canvas.drawRect(
        Rect.fromCenter(center: Offset(-sz * 0.2, 0), width: sz * 0.5, height: sz * 2),
        Paint()..color = const Color(0xD9FFFFFF));
    canvas.drawPath(
        Path()
          ..moveTo(-sz * 1.6, 0)
          ..lineTo(-sz * 2.5, -sz)
          ..lineTo(-sz * 2.5, sz)
          ..close(),
        body);
    canvas.restore();
  }

  // Rising plankton.
  final Paint plank = Paint()..color = p.good.withValues(alpha: 0.4);
  for (int i = 0; i < 24; i++) {
    final double fxk = frac(i * 0.61803398875 + 0.07);
    final double fy = frac(i * 0.75487766625 + 0.3);
    final double r = 0.5 + frac(i * 0.317 + 0.1) * 1.2;
    final double y = h - frac(fy + t * 0.5) * (h + 6);
    final double x = fxk * w + math.sin(tau + fxk * 6.28) * 4;
    canvas.drawCircle(Offset(x, y), r, plank);
  }
}
