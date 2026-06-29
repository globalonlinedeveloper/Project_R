/// Pure, clockless diamond-wallet arithmetic (R-I4 — gems/diamonds soft
/// currency, EARN side).
///
/// Diamonds are an EARNED soft currency: every diamond traces to a REAL learner
/// action (completing a lesson, or meeting the daily XP goal). Like the
/// `learning` engines, this model holds no clock and no balance — a caller
/// passes the current balance plus the event and receives the new balance. The
/// per-event amounts are named constants so the reward curve is auditable and
/// tunable in one place.
///
/// SCOPE (design spec §6, honestly flagged): the EARN side plus the wallet's
/// debit primitive ([canSpend] / [spend]). The FIRST real spend sink built on
/// it is the streak-freeze (`StreakFreezeModel`, R-I2). A real-money IAP 💎
/// top-up and other Shop consumables remain owner-decision §6 items with no
/// engine, deliberately NOT faked here.
enum DiamondEvent {
  /// A lesson was completed (R-O1 lesson crossing).
  lessonCompleted,

  /// The daily XP goal was met for the first time today (the same once-per-day
  /// goal-gated crossing that advances the streak — R-I2 / R-I7).
  dailyGoalMet,
}

/// Computes diamond reward amounts. Holds no state: the [LearnerController]
/// owns the balance and its durable persistence.
class DiamondsModel {
  const DiamondsModel();

  /// 💎 awarded for completing one lesson.
  static const int lessonReward = 1;

  /// 💎 awarded the first time the daily goal is met on a given day.
  static const int goalMetReward = 5;

  /// Diamonds earned by a single [event].
  int reward(DiamondEvent event) => switch (event) {
        DiamondEvent.lessonCompleted => lessonReward,
        DiamondEvent.dailyGoalMet => goalMetReward,
      };

  /// The wallet balance after [event] is credited to [balance]. A negative
  /// input is treated as empty — the wallet never drops below zero.
  int award({required int balance, required DiamondEvent event}) =>
      (balance < 0 ? 0 : balance) + reward(event);

  /// Whether [balance] can cover a spend of [amount] 💎 (a non-negative price).
  bool canSpend({required int balance, required int amount}) =>
      amount >= 0 && balance >= amount;

  /// The wallet balance after spending [amount] 💎 from [balance]. Returns the
  /// balance UNCHANGED when it cannot be afforded or [amount] is negative — a
  /// spend never drives the wallet below zero, and the caller gates user
  /// feedback on [canSpend]. The wallet's debit primitive behind the first real
  /// spend sink, the streak-freeze (R-I2 · R-I4 spend side).
  int spend({required int balance, required int amount}) =>
      canSpend(balance: balance, amount: amount) ? balance - amount : balance;
}
