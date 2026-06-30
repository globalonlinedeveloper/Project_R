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
    final int energyRefillCost = learner.energyRefillCost;
    final bool canRefill = learner.canBuyEnergyRefill;
    final bool energyFull = snap.energy >= learner.energyCap;
    final int streakRepairCost = learner.streakRepairCost;
    final bool canRepair = learner.canRepairStreak;
    final bool streakLapsed = learner.streakLapsed;

    return Scaffold(
      backgroundColor: context.palette.cream,
      appBar: AppBar(
        backgroundColor: context.palette.cream,
        surfaceTintColor: context.palette.cream,
        elevation: 0,
        leading: IconButton(
          icon: Icon(RatelIcons.arrowBack, color: context.palette.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Shop',
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
          padding: const EdgeInsets.fromLTRB(RatelSpace.screen, RatelSpace.lg,
              RatelSpace.screen, RatelSpace.xl),
          children: <Widget>[
            _balance(context, snap.diamonds),
            const SizedBox(height: RatelSpace.lg),
            _proBanner(context),
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
                            Text('Streak Freeze',
                                style: TextStyle(
                                    fontFamily: RatelFont.display,
                                    fontWeight: RatelType.extraBold,
                                    fontSize: RatelType.cardTitle,
                                    color: context.palette.ink)),
                            const SizedBox(height: 2),
                            Text(
                                'Protects your streak for one missed day. Spent '
                                'automatically when you miss your daily goal.',
                                style: TextStyle(
                                    fontFamily: RatelFont.body,
                                    fontSize: RatelType.small,
                                    color: context.palette.muted)),
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
                          style: TextStyle(
                              fontFamily: RatelFont.display,
                              fontWeight: RatelType.extraBold,
                              fontSize: RatelType.body,
                              color: context.palette.ink)),
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
                        style: TextStyle(
                            fontFamily: RatelFont.body,
                            fontSize: RatelType.caption,
                            color: context.palette.muted)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: RatelSpace.cardGap),
            _PowerUpCard(
              emoji: '⚡',
              title: 'Energy Refill',
              desc: 'Top your energy straight back up to full. Energy is '
                  'display-only — lessons never block.',
              status: '⚡ ${snap.energy}/${learner.energyCap}',
              statusTone: RatelChipTone.amber,
              buttonLabel:
                  energyFull ? 'Already full' : 'Buy for $energyRefillCost 💎',
              onBuy: canRefill
                  ? () {
                      learner.buyEnergyRefill();
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(const SnackBar(
                            content: Text('Energy refilled ⚡')));
                    }
                  : null,
              note: canRefill
                  ? null
                  : (energyFull
                      ? 'Your energy is already full.'
                      : 'Not enough 💎 — earn more by finishing lessons.'),
            ),
            const SizedBox(height: RatelSpace.cardGap),
            _PowerUpCard(
              emoji: '🛠️',
              title: 'Streak Repair',
              desc: 'Lost your streak? Restore it to its previous length and '
                  'keep the run going.',
              status: streakLapsed
                  ? 'Streak lapsed'
                  : '🔥 ${snap.streakDays}-day streak',
              statusTone:
                  streakLapsed ? RatelChipTone.coral : RatelChipTone.teal,
              buttonLabel: 'Repair for $streakRepairCost 💎',
              onBuy: canRepair
                  ? () {
                      learner.repairStreak();
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(const SnackBar(
                            content: Text('Streak restored 🔥')));
                    }
                  : null,
              note: canRepair
                  ? null
                  : (streakLapsed
                      ? 'Not enough 💎 — earn more by finishing lessons.'
                      : 'Your streak is safe — nothing to repair right now.'),
            ),
            const SizedBox(height: RatelSpace.lg),
            Text(
              'A real-money 💎 top-up is coming. Diamonds are earned by '
              'finishing lessons and meeting your daily goal, and every '
              'power-up here spends them for real — nothing is faked.',
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: context.palette.muted,
                  height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _proBanner(BuildContext context) => RatelCard(
        gradient: const LinearGradient(
            colors: <Color>[RatelColors.gold, RatelColors.amber],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        onTap: () => context.push('/paywall?source=shop'),
        child: Row(
          children: <Widget>[
            const Text('\u{1F9A1}', style: TextStyle(fontSize: 30)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('RATEL PRO',
                      style: TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.cardTitle,
                          color: RatelColors.onColor)),
                  Text('Live AI, no ads, offline \u00B7 Try 7 days free',
                      style: TextStyle(
                          fontFamily: RatelFont.body,
                          fontSize: RatelType.small,
                          color: RatelColors.onColor.withValues(alpha: 0.95))),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _balance(BuildContext context, int diamonds) {
    return RatelCard(
      child: Row(
        children: <Widget>[
          const Text('💎', style: TextStyle(fontSize: 28)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Your diamonds',
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.small,
                        color: context.palette.muted)),
                Text('$diamonds',
                    style: TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.extraBold,
                        fontSize: RatelType.screenTitle,
                        color: context.palette.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


/// A Shop power-up card (E1): emoji + title + description, a status chip, and a
/// buy button that is disabled (with an honest [note]) when the purchase is not
/// applicable or unaffordable. Mirrors the streak-freeze card's layout.
class _PowerUpCard extends StatelessWidget {
  const _PowerUpCard({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.status,
    required this.statusTone,
    required this.buttonLabel,
    required this.onBuy,
    this.note,
  });

  final String emoji;
  final String title;
  final String desc;
  final String status;
  final RatelChipTone statusTone;
  final String buttonLabel;
  final VoidCallback? onBuy;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return RatelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 34)),
              const SizedBox(width: RatelSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title,
                        style: TextStyle(
                            fontFamily: RatelFont.display,
                            fontWeight: RatelType.extraBold,
                            fontSize: RatelType.cardTitle,
                            color: context.palette.ink)),
                    const SizedBox(height: 2),
                    Text(desc,
                        style: TextStyle(
                            fontFamily: RatelFont.body,
                            fontSize: RatelType.small,
                            color: context.palette.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RatelSpace.md),
          Row(children: <Widget>[RatelChip(label: status, tone: statusTone)]),
          const SizedBox(height: RatelSpace.md),
          RatelButton(label: buttonLabel, onPressed: onBuy),
          if (note != null) ...<Widget>[
            const SizedBox(height: RatelSpace.xs),
            Text(note!,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.caption,
                    color: context.palette.muted)),
          ],
        ],
      ),
    );
  }
}
