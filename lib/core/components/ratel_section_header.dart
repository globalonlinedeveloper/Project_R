import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Small-caps muted section label + optional trailing action (design spec §3),
/// e.g. "READ & LISTEN" or "🏆 View all 10 tiers ›".
class RatelSectionHeader extends StatelessWidget {
  const RatelSectionHeader({
    super.key,
    required this.label,
    this.action,
    this.onAction,
  });

  final String label;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle =
        (Theme.of(context).textTheme.labelSmall ?? const TextStyle())
            .copyWith(fontWeight: RatelType.semiBold, letterSpacing: 1.3);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(label.toUpperCase(), style: labelStyle),
        ),
        if (action != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAction,
            child: Text(
              '$action ›',
              style: labelStyle.copyWith(color: RatelColors.teal),
            ),
          ),
      ],
    );
  }
}
