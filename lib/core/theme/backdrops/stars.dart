import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_fx.dart';

/// The `stars` galaxy backdrop -- the last and richest world painter (R-WT7).
///
/// Ported from the design `drawSky()` `stars` mega-block (`Ratel App.dc.html`
/// L2998-3095) + its `fX` celestial helpers (L3109-3120): a Milky-Way band, an
/// aurora, four drifting nebulae, a spread of the seven celestial features
/// (sun / spiral galaxy / pulsar / black hole / star cluster / wormhole), three
/// parallax layers of twinkling stars (the brightest with a glow + diffraction
/// spikes), rising foreground dust, and a deterministic shooting star + comet.
///
/// The design's interactive furniture -- tap-to-spawn blooms, the pointer
/// trail, device-tilt parallax, shake-to-meteor, and the roving
/// rocket / satellite / station / UFO -- is intentionally OMITTED: a backdrop
/// painter is a pure function of `(size, palette, t)` with no input. All motion
/// derives from `t` via a `2*pi` phase and seams cleanly at t=0/1; every actor
/// is index-seeded (no RNG), so the reduce-motion floor paints a calm static
/// frame at t=0. Colors are the world palette's bright tokens (`p.text`,
/// `p.muted`, `p.accent`, `p.gold`) plus the intrinsic tints space objects
/// demand (a warm sun, an orange accretion disk, a violet wormhole).
void paintStars(Canvas canvas, Size size, WorldPalette p, double t) {
  final double w = size.width, h = size.height;
  if (w <= 0 || h <= 0) return;
  final double tau = t * math.pi * 2;

  // ---- Milky Way band (fMilky): a soft tilted luminous swath. ----
  canvas.save();
  canvas.translate(w * 0.5, h * 0.42);
  canvas.rotate(-0.62);
  canvas.drawRect(
    Rect.fromCenter(center: Offset.zero, width: w * 2.6, height: 144),
    Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, -72),
        const Offset(0, 72),
        <Color>[
          p.text.withValues(alpha: 0),
          p.text.withValues(alpha: 0.09),
          p.text.withValues(alpha: 0),
        ],
        <double>[0, 0.5, 1],
      ),
  );
  canvas.restore();

  // ---- Aurora (fAurora): two slow wavy ribbon bands near the top. ----
  for (int b = 0; b < 2; b++) {
    final Path path = Path()..moveTo(0, 0);
    for (double x = 0; x <= w; x += 8) {
      final double y = 22 +
          b * 14 +
          math.sin(x * 0.018 + tau + b) * 10 +
          math.sin(x * 0.05 + tau * 0.7) * 5;
      path.lineTo(x, y);
    }
    path
      ..lineTo(w, 0)
      ..close();
    final Color aur = b == 0 ? p.muted : p.accent;
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          const Offset(0, 56),
          <Color>[aur.withValues(alpha: 0.12), aur.withValues(alpha: 0)],
        ),
    );
  }

  // ---- Four drifting nebulae (radial washes, intrinsic hues). ----
  const List<List<double>> neb = <List<double>>[
    <double>[0.24, 0.16, 170, 265],
    <double>[0.82, 0.44, 200, 205],
    <double>[0.50, 0.72, 160, 325],
    <double>[0.30, 0.94, 180, 190],
  ];
  for (int i = 0; i < neb.length; i++) {
    final double nx = neb[i][0] * w + math.sin(tau + i) * 12;
    final double ny = neb[i][1] * h;
    final double r = neb[i][2], hue = neb[i][3];
    final Rect nr = Rect.fromCircle(center: Offset(nx, ny), radius: r);
    canvas.drawCircle(
      Offset(nx, ny),
      r,
      Paint()
        ..shader = RadialGradient(colors: <Color>[
          HSLColor.fromAHSL(0.17, hue, 0.75, 0.62).toColor(),
          HSLColor.fromAHSL(0, hue, 0.75, 0.62).toColor(),
        ]).createShader(nr),
    );
  }

  // ---- Celestial features (a spread of the design's seven). ----
  _sun(canvas, Offset(0.80 * w, 0.16 * h), tau);
  _spiralGalaxy(canvas, Offset(0.52 * w, 0.60 * h), tau);
  _pulsar(canvas, Offset(0.28 * w, 0.30 * h), tau);
  _blackHole(canvas, Offset(0.18 * w, 0.76 * h), tau);
  _cluster(canvas, Offset(0.84 * w, 0.54 * h), tau);
  _wormhole(canvas, Offset(0.66 * w, 0.86 * h), tau);

  // ---- Three parallax layers of twinkling stars. ----
  final Paint star = Paint();
  for (int i = 0; i < 108; i++) {
    final double fx = frac(i * 0.61803398875);
    final double fy = frac(i * 0.75487766625);
    final double d = frac(i * 0.317);
    final int layer = d < 0.55 ? 0 : (d < 0.85 ? 1 : 2);
    final double sr = layer == 2
        ? (1.3 + frac(i * 0.19) * 1.3)
        : layer == 1
            ? (0.8 + frac(i * 0.19) * 0.7)
            : (0.4 + frac(i * 0.19) * 0.5);
    final double ph = frac(i * 0.911) * math.pi * 2;
    final int cyc = 1 + (i % 3);
    final double tw = 0.35 + 0.65 * math.sin(tau * cyc + ph).abs();
    final double x = fx * w, y = fy * h;
    final double baseA = layer == 2 ? 1.0 : (layer == 1 ? 0.8 : 0.5);
    star.color = (layer == 2 ? p.text : p.muted)
        .withValues(alpha: (tw * baseA).clamp(0.0, 1.0));
    canvas.drawCircle(Offset(x, y), sr, star);
    if (layer == 2) {
      final Rect gr = Rect.fromCircle(center: Offset(x, y), radius: sr * 2.4);
      canvas.drawCircle(
          Offset(x, y),
          sr * 2.4,
          Paint()
            ..shader = RadialGradient(colors: <Color>[
              p.text.withValues(alpha: 0.4 * tw),
              p.text.withValues(alpha: 0),
            ]).createShader(gr));
      final double sk = sr * 3.4 * tw;
      final Paint spike = Paint()
        ..strokeWidth = 0.8
        ..color = p.text.withValues(alpha: 0.5 * tw);
      canvas.drawLine(Offset(x - sk, y), Offset(x + sk, y), spike);
      canvas.drawLine(Offset(x, y - sk), Offset(x, y + sk), spike);
    }
  }

  // ---- Rising foreground dust motes. ----
  for (int i = 0; i < 14; i++) {
    final double dx = frac(i * 0.61803398875) * w;
    final double y0 = frac(i * 0.428) * h;
    final double y = wrap(y0 - t * h * (0.12 + frac(i * 0.19) * 0.10), h);
    final double r = 0.6 + frac(i * 0.7) * 1.4;
    canvas.drawCircle(Offset(dx + math.sin(tau + i) * 3, y), r,
        Paint()..color = p.muted.withValues(alpha: 0.16));
  }

  // ---- Deterministic shooting stars + a comet. The phase windows are
  //      interior to [0,1), so every streak is calm (absent) at t=0/1. ----
  _streak(canvas, t, 0.16, 0.30, Offset(0.12 * w, 0.10 * h),
      Offset(0.55 * w, 0.42 * h), p.text, 2.0, 7);
  _streak(canvas, t, 0.62, 0.74, Offset(0.90 * w, 0.14 * h),
      Offset(0.48 * w, 0.52 * h), p.text, 2.0, 7);
  _streak(canvas, t, 0.40, 0.80, Offset(-0.05 * w, 0.22 * h),
      Offset(1.05 * w, 0.50 * h), p.accent, 3.0, 16);
}

