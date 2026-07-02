import 'package:flutter/material.dart';
import 'package:ratel/core/theme/world_theme.dart';

import 'backdrop_paint.dart';
import 'backdrop_registry.dart';

/// Paints a [ThemeWorld]'s animated backdrop behind [child], full-bleed.
///
/// Layering (matching the design's z-0 `<canvas>` behind the app): the world's
/// solid `page` color, then the animated backdrop, then [child].
///
/// **Hard reduce-motion floor.** If `MediaQuery.of(context).disableAnimations`
/// is true, this widget starts NO ticker and paints exactly ONE static frame at
/// `t = 0` — no per-frame rebuilds, battery-safe. This mirrors the app-wide
/// floor already enforced in `RatelApp` (OS setting OR the in-app reduce-motion
/// toggle, combined with `||`, so the OS wins). Motion worlds degrade to a
/// still image, never to jank. Otherwise a single [AnimationController]
/// (~60 s period, repeating) drives the phase `t ∈ [0, 1)`.
///
/// If the world's `backdrop` id has no registered painter (e.g. `none`, or a
/// not-yet-ported id), only the solid `page` color is painted — no animation.
class WorldBackdrop extends StatefulWidget {
  const WorldBackdrop({
    super.key,
    required this.world,
    required this.child,
  });

  /// The active theme world (supplies the palette + backdrop id).
  final ThemeWorld world;

  /// The app content painted in front of the backdrop.
  final Widget child;

  @override
  State<WorldBackdrop> createState() => _WorldBackdropState();
}

class _WorldBackdropState extends State<WorldBackdrop>
    with SingleTickerProviderStateMixin {
  /// The looping phase driver. Non-null ONLY when animations are enabled;
  /// under the reduce-motion floor it is never created (no ticker, no repaint).
  AnimationController? _controller;

  /// Whether a ticker is currently running (tracks the reduce-motion decision
  /// so we can react to it changing at runtime).
  bool _animating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // OS accessibility setting is the hard floor (already OR-folded with the
    // in-app toggle upstream, so reading it here honors both).
    final bool reduceMotion = MediaQuery.of(context).disableAnimations;
    _syncTicker(animate: !reduceMotion);
  }

  void _syncTicker({required bool animate}) {
    if (animate == _animating) return;
    _animating = animate;
    if (animate) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 60),
      )..repeat();
    } else {
      _controller?.dispose();
      _controller = null;
      // Repaint once so the static t=0 frame shows immediately.
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final WorldPalette palette = widget.world.palette;
    final BackdropPaint? painter = kBackdropPainters[widget.world.backdrop];

    // No painter for this world → just the solid page color behind the child.
    if (painter == null) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ColoredBox(color: palette.page),
          widget.child,
        ],
      );
    }

    final AnimationController? controller = _controller;
    final Widget backdrop = controller == null
        // Reduce-motion floor: one static frame at t = 0.
        ? CustomPaint(
            painter: _BackdropPainter(painter, palette, 0),
            isComplex: true,
            willChange: false,
          )
        // Animated: repaint as the phase advances.
        : AnimatedBuilder(
            animation: controller,
            builder: (BuildContext context, _) => CustomPaint(
              painter: _BackdropPainter(painter, palette, controller.value),
              isComplex: true,
              willChange: true,
            ),
          );

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ColoredBox(color: palette.page),
        Positioned.fill(child: RepaintBoundary(child: backdrop)),
        widget.child,
      ],
    );
  }
}

/// Adapts a [BackdropPaint] function to a [CustomPainter], repainting only when
/// the phase [t] (or palette / painter identity) changes.
class _BackdropPainter extends CustomPainter {
  const _BackdropPainter(this.paintFn, this.palette, this.t);

  final BackdropPaint paintFn;
  final WorldPalette palette;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    paintFn(canvas, size, palette, t);
  }

  @override
  bool shouldRepaint(_BackdropPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.paintFn != paintFn ||
      oldDelegate.palette != palette;
}
