import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

/// Mascot moods the placeholder rig can show (maps to Rive state-machine inputs
/// once the real `.riv` lands).
enum MascotMood { idle, cheer }

/// Placeholder mascot rig (R-L18). Ships a programmatic, token-drawn mascot
/// until the owner authors the real pure-vector `.riv` (guarded by
/// `riv_contract`). A single controller, DISPOSED offscreen (R-N8), and
/// MotionTier-aware (R-N7):
///   full          → a gentle idle bob loop
///   reduced/static → a paused pose (no motion)
/// Swap-in point: when `assets/rive/mascot.riv` exists, render `RiveAnimation`
/// here behind the same MotionTier gate (and verify rive web support in CI).
class MascotView extends StatefulWidget {
  const MascotView({super.key, this.size = 72, this.mood = MascotMood.idle});
  final double size;
  final MascotMood mood;

  @override
  State<MascotView> createState() => _MascotViewState();
}

class _MascotViewState extends State<MascotView>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Decorative looping is allowed ONLY at the full tier (R-N8).
    final looping = context.motionTier.allowsLooping;
    if (looping && _controller == null) {
      _controller = AnimationController(vsync: this, duration: RatelMotion.slow)
        ..repeat(reverse: true);
    } else if (!looping && _controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // dispose offscreen (R-N8)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final art = _MascotArt(
      size: widget.size,
      mood: widget.mood,
      body: t.primary,
      stripe: t.accent,
      face: t.onPrimary,
    );
    final controller = _controller;
    if (controller == null) {
      // paused pose / static still
      return Semantics(label: 'Ratel mascot', child: art);
    }
    return Semantics(
      label: 'Ratel mascot',
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -widget.size * 0.06 * controller.value),
          child: child,
        ),
        child: art,
      ),
    );
  }
}

class _MascotArt extends StatelessWidget {
  const _MascotArt({
    required this.size,
    required this.mood,
    required this.body,
    required this.stripe,
    required this.face,
  });
  final double size;
  final MascotMood mood;
  final Color body;
  final Color stripe;
  final Color face;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _MascotPainter(mood: mood, body: body, stripe: stripe, face: face),
      ),
    );
  }
}

/// A stylised honey-badger silhouette (the Ratel) — pale back-stripe + two eyes.
class _MascotPainter extends CustomPainter {
  _MascotPainter({
    required this.mood,
    required this.body,
    required this.stripe,
    required this.face,
  });
  final MascotMood mood;
  final Color body;
  final Color stripe;
  final Color face;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final bodyP = Paint()..color = body;
    final stripeP = Paint()..color = stripe;
    final faceP = Paint()..color = face;
    final pupilP = Paint()..color = body;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.20, w * 0.76, h * 0.66),
      Radius.circular(w * 0.34),
    );
    canvas.drawRRect(bodyRect, bodyP);

    final stripeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.20, w * 0.76, h * 0.22),
      Radius.circular(w * 0.2),
    );
    canvas.drawRRect(stripeRect, stripeP);

    final eyeY = h * 0.54;
    final eyeR = w * 0.10;
    for (final dx in [0.37, 0.63]) {
      canvas.drawCircle(Offset(w * dx, eyeY), eyeR, faceP);
      canvas.drawCircle(Offset(w * dx, eyeY), eyeR * 0.5, pupilP);
    }

    if (mood == MascotMood.cheer) {
      final smile = Paint()
        ..color = face
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.04
        ..strokeCap = StrokeCap.round;
      final path = Path()
        ..moveTo(w * 0.42, h * 0.70)
        ..quadraticBezierTo(w * 0.5, h * 0.78, w * 0.58, h * 0.70);
      canvas.drawPath(path, smile);
    }
  }

  @override
  bool shouldRepaint(_MascotPainter old) =>
      old.mood != mood || old.body != body || old.stripe != stripe || old.face != face;
}
