import 'dart:math' as math;
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import '../motion/ratel_motion_tier.dart';
import 'galaxy_model.dart';
import 'space_palette.dart';

/// Tier-gated ambient FX for the galaxy (spec §4/§9/§10). A PURE, seeded model
/// ([GalaxyFx]) advances/spawns deterministically so it can be unit-tested
/// (the no-pixel-tests-on-moving-layers policy), a [GalaxyFxPainter] renders it,
/// and [GalaxyFxLayer] drives the loop with a [Ticker].
///
/// Gating (R-WT7 / R-N7): nothing runs at [MotionTier.none] (canvas cleared);
/// ambient shooting-stars/_comet/_asteroids + parallax features run at any moving
/// tier; supernova flashes and the pod auto-defense volley are HIGH-only. FX
/// colors are palette-driven from the scrolled-to section (blue-fire/violet).
const double _kW = 344;

/// FX run only while genuinely moving. OS reduce-motion (minimal) + user-off
/// (none) are a HARD floor -> cleared canvas (prototype 'forced off').
bool _fxMoving(MotionTier t) =>
    t == MotionTier.full || t == MotionTier.reduced;

class _Shoot {
  _Shoot(this.x, this.y, this.vx, this.vy, this.life);
  double x, y, vx, vy, life;
}

class _Comet {
  _Comet(this.x, this.y, this.vx, this.vy);
  double x, y, vx, vy;
}

class _Asteroid {
  _Asteroid(this.x, this.y, this.vx, this.vy, this.a, this.va, this.s);
  double x, y, vx, vy, a, va, s;
}

class _Missile {
  _Missile(this.x, this.y, this.vx, this.vy, this.tgt);
  double x, y, vx, vy;
  final _Asteroid tgt;
  final List<Offset> trail = <Offset>[];
}

class _Nova {
  _Nova(this.x, this.y);
  double x, y, t = 0;
}

class _Dust {
  _Dust(this.x, this.y, this.vx, this.vy, this.life);
  double x, y, vx, vy, life;
}

class GalaxyFx {
  GalaxyFx({int seed = 1}) : _r = math.Random(seed) {
    for (var i = 0; i < 3; i++) {
      _asteroids.add(_Asteroid(
        _r.nextDouble() * _kW,
        _r.nextDouble() * 716,
        -0.2 + _r.nextDouble() * 0.4,
        0.12 + _r.nextDouble() * 0.16,
        _r.nextDouble() * 6.28,
        -0.01 + _r.nextDouble() * 0.02,
        5 + _r.nextDouble() * 6,
      ));
    }
  }

  final math.Random _r;
  final List<_Shoot> _shoots = <_Shoot>[];
  _Comet? _comet;
  final List<_Asteroid> _asteroids = <_Asteroid>[];
  final List<_Missile> _missiles = <_Missile>[];
  final List<_Dust> _dust = <_Dust>[];
  final List<_Nova> _novas = <_Nova>[];
  double _tShoot = 1500, _tComet = 9000, _tNova = 6000, _volley = 4200;

  // test/inspection surface (counts only — the no-pixel-test policy)
  int get shootCount => _shoots.length;
  int get missileCount => _missiles.length;
  int get dustCount => _dust.length;
  int get novaCount => _novas.length;

  void clearTransient() {
    _shoots.clear();
    _comet = null;
    _missiles.clear();
    _dust.clear();
    _novas.clear();
  }

