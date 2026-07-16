import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/services/economy/economy.dart';

/// The honest Diamonds surface (A-H4 · design #13). A bottom sheet opened from
/// the 💎 top-bar chip. It shows the learner's REAL earned-💎 balance plus an
/// honest note about how diamonds are earned and where they are spent, and a
/// single "Open Shop" action routing to the real [ShopScreen] (`/shop`) — the
/// live spend surface (streak-freeze, energy refill, outfits).
///
/// HONESTY (charter "don't fake depth"): [balance] is the REAL wallet value
/// from `LearnerSnapshot.diamonds` (R-I4 earn side, durable via `user_course`).
/// Nothing here is faked — no invented price, no fake storefront, no simulated
/// top-up. The earn line quotes the real [DiamondsModel] reward constants so it
/// can never drift from the engine. A real-money 💎 top-up (IAP) stays an
/// owner-decision §6 item, surfaced honestly in the Shop, never here.
void showDiamondsSheet(BuildContext context, int balance) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.palette.white,
    shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(RatelRadius.featureLg))),
    builder: (BuildContext sheetContext) => _DiamondsSheet(balance: balance),
  );
}

class _DiamondsSheet extends StatelessWidget {
  const _DiamondsSheet({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    // The real per-event 💎 rewards, quoted from the engine so the honest earn
    // line never drifts from what the wallet actually credits.
    const DiamondsModel model = DiamondsModel();
    final int lessonReward = model.reward(DiamondEvent.lessonCompleted);
    final int goalReward = model.reward(DiamondEvent.dailyGoalMet);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(RatelSpace.xl),
        child: Column(
          key: const ValueKey<String>('diamonds-sheet'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              context.l10n.diamondsSheetTitle,
              style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.caption,
                fontWeight: RatelType.extraBold,
                letterSpacing: 1,
                color: context.palette.muted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.diamondsSheetCount(balance),
              style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                fontSize: RatelType.screenTitle,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: RatelSpace.xs),
            Text(
              context.l10n.diamondsSheetBody,
              style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.body,
                height: 1.35,
                color: context.palette.muted,
              ),
            ),
            const SizedBox(height: RatelSpace.md),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RatelChip(
                  label: '$balance',
                  leadingEmoji: '💎',
                  tone: RatelChipTone.teal,
                ),
              ],
            ),
            const SizedBox(height: RatelSpace.md),
            Text(
              context.l10n.diamondsSheetEarn(lessonReward, goalReward),
              style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.small,
                height: 1.4,
                color: context.palette.muted,
              ),
            ),
            const SizedBox(height: RatelSpace.lg),
            RatelButton(
              label: context.l10n.diamondsOpenShop,
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/shop');
              },
            ),
            const SizedBox(height: RatelSpace.sm),
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: RatelSpace.sm, horizontal: RatelSpace.lg),
                  child: Text(
                    context.l10n.diamondsClose,
                    style: TextStyle(
                      fontFamily: RatelFont.display,
                      fontWeight: RatelType.extraBold,
                      fontSize: RatelType.body,
                      color: context.palette.muted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
