import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ratel/core/core.dart';

/// Galaxy Home rendering for the Space world-theme (R-WT4, S66 · G2).
///
/// When the Space [WorldTheme] is active, the Home learning path re-skins into a
/// galaxy: a [GalaxyPathPainter] paints a CustomPainter backdrop (a faint nebula
/// glow + a deterministic sparkle of stars) plus a dashed orbital "planet path"
/// connecting the lesson nodes; each lesson node becomes a [GalaxyPlanet] (a
/// ringed planet body); and the current node carries a [PodTraveller] marker —
/// the badger's space pod parked at the learner's REAL position. Classic keeps
/// the original winding path untouched.
///
/// HONESTY (§6 / "don't fake depth"): this is a pure VISUAL re-skin of the SAME
/// real path. The node states (done / active / locked) and positions are
/// unchanged — derived from the learner's real `lessonsCompleted` — so nothing
/// about progress is fabricated. This G2 layer is fully STATIC, so it is
/// inherently reduce-motion safe; the optional tier-gated motion FX (twinkle /
/// pod drift / shield pulse) land in G3 (R-WT7), gated on the reduce-motion
/// hard floor.

/// The winding horizontal offsets (Alignment x in [-1, 1]) the path cycles
/// through. Shared with the Classic path so Space and Classic place nodes
/// identically — only the skin differs.
const List<double> kGalaxyPath = <double>[
  0.0, 0.5, 0.8, 0.5, 0.0, -0.5, -0.8, -0.5,
];

/// Planet body colours, cycled by global lesson index so the galaxy reads as a
/// varied system rather than one repeated world. Brand accents, reused.
const List<Color> _kPlanetColors = <Color>[
  RatelColors.teal,
  RatelColors.amber,
  RatelColors.coral,
  RatelColors.green,
  RatelColors.purple,
  RatelColors.gold,
];

/// Deterministic planet colour for the lesson at [globalIndex].
Color galaxyPlanetColor(int globalIndex) =>
    _kPlanetColors[globalIndex % _kPlanetColors.length];

/// Maps an [Alignment] x in [-1, 1] to a pixel x within [width], matching how
/// `Align(Alignment(ax, 0))` centres a child of [nodeSize] — so the painted
/// orbital trail passes through the planet centres.
double _cx(double a, double width, double nodeSize) =>
    width / 2 + a * (width - nodeSize) / 2;

/// The CustomPainter backdrop + dashed orbital "planet path" painted behind one
/// node track. The top/bottom trail segments meet adjacent rows at the shared
/// boundary midpoint x, so the dashed orbit reads as continuous down the scroll.
class GalaxyPathPainter extends CustomPainter {
  const GalaxyPathPainter({
    required this.ax,
    required this.prevAx,
    required this.nextAx,
    required this.hasPrev,
    required this.hasNext,
    required this.nodeSize,
    required this.done,
    this.seed = 1,
  });

  /// This node's alignment x.
  final double ax;

  /// Previous node's alignment x (for the incoming trail).
  final double prevAx;

  /// Next node's alignment x (for the outgoing trail).
  final double nextAx;

  /// Whether to draw the incoming (top) trail segment.
  final bool hasPrev;

  /// Whether to draw the outgoing (bottom) trail segment.
  final bool hasNext;

  /// Node diameter — kept in sync with `Align` centring.
  final double nodeSize;

  /// Lit (completed) trail vs upcoming (dim).
  final bool done;

  /// Deterministic local star sprinkle seed.
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(_cx(ax, w, nodeSize), h / 2);

    // (1) Local nebula glow behind the planet — the "backdrop".
    final Color glow = done ? RatelColors.teal : RatelColors.spaceStar;
    canvas.drawCircle(
      center,
      nodeSize * 0.95,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            glow.withValues(alpha: 0.16),
            glow.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: nodeSize * 0.95)),
    );

    // (2) Dashed orbital "planet path" — continuous across rows.
    final Paint dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = (done ? RatelColors.teal : RatelColors.spaceStar)
          .withValues(alpha: done ? 0.55 : 0.30);
    if (hasPrev) {
      final Offset top =
          Offset((_cx(prevAx, w, nodeSize) + center.dx) / 2, 0);
      _dashedLine(canvas, top, center.translate(0, -nodeSize / 2), dash);
    }
    if (hasNext) {
      final Offset bottom =
          Offset((center.dx + _cx(nextAx, w, nodeSize)) / 2, h);
      _dashedLine(canvas, center.translate(0, nodeSize / 2), bottom, dash);
    }

    // (3) A few deterministic sparkle stars around the node for depth.
    final math.Random rng = math.Random(seed * 911 + 7);
    final Paint sp = Paint()
      ..color = RatelColors.spaceStar.withValues(alpha: 0.5);
    for (int i = 0; i < 4; i++) {
      final double sx = rng.nextDouble() * w;
      final double sy = rng.nextDouble() * h;
      if ((Offset(sx, sy) - center).distance < nodeSize * 0.8) continue;
      canvas.drawCircle(Offset(sx, sy), 0.6 + rng.nextDouble() * 0.9, sp);
    }
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const double dashLen = 5.0;
    const double gapLen = 4.0;
    final double total = (b - a).distance;
    if (total <= 0) return;
    final Offset dir = (b - a) / total;
    double d = 0;
    while (d < total) {
      final double end = math.min(d + dashLen, total);
      canvas.drawLine(a + dir * d, a + dir * end, paint);
      d = end + gapLen;
    }
  }

  @override
  bool shouldRepaint(GalaxyPathPainter old) =>
      old.ax != ax ||
      old.prevAx != prevAx ||
      old.nextAx != nextAx ||
      old.hasPrev != hasPrev ||
      old.hasNext != hasNext ||
      old.nodeSize != nodeSize ||
      old.done != done ||
      old.seed != seed;
}

