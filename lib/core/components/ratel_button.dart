import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Full-width pill CTA (design spec §3).
///
/// [RatelButtonVariant.primary] = teal, `success` = green ("Continue"),
/// `danger` = coral, `secondary` = a transparent teal text link ("Skip",
/// "I already have an account"). A null [onPressed] renders the disabled
/// (pale) state.
enum RatelButtonVariant { primary, success, danger, secondary }

class RatelButton extends StatelessWidget {
  const RatelButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = RatelButtonVariant.primary,
    this.expand = true,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final RatelButtonVariant variant;

  /// Stretch to full width (default true).
  final bool expand;

  /// Optional leading widget (e.g. an emoji or small icon).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null;
    final bool secondary = variant == RatelButtonVariant.secondary;

    final Color base = switch (variant) {
      RatelButtonVariant.primary => RatelColors.teal,
      RatelButtonVariant.success => RatelColors.green,
      RatelButtonVariant.danger => RatelColors.coral,
      RatelButtonVariant.secondary => RatelColors.teal,
    };

    final Color bg = secondary
        ? Colors.transparent
        : (disabled ? base.withValues(alpha: 0.4) : base);
    final Color fg = secondary
        ? (disabled ? context.palette.muted : RatelColors.teal)
        : RatelColors.onColor;

    final TextStyle labelStyle =
        (Theme.of(context).textTheme.labelLarge ?? const TextStyle())
            .copyWith(color: fg);

    final Widget inner = leading == null
        ? Text(label, style: labelStyle, maxLines: 1, overflow: TextOverflow.ellipsis)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              leading!,
              const SizedBox(width: RatelSpace.sm),
              Flexible(child: Text(label, style: labelStyle, overflow: TextOverflow.ellipsis)),
            ],
          );

    final Widget button = Container(
      height: 52,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: RatelSpace.xl),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(RatelRadius.pill),
      ),
      child: inner,
    );

    final Widget tappable = Semantics(
      button: true,
      enabled: !disabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: button,
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: tappable) : tappable;
  }
}
