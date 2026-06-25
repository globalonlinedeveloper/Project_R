import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'space_palette.dart';

/// A static deep-space backdrop (Space world): the section-0 dark-space vertical
/// gradient + a seeded starfield + two faint nebula blobs. Used as the base
/// layer of the Space Home and as the app-flow shell backdrop on other screens.
///
/// This is the STILL form (Increment A). The parallax/animated galaxy painter
/// (scroll-reactive nebula, FX catalog, pod auto-defense) extends it in the
/// galaxy build; under reduce-motion the still form is the hard floor.
class SpaceBackdrop extends StatelessWidget {
  const SpaceBackdrop({super.key, this.seed = 1});

  final int seed;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: RepaintBoundary(
        child: CustomPaint(painter: _SpaceBackdropPainter(seed)),
      ),
    );
  }
}

class _SpaceBackdropPainter extends CustomPainter {
  _SpaceBackdropPainter(this.seed);

  final int seed;

  // section-0 sky: hsl(208,55,19) -> (220,58,8) -> (232,52,3)
  static final List<Color> _sky = <Color>[
    HSLColor.fromAHSL(1, 208, 0.55, 0.19).toColor(),
    HSLColor.fromAHSL(1, 220, 0.58, 0.08).toColor(),
    HSLColor.fromAHSL(1, 232, 0.52, 0.03).toColor(),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _sky,
          stops: const <double>[0, 0.5, 1],
        ).createShader(rect),
    );

    // two faint nebula blobs (section-0 hue family)
    _nebula(canvas, Offset(size.width * 0.18, size.height * 0.22),
        size.shortestSide * 0.7, HSLColor.fromAHSL(1, 208, 0.72, 0.52).toColor());
    _nebula(canvas, Offset(size.width * 0.85, size.height * 0.66),
        size.shortestSide * 0.7, HSLColor.fromAHSL(1, 358, 0.60, 0.48).toColor());

    // seeded starfield (3 size tiers)
    final rng = math.Random(seed);
    final star = Paint();
    for (var i = 0; i < 90; i++) {
      final tier = i % 3;
      final r = (tier + 1) * 0.4 + rng.nextDouble() * 0.7;
      final tw = 0.35 + rng.nextDouble() * 0.55;
      star.color = SpacePalette.star.withValues(alpha: tw);
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        r,
        star,
      );
    }
  }

  void _nebula(Canvas canvas, Offset c, double radius, Color color) {
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_SpaceBackdropPainter oldDelegate) => oldDelegate.seed != seed;
}
// Traceability: R-WT4 R-WT7
