import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../energy/energy_controller.dart';
import '../energy/energy_state.dart';

/// Learn tab home. The richer streak/continue surface lands next (R-L4/L8);
/// this slice gives a real entry into the lesson runner (R-L3) behind the
/// gentle-energy start gate, plus the energy HUD.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energy = ref.watch(energyControllerProvider);
    return RatelScreen(
      title: 'Learn',
      actions: [_EnergyHud(state: energy)],
      child: ListView(
        key: const Key('home-screen'),
        children: [
          const SizedBox(height: RatelSpacing.sm),
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
                  onPressed: () => _startLesson(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startLesson(BuildContext context, WidgetRef ref) {
    if (ref.read(energyControllerProvider.notifier).canStart()) {
      context.push('/lesson');
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
            semanticsLabel:
                state.isUnlimited ? 'Unlimited energy' : '${state.energy} energy',
          ),
        ],
      ),
    );
  }
}

/// Out-of-energy upsell (R-J6). Scroll-safe (S14 overflow gotcha): mistakes
/// never cost energy, so this only appears for a normal empty-tank lesson.
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
