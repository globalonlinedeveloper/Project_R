import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ratel/core/core.dart';

import 'path_node_state.dart';

/// A single learning-path node (`Ratel App.dc.html`:156-167, styling 3213-3234).
///
/// Renders one of the four [PathNodeState]s as a circular node with the design's
/// inline-vector glyph (NOT emoji — the check / play / lock / trophy are ported
/// as `CustomPaint` from the design's `viewBox 0 0 24 24` SVG paths):
///
///  * [PathNodeState.done]       teal circle + check glyph
///  * [PathNodeState.active]     teal circle + play glyph + a static 5px pulse
///                               ring, plus a scale pulse (rpulse) when motion
///                               is allowed
///  * [PathNodeState.locked]     cream circle (opacity .85) + muted lock glyph
///  * [PathNodeState.checkpoint] gold circle + trophy glyph (pulses only if it
///                               is also the active node — see [pulsing])
///
/// Sizes match the design: active = 64, all others = 56 (HTML:3215) — the
/// integrating screen passes [size] accordingly.
///
/// Pure: no providers. The only callback is [onTap] (`VoidCallback`). All motion
/// is gated by [reduceMotion]: when true the widget builds NO [AnimationController]
/// and renders statically (the static accent pulse-ring on the active node is
/// kept so it still reads as "current").
class PathNode extends StatefulWidget {
  const PathNode({
    super.key,
    required this.state,
    required this.size,
    this.onTap,
    this.reduceMotion = false,
    this.pulsing = true,
  });

  /// Which of the four visual states to render.
  final PathNodeState state;

  /// Circle diameter in logical px (design: 64 active / 56 otherwise).
  final double size;

  /// Tapped when the node is pressed.
  final VoidCallback? onTap;

  /// Hard reduce-motion floor. When true, no controller is created and the
  /// node is fully static.
  final bool reduceMotion;

  /// Whether an active/active-checkpoint node should run the rpulse scale
  /// animation. Ignored (treated as false) when [reduceMotion] is true or the
  /// node is not active. A completed checkpoint never pulses.
  final bool pulsing;

  @override
  State<PathNode> createState() => _PathNodeState();
}

class _PathNodeState extends State<PathNode>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  bool get _wantsPulse =>
      widget.pulsing &&
      !widget.reduceMotion &&
      widget.state == PathNodeState.active;

  @override
  void initState() {
    super.initState();
    if (_wantsPulse) _startController();
  }

  void _startController() {
    // rpulse: period 1.9s, scale 1 -> 1.08 -> 1, ease-in-out, infinite
    // (HTML:32).
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant PathNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldRun = _wantsPulse;
    if (shouldRun && _controller == null) {
      _startController();
    } else if (!shouldRun && _controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isActive = widget.state == PathNodeState.active;

    // Fill by state (light theme values from the design token cross-map).
    final Color fill;
    switch (widget.state) {
      case PathNodeState.done:
        fill = RatelColors.teal; // --accent #16a085
        break;
      case PathNodeState.active:
        fill = RatelColors.teal; // --accent #16a085
        break;
      case PathNodeState.checkpoint:
        fill = RatelColors.amber; // --gold #E0972B (design gold)
        break;
      case PathNodeState.locked:
        fill = palette.cream3; // --surface2 #f1eee5
        break;
    }

    // Glyph colour: --ink (#fff / onColor) for teal & gold nodes; --muted for
    // the locked lock icon.
    final glyphColor = widget.state == PathNodeState.locked
        ? RatelColors.muted
        : RatelColors.onColor;

    // Glyph selection + its design draw-size within the 24x24 viewBox.
    final _GlyphKind kind;
    final double glyphBox;
    switch (widget.state) {
      case PathNodeState.done:
        kind = _GlyphKind.check;
        glyphBox = 24;
        break;
      case PathNodeState.active:
        kind = _GlyphKind.play;
        glyphBox = 26;
        break;
      case PathNodeState.checkpoint:
        kind = _GlyphKind.trophy;
        glyphBox = 24;
        break;
      case PathNodeState.locked:
        kind = _GlyphKind.lock;
        glyphBox = 22;
        break;
    }

    Widget circle = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        boxShadow: [
          // inset 0 -5px 0 accent2 approximated with a soft drop shadow +
          // outer soft shadow (0 4px 10px shadow). Flutter has no inset shadow;
          // the drop shadow reads as the design's grounded look.
          BoxShadow(
            color: palette.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size.square(glyphBox),
          painter: _NodeGlyphPainter(kind: kind, color: glyphColor),
        ),
      ),
    );

    // Locked nodes render at opacity .85 in the design; active/done/checkpoint
    // stay full opacity.
    if (widget.state == PathNodeState.locked) {
      circle = Opacity(opacity: 0.85, child: circle);
    }

    // Static 5px accent pulse-ring behind the active node (kept even under
    // reduce-motion so "current" still reads).
    Widget node = circle;
    if (isActive) {
      node = Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: widget.size + 10, // +5px ring on each side
            height: widget.size + 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // color-mix(accent 25%, transparent).
              color: RatelColors.teal.withValues(alpha: 0.25),
            ),
          ),
          circle,
        ],
      );
    }

    // rpulse scale wrapper (motion only).
    if (_controller != null) {
      node = AnimatedBuilder(
        animation: _controller!,
        builder: (context, child) {
          // 0/100% -> 1.0, 50% -> 1.08, ease-in-out.
          final phase = math.sin(_controller!.value * 2 * math.pi - math.pi / 2);
          final t = (phase + 1) / 2; // 0..1..0 eased-ish
          final scale = 1.0 + 0.08 * t;
          return Transform.scale(scale: scale, child: child);
        },
        child: node,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: node,
    );
  }
}

