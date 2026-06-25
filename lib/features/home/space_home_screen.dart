import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import '../energy/energy_controller.dart';
import '../energy/energy_gate.dart';
import '../energy/energy_state.dart';
import '../streak/streak_controller.dart';

/// Space "galaxy" Home — the Ratel-in-the-pod traveller over a deep-space
/// backdrop. This is the still foundation (Increment A): the dynamic planet
/// path, full HUD, daily strip, states and tier-gated FX land in the following
/// galaxy increments. Whole-app dark-space re-skin already follows the selected
/// world theme, so this screen reads `context.tokens` (Space tokens) + the
/// named [SpacePalette] for galaxy-specific chrome — no raw literals (R-N6).
class SpaceHomeScreen extends ConsumerWidget {
  const SpaceHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energy = ref.watch(energyControllerProvider);
    final streak = ref.watch(streakControllerProvider);
    return Scaffold(
      backgroundColor: SpacePalette.phoneBg,
      body: Stack(
        key: const Key('space-home'),
        children: [
          const SpaceBackdrop(seed: 7),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.lg),
              child: Column(
                children: [
                  const SizedBox(height: RatelSpacing.sm),
                  _SpaceHud(streak: streak.current, energy: energy),
                  const Spacer(),
                  const _Traveller(),
                  const SizedBox(height: RatelSpacing.xl),
                  Text('Your galaxy',
                      style: RatelType.headline
                          .copyWith(color: SpacePalette.hudText),
                      textAlign: TextAlign.center),
                  const SizedBox(height: RatelSpacing.xs),
                  Text('Fly the Ratel pod to your next lesson.',
                      style: RatelType.body
                          .copyWith(color: SpacePalette.hudMuted),
                      textAlign: TextAlign.center),
                  const Spacer(),
                  RatelButton(
                    label: 'Start lesson',
                    icon: Icons.play_arrow_rounded,
                    expand: true,
                    onPressed: () =>
                        maybeStartLesson(context, ref, review: false),
                  ),
                  const SizedBox(height: RatelSpacing.sm),
                  RatelButton(
                    label: 'Review mistakes',
                    icon: Icons.refresh_rounded,
                    kind: RatelButtonKind.secondary,
                    expand: true,
                    onPressed: () =>
                        maybeStartLesson(context, ref, review: true),
                  ),
                  const SizedBox(height: RatelSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpaceHud extends StatelessWidget {
  const _SpaceHud({required this.streak, required this.energy});
  final int streak;
  final EnergyState energy;

  @override
  Widget build(BuildContext context) {
    final energyLabel = energy.isUnlimited ? '∞' : '${energy.energy}';
    return Row(
      children: [
        const _HudChip(icon: Icons.public, label: 'EN', tint: SpacePalette.teal),
        const Spacer(),
        _HudChip(
            icon: Icons.local_fire_department,
            label: '$streak',
            tint: SpacePalette.checkpoint),
        const SizedBox(width: RatelSpacing.sm),
        _HudChip(
            icon: Icons.bolt, label: energyLabel, tint: SpacePalette.energyGlow),
        const SizedBox(width: RatelSpacing.sm),
        const _HudChip(
            icon: Icons.diamond_outlined,
            label: 'soon',
            tint: SpacePalette.gemB,
            muted: true),
        const SizedBox(width: RatelSpacing.sm),
        const _HudChip(icon: Icons.notifications_none, tint: SpacePalette.langText),
      ],
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip(
      {required this.icon, this.label, required this.tint, this.muted = false});
  final IconData icon;
  final String? label;
  final Color tint;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: RatelSpacing.sm, vertical: RatelSpacing.xs),
      decoration: BoxDecoration(
        color: SpacePalette.hudText.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
        border: Border.all(color: SpacePalette.hudText.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tint),
          if (label != null) ...[
            const SizedBox(width: RatelSpacing.xs),
            Text(label!,
                style: RatelType.caption.copyWith(
                    color: muted ? SpacePalette.hudMuted : SpacePalette.hudText)),
          ],
        ],
      ),
    );
  }
}

class _Traveller extends StatelessWidget {
  const _Traveller();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: RatelSpacing.md, vertical: RatelSpacing.xs),
          decoration: BoxDecoration(
            color: SpacePalette.teal,
            borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
            boxShadow: [
              BoxShadow(
                  color: SpacePalette.teal.withValues(alpha: 0.6),
                  blurRadius: 10,
                  spreadRadius: 1),
            ],
          ),
          child: Text('START',
              style: RatelType.label.copyWith(color: SpacePalette.tealInk)),
        ),
        const SizedBox(height: RatelSpacing.sm),
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: SpacePalette.teal.withValues(alpha: 0.5),
                  blurRadius: 24,
                  spreadRadius: 2),
            ],
          ),
          child: const RatelPod(size: Size(120, 82)),
        ),
      ],
    );
  }
}
// Traceability: R-WT2 R-WT4