/// A ringed planet body standing in for a lesson node in the galaxy skin.
class GalaxyPlanet extends StatelessWidget {
  const GalaxyPlanet({
    super.key,
    required this.color,
    required this.size,
    required this.glyph,
    required this.lit,
  });

  /// Planet base colour.
  final Color color;

  /// Planet body diameter.
  final double size;

  /// State glyph (✓ done · ▶ active · 🔒 locked).
  final String glyph;

  /// Lit (done/active) → full colour + ring; locked → dim.
  final bool lit;

  @override
  Widget build(BuildContext context) {
    final Color base = lit ? color : RatelColors.spaceBg3;
    final Widget body = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 0.95,
          colors: <Color>[
            Color.lerp(base, RatelColors.onColor, lit ? 0.35 : 0.10)!,
            base,
            Color.lerp(base, RatelColors.spacePlanetShade, 0.35)!,
          ],
          stops: const <double>[0.0, 0.55, 1.0],
        ),
        border: Border.all(
          color: lit
              ? RatelColors.onColor.withValues(alpha: 0.25)
              : RatelColors.spaceBorder,
          width: 1.5,
        ),
        boxShadow: lit
            ? <BoxShadow>[
                BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 16,
                    spreadRadius: 1)
              ]
            : const <BoxShadow>[],
      ),
      alignment: Alignment.center,
      child: Text(
        glyph,
        style: TextStyle(
          fontSize: size * 0.36,
          fontFamily: RatelFont.display,
          fontWeight: RatelType.extraBold,
          color: lit ? RatelColors.onColor : RatelColors.spaceMuted,
        ),
      ),
    );
    return Opacity(
      opacity: lit ? 1.0 : 0.85,
      child: SizedBox(
        width: size * 1.7,
        height: size * 1.15,
        child: CustomPaint(
          painter: PlanetRingPainter(
            color: lit ? color : RatelColors.spaceMuted,
            radius: size,
          ),
          child: Center(child: body),
        ),
      ),
    );
  }
}

/// Draws a tilted Saturn-style orbital ring; the opaque planet body (the
/// CustomPaint child) overpaints the ring's front arc, so it reads as encircling.
class PlanetRingPainter extends CustomPainter {
  const PlanetRingPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-0.38);
    final Rect rect = Rect.fromCenter(
        center: Offset.zero, width: radius * 1.7, height: radius * 0.66);
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = color.withValues(alpha: 0.55),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(PlanetRingPainter old) =>
      old.color != color || old.radius != radius;
}

/// The "pod traveller" marker (R-WT4) — a small space pod with the badger
/// piloting, parked at the learner's current planet. Static in G2.
class PodTraveller extends StatelessWidget {
  const PodTraveller({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey<String>('home-galaxy-pod'),
      width: size,
      height: size,
      child: CustomPaint(
        painter: const PodPainter(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: size * 0.10),
            child: Text('🦡', style: TextStyle(fontSize: size * 0.40)),
          ),
        ),
      ),
    );
  }
}

/// Paints the pod body (capsule + window + fins + thruster glow).
class PodPainter extends CustomPainter {
  const PodPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset c = Offset(w / 2, h / 2);

    // Thruster glow at the base.
    final Offset thruster = Offset(c.dx, h * 0.92);
    canvas.drawCircle(
      thruster,
      w * 0.24,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            RatelColors.amber.withValues(alpha: 0.7),
            RatelColors.amber.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: thruster, radius: w * 0.24)),
    );

    // Pod body (rounded capsule).
    final RRect body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: w * 0.66, height: h * 0.80),
      Radius.circular(w * 0.33),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[RatelColors.spacePodLight, RatelColors.spacePodHull],
        ).createShader(body.outerRect),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = RatelColors.tealDark.withValues(alpha: 0.85),
    );

    // Fins.
    final Paint fin = Paint()..color = RatelColors.coral;
    final Path lFin = Path()
      ..moveTo(c.dx - w * 0.30, c.dy + h * 0.04)
      ..lineTo(c.dx - w * 0.46, c.dy + h * 0.24)
      ..lineTo(c.dx - w * 0.30, c.dy + h * 0.22)
      ..close();
    final Path rFin = Path()
      ..moveTo(c.dx + w * 0.30, c.dy + h * 0.04)
      ..lineTo(c.dx + w * 0.46, c.dy + h * 0.24)
      ..lineTo(c.dx + w * 0.30, c.dy + h * 0.22)
      ..close();
    canvas.drawPath(lFin, fin);
    canvas.drawPath(rFin, fin);

    // Window (the badger sits here, drawn as the child on top).
    final Offset win = Offset(c.dx, c.dy - h * 0.02);
    canvas.drawCircle(
        win, w * 0.23, Paint()..color = RatelColors.spaceBg2.withValues(alpha: 0.92));
    canvas.drawCircle(
      win,
      w * 0.23,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = RatelColors.teal,
    );
  }

  @override
  bool shouldRepaint(PodPainter old) => false;
}
