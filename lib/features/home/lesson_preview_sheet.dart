import 'package:flutter/material.dart';

import '../../core/design_system/design_system.dart';

/// Lesson-preview bottom sheet shown on planet tap (spec §11). Variant depends
/// on the planet's [state] + checkpoint flag: an available lesson offers
/// "Start lesson" (energy-gated by the caller), a completed one offers a free
/// "Review", and a locked one explains why and disables the CTA. Tokens only
/// (R-N6) — galaxy chrome reads named [SpacePalette] colours.
class LessonPreviewSheet extends StatelessWidget {
  const LessonPreviewSheet({
    super.key,
    required this.planet,
    required this.state,
    required this.onStart,
    required this.onReview,
  });

  final GalaxyPlanet planet;
  final PlanetState state;
  final VoidCallback onStart;
  final VoidCallback onReview;

  bool get _cp => planet.isCheckpoint;

  @override
  Widget build(BuildContext context) {
    final eyebrow = _cp ? 'CHECKPOINT' : 'UNIT · ${planet.unitTitle.toUpperCase()}';
    final title = _cp ? 'Checkpoint: ${planet.unitTitle}' : planet.unitTitle;

    final String sub;
    final List<_Chip> chips;
    final String cta;
    final VoidCallback? onCta;
    switch (state) {
      case PlanetState.locked:
        sub = 'Locked — finish the earlier lessons first';
        chips = const [_Chip('Locked', SpacePalette.hudMuted)];
        cta = 'Locked';
        onCta = null;
      case PlanetState.done:
        sub = _cp
            ? 'Checkpoint cleared'
            : 'Lesson ${planet.lessonNo} · completed';
        chips = const [_Chip('Review · free', SpacePalette.tealText)];
        cta = 'Review';
        onCta = onReview;
      case PlanetState.active:
        sub = _cp
            ? 'Section checkpoint'
            : 'Lesson ${planet.lessonNo} of ${planet.lessons}';
        chips = _cp
            ? const [
                _Chip('+50 XP', SpacePalette.tealText),
                _Chip('Reward chest', SpacePalette.crownGold),
              ]
            : const [
                _Chip('−1 energy', SpacePalette.energyGlow),
                _Chip('+20 XP', SpacePalette.tealText),
              ];
        cta = 'Start lesson';
        onCta = onStart;
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [SpacePalette.sheetTop, SpacePalette.sheetBottom],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(RatelSpacing.radiusLg)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(RatelSpacing.xl, RatelSpacing.md,
              RatelSpacing.xl, RatelSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SpacePalette.hudText.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: RatelSpacing.lg),
              Text(eyebrow,
                  style: RatelType.caption.copyWith(
                      color: SpacePalette.hudMuted,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: RatelSpacing.xs),
              Text(title,
                  style:
                      RatelType.headline.copyWith(color: SpacePalette.hudText)),
              const SizedBox(height: RatelSpacing.xs),
              Text(sub,
                  style: RatelType.body.copyWith(color: SpacePalette.hudMuted)),
              const SizedBox(height: RatelSpacing.lg),
              Wrap(spacing: RatelSpacing.sm, children: chips),
              const SizedBox(height: RatelSpacing.xl),
              _Cta(label: cta, onPressed: onCta),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.color);
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: RatelSpacing.md, vertical: RatelSpacing.xs),
      decoration: BoxDecoration(
        color: SpacePalette.hudText.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
        border: Border.all(color: SpacePalette.hudText.withValues(alpha: 0.14)),
      ),
      child: Text(label, style: RatelType.caption.copyWith(color: color)),
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SizedBox(
      width: double.infinity,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(RatelSpacing.radiusMd),
          child: Ink(
            decoration: BoxDecoration(
              gradient: enabled
                  ? const LinearGradient(
                      colors: [SpacePalette.teal, SpacePalette.tealDeep])
                  : null,
              color: enabled ? null : SpacePalette.hudText.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(RatelSpacing.radiusMd),
            ),
            padding: const EdgeInsets.symmetric(vertical: RatelSpacing.md),
            child: Center(
              child: Text(label,
                  style: RatelType.label.copyWith(
                      color: enabled
                          ? SpacePalette.tealInk
                          : SpacePalette.hudMuted,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),
    );
  }
}
// Traceability: R-WT4