/// A glowing star with a soft corona, 12 flickering rays and a bright core.
void _sun(Canvas canvas, Offset c, double tau) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  final double pu = 0.92 + 0.08 * math.sin(tau);
  final Rect cor = Rect.fromCircle(center: Offset.zero, radius: 58 * pu);
  canvas.drawCircle(
      Offset.zero,
      58 * pu,
      Paint()
        ..shader = RadialGradient(colors: <Color>[
          const Color(0x80FFEEC4),
          const Color(0x38FFC676),
          const Color(0x00FFB258),
        ], stops: const <double>[0, 0.4, 1]).createShader(cor));
  final Paint ray = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = const Color(0x80FFDC96);
  for (int i = 0; i < 12; i++) {
    final double a = i / 12 * math.pi * 2 + tau * 0.5;
    final double r2 = 24 + math.sin(tau + i) * 4;
    canvas.drawLine(Offset(math.cos(a) * 18, math.sin(a) * 18),
        Offset(math.cos(a) * r2, math.sin(a) * r2), ray);
  }
  final Rect core = Rect.fromCircle(center: Offset.zero, radius: 15);
  canvas.drawCircle(
      Offset.zero,
      15,
      Paint()
        ..shader = RadialGradient(colors: <Color>[
          const Color(0xFFFFF6E0),
          const Color(0xFFFFD98A),
        ]).createShader(core));
  canvas.restore();
}

