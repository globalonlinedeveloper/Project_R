import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import '../energy/energy_controller.dart';
import '../energy/energy_gate.dart';
import '../energy/energy_state.dart';
import '../settings/settings_controller.dart';
import '../streak/streak_controller.dart';

/// The galaxy layout is deterministic, so build it once and share it.
final galaxyLayoutProvider = Provider<GalaxyLayout>((ref) => generateGalaxy());

/// Space "galaxy" Home: the scrollable planet path with the Ratel pod on the
/// current lesson, an animated-ready HUD overlay, and a course-progress / free-
/// review bottom bar. `activeIdx` is REAL (lessons completed); the energy gate +
/// free reviews are preserved. Whole-app dark-space re-skin follows the selected
/// world theme; galaxy chrome reads named [SpacePalette] colours (no raw
/// literals — R-N6). The full daily strip, lesson-preview sheet, Lv/XP bar,
/// locate FAB and tier-gated FX land in the following galaxy increments.
class SpaceHomeScreen extends ConsumerWidget {
  const SpaceHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energy = ref.watch(energyControllerProvider);
    final streak = ref.watch(streakControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final layout = ref.watch(galaxyLayoutProvider);

    final active = energy.lessonsCompleted.clamp(0, layout.count - 1);
    final tier = effectiveMotionTier(
      osReduceMotion: MediaQuery.maybeOf(context)?.disableAnimations ?? false,
      perfTier: PerfTier.high,
      motionPreference: settings.motion,
    );

    void onPlanetTap(GalaxyPlanet planet, int index) {
      if (index > active) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text('Finish the earlier lessons first',
                style: RatelType.body.copyWith(color: SpacePalette.hudText)),
            backgroundColor: SpacePalette.sheetTop,
          ));
        return;
      }
      maybeStartLesson(context, ref, review: index < active);
    }

    return Scaffold(
      backgroundColor: SpacePalette.phoneBg,
      body: Stack(
        key: const Key('space-home'),
        children: [
          Positioned.fill(
            child: GalaxyView(
              layout: layout,
              activeIdx: active,
              tier: tier,
              onPlanetTap: onPlanetTap,
            ),
          ),
          // top scrim so planets fade under the header (matches the prototype)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: IgnorePointer(child: _TopScrim()),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  RatelSpacing.lg, RatelSpacing.sm, RatelSpacing.lg, 0),
              child: _SpaceHud(streak: streak.current, energy: energy),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _SpaceBottomBar(
              done: active,
              total: layout.count,
              lessons: energy.lessonsCompleted,
              onReview: () => maybeStartLesson(context, ref, review: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopScrim extends StatelessWidget {
  const _TopScrim();
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            SpacePalette.phoneBg,
            SpacePalette.phoneBg.withValues(alpha: 0),
          ],
          stops: const [0.55, 1],
        ),
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

class _SpaceBottomBar extends StatelessWidget {
  const _SpaceBottomBar({
    required this.done,
    required this.total,
    required this.lessons,
    required this.onReview,
  });
  final int done;
  final int total;
  final int lessons;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            SpacePalette.phoneBg,
            SpacePalette.phoneBg.withValues(alpha: 0),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(RatelSpacing.lg, RatelSpacing.md,
              RatelSpacing.lg, RatelSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('${(pct * 100).round()}% · galaxy',
                      style: RatelType.caption
                          .copyWith(color: SpacePalette.tealText)),
                  const Spacer(),
                  Text('$lessons lessons',
                      style: RatelType.caption
                          .copyWith(color: SpacePalette.hudMuted)),
                ],
              ),
              const SizedBox(height: RatelSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: SpacePalette.hudText.withValues(alpha: 0.12),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(SpacePalette.teal),
                ),
              ),
              const SizedBox(height: RatelSpacing.sm),
              TextButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.refresh_rounded,
                    size: 18, color: SpacePalette.tealText),
                label: Text('Review mistakes · free',
                    style: RatelType.label
                        .copyWith(color: SpacePalette.tealText)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Traceability: R-WT4
