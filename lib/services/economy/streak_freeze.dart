import 'diamonds.dart';

/// Pure, clockless streak-freeze economics — the FIRST real diamond SPEND sink
/// (R-I4 gems spend side · R-I2 streak-freeze).
///
/// A streak-freeze is a consumable bought with earned 💎. Holding one lets a
/// single missed day pass WITHOUT the goal-gated streak (R-I2) lapsing: the
/// [LearnerController]'s day-roll spends one freeze per missed day automatically
/// (the calendar-day coverage math lives in `StreakModel.applyFreezes`). This
/// model owns only the PURCHASE transition — price + inventory cap — and holds
/// no clock and no balance; the controller owns the durable 💎 and freeze counts
/// and their persistence.
///
/// HONESTY (design spec §6): buying and auto-consuming a freeze is REAL and
/// durable end to end. A real-money 💎 top-up (IAP) and other Shop consumables
/// stay §6 owner-decisions with no engine — deliberately NOT faked.
class StreakFreezeModel {
  const StreakFreezeModel();

  /// 💎 price of one streak-freeze.
  static const int cost = 10;

  /// Most freezes a learner may hold at once (a small Duolingo-style cap).
  static const int maxHeld = 2;

  final DiamondsModel _wallet = const DiamondsModel();

  /// Whether one freeze can be bought now: room under [maxHeld] AND the wallet
  /// holds at least [cost] 💎.
  bool canBuy({required int diamonds, required int held}) =>
      held < maxHeld && _wallet.canSpend(balance: diamonds, amount: cost);

  /// The (diamonds, held) after buying one freeze: debits [cost] and adds one
  /// to inventory when [canBuy], else returns both UNCHANGED (callers gate the
  /// buy control on [canBuy] for honest feedback).
  ({int diamonds, int held}) buy({required int diamonds, required int held}) =>
      canBuy(diamonds: diamonds, held: held)
          ? (
              diamonds: _wallet.spend(balance: diamonds, amount: cost),
              held: held + 1,
            )
          : (diamonds: diamonds, held: held);
}
