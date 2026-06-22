import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../context_ext.dart';
import '../motion/ratel_motion_tier.dart';
import '../tokens/ratel_color_tokens.dart';
import '../tokens/ratel_motion.dart';

/// R-L19 escalation levels: correct answer -> lesson complete -> level up.
enum CelebrationLevel { flourish, lessonComplete, levelUp }

/// One-shot GPU particle celebration (no video — R-L19). Honors MotionTier:
/// static tiers render nothing (the caller still shows the final number/still).
class RatelCelebration extends StatefulWidget {
  const RatelCelebration({
    super.key,
    this.level = CelebrationLevel.lessonComplete,
    this.onComplete,
  });

  final CelebrationLevel level;
  final VoidCallback? onComplete;

  @override
  State<RatelCelebration> createState() => _RatelCelebrationState();
}

class _RatelCelebrationState extends State<RatelCelebration>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late final List<_Particle> _particles = _build(widget.level);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!context.motionTier.isStatic && _controller == null) {
      _controller = AnimationController(vsync: this, duration: RatelMotion.celebrate)
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) widget.onComplete?.call();
        })
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (context.motionTier.isStatic || controller == null) {
      return const SizedBox.shrink();
    }
    final tokens = context.tokens;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(_particles, controller.value, tokens),
          size: Size.infinite,
        ),
      ),
    );
  }

  static List<_Particle> _build(CelebrationLevel level) {
    final count = switch (level) {
      CelebrationLevel.flourish => 8,
      CelebrationLevel.lessonComplete => 28,
      CelebrationLevel.levelUp => 60,
    };
    final rnd = math.Random(level.index + 7);
    return List<_Particle>.generate(count, (i) {
      final angle = rnd.nextDouble() * 2 * math.pi;
      final speed = 0.5 + rnd.nextDouble();
      return _Particle(
        dx: math.cos(angle) * speed,
        dy: math.sin(angle) * speed - 0.6,
        rot: rnd.nextDouble() * 2 * math.pi,
        hue: rnd.nextInt(4),
        size: 6 + rnd.nextDouble() * 6,
      );
    });
  }
}

class _Particle {
  _Particle({
    required this.dx,
    required this.dy,
    required this.rot,
    required this.hue,
    required this.size,
  });
  final double dx;
  final double dy;
  final double rot;
  final int hue;
  final double size;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.t, this.tokens);
  final List<_Particle> particles;
  final double t;
  final RatelColorTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final palette = [tokens.primary, tokens.accent, tokens.success, tokens.danger];
    const dist = 140.0;
    const gravity = 0.8;
    for (final p in particles) {
      final x = center.dx + p.dx * dist * t;
      final y = center.dy + (p.dy * dist * t) + (gravity * dist * t * t);
      final opacity = (1.0 - t).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = palette[p.hue % palette.length].withValues(alpha: opacity);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rot + t * 6);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
