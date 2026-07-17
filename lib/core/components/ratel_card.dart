import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'ratel_scrim.dart';

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
    final Color fill =
        _feature ? (color ?? RatelColors.teal) : context.palette.white;
    final Widget container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: _feature ? null : Border.all(color: context.palette.border),
        boxShadow: _feature
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: context.palette.shadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
    // Shared chrome scrim: back a TRANSLUCENT plain surface (backdrop worlds)
    // so muted card content reads at full contrast over the animated field.
    // No-op on opaque (Daylight) surfaces and on feature cards (own solid fill).
    final Widget content = RatelScrim(
      active: !_feature && fill.a < 1.0,
      radius: radius,
      child: container,
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
