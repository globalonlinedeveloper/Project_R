import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Surface card (design spec §3).
///
/// Plain (default) = white, 1px warm border + a very soft shadow. Pass a
/// [gradient] or solid [color] for a **feature** card (carries the color, no
/// border/shadow — e.g. the AI-Tutor dark-teal card or the amber daily-goal
/// card). [onTap] makes the whole card a button.
class RatelCard extends StatelessWidget {
  const RatelCard({
    super.key,
    this.padding = const EdgeInsets.all(RatelSpace.cardPad),
    this.onTap,
    this.gradient,
    this.color,
    this.radius = RatelRadius.card,
    required this.child,
  });

  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;
  final double radius;
  final Widget child;

  bool get _feature => gradient != null || color != null;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _feature ? (color ?? RatelColors.teal) : RatelColors.white,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: _feature ? null : Border.all(color: RatelColors.border),
        boxShadow: _feature
            ? null
            : const <BoxShadow>[
                BoxShadow(
                  color: RatelColors.shadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      ),
    );
  }
}
