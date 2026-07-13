import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/shop/outfits_controller.dart';

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
        ? context.l10n.shopFreezeAtCap(max)
        : context.l10n.shopNotEnoughEarnCost(cost);
    final int energyRefillCost = learner.energyRefillCost;
    final bool canRefill = learner.canBuyEnergyRefill;
    final bool energyFull = snap.energy >= learner.energyCap;
    final int streakRepairCost = learner.streakRepairCost;
    final bool canRepair = learner.canRepairStreak;
    final bool streakLapsed = learner.streakLapsed;
    final int doubleXpCost = learner.doubleXpCost;
    final bool canBuyXp = learner.canBuyDoubleXp;
    final bool xpBoostActive = learner.isDoubleXpActive;
    final Duration? xpBoostLeft = learner.doubleXpRemaining;
    final OutfitState outfits = ref.watch(outfitsControllerProvider);
    final OutfitsController outfitsCtl =
        ref.read(outfitsControllerProvider.notifier);
    final BadgerOutfit equipped = ref.watch(equippedOutfitProvider);

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
          context.l10n.profileShop,
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
            RatelSectionHeader(label: context.l10n.shopPowerUps),
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
                            Text(context.l10n.shopStreakFreeze,
                                style: TextStyle(
                                    fontFamily: RatelFont.display,
                                    fontWeight: RatelType.extraBold,
                                    fontSize: RatelType.cardTitle,
                                    color: context.palette.ink)),
                            const SizedBox(height: 2),
                            Text(
                                context.l10n.shopStreakFreezeDesc,
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
                          label: context.l10n.shopOwned(snap.streakFreezes, max),
                          tone: RatelChipTone.teal),
                      const Spacer(),
                      RatelChip(
                          label: '$cost',
                          leadingEmoji: '💎',
                          tone: RatelChipTone.green,
                          filled: true),
                    ],
                  ),
                  const SizedBox(height: RatelSpace.md),
                  RatelButton(
                    label: atCap
                        ? context.l10n.shopMaxedOut
                        : context.l10n.shopBuyFor(cost),
                    onPressed: canBuy
                        ? () {
                            learner.buyStreakFreeze();
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(
                                  content: Text(context.l10n.shopFreezeAdded)));
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
              title: context.l10n.shopEnergyRefill,
              desc: context.l10n.shopEnergyRefillDesc,
              status: '⚡ ${snap.energy}/${learner.energyCap}',
              statusTone: RatelChipTone.amber,
              buttonLabel: energyFull
                  ? context.l10n.shopAlreadyFull
                  : context.l10n.shopBuyFor(energyRefillCost),
              onBuy: canRefill
                  ? () {
                      learner.buyEnergyRefill();
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                            content: Text(context.l10n.shopEnergyRefilled)));
                    }
                  : null,
              note: canRefill
                  ? null
                  : (energyFull
                      ? context.l10n.shopEnergyAlreadyFull
                      : context.l10n.shopNotEnoughEarnMore),
            ),
            const SizedBox(height: RatelSpace.cardGap),
            _PowerUpCard(
              emoji: '🛠️',
              title: context.l10n.shopStreakRepair,
              desc: context.l10n.shopStreakRepairDesc,
              status: streakLapsed
                  ? context.l10n.shopStreakLapsed
                  : context.l10n.shopStreakDays(snap.streakDays),
              statusTone:
                  streakLapsed ? RatelChipTone.coral : RatelChipTone.teal,
              buttonLabel: context.l10n.shopRepairFor(streakRepairCost),
              onBuy: canRepair
                  ? () {
                      learner.repairStreak();
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                            content: Text(context.l10n.shopStreakRestored)));
                    }
                  : null,
              note: canRepair
                  ? null
                  : (streakLapsed
                      ? context.l10n.shopNotEnoughEarnMore
                      : context.l10n.shopStreakSafe),
            ),
            const SizedBox(height: RatelSpace.cardGap),
            _PowerUpCard(
              emoji: '✨',
              title: context.l10n.shopDoubleXp,
              desc: context.l10n.shopDoubleXpDesc,
              status: xpBoostActive
                  ? context.l10n
                      .shopActiveLeft((xpBoostLeft?.inMinutes ?? 0) + 1)
                  : context.l10n.shopInactive,
              statusTone:
                  xpBoostActive ? RatelChipTone.green : RatelChipTone.neutral,
              buttonLabel: xpBoostActive
                  ? context.l10n.shopActive
                  : context.l10n.shopBuyFor(doubleXpCost),
              onBuy: canBuyXp
                  ? () {
                      learner.buyDoubleXp();
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                            content: Text(context.l10n.shopDoubleXpActive)));
                    }
                  : null,
              note: canBuyXp
                  ? null
                  : (xpBoostActive
                      ? context.l10n.shopBoostRunning
                      : context.l10n.shopNotEnoughEarnMore),
            ),
            const SizedBox(height: RatelSpace.lg),
            RatelSectionHeader(label: context.l10n.shopBadgerOutfits),
            const SizedBox(height: RatelSpace.sm),
            RatelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(equipped.emoji,
                          style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: RatelSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(context.l10n.shopYourBadger,
                                style: TextStyle(
                                    fontFamily: RatelFont.body,
                                    fontSize: RatelType.small,
                                    color: context.palette.muted)),
                            Text(ratelOutfitName(context, equipped.id),
                                style: TextStyle(
                                    fontFamily: RatelFont.display,
                                    fontWeight: RatelType.extraBold,
                                    fontSize: RatelType.cardTitle,
                                    color: context.palette.ink)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: RatelSpace.lg, color: context.palette.border),
                  for (final BadgerOutfit o in OutfitCatalogue.all)
                    _outfitRow(context, o, outfits, snap.diamonds, outfitsCtl),
                ],
              ),
            ),
            const SizedBox(height: RatelSpace.lg),
            Text(
              context.l10n.shopDiamondsNote,
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
                  Text(context.l10n.shopProBannerSub,
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
                Text(context.l10n.shopYourDiamonds,
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

  /// One badger-outfit row: emoji + name + price, and a trailing control —
  /// "Equipped" chip, a free "Equip" pill (owned), or a "N 💎" buy pill gated on
  /// affordability. Buying debits the real wallet and equips the outfit.
  Widget _outfitRow(BuildContext context, BadgerOutfit o, OutfitState st,
      int diamonds, OutfitsController ctl) {
    final bool owned = st.isOwned(o.id);
    final bool isOn = st.selected == o.id;
    final bool canAfford = diamonds >= o.cost;
    final Widget trailing;
    if (isOn) {
      trailing = RatelChip(label: context.l10n.shopEquipped, tone: RatelChipTone.teal);
    } else if (owned) {
      trailing = _pill(context, context.l10n.shopEquip, RatelColors.teal, RatelColors.onColor,
          () => ctl.equip(o.id));
    } else {
      trailing = _pill(
        context,
        '💎 ${o.cost}',
        canAfford ? RatelColors.green : context.palette.cream3,
        canAfford ? RatelColors.onColor : context.palette.muted,
        canAfford
            ? () {
                if (ctl.buy(o)) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                        content: Text(context.l10n.shopEquippedSnack(
                            ratelOutfitName(context, o.id), o.emoji))));
                }
              }
            : null,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RatelSpace.xs),
      child: Row(
        children: <Widget>[
          Text(o.emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(ratelOutfitName(context, o.id),
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.body,
                        color: context.palette.ink)),
                Text(o.cost == 0 ? context.l10n.shopFree : '${o.cost} 💎',
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.small,
                        color: context.palette.muted)),
              ],
            ),
          ),
          const SizedBox(width: RatelSpace.sm),
          trailing,
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, String label, Color bg, Color fg,
          VoidCallback? onTap) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: RatelSpace.md, vertical: RatelSpace.xs),
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(20)),
          child: Text(label,
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  fontWeight: RatelType.semiBold,
                  color: fg)),
        ),
      );
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
