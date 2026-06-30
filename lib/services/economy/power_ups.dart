/// Prices for the Shop's diamond SPEND sinks beyond the streak-freeze (E1 ·
/// R-I3 energy · R-I4 gems-spend). Pure constants: the `LearnerController` owns
/// the 💎 balance + the energy / streak state and gates every buy on
/// affordability AND applicability, so nothing here is faked.
class PowerUpPrices {
  const PowerUpPrices._();

  /// 💎 to refill ⚡ energy back to the cap (R-I3 display-only energy).
  static const int energyRefillCost = 5;

  /// 💎 to restore a lapsed streak to its prior length (R-I2).
  static const int streakRepairCost = 20;

  /// 💎 to activate a timed Double-XP boost (R-I4 spend · R-I1 XP).
  static const int doubleXpCost = 15;

  /// How long a Double-XP boost lasts once bought.
  static const Duration doubleXpDuration = Duration(minutes: 15);

  /// The XP multiplier applied while a Double-XP boost is active.
  static const int doubleXpMultiplier = 2;
}