enum _GlyphKind { check, play, lock, trophy }

/// Paints the design's node glyphs from their `viewBox 0 0 24 24` SVG paths,
/// scaled to fit [size]. Faithful to `Ratel App.dc.html`:161-164.
class _NodeGlyphPainter extends CustomPainter {
  _NodeGlyphPainter({required this.kind, required this.color});

  final _GlyphKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final scale = size.width / 24.0; // all design glyphs use a 24 viewBox
    canvas.save();
    canvas.scale(scale, scale);
    canvas.drawPath(_pathFor(kind), paint);
    canvas.restore();
  }

  Path _pathFor(_GlyphKind kind) {
    switch (kind) {
      case _GlyphKind.check:
        // m9 16.2 -3.5 -3.5 L4 14.2 9 19 20 8 l-1.4 -1.4 z
        return Path()
          ..moveTo(9, 16.2)
          ..relativeLineTo(-3.5, -3.5)
          ..lineTo(4, 14.2)
          ..lineTo(9, 19)
          ..lineTo(20, 8)
          ..relativeLineTo(-1.4, -1.4)
          ..close();
      case _GlyphKind.play:
        // M8 5 v14 l11 -7 z
        return Path()
          ..moveTo(8, 5)
          ..relativeLineTo(0, 14)
          ..relativeLineTo(11, -7)
          ..close();
      case _GlyphKind.lock:
        // M12 2 a5 5 0 0 0 -5 5 v3 H6 a2 2 0 0 0 -2 2 v8 h16 v-8 a2 2 0 0 0 -2 -2
        // h-1 V7 a5 5 0 0 0 -5 -5 m3 8 H9 V7 a3 3 0 0 1 6 0 z
        // SVG sweep-flag 0 => counter-clockwise (clockwise:false); the inner
        // shackle uses sweep-flag 1 (clockwise:true). Coordinates traced to
        // absolute points with a consistent current-point. Even-odd fill so the
        // shackle sub-path reads as a hole.
        return Path()
          ..fillType = PathFillType.evenOdd
          ..moveTo(12, 2)
          ..arcToPoint(const Offset(7, 7),
              radius: const Radius.circular(5), clockwise: false) // a5 5 .. -5 5
          ..lineTo(7, 10) // v3
          ..lineTo(6, 10) // H6
          ..arcToPoint(const Offset(4, 12),
              radius: const Radius.circular(2), clockwise: false) // a2 2 .. -2 2
          ..lineTo(4, 20) // v8
          ..lineTo(20, 20) // h16
          ..lineTo(20, 12) // v-8
          ..arcToPoint(const Offset(18, 10),
              radius: const Radius.circular(2), clockwise: false) // a2 2 .. -2 -2
          ..lineTo(17, 10) // h-1
          ..lineTo(17, 7) // V7
          ..arcToPoint(const Offset(12, 2),
              radius: const Radius.circular(5), clockwise: false) // a5 5 .. -5 -5
          ..close()
          // inner shackle hole (even-odd fill punches it out):
          ..moveTo(15, 10) // m3 8 from (12,2)
          ..lineTo(9, 10) // H9
          ..lineTo(9, 7) // V7
          ..arcToPoint(const Offset(15, 7),
              radius: const Radius.circular(3), clockwise: true) // a3 3 .. 6 0
          ..close();
      case _GlyphKind.trophy:
        // M6 3 h12 v3 a4 4 0 0 1 -3 3.9 V12 a3 3 0 0 1 -2 2.8 V17 h3 v2 H8 v-2
        // h3 v-2.2 A3 3 0 0 1 9 12 V9.9 A4 4 0 0 1 6 6 z
        return Path()
          ..moveTo(6, 3)
          ..relativeLineTo(12, 0)
          ..relativeLineTo(0, 3)
          ..relativeArcToPoint(const Offset(-3, 3.9),
              radius: const Radius.circular(4),
              rotation: 0,
              largeArc: false,
              clockwise: true)
          ..lineTo(15, 12)
          ..relativeArcToPoint(const Offset(-2, 2.8),
              radius: const Radius.circular(3),
              rotation: 0,
              largeArc: false,
              clockwise: true)
          ..lineTo(13, 17)
          ..relativeLineTo(3, 0)
          ..relativeLineTo(0, 2)
          ..lineTo(8, 19)
          ..relativeLineTo(0, -2)
          ..relativeLineTo(3, 0)
          ..relativeLineTo(0, -2.2)
          ..arcToPoint(const Offset(9, 12),
              radius: const Radius.circular(3),
              rotation: 0,
              largeArc: false,
              clockwise: true)
          ..lineTo(9, 9.9)
          ..arcToPoint(const Offset(6, 6),
              radius: const Radius.circular(4),
              rotation: 0,
              largeArc: false,
              clockwise: true)
          ..close();
    }
  }

  @override
  bool shouldRepaint(covariant _NodeGlyphPainter old) =>
      old.kind != kind || old.color != color;
}

// Traceability: [R-B3] Course→Section→Unit→Lesson path rendering (WS2 design-fidelity: serpentine geometry, 4 node states incl. end-of-unit checkpoint, dotted trail, bobbing traveller — SPEC_HOME_PATH).