  /// Advance one frame. [pod] is the pod centre in screen space (or null when
  /// off-screen). Deterministic given the seed + the same call sequence.
  void update({
    required double dtMs,
    required Size size,
    Offset? pod,
    required MotionTier tier,
  }) {
    if (!_fxMoving(tier)) {
      clearTransient();
      return;
    }
    final f = (dtMs / 16).clamp(0.1, 3.0);
    final high = tier == MotionTier.full;
    final w = size.width, h = size.height;

    _tShoot -= dtMs;
    if (_tShoot <= 0) {
      final dir = _r.nextBool() ? 1.0 : -1.0;
      _shoots.add(_Shoot(_r.nextDouble() * w, -10, dir * (4 + _r.nextDouble() * 3),
          4 + _r.nextDouble() * 3, 1));
      _tShoot = 900 + _r.nextDouble() * 2400;
    }
    for (final s in _shoots) {
      s.x += s.vx * f;
      s.y += s.vy * f;
      s.life -= 0.012 * f;
    }
    _shoots.removeWhere((s) => s.life <= 0 || s.y > h + 20);

    _tComet -= dtMs;
    if (_comet == null && _tComet <= 0) {
      _comet = _Comet(-40, 30 + _r.nextDouble() * 120, 1.5, 0.5);
      _tComet = 10000 + _r.nextDouble() * 6000;
    }
    final c = _comet;
    if (c != null) {
      c.x += c.vx * f;
      c.y += c.vy * f;
      if (c.x > w + 60) _comet = null;
    }

    for (final a in _asteroids) {
      a.x += a.vx * f;
      a.y += a.vy * f;
      a.a += a.va * f;
      if (a.y > h + 10) {
        a.x = _r.nextDouble() * w;
        a.y = -10;
      }
    }

    if (high) {
      _tNova -= dtMs;
      if (_tNova <= 0) {
        _novas.add(_Nova(
            30 + _r.nextDouble() * (w - 60), 40 + _r.nextDouble() * (h - 120)));
        _tNova = 8000 + _r.nextDouble() * 7000;
      }
    } else {
      _novas.clear();
    }
    for (final n in _novas) {
      n.t += dtMs;
    }
    _novas.removeWhere((n) => n.t > 900);

    // pod auto-defense — HIGH only, one volley at a time, pod on-screen
    if (high && pod != null && pod.dy > 130 && pod.dy < h - 28) {
      _volley -= dtMs;
      if (_missiles.isEmpty && _volley <= 0) {
        _Asteroid? tgt;
        var best = 150.0;
        for (final a in _asteroids) {
          final d = (Offset(a.x, a.y) - pod).distance;
          if (d < best) {
            best = d;
            tgt = a;
          }
        }
        if (tgt != null) {
          _missiles.add(_Missile(pod.dx - 13, pod.dy + 2, -1.4, -0.7, tgt));
          _missiles.add(_Missile(pod.dx + 13, pod.dy + 2, 1.4, -0.7, tgt));
          _volley = 3600 + _r.nextDouble() * 3800;
        }
      }
    } else if (!high) {
      _missiles.clear();
    }
    const spd = 1.8;
    for (final m in _missiles) {
      final dx = m.tgt.x - m.x, dy = m.tgt.y - m.y;
      final dl = math.max(0.001, math.sqrt(dx * dx + dy * dy));
      m.vx += ((dx / dl * spd) - m.vx) * 0.09;
      m.vy += ((dy / dl * spd) - m.vy) * 0.09;
      m.x += m.vx * f;
      m.y += m.vy * f;
      m.trail.add(Offset(m.x, m.y));
      if (m.trail.length > 13) m.trail.removeAt(0);
    }
    _Missile? hit;
    for (final m in _missiles) {
      if ((Offset(m.tgt.x, m.tgt.y) - Offset(m.x, m.y)).distance < 9) {
        hit = m;
        break;
      }
    }
    if (hit != null) {
      final tgt = hit.tgt;
      for (var q = 0; q < 18; q++) {
        final qa = q / 18 * 6.28;
        final sp = 0.5 + _r.nextDouble() * 2;
        _dust.add(_Dust(
            tgt.x, tgt.y, math.cos(qa) * sp, math.sin(qa) * sp, 1));
      }
      tgt.x = _r.nextDouble() * w;
      tgt.y = -12;
      _missiles.clear();
    }
    for (final d in _dust) {
      d.x += d.vx * f;
      d.y += d.vy * f;
      d.vy += 0.02 * f;
      d.life -= 0.03 * f;
    }
    _dust.removeWhere((d) => d.life <= 0);
  }
}

Color _hsl(double h, double s, double l) =>
    HSLColor.fromAHSL(1, h % 360, s.clamp(0, 1), l.clamp(0, 1)).toColor();

/// Renders the [GalaxyFx] model + persistent parallax features (pulsar / black
/// hole / galaxy), palette-driven from the scrolled-to [section].
class GalaxyFxPainter extends CustomPainter {
  GalaxyFxPainter({
    required this.fx,
    required this.scrollY,
    required this.nowMs,
    required this.section,
    required this.tier,
  });

  final GalaxyFx fx;
  final double scrollY;
  final double nowMs;
  final int section;
  final MotionTier tier;

