import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ratel/core/core.dart';

/// The bobbing honey-badger traveller + START bubble that sits by the active
/// node (`Ratel App.dc.html`:169-182, placement 3236).
///
/// The badger art is ported as `CustomPaint` from the design's inline SVG
/// (`viewBox 0 0 64 56`, rendered 58x50): a soft ground-shadow ellipse, two
/// dark ears, a dark head with a cream face, two white eyes with dark pupils,
/// and a black nose. Below it sits a small teal "START" pill.
///
/// The whole column bobs with the design's `rbob` (translateY 0 -> -7px -> 0,
/// period 2.4s). Pure: no providers, no navigation. Motion is gated by
/// [reduceMotion] — when true NO controller is created and the traveller rests
/// at y = 0 (fully static).
///
/// E2 (INC-10): when [vehicleGlyph] is supplied (the active world's vehicle
/// emoji from `kWorldVehicleGlyphs`) it is rendered AS the traveller in place of
/// the badger — so Ocean shows a submarine, Forest a leaf glider, etc. The
/// glyph node is keyed `home-vehicle-<worldId>` for targeting. When
/// [vehicleGlyph] is null the historic honey-badger `CustomPaint` is drawn
/// (galaxy keeps its own [PodTraveller] elsewhere). Either way the same
/// reduce-motion-gated bob + START pill wrap it.
class PathTraveller extends StatefulWidget {
  const PathTraveller({
    super.key,
    required this.size,
    this.reduceMotion = false,
    this.vehicleGlyph,
    this.worldId,
  });

  /// Rendered width of the traveller art in logical px (design: 58). Height is
  /// derived from the 64:56 design aspect ratio.
  final double size;

  /// Hard reduce-motion floor. When true, no ticker is created and the
  /// traveller is static.
  final bool reduceMotion;

  /// The active world's vehicle emoji (e.g. `🤿` for Ocean's Submarine). When
  /// non-null it replaces the badger as the traveller; when null the badger is
  /// painted. Sourced from `worldVehicleGlyph(world.id)`.
  final String? vehicleGlyph;

  /// The active world id, used only to key the rendered vehicle node
  /// (`home-vehicle-<worldId>`) so tests can assert the per-world traveller.
  final String? worldId;

  @override
  State<PathTraveller> createState() => _PathTravellerState();
}

class _PathTravellerState extends State<PathTraveller>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (!widget.reduceMotion) _startController();
  }

  void _startController() {
    // rbob: period 2.4s, translateY 0 -> -7 -> 0, ease-in-out, infinite.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant PathTraveller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduceMotion && _controller != null) {
      _controller!.dispose();
      _controller = null;
    } else if (!widget.reduceMotion && _controller == null) {
      _startController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.size;
    final h = w * (56.0 / 64.0); // design viewBox aspect

    // E2: the traveller is either the active world's VEHICLE glyph (when one is
    // supplied) or the historic honey-badger. The glyph node is keyed so tests
    // can assert the per-world vehicle; it occupies the same w x h footprint so
    // node placement is unchanged.
    Widget traveller;
    if (widget.vehicleGlyph != null) {
      traveller = SizedBox(
        key: ValueKey<String>('home-vehicle-${widget.worldId ?? 'x'}'),
        width: w,
        height: h,
        child: Center(
          child: Text(
            widget.vehicleGlyph!,
            textAlign: TextAlign.center,
            // Emoji are a self-coloured glyph; the fontSize alone drives size.
            style: TextStyle(fontSize: h * 0.86, height: 1.0),
          ),
        ),
      );
    } else {
      // Badger artwork palette, sourced from tokens (no raw hex in this file).
      // The mascot is an illustration; where the design's intrinsic art colour
      // has no semantic token we derive it from the nearest neutral token:
      //  - dark fur/ears/pupils/nose  <- RatelColors.ink (#1B1D1F ~ design #1C1C1C)
      //  - cream face                 <- context.palette.cream3 (warm off-white)
      //  - eye white / shadow tint    <- RatelColors.onColor (white) w/ opacity
      final palette = context.palette;
      final colors = _BadgerColors(
        shadow: RatelColors.ink.withValues(alpha: 0.18),
        ear: RatelColors.ink,
        headDark: RatelColors.ink,
        face: palette.cream3,
        eyeWhite: RatelColors.onColor,
        pupil: RatelColors.ink,
        nose: RatelColors.ink,
      );
      traveller = CustomPaint(
        size: Size(w, h),
        painter: _BadgerPainter(colors),
      );
    }

    if (_controller != null) {
      traveller = AnimatedBuilder(
        animation: _controller!,
        builder: (context, child) {
          // 0/100% -> 0, 50% -> -7px, ease-in-out.
          final phase =
              math.sin(_controller!.value * 2 * math.pi - math.pi / 2);
          final t = (phase + 1) / 2; // 0..1..0
          final dy = -7.0 * t;
          return Transform.translate(offset: Offset(0, dy), child: child);
        },
        child: traveller,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        traveller,
        // margin-top:-2px in the design (bubble nudged up under the traveller).
        Transform.translate(
          offset: const Offset(0, -2),
          child: _StartBubble(),
        ),
      ],
    );
  }
}

