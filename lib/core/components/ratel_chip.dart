import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Small rounded pill (design spec §3): energy/XP chips, the level pill ("A2"),
/// the amber PRO badge, the green FREE badge, reward chips ("🎁 15 💎").
enum RatelChipTone { neutral, teal, green, amber, coral }

class RatelChip extends StatelessWidget {
  const RatelChip({
    super.key,
    required this.label,
    this.tone = RatelChipTone.neutral,
    this.filled = false,
    this.leadingEmoji,
  });

  final String label;
  final RatelChipTone tone;

  /// Filled (solid tone bg + white text) vs tinted (soft tone bg + tone text).
  final bool filled;
  final String? leadingEmoji;

  /// Amber filled "PRO" badge.
  factory RatelChip.pro() =>
      const RatelChip(label: 'PRO', tone: RatelChipTone.amber, filled: true);

  /// Green tinted "FREE" badge.
  factory RatelChip.free() =>
      const RatelChip(label: 'FREE', tone: RatelChipTone.green);

  /// Teal-tinted CEFR level pill (e.g. "A2").
  factory RatelChip.level(String level) =>
      RatelChip(label: level, tone: RatelChipTone.teal, filled: true);

  Color _base(BuildContext context) => switch (tone) {
        RatelChipTone.neutral => context.palette.muted,
        RatelChipTone.teal => RatelColors.teal,
        RatelChipTone.green => RatelColors.green,
        RatelChipTone.amber => RatelColors.amber,
        RatelChipTone.coral => RatelColors.coral,
      };

  @override
  Widget build(BuildContext context) {
    final bool neutral = tone == RatelChipTone.neutral;
    final Color bg = filled
        ? _base(context)
        : (neutral ? context.palette.cream3 : _base(context).withValues(alpha: 0.14));
    final Color fg = filled
        ? RatelColors.onColor
        : (neutral ? context.palette.ink : _base(context));

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RatelSpace.md,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(RatelRadius.chip),
      ),
      child: Text(
        leadingEmoji == null ? label : '$leadingEmoji $label',
        style: TextStyle(
          fontFamily: RatelFont.display,
          fontSize: RatelType.small,
          fontWeight: RatelType.extraBold,
          color: fg,
        ),
      ),
    );
  }
}
