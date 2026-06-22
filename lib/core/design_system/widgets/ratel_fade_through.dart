import 'package:flutter/widgets.dart';
import '../context_ext.dart';
import '../motion/ratel_motion_tier.dart';
import '../tokens/ratel_motion.dart';

/// Cross-fade between data states (R-L17: data-state changes cross-fade).
/// Static motion tiers swap instantly.
class RatelFadeThrough extends StatelessWidget {
  const RatelFadeThrough({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration =
        context.motionTier.isStatic ? Duration.zero : RatelMotion.crossFade;
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: RatelMotion.enter,
      switchOutCurve: RatelMotion.exit,
      child: child,
    );
  }
}