class _StartBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: RatelColors.teal,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: context.palette.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        context.l10n.homeStartNode,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: RatelColors.onColor,
        ),
      ),
    );
  }
}

/// The badger artwork's colour set, built from theme tokens by the widget and
/// passed in — so the painter holds no raw colour literals.
class _BadgerColors {
  const _BadgerColors({
    required this.shadow,
    required this.ear,
    required this.headDark,
    required this.face,
    required this.eyeWhite,
    required this.pupil,
    required this.nose,
  });

  final Color shadow;
  final Color ear;
  final Color headDark;
  final Color face;
  final Color eyeWhite;
  final Color pupil;
  final Color nose;
}

/// Paints the honey-badger head from the design SVG (`viewBox 0 0 64 56`,
/// HTML:172-179). Colours arrive via [_BadgerColors] (token-derived).
class _BadgerPainter extends CustomPainter {
  _BadgerPainter(this.colors);

  final _BadgerColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 64.0;
    canvas.save();
    canvas.scale(scale, scale);

    final p = Paint()..isAntiAlias = true;

    // ground shadow ellipse: cx32 cy50 rx18 ry4
    p.color = colors.shadow;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(32, 50), width: 36, height: 8),
      p,
    );

    // ears: circles cx16/48 cy19 r6
    p.color = colors.ear;
    canvas.drawCircle(const Offset(16, 19), 6, p);
    canvas.drawCircle(const Offset(48, 19), 6, p);

    // dark head: M12 30 a20 17 0 0 1 40 0 v3 a20 15 0 0 1 -40 0 z
    p.color = colors.headDark;
    final head = Path()
      ..moveTo(12, 30)
      ..arcToPoint(const Offset(52, 30),
          radius: const Radius.elliptical(20, 17),
          rotation: 0,
          largeArc: false,
          clockwise: true)
      ..relativeLineTo(0, 3)
      ..arcToPoint(const Offset(12, 33),
          radius: const Radius.elliptical(20, 15),
          rotation: 0,
          largeArc: false,
          clockwise: true)
      ..close();
    canvas.drawPath(head, p);

    // cream face: M12 31 a20 17 0 0 1 40 0 h-40 z
    p.color = colors.face;
    final face = Path()
      ..moveTo(12, 31)
      ..arcToPoint(const Offset(52, 31),
          radius: const Radius.elliptical(20, 17),
          rotation: 0,
          largeArc: false,
          clockwise: true)
      ..relativeLineTo(-40, 0)
      ..close();
    canvas.drawPath(face, p);

    // eyes: white circles cx24/40 cy33 r3.6
    p.color = colors.eyeWhite;
    canvas.drawCircle(const Offset(24, 33), 3.6, p);
    canvas.drawCircle(const Offset(40, 33), 3.6, p);

    // pupils: cx24.7/40.7 cy33.4 r1.8
    p.color = colors.pupil;
    canvas.drawCircle(const Offset(24.7, 33.4), 1.8, p);
    canvas.drawCircle(const Offset(40.7, 33.4), 1.8, p);

    // nose: ellipse cx32 cy40 rx3.2 ry2.4
    p.color = colors.nose;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(32, 40), width: 6.4, height: 4.8),
      p,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BadgerPainter oldDelegate) =>
      oldDelegate.colors != colors;
}