/// A small tilted two-arm spiral galaxy, slowly turning, with a warm core.
void _spiralGalaxy(Canvas canvas, Offset c, double tau) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(0.6 + tau);
  for (int arm = 0; arm < 2; arm++) {
    canvas.rotate(math.pi);
    final Path path = Path();
    for (int i = 0; i < 58; i++) {
      final double an = i * 0.18, rr = i * 1.05;
      final double px = math.cos(an) * rr, py = math.sin(an) * rr * 0.6;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0x43BEB4FF));
  }
  final Rect gr = Rect.fromCircle(center: Offset.zero, radius: 28);
  canvas.drawCircle(
      Offset.zero,
      28,
      Paint()
        ..shader = RadialGradient(colors: <Color>[
          const Color(0x8CFFF0D2),
          const Color(0x00FFF0D2),
        ]).createShader(gr));
  canvas.restore();
}

/// A neutron-star pulsar: a rotating twin beam and a bright pinpoint core.
void _pulsar(Canvas canvas, Offset c, double tau) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  final double pu = 0.6 + 0.4 * math.sin(tau * 2).abs();
  canvas.rotate(tau);
  canvas.drawRect(
      const Rect.fromLTWH(-9, -78, 18, 156),
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, -78),
          const Offset(0, 78),
          <Color>[
            const Color(0x0096D2FF),
            const Color(0xFF96D2FF).withValues(alpha: 0.2 * pu),
            const Color(0x0096D2FF),
          ],
          <double>[0, 0.5, 1],
        ));
  canvas.drawCircle(Offset.zero, 4, Paint()..color = const Color(0xFFEAF6FF));
  canvas.restore();
}

/// A black hole: a tilted orange accretion disk around a dark core.
void _blackHole(Canvas canvas, Offset c, double tau) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(tau);
  for (int i = 0; i < 3; i++) {
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset.zero,
            width: (26 - i * 3) * 2,
            height: (9 - i * 2) * 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = const Color(0xFFFFA05A)
              .withValues(alpha: (0.5 - i * 0.13).clamp(0.0, 1.0)));
  }
  canvas.drawCircle(Offset.zero, 9, Paint()..color = const Color(0xFF05060C));
  canvas.drawCircle(
      Offset.zero,
      10.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0x80FFC878));
  canvas.restore();
}

/// A globular star cluster: 14 twinkling members on a tight spiral.
void _cluster(Canvas canvas, Offset c, double tau) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  for (int i = 0; i < 14; i++) {
    final double a = i * 2.4, rr = 4 + i * 1.5;
    final double tw = 0.4 + 0.6 * math.sin(tau + i).abs();
    canvas.drawCircle(
        Offset(math.cos(a) * rr, math.sin(a) * rr),
        1.4,
        Paint()
          ..color = (i % 3 != 0
                  ? const Color(0xFFDFEAFF)
                  : const Color(0xFFFFF2CF))
              .withValues(alpha: tw.clamp(0.0, 1.0)));
  }
  canvas.restore();
}

/// A wormhole: five wobbling violet rings around a dark throat.
void _wormhole(Canvas canvas, Offset c, double tau) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(tau);
  for (int i = 0; i < 5; i++) {
    final Path path = Path();
    final double rr = 8 + i * 5;
    for (double a = 0; a <= 6.31; a += 0.3) {
      final double wob = math.sin(a * 3 + tau + i) * 2;
      final double px = math.cos(a) * (rr + wob),
          py = math.sin(a) * (rr * 0.7 + wob);
      if (a == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = HSLColor.fromAHSL((0.5 - i * 0.08).clamp(0.0, 1.0),
                  ((262 + i * 15) % 360).toDouble(), 0.9, 0.72)
              .toColor());
  }
  final Rect gr = Rect.fromCircle(center: Offset.zero, radius: 9);
  canvas.drawCircle(
      Offset.zero,
      9,
      Paint()
        ..shader = RadialGradient(colors: <Color>[
          const Color(0xF2120626),
          const Color(0x007850DC),
        ]).createShader(gr));
  canvas.restore();
}

/// A single streak (shooting star / comet) crossing during the phase window
/// `[t0, t1)`. A `sin` envelope fades it in and out (zero at both ends), so the
/// loop stays calm at t=0/1. Deterministic: position is a straight lerp of `t`.
void _streak(Canvas canvas, double t, double t0, double t1, Offset a, Offset b,
    Color color, double width, double tail) {
  if (t < t0 || t >= t1) return;
  final double u = (t - t0) / (t1 - t0);
  final double env = math.sin(u * math.pi);
  if (env <= 0.001) return;
  final Offset pos = Offset.lerp(a, b, u)!;
  final Offset delta = b - a;
  final double dist = delta.distance == 0 ? 1 : delta.distance;
  final Offset back = pos - (delta / dist) * (tail * 4);
  canvas.drawLine(
      pos,
      back,
      Paint()
        ..strokeWidth = width
        ..shader = ui.Gradient.linear(pos, back, <Color>[
          color.withValues(alpha: env),
          color.withValues(alpha: 0),
        ]));
  canvas.drawCircle(
      pos, width * 0.9, Paint()..color = color.withValues(alpha: env));
}
