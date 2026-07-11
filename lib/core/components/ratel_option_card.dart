import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Lesson answer states (design spec §3 / §4.7).
enum RatelOptionState { idle, selected, correct, wrong }

/// A lesson option card: emoji + label with a state-driven border/tint
/// (default → selected teal → correct green → wrong coral).
class RatelOptionCard extends StatelessWidget {
  const RatelOptionCard({
    super.key,
    this.emoji,
    required this.label,
    this.state = RatelOptionState.idle,
    this.onTap,
  });

  final String? emoji;
  final String label;
  final RatelOptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = switch (state) {
      RatelOptionState.idle => context.palette.border,
      RatelOptionState.selected => RatelColors.teal,
      RatelOptionState.correct => RatelColors.green,
      RatelOptionState.wrong => RatelColors.coral,
    };
    final bool active = state != RatelOptionState.idle;
    final Color bg = active ? accent.withValues(alpha: 0.10) : context.palette.white;

    return Semantics(
      button: true,
      selected: state == RatelOptionState.selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: RatelMotion.fast,
          padding: const EdgeInsets.all(RatelSpace.lg),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(RatelRadius.card),
            border: Border.all(color: accent, width: active ? 2 : 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (emoji != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: RatelSpace.sm),
                  child: Text(emoji!, style: const TextStyle(fontSize: 40)),
                ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: RatelFont.display,
                  fontSize: RatelType.bodyLg,
                  fontWeight: RatelType.semiBold,
                  color: context.palette.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A word-bank tile (design spec §4.7) — a smaller rounded pill used in the
/// translate exercise. [used] fades it once tapped into the answer.
class RatelWordTile extends StatelessWidget {
  const RatelWordTile({
    super.key,
    required this.word,
    this.onTap,
    this.used = false,
  });

  final String word;
  final VoidCallback? onTap;
  final bool used;

  @override
  Widget build(BuildContext context) {
    // Q-4: screen-reader parity with [RatelOptionCard] — every word-bank
    // tile announces as a labelled button (repo Semantics convention).
    // Flags-only wrapper: the child Text supplies the (single) label and
    // the GestureDetector supplies the tap action — adding a label here
    // would double-announce, excluding children would strip activation.
    return Semantics(
      button: true,
      child: Opacity(
        opacity: used ? 0.35 : 1,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: used ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: RatelSpace.lg,
              vertical: RatelSpace.md,
            ),
            decoration: BoxDecoration(
              color: context.palette.white,
              borderRadius: BorderRadius.circular(RatelRadius.chip),
              border: Border.all(color: context.palette.border),
            ),
            child: Text(
              word,
              style: TextStyle(
                fontFamily: RatelFont.display,
                fontSize: RatelType.body,
                fontWeight: RatelType.semiBold,
                color: context.palette.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
