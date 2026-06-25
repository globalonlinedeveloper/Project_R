import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'galaxy_model.dart';
import 'space_palette.dart';

/// Per-planet rendered state (derived from real progress by the host).
enum PlanetState { done, active, locked }

Color _hsl(double h, double s, double l) =>
    HSLColor.fromAHSL(1, h % 360, s.clamp(0, 1), l.clamp(0, 1)).toColor();

/// The dynamic dark-space backdrop (spec §1/§4): the section-palette vertical
/// gradient (chosen by the scrolled-to section), two parallax nebula blobs and
/// three parallax star layers. Scroll-reactive but NOT self-animating, so it is
/// safe under reduce-motion (no looping); the animated FX layer is separate.
class GalaxyBackdropPainter extends CustomPainter {
  GalaxyBackdropPainter({
    required this.scrollY,
    required this.bands,
    required this.total,
    this.starSeed = 7,
  });

  final double scrollY;
  final List<GalaxyBand> bands;
  final double total;
  final int starSeed;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // current section = the band whose top is above the viewport centre
    final centreY = scrollY + size.height / 2;
    var sec = 0;
    for (final b in bands) {
      if (centreY >= b.y) sec = b.section;
    }
    final h = goldenHue(sec);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            _hsl(h, 0.55, 0.19),
            _hsl(h + 12, 0.58, 0.08),
            _hsl(h + 24, 0.52, 0.03),
          ],
          stops: const <double>[0, 0.5, 1],
        ).createShader(rect),
    );

    // nebula (parallax 0.13)
    double ny(double b) => ((b - scrollY * 0.13) % 960 + 960) % 960 - 140;
    _nebula(canvas, Offset(size.width * 0.18, ny(120)), 150,
        _hsl(h, 0.72, 0.52));
    _nebula(canvas, Offset(size.width * 0.86, ny(520)), 150,
        _hsl(h + 150, 0.60, 0.48));

    // 3 parallax star layers (counts 26/18/12), wrapped over total
    final rng = math.Random(starSeed);
    final star = Paint();
    const counts = <int>[26, 18, 12];
    for (var L = 0; L < 3; L++) {
      final par = 0.12 + L * 0.10;
      for (var i = 0; i < counts[L]; i++) {
        final bx = rng.nextDouble() * size.width;
        final by = rng.nextDouble() * total;
        final r = (L + 1) * 0.5 + rng.nextDouble() * 0.6;
        final tw = 0.35 + rng.nextDouble() * 0.55;
        final yy = ((by - scrollY * par) % total + total) % total;
        if (yy < -4 || yy > size.height + 4) continue;
        star.color = SpacePalette.star.withValues(alpha: tw);
        canvas.drawCircle(Offset(bx, yy), r, star);
      }
    }
  }

  void _nebula(Canvas canvas, Offset c, double radius, Color color) {
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..shader = RadialGradient(colors: <Color>[
          color.withValues(alpha: 0.30),
          color.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: c, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(GalaxyBackdropPainter old) =>
      old.scrollY != scrollY || old.total != total;
}

/// The dashed path between consecutive planets of the SAME unit (spec §3), plus
/// the mint ion trail into the active planet. Painted in the scroll content
/// space (so y is absolute). [dx] centres the 344-wide design in the viewport.
class GalaxyTrailPainter extends CustomPainter {
  GalaxyTrailPainter({
    required this.planets,
    required this.dx,
    required this.activeIdx,
    required this.showIon,
  });

  final List<GalaxyPlanet> planets;
  final double dx;
  final int activeIdx;
  final bool showIon;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < planets.length - 1; i++) {
      final a = planets[i], b = planets[i + 1];
      if (a.ui != b.ui) continue;
      final done = i < activeIdx;
      _dashed(
        canvas,
        Offset(a.x + dx, a.y),
        Offset(b.x + dx, b.y),
        done ? SpacePalette.pathDone : SpacePalette.pathIdle,
      );
    }
    // ion trail: from the same-unit predecessor into the active planet
    if (showIon && activeIdx > 0 && activeIdx < planets.length) {
      final a = planets[activeIdx - 1], b = planets[activeIdx];
      if (a.ui == b.ui) {
        final p1 = Offset(a.x + dx, a.y), p2 = Offset(b.x + dx, b.y);
        canvas.drawLine(
          p1,
          p2,
          Paint()
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round
            ..shader = LinearGradient(colors: <Color>[
              SpacePalette.teal.withValues(alpha: 0),
              SpacePalette.teal.withValues(alpha: 0.8),
            ]).createShader(Rect.fromPoints(p1, p2))
            ..color = SpacePalette.teal.withValues(alpha: 0.7),
        );
      }
    }
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final total = (b - a).distance;
    final dir = (b - a) / total;
    const dash = 2.0, gap = 9.0;
    var d = 0.0;
    while (d < total) {
      final s = a + dir * d;
      final e = a + dir * math.min(d + dash, total);
      canvas.drawLine(s, e, paint);
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(GalaxyTrailPainter old) =>
      old.activeIdx != activeIdx || old.dx != dx || old.showIon != showIon;
}

/// One planet's surface (46×46 within a 56-box to allow ring/glow overflow):
/// archetype/state gradient + spherical shading + optional Saturn ring + moon +
/// the active/done teal glow. Lock/check/crown glyphs are widget overlays.
class PlanetSurfacePainter extends CustomPainter {
  PlanetSurfacePainter({required this.planet, required this.state});

  final GalaxyPlanet planet;
  final PlanetState state;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    const r = 23.0;
    final hue = planet.hue.toDouble();

    // ring (behind the body), if any
    if (planet.ring && !planet.isCheckpoint) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(-20 * math.pi / 180);
      final ringRect = Rect.fromCenter(center: Offset.zero, width: r * 3.4, height: r * 0.92);
      canvas.drawArc(ringRect, math.pi, math.pi, false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..color = _hsl(hue, 0.75, 0.72));
      canvas.restore();
    }

    // glow for active / done
    if (state != PlanetState.locked) {
      final glow = state == PlanetState.active ? 0.85 : (state == PlanetState.done ? 0.45 : 0.0);
      if (glow > 0) {
        canvas.drawCircle(
            c,
            r + 3,
            Paint()
              ..color = SpacePalette.teal.withValues(alpha: glow)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      }
    }

    // body gradient
    final bodyRect = Rect.fromCircle(center: c, radius: r);
    final List<Color> cols;
    if (state == PlanetState.active) {
      cols = <Color>[const Color(0xFF9FF5DD), const Color(0xFF16A085), const Color(0xFF0A5E4E)];
    } else if (planet.isCheckpoint) {
      cols = <Color>[const Color(0xFFFFE9A8), const Color(0xFFEF9F27), const Color(0xFF8A5708)];
    } else {
      switch (planet.arch) {
        case PlanetArch.banded:
          cols = <Color>[_hsl(hue, 0.58, 0.74), _hsl(hue, 0.44, 0.52), _hsl(hue + 18, 0.60, 0.66)];
        case PlanetArch.icy:
          cols = <Color>[_hsl(hue, 0.45, 0.93), _hsl(hue, 0.48, 0.74), _hsl(hue, 0.45, 0.42)];
        case PlanetArch.smooth:
          cols = <Color>[_hsl(hue, 0.72, 0.80), _hsl(hue, 0.64, 0.48), _hsl(hue, 0.60, 0.20)];
      }
    }
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.32, -0.44),
          colors: cols,
          stops: const <double>[0, 0.55, 1],
        ).createShader(bodyRect),
    );

    // spherical shading
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.5, 0.5),
          colors: <Color>[Colors.transparent, Colors.black.withValues(alpha: 0.5)],
          stops: const <double>[0.55, 1],
        ).createShader(bodyRect),
    );

    if (state == PlanetState.locked) {
      canvas.drawCircle(c, r, Paint()..color = SpacePalette.phoneBg.withValues(alpha: 0.5));
    }

    // moon
    if (planet.moon && !planet.isCheckpoint) {
      final m = c + const Offset(0, -1) * (r + 6);
      canvas.drawCircle(m, 3.5, Paint()..color = const Color(0xFFCFD6E6));
    }
  }

  @override
  bool shouldRepaint(PlanetSurfacePainter old) =>
      old.state != state || old.planet != planet;
}
