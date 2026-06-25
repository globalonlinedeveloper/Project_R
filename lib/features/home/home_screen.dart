import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import '../energy/energy_controller.dart';
import '../energy/energy_gate.dart';
import '../energy/energy_state.dart';
import '../settings/settings_controller.dart';
import '../streak/streak_controller.dart';
import 'space_home_screen.dart';

/// Learn tab home. Renders the active world: the Classic teal/honey dashboard by
/// default, or the Space "galaxy" home when the Space world theme is selected
/// (Profile › Settings). Switching is app-wide + persisted, so this swap follows
/// the same provider every other screen reads.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSpace = ref.watch(
        settingsControllerProvider.select((s) => s.world == WorldThemeId.space));
    return isSpace ? const SpaceHomeScreen() : const ClassicHomeScreen();
  }
}

/// The Classic (default) Learn dashboard (R-L4/L8): streak banner, the daily
/// lesson entry behind the gentle-energy gate, and an always-free "Practice your
/// mistakes" review entry. Energy HUD lives in the app bar. Unchanged from the
/// shipped home so its widget contract holds.
class ClassicHomeScreen extends ConsumerWidget {
  const ClassicHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energy = ref.watch(energyControllerProvider);
    final streak = ref.watch(streakControllerProvider);
    return RatelScreen(
      title: 'Learn',
      actions: [_EnergyHud(state: energy)],
      child: ListView(
        key: const Key('home-screen'),
        children: [
          const SizedBox(height: RatelSpacing.sm),
          _StreakBanner(current: streak.current, longest: streak.longest),
          const SizedBox(height: RatelSpacing.xl),
          Text('Your lessons', style: RatelType.headline),
          const SizedBox(height: RatelSpacing.lg),
          RatelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily lesson', style: RatelType.title),
                const SizedBox(height: RatelSpacing.xs),
                Text(
                  'A few quick exercises to keep your streak going.',
                  style: RatelType.body,
                ),
                const SizedBox(height: RatelSpacing.lg),
                RatelButton(
                  label: 'Start lesson',
                  icon: Icons.play_arrow_rounded,
                  expand: true,
                  onPressed: () => maybeStartLesson(context, ref, review: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: RatelSpacing.lg),
          RatelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text('Practice your mistakes',
                            style: RatelType.title)),
                    _FreeTag(),
                  ],
                ),
                const SizedBox(height: RatelSpacing.xs),
                Text(
                  'Reviews are always free — they never cost energy.',
                  style: RatelType.body,
                ),
                const SizedBox(height: RatelSpacing.lg),
                RatelButton(
                  label: 'Review mistakes',
                  icon: Icons.refresh_rounded,
                  kind: RatelButtonKind.secondary,
                  expand: true,
                  onPressed: () => maybeStartLesson(context, ref, review: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.current, required this.longest});
  final int current;
  final int longest;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final started = current > 0;
    return RatelCard(
      child: Row(
        children: [
          Icon(Icons.local_fire_department,
              color: started ? t.accent : t.outline, size: 32),
          const SizedBox(width: RatelSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  started ? '$current day streak' : 'Start your streak',
                  style: RatelType.title,
                ),
                const SizedBox(height: RatelSpacing.xs),
                Text(
                  started
                      ? 'Best: $longest days'
                      : 'Finish a lesson today to begin',
                  style: RatelType.caption.copyWith(color: t.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeTag extends StatelessWidget {
  const _FreeTag();
  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: RatelSpacing.sm, vertical: RatelSpacing.xs),
      decoration: BoxDecoration(
        color: t.success,
        borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
      ),
      child: Text('FREE', style: RatelType.caption.copyWith(color: t.onSuccess)),
    );
  }
}

class _EnergyHud extends StatelessWidget {
  const _EnergyHud({required this.state});
  final EnergyState state;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final label = state.isUnlimited ? '∞' : '${state.energy}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RatelSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, color: t.accent, size: 20),
          const SizedBox(width: RatelSpacing.xs),
          Text(
            label,
            style: RatelType.bodyStrong,
            semanticsLabel: state.isUnlimited
                ? 'Unlimited energy'
                : '${state.energy} energy',
          ),
        ],
      ),
    );
  }
}
