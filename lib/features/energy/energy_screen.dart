import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/economy/energy.dart';

/// Energy screen (⚡) — design #12 / lane A-E (`/energy`).
///
/// INFO-ONLY, NON-BLOCKING (owner-locked S60 / R-I3). Energy is a display-only
/// pace signal that NEVER gates a lesson — the design's `energygate` is
/// deliberately not built (`services/economy/energy.dart` header). This screen
/// therefore explains, honestly, that learning is never blocked.
///
/// REAL data: the current [LearnerSnapshot.energy] and the real
/// [EnergyModel.cap] / [EnergyModel.lessonCost] (the same values the top-bar ⚡
/// chip reads). PRO shows ∞ (the design's unlimited).
///
/// What is DELIBERATELY NOT shown (owner-taste §9.4 is unresolved — the app
/// won't commit to a number it can't back): the "NEXT ⚡ IN 35:10" countdown,
/// the "refills 1 every 60 min" interval copy, and the "Refill now · 350"
/// price. Regeneration IS real (time-based toward the cap) but the exact
/// cadence/price are not finalised, so there is an honest note instead of a
/// fabricated timer or figure. The "Preview the empty state (demo)" affordance
/// is omitted because there is no out-of-energy gate to preview.
///
/// Reached from the Home top-bar ⚡ chip (A-E1 wiring).
class EnergyScreen extends ConsumerWidget {
  const EnergyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final bool isPro = ref.watch(isProProvider);
    final int energy = snap.energy;
    const int cap = EnergyModel.cap;

    return Scaffold(
      backgroundColor: context.palette.cream,
      appBar: AppBar(
        backgroundColor: context.palette.cream,
        surfaceTintColor: context.palette.cream,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: RatelSpace.md),
          child: GestureDetector(
            key: const ValueKey<String>('energy-back'),
            onTap: () => context.pop(),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: context.palette.white,
              child: Icon(RatelIcons.arrowBack,
                  color: context.palette.ink, size: 20),
            ),
          ),
        ),
        title: Text(
          context.l10n.energyTitle,
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            color: context.palette.ink,
            fontSize: RatelType.cardTitle,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          key: const ValueKey<String>('screen-energy'),
          padding: const EdgeInsets.fromLTRB(RatelSpace.screen, RatelSpace.lg,
              RatelSpace.screen, RatelSpace.xl),
          children: <Widget>[
            const SizedBox(height: RatelSpace.md),
            const Center(child: Text('⚡', style: TextStyle(fontSize: 64))),
            const SizedBox(height: RatelSpace.md),
            Center(
              child: Text(
                isPro
                    ? context.l10n.energyUnlimitedLabel
                    : context.l10n.energyCountLabel(energy, cap),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: RatelFont.display,
                  fontWeight: RatelType.extraBold,
                  fontSize: RatelType.screenTitle,
                  color: context.palette.ink,
                ),
              ),
            ),
            const SizedBox(height: RatelSpace.xs),
            Center(
              child: Text(
                context.l10n.energyLessonCost,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.body,
                  color: context.palette.muted,
                ),
              ),
            ),
            const SizedBox(height: RatelSpace.xl),
            if (isPro)
              _infoCard(
                context,
                emoji: '♾️',
                title: context.l10n.energyProTitle,
                body: context.l10n.energyProBody,
              )
            else ...<Widget>[
              _infoCard(
                context,
                emoji: '🌱',
                title: context.l10n.energyNeverBlocksTitle,
                body: context.l10n.energyNeverBlocksBody,
              ),
              const SizedBox(height: RatelSpace.md),
              _infoCard(
                context,
                emoji: '⏳',
                title: null,
                body: context.l10n.energyRegenNote,
              ),
            ],
            const SizedBox(height: RatelSpace.lg),
            RatelButton(
              label: context.l10n.energyPracticeFree,
              variant: RatelButtonVariant.success,
              onPressed: () => context.push('/practice'),
            ),
            if (!isPro) ...<Widget>[
              const SizedBox(height: RatelSpace.md),
              RatelButton(
                label: context.l10n.energyGoProUnlimited,
                variant: RatelButtonVariant.secondary,
                onPressed: () => context.push('/paywall?source=energy'),
              ),
            ],
            const SizedBox(height: RatelSpace.lg),
            Text(
              context.l10n.energyHonestNote,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.small,
                height: 1.4,
                color: context.palette.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
    BuildContext context, {
    required String emoji,
    required String? title,
    required String body,
  }) {
    return RatelCard(
      color: context.palette.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title != null) ...<Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: RatelFont.display,
                      fontWeight: RatelType.extraBold,
                      fontSize: RatelType.body,
                      color: context.palette.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  body,
                  style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    height: 1.35,
                    color: context.palette.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
