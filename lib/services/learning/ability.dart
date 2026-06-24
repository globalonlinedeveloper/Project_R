// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// ABILITY-1 [R-G2] — online θ (theta) ability model. A pure, deterministic
// estimate of a learner's ability on the IRT logit scale: one global θ plus a
// sparse per-skill θ map, updated after every GRADED item by an online
// Elo-style step whose K decays with item count, with each per-skill estimate
// reverting toward global. Ungraded reading never moves θ (R-G2).
//
// PURITY CONTRACT (what makes this safe build-ahead and trivially testable):
//   * NO I/O, NO database, NO network, NO provider — it is just arithmetic.
//   * NO clock, NO DateTime.now(), NO randomness. Given the same prior state,
//     the same item difficulty, the same outcome and the same params it always
//     returns the same next state — so it can be golden-tested exactly.
//   * The step-size schedule + the per-skill→global shrinkage are INJECTED
//     (AbilityParams) with a documented const default, so callers can use
//     `const AbilityModel()` with nothing to configure.
//
// THE MODEL (no constant is invented — each is an injected, documented knob):
//   * Success probability is the 1PL / Rasch logistic P = σ(θ − b), where
//     σ(x) = 1 / (1 + e^(−x)), θ is the current ability and b the item's
//     difficulty (irt_b), both on the standard logit scale (≈ −3 easy …
//     +3 hard).
//   * The online update is the Elo/logit step θ' = θ + K(n)·(outcome − P),
//     with outcome ∈ {1 correct, 0 wrong}. Because P rises with (θ − b), a
//     correct answer on a HARD item (low P) moves θ more than on an EASY item,
//     and a wrong answer on an easy item costs more than on a hard one — the
//     IRT-Elo behaviour R-G2 specifies.
//   * K DECAYS WITH ITEM COUNT — hyperbolic K(n) = initialK / (1 + kDecay·n),
//     floored at minK. A large early step (early answers move θ noticeably);
//     hundreds of items later the same answer barely moves θ.
//   * PER-SKILL SHRINKS TOWARD GLOBAL — after the per-skill Elo step the
//     estimate is pulled a `skillShrinkage` fraction toward the (updated)
//     global θ (partial pooling), so a sparsely-observed skill stays near the
//     global ability and a never-seen skill starts AT global (cold-start).
//   * Only ATOMIC GRADED items feed θ. An ungraded item (graded: false) is a
//     no-op — θ and the counts are returned unchanged. The branching
//     scripted-roleplay composite emits no θ of its own: its caller feeds each
//     embedded atomic turn through `update` as that turn's own type, and never
//     calls `update` for the composite wrapper.
//
// GO-LIVE STOP — this is the online θ MATH only. NOT wired here (lands at
// go-live behind the human dual senior-architect sign-off): persisting the
// global θ onto the User and the per-skill θ into the UserCourse
// `theta_per_skill` jsonb; sourcing the calibrated item irt_b and recording
// theta_before / irt_b_at_review into the append-only ReviewLog; seeding the
// cold-start prior from the CAT placement θ (else the CEFR-anchor prior); and
// the periodic EAP / IRT batch RE-FIT that complements this online step. This
// file performs none of that — it is pure functions over plain values.

import 'dart:math' as math;

/// Immutable ability estimate: the global θ plus a sparse per-skill θ map, each
/// with the count of graded items seen so far (the counts drive the per-track K
/// decay). All θ values are on the IRT logit scale. Treated as immutable — the
/// engine returns a NEW state and never mutates the one passed in.
class AbilityState {
  const AbilityState({
    this.thetaGlobal = 0.0,
    this.thetaPerSkill = const <String, double>{},
    this.globalItemCount = 0,
    this.skillItemCounts = const <String, int>{},
  });

  /// A cold-start state seeded with a prior global ability [priorTheta] (e.g.
  /// the CAT placement θ, or the CEFR-anchor prior) and no graded items yet.
  const AbilityState.coldStart(double priorTheta)
      : this(thetaGlobal: priorTheta);

  /// Running global ability on the logit scale (updated on every graded item).
  final double thetaGlobal;

  /// Sparse per-skill ability on the logit scale, keyed by skill id. A skill
  /// absent from the map has never been graded; its effective θ is the global
  /// estimate (see [thetaForSkill]).
  final Map<String, double> thetaPerSkill;

  /// Number of graded items applied to the global track (drives global K).
  final int globalItemCount;

  /// Number of graded items applied per skill (drives per-skill K), keyed by
  /// skill id.
  final Map<String, int> skillItemCounts;

