import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../energy/energy_controller.dart';
import '../energy/energy_state.dart';
import '../streak/streak_controller.dart';

/// Learn tab home (R-L4/L8): streak banner, the daily lesson entry behind the
/// gentle-energy gate, and an always-free "Practice your mistakes" review entry.
/// Energy HUD lives in the app bar. Learner state stays in-memory stubs (R-O1).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
                  onPressed: () => _start(context, ref, review: false),
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
                    Expanded(child: Text('Practice your mistakes', style: RatelType.title)),
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
                  onPressed: () => _start(context, ref, review: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _start(BuildContext context, WidgetRef ref, {required bool review}) {
    if (ref.read(energyControllerProvider.notifier).canStart(isReview: review)) {
      context.push(review ? '/lesson?review=1' : '/lesson');
    } else {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: context.tokens.surface,
        isScrollControlled: true,
        builder: (ctx) => OutOfEnergySheet(
          onWatchAd: () {
            ref.read(energyControllerProvider.notifier).refill();
            Navigator.of(ctx).pop();
          },
          onGoPro: () {
            ref.read(energyControllerProvider.notifier).setPro(true);
            Navigator.of(ctx).pop();
          },
        ),
      );
    }
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
                  started ? 'Best: $longest days' : 'Finish a lesson today to begin',
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

/// Out-of-energy upsell (R-J6). Scroll-safe; only appears for a normal
/// empty-tank lesson (mistakes + reviews never cost energy).
class OutOfEnergySheet extends StatelessWidget {
  const OutOfEnergySheet({
    super.key,
    required this.onWatchAd,
    required this.onGoPro,
  });
  final VoidCallback onWatchAd;
  final VoidCallback onGoPro;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(RatelSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.bolt, color: t.accent, size: 40),
            const SizedBox(height: RatelSpacing.sm),
            Text('Out of energy',
                style: RatelType.headline, textAlign: TextAlign.center),
            const SizedBox(height: RatelSpacing.sm),
            Text(
              'Mistakes never cost energy. Refill to keep going, or go Pro for unlimited.',
              style: RatelType.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RatelSpacing.xl),
            RatelButton(
              label: 'Watch ad to refill',
              icon: Icons.ondemand_video_outlined,
              expand: true,
              onPressed: onWatchAd,
            ),
            const SizedBox(height: RatelSpacing.sm),
            RatelButton(
              label: 'Go Pro — unlimited',
              kind: RatelButtonKind.secondary,
              expand: true,
              onPressed: onGoPro,
            ),
          ],
        ),
      ),
    );
  }
}
