import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';
import 'energy_controller.dart';

/// Shared start-lesson gate (R-J6/R-L3): starts the lesson unless it's a normal
/// empty-tank lesson, in which case the out-of-energy upsell is shown. Used by
/// both the Classic and Space home traveller CTAs so the gate is identical.
void maybeStartLesson(BuildContext context, WidgetRef ref,
    {required bool review}) {
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