  /// Effective per-skill ability: the stored per-skill θ, or the global θ for a
  /// never-graded skill (cold-start partial pooling — a new skill starts at the
  /// learner's global ability).
  double thetaForSkill(String skill) => thetaPerSkill[skill] ?? thetaGlobal;

  /// Graded-item count for [skill] (0 if never graded).
  int itemCountForSkill(String skill) => skillItemCounts[skill] ?? 0;
}

/// Injectable θ-update parameters: the Elo step-size schedule (initial K, its
/// decay rate, an optional floor) and the per-skill→global shrinkage weight.
/// The const default supplies documented, pilot-tunable starting values so
/// callers can use `const AbilityModel()` with nothing to configure.
class AbilityParams {
  const AbilityParams({
    this.initialK = 1.0,
    this.kDecay = 0.05,
    this.minK = 0.0,
    this.skillShrinkage = 0.1,
  })  : assert(initialK > 0, 'initialK must be > 0'),
        assert(kDecay >= 0, 'kDecay must be >= 0'),
        assert(minK >= 0 && minK <= initialK, 'minK must be in [0, initialK]'),
        assert(skillShrinkage >= 0 && skillShrinkage <= 1,
            'skillShrinkage must be in [0, 1]');

  /// Elo step size at item count 0 — the large early step.
  final double initialK;

  /// Hyperbolic decay rate of K with item count (0 = no decay, constant K).
  final double kDecay;

  /// Lower bound on K so θ never fully freezes (0 = pure hyperbolic decay).
  final double minK;

  /// Fraction the per-skill estimate is pulled toward the global θ each update
  /// (0 = independent per-skill Elo, 1 = fully pooled to global).
  final double skillShrinkage;

  /// Documented, pilot-tunable build-now defaults.
  static const AbilityParams defaults = AbilityParams();
}

/// Pure, deterministic online θ ability engine. Construct with
/// `const AbilityModel()` for the defaults, or inject custom [params].
class AbilityModel {
  const AbilityModel([this.params = AbilityParams.defaults]);

  /// The injected step-size schedule + shrinkage weight.
  final AbilityParams params;

  /// The 1PL / Rasch success probability P = σ(θ − b): the logistic chance a
  /// learner of ability [theta] answers an item of difficulty [itemDifficulty]
  /// correctly. Always in the open interval (0, 1).
  double pCorrect(double theta, double itemDifficulty) =>
      1.0 / (1.0 + math.exp(-(theta - itemDifficulty)));

  /// Elo step size after [itemCount] graded items: K = initialK / (1 +
  /// kDecay·itemCount), floored at minK. Non-increasing in itemCount (when
  /// kDecay > 0) — large early, vanishing late.
  double stepSize(int itemCount) {
    final double k = params.initialK / (1.0 + params.kDecay * itemCount);
    return k < params.minK ? params.minK : k;
  }

  /// Apply one item to [state] and return the next state (the input is never
  /// mutated). A GRADED item performs the Elo/logit update on both the global
  /// track and [skill]'s track (the per-skill estimate reverting toward
  /// global), incrementing both counts. An UNGRADED item (graded: false) is a
  /// no-op: θ and the counts are returned unchanged. Pure + deterministic.
  AbilityState update(
    AbilityState state, {
    required String skill,
    required double itemDifficulty,
    required bool correct,
    bool graded = true,
  }) {
    if (!graded) {
      return state;
    }
    final double outcome = correct ? 1.0 : 0.0;

    // Global track: Elo step at the global item count.
    final double pGlobal = pCorrect(state.thetaGlobal, itemDifficulty);
    final double nextGlobal = state.thetaGlobal +
        stepSize(state.globalItemCount) * (outcome - pGlobal);

    // Per-skill track: Elo step at this skill's count (a never-seen skill
    // starts at the global θ), then shrink toward the updated global.
    final double skillTheta = state.thetaForSkill(skill);
    final int skillCount = state.itemCountForSkill(skill);
    final double pSkill = pCorrect(skillTheta, itemDifficulty);
    final double skillElo =
        skillTheta + stepSize(skillCount) * (outcome - pSkill);
    final double nextSkill =
        skillElo + params.skillShrinkage * (nextGlobal - skillElo);

    final Map<String, double> nextThetas =
        Map<String, double>.of(state.thetaPerSkill);
    nextThetas[skill] = nextSkill;
    final Map<String, int> nextCounts =
        Map<String, int>.of(state.skillItemCounts);
    nextCounts[skill] = skillCount + 1;

    return AbilityState(
      thetaGlobal: nextGlobal,
      thetaPerSkill: nextThetas,
      globalItemCount: state.globalItemCount + 1,
      skillItemCounts: nextCounts,
    );
  }
}