  @override
  void paint(Canvas canvas, Size size) {
    if (!_fxMoving(tier)) return;
    final w = size.width;
    final accent = _hsl(goldenHue(section), 0.85, 0.66);
    final high = tier == MotionTier.full;

    // aurora ribbon (HIGH only) — palette accent
    if (high) {
      final path = Path()..moveTo(0, 30);
      for (double x = 0; x <= w; x += 8) {
        final y = 70 +
            math.sin(x * 0.03 + nowMs * 0.0014) * 14 +
            math.sin(x * 0.07 - nowMs * 0.0014) * 6;
        path.lineTo(x, y);
      }
      path
        ..lineTo(w, 30)
        ..close();
      canvas.drawPath(path, Paint()..color = accent.withValues(alpha: 0.12));
    }

    _features(canvas, size, accent);

    // shooting stars
    for (final s in fx._shoots) {
      final p = Paint()
        ..strokeWidth = 2
        ..shader = LinearGradient(colors: <Color>[
          SpacePalette.star.withValues(alpha: 0),
          SpacePalette.star.withValues(alpha: s.life.clamp(0, 1)),
        ]).createShader(Rect.fromPoints(
            Offset(s.x - s.vx * 4, s.y - s.vy * 4), Offset(s.x, s.y)));
      canvas.drawLine(
          Offset(s.x - s.vx * 4, s.y - s.vy * 4), Offset(s.x, s.y), p);
      canvas.drawCircle(Offset(s.x, s.y), 1.7,
          Paint()..color = SpacePalette.star.withValues(alpha: s.life.clamp(0, 1)));
    }

    // _comet
    final c = fx._comet;
    if (c != null) {
      final tail = Paint()
        ..strokeWidth = 3
        ..shader = LinearGradient(colors: <Color>[
          accent.withValues(alpha: 0),
          accent.withValues(alpha: 0.9),
        ]).createShader(
            Rect.fromPoints(Offset(c.x - 90, c.y - 30), Offset(c.x, c.y)));
      canvas.drawLine(Offset(c.x - 90, c.y - 30), Offset(c.x, c.y), tail);
      canvas.drawCircle(Offset(c.x, c.y), 3, Paint()..color = SpacePalette.star);
    }

    // ambient _asteroids (auto-defense targets)
    final aFill = Paint()..color = SpacePalette.navInactive;
    for (final a in fx._asteroids) {
      _poly(canvas, Offset(a.x, a.y), a.s, 7, a.a, aFill);
    }

    // _novas (HIGH)
    for (final n in fx._novas) {
      final k = (n.t / 900).clamp(0.0, 1.0);
      final rad = 4 + k * 40;
      final al = (1 - k) * 0.9;
      canvas.drawCircle(
        Offset(n.x, n.y),
        rad,
        Paint()
          ..shader = RadialGradient(colors: <Color>[
            SpacePalette.hudText.withValues(alpha: al),
            accent.withValues(alpha: al * 0.6),
            accent.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: Offset(n.x, n.y), radius: rad)),
      );
    }

    // pod _missiles + sparkle _dust
    for (final m in fx._missiles) {
      for (var i = 1; i < m.trail.length; i++) {
        final al = i / m.trail.length * 0.85;
        canvas.drawLine(
            m.trail[i - 1],
            m.trail[i],
            Paint()
              ..strokeWidth = 2 * al + 0.5
              ..color = _hsl(160, 1, 0.8).withValues(alpha: al));
      }
      canvas.drawCircle(Offset(m.x, m.y), 2.4,
          Paint()..color = _hsl(160, 1, 0.95));
    }
    for (final d in fx._dust) {
      canvas.drawCircle(Offset(d.x, d.y), 1.7 * d.life + 0.4,
          Paint()..color = SpacePalette.tealText.withValues(alpha: d.life.clamp(0, 1)));
    }
  }

  void _features(Canvas canvas, Size size, Color accent) {
    final dx = (size.width - _kW) / 2;
    double sy(double wy, double par) => wy - scrollY * par;
    // pulsar (wy520 par.92 x255)
    _pulsar(canvas, Offset(255 + dx, sy(520, 0.92)));
    // black hole (wy1480 par.86 x115)
    _blackHole(canvas, Offset(115 + dx, sy(1480, 0.86)));
    // galaxy (wy2560 par.8 x225)
    _galaxy(canvas, Offset(225 + dx, sy(2560, 0.8)), accent);
  }

  void _pulsar(Canvas canvas, Offset c) {
    if (c.dy < -60 || c.dy > 800) return;
    final pulse = 0.6 + 0.4 * math.sin(nowMs * 0.005);
    final rot = nowMs * 0.001;
    final beam = Paint()
      ..strokeWidth = 2
      ..color = const Color(0xFFBFE0FF).withValues(alpha: 0.10);
    for (var k = 0; k < 2; k++) {
      final a = rot + k * math.pi;
      canvas.drawLine(c, c + Offset(math.cos(a) * 60, math.sin(a) * 60), beam);
    }
    canvas.drawCircle(c, 3.5 * pulse,
        Paint()..color = const Color(0xFFEAF6FF).withValues(alpha: 0.9));
  }

