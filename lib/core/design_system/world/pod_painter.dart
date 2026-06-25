import 'package:flutter/material.dart';

/// The LOCKED v8 traveller "pod" — Ratel-in-a-teal-saucer — reproduced verbatim
/// from `pod_v8.svg` (viewBox 0 0 84 56). Owner-locked to the EXACT v8 pod
/// (S32): teal saucer + cockpit (`#00665C`) + orange visor (`#EF9F27`) + two
/// white eyes. Pure vector painter (no raster) → perf-cheap on the beachhead
/// phones. The mint drop-shadow that gives the "float" read is applied by the
/// host widget, not here.
class PodPainter extends CustomPainter {
  const PodPainter();

  // viewBox is 84 x 56.
  static const double vbW = 84;
  static const double vbH = 56;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / vbW, size.height / vbH);

    // base shadow ellipse: cx42 cy42 rx36 ry11 #073c32
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(42, 42), width: 72, height: 22),
      Paint()..color = const Color(0xFF073C32),
    );

    // hull ellipse: cx42 cy38 rx36 ry10, vertical gradient #1aa183 -> #0a5547
    final hullRect = Rect.fromCenter(center: const Offset(42, 38), width: 72, height: 20);
    canvas.drawOval(
      hullRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF1AA183), Color(0xFF0A5547)],
        ).createShader(hullRect),
    );

    // nav lights: cx10/74 cy40 r3 #EF9F27
    final orange = Paint()..color = const Color(0xFFEF9F27);
    canvas.drawCircle(const Offset(10, 40), 3, orange);
    canvas.drawCircle(const Offset(74, 40), 3, orange);

    // dome: top half-ellipse center(42,35) rx24 ry19 #0d7a66
    canvas.drawPath(
      _topHalfEllipse(const Offset(42, 35), 24, 19),
      Paint()..color = const Color(0xFF0D7A66),
    );
    // blue glass: top half-ellipse center(42,34) rx20 ry15 #bfe0ff @.45
    canvas.drawPath(
      _topHalfEllipse(const Offset(42, 34), 20, 15),
      Paint()..color = const Color(0xFFBFE0FF).withValues(alpha: 0.45),
    );

    // cockpit: rect x31 y18 w22 h17 rx9 #00665C
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(31, 18, 22, 17), const Radius.circular(9)),
      Paint()..color = const Color(0xFF00665C),
    );
    // gold visor strip: rect x31 y18 w22 h6 rx4 #EF9F27
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(31, 18, 22, 6), const Radius.circular(4)),
      orange,
    );

    // two white eyes: cx38/46 cy28 r2.6 #fff
    final white = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(const Offset(38, 28), 2.6, white);
    canvas.drawCircle(const Offset(46, 28), 2.6, white);

    canvas.restore();
  }

  /// Upper half of an ellipse (the dome): start at the left point and sweep the
  /// top semicircle, then close along the diameter. In Flutter's y-down frame an
  /// arc from angle π sweeping +π passes through 3π/2 (straight up).
  Path _topHalfEllipse(Offset c, double rx, double ry) {
    final rect = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
    return Path()
      ..addArc(rect, 3.141592653589793, 3.141592653589793)
      ..close();
  }

  @override
  bool shouldRepaint(PodPainter oldDelegate) => false;
}

/// Convenience widget: the locked pod at a given [size] with the signature mint
/// drop-shadow glow. Used by the Space Home traveller and any "Ratel pod" art.
class RatelPod extends StatelessWidget {
  const RatelPod({super.key, this.size = const Size(58, 40)});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: const RepaintBoundary(
        child: CustomPaint(painter: PodPainter()),
      ),
    );
  }
}
// Traceability: R-WT4
