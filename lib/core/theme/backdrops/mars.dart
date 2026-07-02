import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// Mars backdrop -- a hazy sun over a rust crater plain with breathing dust
/// devils, drifting dust, and a little rover trundling across (wheels rolling at
/// true ground speed, kicking dust).
///
/// Ported from the design `drawMars` (`Ratel App.dc.html` L2579). The design's
/// random rover gaps become one deterministic crossing per loop; the dust
/// devils breathe on offset phases. Reds come from the world palette; every
/// actor is index-seeded and driven by `t`.
void paintMars(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;
  final double ground = h * 0.66;

  // Sun (halo + core) + a distant blue "earth" speck.
  sunHalo(canvas, size, Offset(w * 0.76, h * 0.18), 70,
      p.gold.withValues(alpha: 0.5),
      coreR: 16, core: p.gold.withValues(alpha: 0.9));
  canvas.drawCircle(Offset(w * 0.18, h * 0.16), 2.6,
      Paint()..color = const Color(0xD996BEFF));

  // Distant ridge + ground plane.
  canvas.drawPath(
      Path()
        ..moveTo(0, ground)
        ..lineTo(w * 0.3, h * 0.56)
        ..lineTo(w * 0.6, h * 0.64)
        ..lineTo(w, h * 0.58)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = p.accent2.withValues(alpha: 0.5));
  canvas.drawRect(Rect.fromLTWH(0, ground, w, h - ground),
      Paint()..color = p.page.withValues(alpha: 0.7));

  // Craters.
  final Paint crater = Paint()..color = p.page.withValues(alpha: 0.6);
  for (int i = 0; i < 6; i++) {
    final double cx = frac(i * 0.61803398875) * w;
    final double cy = ground + 12 + frac(i * 0.75487766625 + 0.1) * (h - ground - 24);
    final double cr = 6 + frac(i * 0.317) * 10;
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: cr * 2, height: cr * 0.8),
        crater);
  }

  // Two breathing dust devils (tapered swirling columns).
  for (int d = 0; d < 2; d++) {
    final double bx = w * (0.3 + d * 0.4);
    final double seed = d * 2.3;
    final double lean = math.sin(tau + seed) * 7;
    final double env = 0.4 + 0.6 * math.sin(tau + d * math.pi).abs();
    final double colH = 64 + d * 30.0;
    for (int s = 0; s < 20; s++) {
      final double u = s / 20;
      final double yy = ground - u * colH;
      final double cx = bx + lean * u + math.sin(tau + seed + u * 5) * 3 * (1 - u * 0.3);
      final double rw = 2 + u * 9;
      final double a = env * 0.23 * (1 - u) * (0.6 + 0.4 * math.sin(tau + seed + s));
      if (a > 0) {
        canvas.drawOval(
            Rect.fromCenter(center: Offset(cx, yy), width: rw * 2, height: rw),
            Paint()..color = p.muted.withValues(alpha: a.clamp(0.0, 1.0)));
      }
    }
  }

  // Rover: one deterministic left-to-right crossing, wheels rolling true.
  final double rp = frac(t);
  final double rx = rp * (w + 96) - 48;
  final double wa = rx / 3.4; // rolling angle
  final double ry = ground - 7 + math.sin(tau * 8) * 0.6;
  // Kicked dust trailing behind.
  for (int dd = 0; dd < 3; dd++) {
    canvas.drawCircle(
        Offset(rx - (12 + dd * 5), ground + 4 + math.sin(tau * 8 + dd) * 1.5),
        2.5 + dd,
        Paint()..color = p.accent.withValues(alpha: 0.12));
  }
  canvas.save();
  canvas.translate(rx, ry);
  // shadow
  canvas.drawOval(Rect.fromCenter(center: const Offset(0, 9), width: 30, height: 4.8),
      Paint()..color = p.page.withValues(alpha: 0.28));
  // struts + body + solar deck + mast + lamp
  final Paint strut = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..color = p.muted.withValues(alpha: 0.7);
  for (final double wx in <double>[-9, 0, 9]) {
    canvas.drawLine(Offset(wx, 1), Offset(wx, 6), strut);
  }
  canvas.drawPath(
      Path()
        ..moveTo(-11, -2)
        ..lineTo(10, -2)
        ..lineTo(12, 3)
        ..lineTo(-12, 3)
        ..close(),
      Paint()..color = p.text.withValues(alpha: 0.92));
  canvas.drawRect(const Rect.fromLTWH(-9, -5, 16, 3),
      Paint()..color = p.muted.withValues(alpha: 0.8));
  canvas.drawLine(const Offset(7, -2), const Offset(7, -12),
      Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = p.muted);
  canvas.drawCircle(const Offset(10, -13.3), 1, Paint()..color = const Color(0xE696D2FF));
  // three spoked wheels rolling at wa
  final Paint spoke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8
    ..color = p.text.withValues(alpha: 0.7);
  for (final double wx in <double>[-9, 0, 9]) {
    canvas.save();
    canvas.translate(wx, 6);
    canvas.drawCircle(Offset.zero, 3.4, Paint()..color = p.ink.withValues(alpha: 0.95));
    for (int sp = 0; sp < 6; sp++) {
      final double a = wa + sp * 1.047;
      canvas.drawLine(Offset.zero, Offset(math.cos(a) * 3.1, math.sin(a) * 3.1), spoke);
    }
    canvas.restore();
  }
  canvas.restore();

  // Drifting dust motes.
  for (int i = 0; i < 24; i++) {
    final double fx = frac(i * 0.61803398875);
    final double fy = frac(i * 0.75487766625);
    final double r = 0.6 + frac(i * 0.317) * 1.3;
    final double x = wrap(fx * w + t * w * (0.4 + fx * 0.5), w + 8) - 4;
    final double y = fy * h + math.sin(tau + fx * 6.28) * 3;
    canvas.drawCircle(Offset(x, y), r, Paint()..color = p.muted.withValues(alpha: 0.22));
  }
}
