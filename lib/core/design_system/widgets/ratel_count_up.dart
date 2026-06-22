import 'package:flutter/widgets.dart';
import '../context_ext.dart';
import '../motion/ratel_motion_tier.dart';
import '../tokens/ratel_motion.dart';

/// Count-up number animation (R-L16). Honors MotionTier: static tiers jump
/// straight to [value] with no motion (reduced-motion still).
class RatelCountUp extends StatelessWidget {
  const RatelCountUp({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
  });

  final int value;
  final TextStyle? style;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    if (context.motionTier.isStatic) {
      return Text('$prefix$value$suffix', style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: RatelMotion.celebrate,
      curve: RatelMotion.standard,
      builder: (context, v, _) => Text('$prefix${v.round()}$suffix', style: style),
    );
  }
}