  void _blackHole(Canvas canvas, Offset c) {
    if (c.dy < -60 || c.dy > 800) return;
    final rot = nowMs * 0.0004;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rot);
    for (var i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset.zero, width: (34 - i * 3) * 2, height: (12 - i * 1.5) * 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = (i == 0 ? const Color(0xFFFFD9A0) : const Color(0xFF9FD2FF))
              .withValues(alpha: 0.18 - i * 0.04),
      );
    }
    canvas.restore();
    canvas.drawCircle(c, 13, Paint()..color = SpacePalette.phoneBg);
    canvas.drawCircle(
        c,
        13,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFFFFE9C2).withValues(alpha: 0.75));
  }

  void _galaxy(Canvas canvas, Offset c, Color accent) {
    if (c.dy < -60 || c.dy > 800) return;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(1, 0.42);
    canvas.rotate(0.6 + nowMs * 0.00003);
    canvas.drawCircle(
        Offset.zero,
        14,
        Paint()
          ..shader = RadialGradient(colors: <Color>[
            SpacePalette.hudText,
            accent.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: Offset.zero, radius: 14)));
    final arm = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = accent.withValues(alpha: 0.16);
    for (var s = 0; s < 2; s++) {
      final path = Path();
      for (double t = 0; t < 1; t += 0.1) {
        final ang = t * 6.28 + s * math.pi;
        final rr = 5 + t * 7 * 2;
        final p = Offset(math.cos(ang) * rr, math.sin(ang) * rr);
        t == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, arm);
    }
    canvas.restore();
  }

  void _poly(Canvas canvas, Offset c, double r, int n, double rot, Paint p) {
    final path = Path();
    for (var i = 0; i < n; i++) {
      final a = rot + i / n * 6.28;
      final pt = c + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(GalaxyFxPainter old) => true; // ticker-driven
}

/// Ticker-driven FX overlay. Runs the loop only while moving; at
/// [MotionTier.none] it stops + clears (canvas blank). HIGH-only effects are
/// gated inside the model. [activePlanet] is the pod's content-space anchor.
class GalaxyFxLayer extends StatefulWidget {
  const GalaxyFxLayer({
    super.key,
    required this.controller,
    required this.size,
    required this.activePlanet,
    required this.bands,
    required this.tier,
    this.fx,
  });

  final ScrollController controller;
  final Size size;
  final Offset? activePlanet; // content-space (x,y) of the active planet
  final List<GalaxyBand> bands;
  final MotionTier tier;
  final GalaxyFx? fx; // injectable for tests

  @override
  State<GalaxyFxLayer> createState() => _GalaxyFxLayerState();
}

class _GalaxyFxLayerState extends State<GalaxyFxLayer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final GalaxyFx _fx = widget.fx ?? GalaxyFx();
  Duration _last = Duration.zero;
  double _nowMs = 0;
  double _scrollY = 0;
  int _section = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    _sync();
  }

  void _sync() {
    if (!_fxMoving(widget.tier)) {
      if (_ticker.isActive) _ticker.stop();
      _fx.clearTransient();
    } else if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  int _sectionFor(double scrollY) {
    final centre = scrollY + widget.size.height / 2;
    var sec = 0;
    for (final b in widget.bands) {
      if (centre >= b.y) sec = b.section;
    }
    return sec;
  }

  void _tick(Duration elapsed) {
    final dt =
        _last == Duration.zero ? 16.0 : (elapsed - _last).inMicroseconds / 1000.0;
    _last = elapsed;
    _nowMs += dt;
    _scrollY = widget.controller.hasClients ? widget.controller.offset : 0;
    _section = _sectionFor(_scrollY);
    Offset? pod;
    final a = widget.activePlanet;
    if (a != null) pod = Offset(a.dx + 20, a.dy + 14 - _scrollY);
    _fx.update(dtMs: dt, size: widget.size, pod: pod, tier: widget.tier);
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant GalaxyFxLayer old) {
    super.didUpdateWidget(old);
    if (old.tier != widget.tier) _sync();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_fxMoving(widget.tier)) return const SizedBox.expand();
    return IgnorePointer(
      child: CustomPaint(
        size: widget.size,
        painter: GalaxyFxPainter(
          fx: _fx,
          scrollY: _scrollY,
          nowMs: _nowMs,
          section: _section,
          tier: widget.tier,
        ),
      ),
    );
  }
}
