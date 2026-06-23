/// Gentle-energy economy (R-J* / R-L3). Pure + unit-tested; in-memory only
/// (learner state stays interfaces/stubs until Stage 3 — R-O1).
///
/// Principles: mistakes NEVER cost energy; the start gate blocks ONLY a normal
/// empty-tank lesson; reviews and the first daily lesson are always free;
/// exactly one energy is spent on a normal lesson commit; Pro is unlimited.
class EnergyConfig {
  const EnergyConfig({
    this.maxEnergy = 5,
    this.lessonCost = 1,
    this.interstitialEvery = 3,
  });

  final int maxEnergy;
  final int lessonCost;

  /// Free-tier interstitial cadence (every Nth completed lesson). 0 disables.
  final int interstitialEvery;
}

class EnergyState {
  const EnergyState({
    this.energy = 5,
    this.isPro = false,
    this.dailyFreeUsed = false,
    this.lessonsCompleted = 0,
    this.config = const EnergyConfig(),
  });

  final int energy;
  final bool isPro;

  /// Whether the always-free first daily (normal) lesson has been used.
  final bool dailyFreeUsed;
  final int lessonsCompleted;
  final EnergyConfig config;

  bool get isUnlimited => isPro;

  /// A lesson can START unless it is a NORMAL lesson on an empty tank.
  /// Pro, reviews, and the first daily lesson are always allowed.
  bool canStart({required bool isReview}) {
    if (isPro || isReview || !dailyFreeUsed) return true;
    return energy >= config.lessonCost;
  }

  EnergyState copyWith({
    int? energy,
    bool? isPro,
    bool? dailyFreeUsed,
    int? lessonsCompleted,
  }) =>
      EnergyState(
        energy: energy ?? this.energy,
        isPro: isPro ?? this.isPro,
        dailyFreeUsed: dailyFreeUsed ?? this.dailyFreeUsed,
        lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
        config: config,
      );
}

/// What happened when a completed lesson was committed.
class EnergyCommitOutcome {
  const EnergyCommitOutcome({
    required this.energySpent,
    required this.showInterstitial,
    required this.energy,
    required this.wasFree,
  });

  final int energySpent;
  final bool showInterstitial;
  final int energy;
  final bool wasFree;
}
