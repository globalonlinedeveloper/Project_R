import 'package:flutter/material.dart';
import '../context_ext.dart';
import '../tokens/ratel_spacing.dart';

/// Surface card on tokens. Tappable variant uses an Ink ripple (state feedback).
class RatelCard extends StatelessWidget {
  const RatelCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.selected = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final radius = BorderRadius.circular(RatelSpacing.radiusLg);
    final decoration = BoxDecoration(
      color: selected ? t.surfaceVariant : t.surface,
      borderRadius: radius,
      border: Border.all(
        color: selected ? t.primary : t.outline.withValues(alpha: 0.25),
        width: selected ? 2 : 1,
      ),
    );
    final body = Padding(
      padding: padding ?? const EdgeInsets.all(RatelSpacing.lg),
      child: child,
    );
    if (onTap == null) {
      return DecoratedBox(decoration: decoration, child: body);
    }
    return Material(
      color: decoration.color,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? t.primary : t.outline.withValues(alpha: 0.25),
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: body),
    );
  }
}
