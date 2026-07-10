import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Horizontal progress pill (design spec §3) — the lesson header bar / course
/// progress track. [value] is clamped to 0..1.
class RatelProgressBar extends StatelessWidget {
  const RatelProgressBar({
    super.key,
    required this.value,
    this.color = RatelColors.green,
    this.height = 14,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final double v = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(RatelRadius.pill),
      child: Container(
        height: height,
        color: context.palette.cream3,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: v,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(RatelRadius.pill),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular progress ring (design spec §3) — Profile dashboard "72/160" / the
/// daily-goal ring. Track + colored arc with an optional [center] widget.
class RatelProgressRing extends StatelessWidget {
  const RatelProgressRing({
    super.key,
    required this.value,
    this.size = 64,
    this.stroke = 8,
    this.color = RatelColors.teal,
    this.center,
  });

  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.clamp(0.0, 1.0),
          stroke: stroke,
          color: color,
          track: context.palette.border,
        ),
        child: center == null
            ? null
            : Center(
                child: Padding(
                  padding: EdgeInsets.all(stroke),
                  child: FittedBox(fit: BoxFit.scaleDown, child: center),
                ),
              ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.stroke,
    required this.color,
    required this.track,
  });

  final double value;
  final double stroke;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = (size.shortestSide - stroke) / 2;
    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(c, r, base..color = track);
    if (value > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        value * 2 * math.pi,
        false,
        base..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.color != color ||
      old.stroke != stroke ||
      old.track != track;
}
