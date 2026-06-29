import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// iOS-style toggle (design spec §3, Settings): teal track when on, gray off.
class RatelToggle extends StatelessWidget {
  const RatelToggle({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onChanged != null;
    return Semantics(
      toggled: value,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(!value) : null,
        child: AnimatedContainer(
          duration: RatelMotion.fast,
          width: 48,
          height: 28,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value
                ? RatelColors.teal
                : context.palette.muted.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(RatelRadius.pill),
          ),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: context.palette.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
