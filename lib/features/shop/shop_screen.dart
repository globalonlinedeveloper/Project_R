import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';

/// Shop (💎) — design spec §4.5 / §6. The FIRST real diamond SPEND sink: buy a
/// streak-freeze with earned 💎 (R-I2 streak-freeze · R-I4 gems spend side).
///
/// HONESTY (charter "don't fake depth"): the streak-freeze purchase is REAL and
/// durable — it debits the live 💎 wallet and the freeze is auto-spent to cover
/// a missed day (see [LearnerController]). The 💎 balance, the owned count and
/// the buy control's enabled/disabled state are all real engine state. A
/// real-money 💎 top-up (IAP) and other consumables stay §6 owner-decisions —
/// shown here as an honest note, never a fake storefront.
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final LearnerController learner =
        ref.read(learnerControllerProvider.notifier);
    final int cost = learner.streakFreezeCost;
    final int max = learner.maxStreakFreezes;
    final bool atCap = snap.streakFreezes >= max;
    final bool canBuy = learner.canBuyStreakFreeze;
    final String reason = atCap
        ? 'You already hold the most freezes ($max).'
        : 'Not enough 💎 — earn $cost by finishing lessons.';

    return Scaffold(
      backgroundColor: RatelColors.cream,
      appBar: AppBar(
        backgroundColor: RatelColors.cream,
        surfaceTintColor: RatelColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: RatelColors.ink),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Shop',
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            color: RatelColors.ink,
            fontSize: RatelType.cardTitle,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(RatelSpace.screen, RatelSpace.lg,
              RatelSpace.screen, RatelSpace.xl),
          children: <Widget>[
            _balance(snap.diamonds),
            const SizedBox(height: RatelSpace.lg),
            const RatelSectionHeader(label: 'Power-ups'),
            const SizedBox(height: RatelSpace.sm),
            RatelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('💪', style: TextStyle(fontSize: 34)),
                      const SizedBox(width: RatelSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('Streak Freeze',
                                style: TextStyle(
                                    fontFamily: RatelFont.display,
                                    fontWeight: RatelType.extraBold,
                                    fontSize: RatelType.cardTitle,
                                    color: RatelColors.ink)),
                            const SizedBox(height: 2),
                            const Text(
                                'Protects your streak for one missed day. Spent '
                                'automatically when you miss your daily goal.',
                                style: TextStyle(
                                    fontFamily: RatelFont.body,
                                    fontSize: RatelType.small,
                                    color: RatelColors.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RatelSpace.md),
                  Row(
                    children: <Widget>[
                      RatelChip(
                          label: 'Owned ${snap.streakFreezes}/$max',
                          tone: RatelChipTone.teal),
                      const Spacer(),
                      Text('$cost 💎',
                          style: const TextStyle(
                              fontFamily: RatelFont.display,
                              fontWeight: RatelType.extraBold,
                              fontSize: RatelType.body,
                              color: RatelColors.ink)),
                    ],
                  ),
                  const SizedBox(height: RatelSpace.md),
                  RatelButton(
                    label: atCap ? 'Maxed out' : 'Buy for $cost 💎',
                    onPressed: canBuy
                        ? () {
                            learner.buyStreakFreeze();
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(const SnackBar(
                                  content: Text('Streak freeze added 💪')));
                          }
                        : null,
                  ),
                  if (!canBuy) ...<Widget>[
                    const SizedBox(height: RatelSpace.xs),
                    Text(reason,
                        style: const TextStyle(
                            fontFamily: RatelFont.body,
                            fontSize: RatelType.caption,
                            color: RatelColors.muted)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: RatelSpace.lg),
            const Text(
              'More power-ups and a 💎 top-up are coming. Diamonds are earned by '
              'finishing lessons and meeting your daily goal — nothing here is '
              'faked.',
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: RatelColors.muted,
                  height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _balance(int diamonds) {
    return RatelCard(
      child: Row(
        children: <Widget>[
          const Text('💎', style: TextStyle(fontSize: 28)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Your diamonds',
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.small,
                        color: RatelColors.muted)),
                Text('$diamonds',
                    style: const TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.extraBold,
                        fontSize: RatelType.screenTitle,
                        color: RatelColors.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
