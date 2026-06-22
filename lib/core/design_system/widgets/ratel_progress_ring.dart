import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../context_ext.dart';
import '../motion/ratel_motion_tier.dart';
import '../tokens/ratel_motion.dart';

/// Goal/progress ring (R-L16 ring-fill). Honors MotionTier: static tiers paint
/// the final value with no tween.
class RatelProgressRing extends StatelessWidget {
  const RatelProgressRing({
    super.key,
    required this.progress,
    this.size = 64,
    this.stroke = 8,
    this.child,
  });

  final double progress;
  final double size;
  final double stroke;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final clamped = progress.clamp(0.0, 1.0);
    Widget paint(double p) => CustomPaint(
          painter: _RingPainter(p, t.primary, t.surfaceVariant, stroke),
          child: SizedBox.square(dimension: size, child: Center(child: child)),
        );
    if (context.motionTier.isStatic) return paint(clamped);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: clamped),
      duration: RatelMotion.slow,
      curve: RatelMotion.standard,
      builder: (context, p, _) => paint(p),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.fg, this.bg, this.stroke);
  final double progress;
  final Color fg;
  final Color bg;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    final track = Paint()
      ..color = bg
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final arc = Paint()
      ..color = fg
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.fg != fg || old.bg != bg || old.stroke != stroke;
}
