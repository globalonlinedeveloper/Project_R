// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// CALIBRATION-1 [R-G3] — batch IRT item re-calibration. The periodic re-fit the
// online θ engine (ability.dart) and the recall-probability family (irt.dart)
// both name in their GO-LIVE STOP: recompute an item's parameters (irt_b, then
// irt_a, then the mcq irt_c) from the append-only ReviewLog, following the
// staged ladder R-G3 specifies — 1PL on priors, a 1PL b refine once an item has
// a few hundred answers, a 2PL discrimination `a` fit at ~1,000, a 3PL guessing
// `c` for mcq later.
//
// THIN-DATA SAFE BY CONSTRUCTION (the reason this can ship before the answer
// data is deep): every rung is GATED on the item's answer count, and the
// difficulty estimate is a MAP (maximum-a-posteriori), not a raw MLE — a
// Gaussian prior centered on the item's current authored difficulty regularizes
// the fit, so
//   * below the refine threshold the authored difficulty is returned UNCHANGED
//     (rung insufficientData) — a handful of answers never moves a good prior;
//   * just above it the estimate SHRINKS toward the prior (few answers → small
//     move; many answers → the data dominates);
//   * degenerate all-correct / all-wrong data, whose raw MLE diverges to ∓∞,
//     yields a FINITE shrunk-and-clamped estimate.
// The calibrator can therefore NEVER overwrite a sound authored difficulty with
// small-sample noise — the explicit design constraint for launch-thin data.
//
// PURITY CONTRACT (safe build-ahead + trivially testable):
//   * NO I/O, NO database, NO network, NO provider, NO LLM — arithmetic over
//     plain values (a list of (θ-at-answer, correct) responses + the item's
//     current params).
//   * NO clock, NO DateTime.now(), NO randomness. The estimate is a
//     deterministic bisection of a strictly-monotone score function, so the
//     same responses + the same prior always return the same result — it is
//     golden-testable exactly, and it is order-independent (a sum).
//   * Every knob (prior variance, rung thresholds, difficulty clamp, solver
//     tolerance) is INJECTED via [CalibrationParams] with a documented const
//     default, so callers use `const IrtCalibrator()` with nothing to configure.
//
// THE ESTIMATORS (staged coordinate MAP — no constant invented). Each rung adds
// ONE parameter, fit by a bisection of a strictly-DECREASING score (its unique
// root = the MAP estimate), holding the already-fit parameters:
//   * 1PL difficulty b. For responses {(θ_j, y_j)}, y_j ∈ {1 correct, 0 wrong},
//     the 1PL log-likelihood is Σ_j [ y_j·log σ(θ_j−b) + (1−y_j)·log(1−σ(θ_j−b)) ],
//     σ(x)=1/(1+e^(−x)). A Gaussian prior b ~ N(b0, τ²) centered on the current
//     difficulty b0 gives the MAP objective, whose score is
//         S(b) = Σ_j ( σ(θ_j − b) − y_j )  −  (b − b0) / τ²
//     STRICTLY DECREASING in b ⇒ a UNIQUE root ⇒ deterministic bisection; the
//     root is clamped to [bMin, bMax]. τ² ([CalibrationParams.priorVariance]) is
//     the prior width: small τ² trusts the authored difficulty (strong
//     shrinkage), large τ² trusts the data (τ² → ∞ recovers the raw MLE).
//   * 2PL discrimination a (rung eligible2pl+, holding b at the 1PL re-fit).
//     With d_j = θ_j − b, the 2PL log-likelihood Σ_j [ y_j·log σ(a·d_j) +
//     (1−y_j)·log(1−σ(a·d_j)) ] and a Gaussian prior a ~ N(a0, τ_a²) give
//         S(a) = Σ_j d_j·( y_j − σ(a·d_j) )  −  (a − a0) / τ_a²
//     with dS/da = −Σ_j d_j²·σ'(a·d_j) − 1/τ_a² < 0 ⇒ STRICTLY DECREASING ⇒ the
//     same unique-root bisection. Clamped to [aMin, aMax] with aMin > 0, so the
//     result is ALWAYS a valid IRT discrimination (reverse-keyed data lands on
//     the floor with a large delta — a review flag, never a ≤ 0 slope).
//   * 3PL guessing c (rung eligible3pl, mcq only, holding a and b). With
//     g_j = σ(a·d_j), the 3PL probability p_j = c + (1−c)·g_j has a
//     log-likelihood STRICTLY CONCAVE in c (d²L/dc² = −Σ_j [ y_j·(1−g_j)²/p_j² +
//     (1−y_j)/(1−c)² ] < 0), so its MAP score
//         S(c) = Σ_j [ y_j·(1−g_j)/p_j − (1−y_j)/(1−c) ]  −  (c − c0) / τ_c²
//     is STRICTLY DECREASING ⇒ unique-root bisection. Clamped to [cMin, cMax]
//     with 0 ≤ cMin and cMax < 1, so the result is ALWAYS a valid guessing floor.
//   Every rung is a single deterministic coordinate step, an order-independent
//   sum bisected to tolerance ⇒ golden-testable exactly. THIN-DATA SAFE the same
//   way b is: below each rung's threshold the authored a/c pass through VERBATIM;
//   above it the estimate SHRINKS toward the prior (few answers → small move) and
//   degenerate/separated data stays FINITE and clamped. A handful of answers can
//   never move a sound authored a or c — the launch-thin design constraint,
//   applied to all three parameters.
//
// THE JOINT / ITERATED (a, b, c) REFIT (calibrateItemJoint). calibrateItem
// takes ONE coordinate step per rung (b, then a holding b, then c holding a and
// b); calibrateItemJoint instead ITERATES the coordinate updates to a fixed
// point — guarded cyclic coordinate ascent on the penalized log-posterior.
// Each update is the SAME strictly-monotone bisection, generalized to hold the
// other two parameters; a step is ACCEPTED only if it does not decrease the
// penalized log-posterior (penLP). For the 2PL (a, b) sub-problem every
// coordinate is strictly concave (its bisection is the exact coordinate max) so
// the guard is a no-op and the ascent converges to the joint MAP; with a 3PL
// guessing floor the (a, b) surface is non-concave, so the guard makes each
// cycle a monotone IMPROVEMENT from the authored prior (a prior-anchored local
// ascent — never a global-optimum claim, never worse than the single pass).
// penLP is bounded above ⇒ the monotone ascent converges; jointConverged
// reports whether the parameter move fell below jointTolerance before
// jointMaxCycles. Same thin-data guards as the single pass: below-rung
// parameters never enter the cycle (verbatim), and every bisection stays finite
// + clamped on separated / reverse-keyed data.
//
// THE EAP θ RE-ESTIMATE (EapThetaEstimator) — the batch posterior-mean ability
// that COMPLEMENTS the online θ step (ability.dart): given a learner's graded
// responses to items with calibrated (a, b, c) parameters and a Gaussian θ
// prior, integrate θ·posterior over a fixed quadrature grid (log-sum-exp
// stable). Pure, deterministic, order-independent; with no responses it returns
// the prior mean (thin-data-safe by the same construction). The mcq-only
// guessing guard mirrors IrtModel.guessingFor.
//
// GO-LIVE STOP — this is the batch re-fit MATH (item a/b/c AND learner θ) only.
// NOT done here (lands at go-live behind the human dual senior-architect
// sign-off): the wiring that reads the ReviewLog out of Supabase, writes the
// calibrated irt_a / irt_b / irt_c back onto the item bank, persists the
// re-estimated θ, and schedules the batch. Pure values only.

import 'dart:math' as math;

import 'package:ratel/content/models/enums.dart' show ExerciseType;
import 'package:ratel/services/learning/irt.dart' show IrtItem;
import 'package:ratel/services/learning/learner_state.dart' show ReviewLogEntry;

/// One graded response feeding an item's difficulty re-fit: the learner's
/// global ability [theta] frozen at answer time (the ReviewLog `theta_before`)
/// and the binary [correct] outcome. All the 1PL difficulty MAP needs.
class CalibrationResponse {
  const CalibrationResponse({required this.theta, required this.correct});

  /// The learner's θ (logit scale) at the moment this item was answered.
  final double theta;

  /// Whether the answer was correct (the outcome the likelihood fits).
  final bool correct;
}

/// Which rung of the staged calibration ladder (R-G3) an item's answer count
/// supports. Gated on the response count `n`:
///   * [insufficientData] — `n` below the refine threshold: the authored
///     difficulty is kept UNCHANGED (thin-data guard; no estimate is made).
///   * [refined1pl] — `n` at/above the refine threshold, below the 2PL
///     threshold: the 1PL difficulty `b` is MAP-refit; `a` and `c` pass through.
///   * [eligible2pl] — `n` at/above the 2PL threshold: `b` is MAP-refit AND the
///     2PL discrimination `a` is MAP-refit (a single coordinate step holding the
///     re-fit `b`); `c` passes through.
///   * [eligible3pl] — an `mcq` item at/above the 3PL threshold: as
///     [eligible2pl] plus the 3PL guessing `c` MAP-refit (mcq only, holding the
///     re-fit `a` and `b`).
enum CalibrationRung { insufficientData, refined1pl, eligible2pl, eligible3pl }

/// The immutable, auditable outcome of re-calibrating ONE item. Carries the
/// resulting parameters ([b]/[a]/[c]), the [rung] the data supported, the
/// [responseCount] used, the priors it started from ([priorB]/[priorA]/[priorC],
/// so [delta]/[aDelta]/[cDelta] are the signed moves), and whether each performed
/// solve reached tolerance ([converged]/[aConverged]/[cConverged]) — everything a
/// review dashboard needs to see WHY a parameter did (or did not) change.
class CalibrationResult {
  const CalibrationResult({
    required this.b,
    required this.a,
    required this.c,
    required this.rung,
    required this.responseCount,
    required this.priorB,
    required this.priorA,
    required this.priorC,
    required this.converged,
    required this.aConverged,
    required this.cConverged,
    this.cycles = 0,
    this.jointConverged = true,
  });

  /// The calibrated difficulty — or, at [CalibrationRung.insufficientData], the
  /// authored [priorB] returned verbatim.
  final double b;

  /// The calibrated discrimination at [CalibrationRung.eligible2pl] /
  /// [CalibrationRung.eligible3pl] — or the authored [priorA] passed through
  /// verbatim below the 2PL rung.
  final double a;

  /// The calibrated mcq guessing floor at [CalibrationRung.eligible3pl] — or the
  /// authored [priorC] passed through verbatim below the 3PL rung.
  final double c;

  /// The ladder rung the response count supported.
  final CalibrationRung rung;

  /// How many responses fed the fit.
  final int responseCount;

  /// The authored difficulty the fit started from (the `b` prior mean).
  final double priorB;

  /// The authored discrimination the fit started from (the `a` prior mean).
  final double priorA;

  /// The authored guessing floor the fit started from (the `c` prior mean).
  final double priorC;

  /// Whether the `b` bisection reached tolerance (always true when the prior was
  /// kept or the root was clamped to a bound).
  final bool converged;

  /// Whether the `a` bisection reached tolerance (true when `a` was not re-fit
  /// this rung, the prior was kept, or the root was clamped to a bound).
  final bool aConverged;

  /// Whether the `c` bisection reached tolerance (true when `c` was not re-fit
  /// this rung, the prior was kept, or the root was clamped to a bound).
  final bool cConverged;

  /// How many cyclic-coordinate-ascent cycles
  /// [IrtCalibrator.calibrateItemJoint] ran (0 for a single-pass
  /// [IrtCalibrator.calibrateItem] result).
  final int cycles;

  /// Whether the joint refit's parameter moves settled below
  /// [CalibrationParams.jointTolerance] before [CalibrationParams.jointMaxCycles]
  /// (always true for a single-pass result).
  final bool jointConverged;

  /// Signed difficulty change from the prior (0.0 when the prior was kept).
  double get delta => b - priorB;

  /// Signed discrimination change from the prior (0.0 below the 2PL rung).
  double get aDelta => a - priorA;

  /// Signed guessing change from the prior (0.0 below the 3PL rung).
  double get cDelta => c - priorC;

  /// Whether the calibrator actually re-fit the difficulty (false at
  /// [CalibrationRung.insufficientData], where the authored value is verbatim).
  bool get refined => rung != CalibrationRung.insufficientData;

  /// Whether the discrimination `a` was re-fit ([CalibrationRung.eligible2pl] or
  /// [CalibrationRung.eligible3pl]).
  bool get aRefined =>
      rung == CalibrationRung.eligible2pl ||
      rung == CalibrationRung.eligible3pl;

  /// Whether the guessing floor `c` was re-fit ([CalibrationRung.eligible3pl],
  /// mcq only).
  bool get cRefined => rung == CalibrationRung.eligible3pl;
}

/// An item's current authored parameters + exercise type, the prior a batch
/// re-fit starts from (the mcq-only [type] gates 3PL eligibility).
class ItemPrior {
  const ItemPrior({
    required this.b,
    this.a = 1.0,
    this.c = 0.0,
    this.type = ExerciseType.mcq,
  });

  /// Current authored difficulty (irt_b), the prior mean.
  final double b;

  /// Current discrimination (irt_a); passed through the 1PL rung.
  final double a;

  /// Current guessing floor (irt_c); passed through the 1PL rung.
  final double c;

  /// The item's exercise type — only `mcq` can reach [CalibrationRung.eligible3pl].
  final ExerciseType type;
}

/// Injectable calibration knobs with documented const defaults tuned for
/// launch-thin data. `const CalibrationParams()` is the launch profile.
class CalibrationParams {
  const CalibrationParams({
    this.priorVariance = 1.0,
    this.discriminationPriorVariance = 0.5,
    this.guessingPriorVariance = 0.05,
    this.minResponsesToRefine = 200,
    this.twoPlThreshold = 1000,
    this.threePlThreshold = 2000,
    this.bMin = -6.0,
    this.bMax = 6.0,
    this.aMin = 0.2,
    this.aMax = 4.0,
    this.cMin = 0.0,
    this.cMax = 0.5,
    this.tolerance = 1e-9,
    this.maxIterations = 200,
    this.jointMaxCycles = 50,
    this.jointTolerance = 1e-6,
  })  : assert(priorVariance > 0, 'priorVariance (τ²) must be > 0'),
        assert(discriminationPriorVariance > 0,
            'discriminationPriorVariance (τ_a²) must be > 0'),
        assert(guessingPriorVariance > 0,
            'guessingPriorVariance (τ_c²) must be > 0'),
        assert(minResponsesToRefine >= 0, 'minResponsesToRefine must be >= 0'),
        assert(twoPlThreshold >= minResponsesToRefine,
            'twoPlThreshold must be >= minResponsesToRefine'),
        assert(threePlThreshold >= twoPlThreshold,
            'threePlThreshold must be >= twoPlThreshold'),
        assert(bMax > bMin, 'bMax must be > bMin'),
        assert(aMin > 0, 'aMin must be > 0 (a valid IRT discrimination)'),
        assert(aMax > aMin, 'aMax must be > aMin'),
        assert(cMin >= 0, 'cMin must be >= 0'),
        assert(cMax > cMin, 'cMax must be > cMin'),
        assert(cMax < 1, 'cMax must be < 1 (a valid guessing floor)'),
        assert(tolerance > 0, 'tolerance must be > 0'),
        assert(maxIterations > 0, 'maxIterations must be > 0'),
        assert(jointMaxCycles > 0, 'jointMaxCycles must be > 0'),
        assert(jointTolerance > 0, 'jointTolerance must be > 0');

  /// τ² — the Gaussian prior variance on `b` (logit scale). Small = trust the
  /// authored difficulty (strong shrinkage); large = trust the data.
  final double priorVariance;

  /// τ_a² — the Gaussian prior variance on the discrimination `a`. Small = trust
  /// the authored `a` (strong shrinkage); large = trust the data.
  final double discriminationPriorVariance;

  /// τ_c² — the Gaussian prior variance on the mcq guessing floor `c`. Small =
  /// trust the authored `c` (strong shrinkage); large = trust the data.
  final double guessingPriorVariance;

  /// Minimum responses before `b` is re-fit at all; below this the authored
  /// difficulty is kept verbatim (the thin-data floor).
  final int minResponsesToRefine;

  /// Responses at/above which the 2PL discrimination `a` is re-fit (rung
  /// [CalibrationRung.eligible2pl]); below it `a` passes through verbatim.
  final int twoPlThreshold;

  /// Responses at/above which an mcq item's 3PL guessing `c` is re-fit (rung
  /// [CalibrationRung.eligible3pl]); below it `c` passes through verbatim.
  final int threePlThreshold;

  /// Lower / upper clamp on the fitted difficulty (finite ceiling for
  /// separated data).
  final double bMin;
  final double bMax;

  /// Lower / upper clamp on the fitted discrimination. [aMin] > 0 keeps the
  /// result a valid IRT slope (reverse-keyed data clamps to [aMin], not ≤ 0).
  final double aMin;
  final double aMax;

  /// Lower / upper clamp on the fitted guessing floor. Kept in [0, 1) so the
  /// result is always a valid pseudo-guessing asymptote.
  final double cMin;
  final double cMax;

  /// Bisection stopping tolerance on |S(·)| and the bracket width.
  final double tolerance;

  /// Bisection iteration cap (a safety bound; the strictly-monotone score
  /// converges well within it).
  final int maxIterations;

  /// Maximum cyclic-coordinate-ascent cycles in
  /// [IrtCalibrator.calibrateItemJoint] before returning the best fixed point
  /// reached (a safety bound; the 2PL joint MAP converges well within it).
  final int jointMaxCycles;

  /// Joint-refit convergence tolerance: the cycle stops once the largest
  /// absolute parameter move within a cycle falls below this.
  final double jointTolerance;

  /// Documented, pilot-tunable launch defaults.
  static const CalibrationParams defaults = CalibrationParams();
}

/// Pure, deterministic batch IRT item re-calibrator. Construct with
/// `const IrtCalibrator()` for the launch defaults, or inject [params].
class IrtCalibrator {
  const IrtCalibrator([this.params = CalibrationParams.defaults]);

  /// The injected thresholds / prior width / solver bounds.
  final CalibrationParams params;

  /// Re-calibrate ONE item from its [responses], given its current authored
  /// [priorB]/[priorA]/[priorC] and exercise [type] (which gates the mcq-only
  /// 3PL eligibility). Staged, thin-data-safe coordinate MAP:
  ///   * below [CalibrationParams.minResponsesToRefine] → the authored params are
  ///     returned UNCHANGED (rung insufficientData);
  ///   * at/above it → the 1PL difficulty `b` is MAP-refit (shrunk to [priorB]);
  ///   * at/above [CalibrationParams.twoPlThreshold] → the 2PL discrimination `a`
  ///     is also MAP-refit holding `b` (shrunk to [priorA]);
  ///   * an `mcq` item at/above [CalibrationParams.threePlThreshold] → the 3PL
  ///     guessing `c` is also MAP-refit holding `a` and `b` (shrunk to [priorC]).
  /// Each parameter not yet at its rung passes through verbatim.
  CalibrationResult calibrateItem({
    required List<CalibrationResponse> responses,
    required double priorB,
    double priorA = 1.0,
    double priorC = 0.0,
    ExerciseType type = ExerciseType.mcq,
  }) {
    final int n = responses.length;
    final CalibrationRung rung = _rungFor(n, type);

    if (rung == CalibrationRung.insufficientData) {
      return CalibrationResult(
        b: priorB,
        a: priorA,
        c: priorC,
        rung: rung,
        responseCount: n,
        priorB: priorB,
        priorA: priorA,
        priorC: priorC,
        converged: true,
        aConverged: true,
        cConverged: true,
      );
    }

    // 1PL: MAP-refit the difficulty (every refit rung).
    final (double b, bool bConverged) = _fitDifficulty(responses, priorB);

    // 2PL: MAP-refit the discrimination once the 2PL rung is reached, holding b.
    double a = priorA;
    bool aConverged = true;
    if (rung == CalibrationRung.eligible2pl ||
        rung == CalibrationRung.eligible3pl) {
      (a, aConverged) = _fitDiscrimination(responses, b, priorA);
    }

    // 3PL: MAP-refit the mcq guessing floor at the 3PL rung, holding a and b.
    double c = priorC;
    bool cConverged = true;
    if (rung == CalibrationRung.eligible3pl) {
      (c, cConverged) = _fitGuessing(responses, a, b, priorC);
    }

    return CalibrationResult(
      b: b,
      a: a,
      c: c,
      rung: rung,
      responseCount: n,
      priorB: priorB,
      priorA: priorA,
      priorC: priorC,
      converged: bConverged,
      aConverged: aConverged,
      cConverged: cConverged,
    );
  }

  /// Re-calibrate a batch: map each item id to its [CalibrationResult]. [priors]
  /// supplies each item's current params; [responsesByItem] its responses (an
  /// item absent from [responsesByItem] has zero responses → insufficientData,
  /// prior kept). Deterministic and order-independent.
  Map<String, CalibrationResult> calibrateBatch({
    required Map<String, ItemPrior> priors,
    required Map<String, List<CalibrationResponse>> responsesByItem,
  }) {
    final Map<String, CalibrationResult> out = <String, CalibrationResult>{};
    for (final MapEntry<String, ItemPrior> e in priors.entries) {
      final ItemPrior p = e.value;
      out[e.key] = calibrateItem(
        responses:
            responsesByItem[e.key] ?? const <CalibrationResponse>[],
        priorB: p.b,
        priorA: p.a,
        priorC: p.c,
        type: p.type,
      );
    }
    return out;
  }

  /// Fold an append-only ReviewLog slice into per-item response lists, keeping
  /// ONLY entries that [ReviewLogEntry.feedsTheta] (the calibrated graded
  /// answers — the same gate the online θ engine uses; saved-word / ungraded
  /// rows never calibrate). Each kept entry contributes (theta_before, correct).
  static Map<String, List<CalibrationResponse>> groupResponses(
    Iterable<ReviewLogEntry> log,
  ) {
    final Map<String, List<CalibrationResponse>> out =
        <String, List<CalibrationResponse>>{};
    for (final ReviewLogEntry e in log) {
      if (!e.feedsTheta) {
        continue;
      }
      (out[e.itemId] ??= <CalibrationResponse>[]).add(
        CalibrationResponse(theta: e.thetaBefore, correct: e.correct),
      );
    }
    return out;
  }

  CalibrationRung _rungFor(int n, ExerciseType type) {
    if (n < params.minResponsesToRefine) {
      return CalibrationRung.insufficientData;
    }
    if (n >= params.threePlThreshold && type == ExerciseType.mcq) {
      return CalibrationRung.eligible3pl;
    }
    if (n >= params.twoPlThreshold) {
      return CalibrationRung.eligible2pl;
    }
    return CalibrationRung.refined1pl;
  }

  /// MAP 1PL difficulty via bisection of the strictly-decreasing score
  /// S(b) = Σ(σ(θ_j − b) − y_j) − (b − b0)/τ². Brackets around [priorB],
  /// expands the bracket outward until it straddles the root (or hits a clamp),
  /// then bisects to [CalibrationParams.tolerance]. Returns (b, converged).
  (double, bool) _fitDifficulty(
    List<CalibrationResponse> responses,
    double priorB,
  ) {
    double score(double b) {
      double s = 0.0;
      for (final CalibrationResponse r in responses) {
        final double p = 1.0 / (1.0 + math.exp(-(r.theta - b)));
        s += p - (r.correct ? 1.0 : 0.0);
      }
      return s - (b - priorB) / params.priorVariance;
    }

    // The prior is already the root (no responses, or perfectly balanced data).
    final double sPrior = score(priorB);
    if (sPrior.abs() < params.tolerance) {
      return (priorB, true);
    }

    double lo;
    double hi;
    if (sPrior > 0) {
      // Root is to the RIGHT (S decreasing): lo=priorB has S>0, expand hi up.
      lo = priorB;
      hi = priorB;
      double step = 1.0;
      int guard = 0;
      double sHi = sPrior;
      while (sHi > 0 && hi < params.bMax && guard < 64) {
        hi = math.min(params.bMax, hi + step);
        sHi = score(hi);
        step *= 2.0;
        guard++;
      }
      if (sHi > 0) {
        return (params.bMax, true); // root beyond the upper clamp
      }
    } else {
      // Root is to the LEFT: hi=priorB has S<0, expand lo down.
      hi = priorB;
      lo = priorB;
      double step = 1.0;
      int guard = 0;
      double sLo = sPrior;
      while (sLo < 0 && lo > params.bMin && guard < 64) {
        lo = math.max(params.bMin, lo - step);
        sLo = score(lo);
        step *= 2.0;
        guard++;
      }
      if (sLo < 0) {
        return (params.bMin, true); // root beyond the lower clamp
      }
    }

    // Bisect [lo, hi] where score(lo) > 0 > score(hi).
    double mid = 0.5 * (lo + hi);
    bool converged = false;
    for (int i = 0; i < params.maxIterations; i++) {
      mid = 0.5 * (lo + hi);
      final double sMid = score(mid);
      if (sMid.abs() < params.tolerance || (hi - lo) < params.tolerance) {
        converged = true;
        break;
      }
      if (sMid > 0) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    final double clamped =
        mid < params.bMin ? params.bMin : (mid > params.bMax ? params.bMax : mid);
    return (clamped, converged);
  }

  /// MAP 2PL discrimination via bisection of the strictly-decreasing score
  /// S(a) = Σ d_j·(y_j − σ(a·d_j)) − (a − a0)/τ_a², d_j = θ_j − [b] (held at the
  /// 1PL re-fit). a0 = [priorA] is the prior mean and bracket center; the root is
  /// clamped to [CalibrationParams.aMin]..[CalibrationParams.aMax] (aMin > 0, so
  /// the result is always a valid IRT slope). Returns (a, converged).
  (double, bool) _fitDiscrimination(
    List<CalibrationResponse> responses,
    double b,
    double priorA,
  ) {
    double score(double a) {
      double s = 0.0;
      for (final CalibrationResponse r in responses) {
        final double d = r.theta - b;
        final double p = 1.0 / (1.0 + math.exp(-a * d));
        s += d * ((r.correct ? 1.0 : 0.0) - p);
      }
      return s - (a - priorA) / params.discriminationPriorVariance;
    }

    return _bisectDecreasing(score, priorA, params.aMin, params.aMax);
  }

  /// MAP 3PL guessing floor via bisection of the strictly-decreasing score
  /// S(c) = Σ [ y_j·(1−g_j)/p_j − (1−y_j)/(1−c) ] − (c − c0)/τ_c², with
  /// g_j = σ([a]·(θ_j − [b])) and p_j = c + (1−c)·g_j ([a] and [b] held). c0 =
  /// [priorC] is the prior mean and bracket center; the root is clamped to
  /// [CalibrationParams.cMin]..[CalibrationParams.cMax] (kept in [0, 1)).
  /// Returns (c, converged).
  (double, bool) _fitGuessing(
    List<CalibrationResponse> responses,
    double a,
    double b,
    double priorC,
  ) {
    double score(double c) {
      double s = 0.0;
      for (final CalibrationResponse r in responses) {
        final double g = 1.0 / (1.0 + math.exp(-a * (r.theta - b)));
        final double p = c + (1.0 - c) * g;
        if (r.correct) {
          s += (1.0 - g) / p;
        } else {
          s -= 1.0 / (1.0 - c);
        }
      }
      return s - (c - priorC) / params.guessingPriorVariance;
    }

    return _bisectDecreasing(score, priorC, params.cMin, params.cMax);
  }

  /// Bisect a STRICTLY-DECREASING [score] for its unique root, starting from
  /// [center] (clamped into [floor]..[ceil]): if the score there is already ~0
  /// the center is the root; otherwise the bracket is expanded outward (doubling
  /// step) toward the bound the root lies past, then bisected to
  /// [CalibrationParams.tolerance]. A root beyond a bound returns that bound (the
  /// finite clamp for separated data). Returns (root, converged) — the same
  /// contract as [_fitDifficulty], reused for the `a` and `c` fits.
  (double, bool) _bisectDecreasing(
    double Function(double) score,
    double center,
    double floor,
    double ceil,
  ) {
    final double start =
        center < floor ? floor : (center > ceil ? ceil : center);
    final double sStart = score(start);
    if (sStart.abs() < params.tolerance) {
      return (start, true);
    }

    double lo;
    double hi;
    if (sStart > 0) {
      // Root is to the RIGHT (score decreasing): start has S>0, expand hi up.
      lo = start;
      hi = start;
      double step = 1.0;
      int guard = 0;
      double sHi = sStart;
      while (sHi > 0 && hi < ceil && guard < 64) {
        hi = math.min(ceil, hi + step);
        sHi = score(hi);
        step *= 2.0;
        guard++;
      }
      if (sHi > 0) {
        return (ceil, true); // root beyond the upper clamp
      }
    } else {
      // Root is to the LEFT: start has S<0, expand lo down.
      hi = start;
      lo = start;
      double step = 1.0;
      int guard = 0;
      double sLo = sStart;
      while (sLo < 0 && lo > floor && guard < 64) {
        lo = math.max(floor, lo - step);
        sLo = score(lo);
        step *= 2.0;
        guard++;
      }
      if (sLo < 0) {
        return (floor, true); // root beyond the lower clamp
      }
    }

    // Bisect [lo, hi] where score(lo) > 0 > score(hi).
    double mid = 0.5 * (lo + hi);
    bool converged = false;
    for (int i = 0; i < params.maxIterations; i++) {
      mid = 0.5 * (lo + hi);
      final double sMid = score(mid);
      if (sMid.abs() < params.tolerance || (hi - lo) < params.tolerance) {
        converged = true;
        break;
      }
      if (sMid > 0) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    final double clamped = mid < floor ? floor : (mid > ceil ? ceil : mid);
    return (clamped, converged);
  }

  /// Re-calibrate ONE item with the FULL JOINT / iterated (a, b, c) refit —
  /// guarded cyclic coordinate ascent to a fixed point, the go-live complement to
  /// the single-coordinate-step [calibrateItem]. Same staged rungs and thin-data
  /// guards; the difference is that the eligible parameters are co-fit and
  /// iterated rather than updated once:
  ///   * [CalibrationRung.insufficientData] -> authored params verbatim (cycles 0);
  ///   * [CalibrationRung.refined1pl] -> identical to [calibrateItem] (only `b` is
  ///     eligible, so one exact 1PL bisection is already the fixed point);
  ///   * [CalibrationRung.eligible2pl] -> `b` and `a` are co-fit and iterated
  ///     (each cycle: `b` holding `a`, then `a` holding `b`) to the joint 2PL MAP;
  ///   * [CalibrationRung.eligible3pl] -> `b`, `a` and the mcq `c` are co-fit and
  ///     iterated (guarded — the 3PL surface is non-concave, so each accepted step
  ///     only ever IMPROVES the penalized log-posterior from the authored prior).
  /// A coordinate step is accepted only if it does not decrease the penalized
  /// log-posterior, so the ascent is monotone and converges;
  /// [CalibrationResult.cycles] / [CalibrationResult.jointConverged] report the
  /// effort and whether the moves settled below [CalibrationParams.jointTolerance].
  CalibrationResult calibrateItemJoint({
    required List<CalibrationResponse> responses,
    required double priorB,
    double priorA = 1.0,
    double priorC = 0.0,
    ExerciseType type = ExerciseType.mcq,
  }) {
    final int n = responses.length;
    final CalibrationRung rung = _rungFor(n, type);

    if (rung == CalibrationRung.insufficientData) {
      return CalibrationResult(
        b: priorB,
        a: priorA,
        c: priorC,
        rung: rung,
        responseCount: n,
        priorB: priorB,
        priorA: priorA,
        priorC: priorC,
        converged: true,
        aConverged: true,
        cConverged: true,
        cycles: 0,
        jointConverged: true,
      );
    }

    // refined1pl: only `b` is eligible, so the single exact 1PL bisection IS the
    // fixed point (identical to calibrateItem). One trivially-converged cycle.
    if (rung == CalibrationRung.refined1pl) {
      final (double b1, bool b1Converged) = _fitDifficulty(responses, priorB);
      return CalibrationResult(
        b: b1,
        a: priorA,
        c: priorC,
        rung: rung,
        responseCount: n,
        priorB: priorB,
        priorA: priorA,
        priorC: priorC,
        converged: b1Converged,
        aConverged: true,
        cConverged: true,
        cycles: 1,
        jointConverged: true,
      );
    }

    // eligible2pl / eligible3pl: co-fit (b, a[, c]) by guarded coordinate ascent.
    final bool fitC = rung == CalibrationRung.eligible3pl;
    double b = priorB;
    double a = priorA;
    double c = priorC;
    bool bConverged = true;
    bool aConverged = true;
    bool cConverged = true;
    double lp =
        _penalizedLogPosterior(responses, a, b, c, priorB, priorA, priorC, type);

    int cycles = 0;
    bool settled = false;
    for (int k = 0; k < params.jointMaxCycles; k++) {
      cycles++;
      double maxMove = 0.0;

      // `b` holding a, c.
      final (double bProp, bool bcv) =
          _fitDifficultyConditional(responses, a, c, priorB, type);
      final double lpB = _penalizedLogPosterior(
          responses, a, bProp, c, priorB, priorA, priorC, type);
      if (lpB >= lp) {
        maxMove = math.max(maxMove, (bProp - b).abs());
        b = bProp;
        bConverged = bcv;
        lp = lpB;
      }

      // `a` holding b, c.
      final (double aProp, bool acv) =
          _fitDiscriminationConditional(responses, b, c, priorA, type);
      final double lpA = _penalizedLogPosterior(
          responses, aProp, b, c, priorB, priorA, priorC, type);
      if (lpA >= lp) {
        maxMove = math.max(maxMove, (aProp - a).abs());
        a = aProp;
        aConverged = acv;
        lp = lpA;
      }

      // mcq `c` holding a, b (3PL rung only).
      if (fitC) {
        final (double cProp, bool ccv) = _fitGuessing(responses, a, b, priorC);
        final double lpC = _penalizedLogPosterior(
            responses, a, b, cProp, priorB, priorA, priorC, type);
        if (lpC >= lp) {
          maxMove = math.max(maxMove, (cProp - c).abs());
          c = cProp;
          cConverged = ccv;
          lp = lpC;
        }
      }

      if (maxMove < params.jointTolerance) {
        settled = true;
        break;
      }
    }

    return CalibrationResult(
      b: b,
      a: a,
      c: fitC ? c : priorC,
      rung: rung,
      responseCount: n,
      priorB: priorB,
      priorA: priorA,
      priorC: priorC,
      converged: bConverged,
      aConverged: aConverged,
      cConverged: fitC ? cConverged : true,
      cycles: cycles,
      jointConverged: settled,
    );
  }

  /// Batch variant of [calibrateItemJoint]: map each item id to its joint
  /// [CalibrationResult]. Deterministic and order-independent (see
  /// [calibrateBatch]).
  Map<String, CalibrationResult> calibrateBatchJoint({
    required Map<String, ItemPrior> priors,
    required Map<String, List<CalibrationResponse>> responsesByItem,
  }) {
    final Map<String, CalibrationResult> out = <String, CalibrationResult>{};
    for (final MapEntry<String, ItemPrior> e in priors.entries) {
      final ItemPrior p = e.value;
      out[e.key] = calibrateItemJoint(
        responses: responsesByItem[e.key] ?? const <CalibrationResponse>[],
        priorB: p.b,
        priorA: p.a,
        priorC: p.c,
        type: p.type,
      );
    }
    return out;
  }

  /// The penalized log-posterior log P(responses | a, b, c) + log prior(a, b, c)
  /// (up to constants) — the objective the joint coordinate ascent monotonically
  /// increases. p_j = c + (1 - c)*sigma(a*(theta_j - b)) with the mcq-only
  /// guessing guard; logs are guarded against 0/1 saturation so separated data
  /// stays finite. Used only for step-acceptance comparisons.
  double _penalizedLogPosterior(
    List<CalibrationResponse> responses,
    double a,
    double b,
    double c,
    double priorB,
    double priorA,
    double priorC,
    ExerciseType type,
  ) {
    final double cEff = type == ExerciseType.mcq ? c : 0.0;
    double ll = 0.0;
    for (final CalibrationResponse r in responses) {
      final double g = 1.0 / (1.0 + math.exp(-a * (r.theta - b)));
      final double p = cEff + (1.0 - cEff) * g;
      final double pc =
          p < 1e-12 ? 1e-12 : (p > 1.0 - 1e-12 ? 1.0 - 1e-12 : p);
      ll += r.correct ? math.log(pc) : math.log(1.0 - pc);
    }
    ll -= (b - priorB) * (b - priorB) / (2.0 * params.priorVariance);
    ll -=
        (a - priorA) * (a - priorA) / (2.0 * params.discriminationPriorVariance);
    ll -= (c - priorC) * (c - priorC) / (2.0 * params.guessingPriorVariance);
    return ll;
  }

  /// MAP 1PL/2PL/3PL difficulty holding [a] and [cRaw] (mcq-gated): the general
  /// score S(b) = -a*(1-c)*Sum_j w_j*g_j*(1-g_j) - (b-priorB)/tau_b^2 with
  /// w_j = y_j/p_j - (1-y_j)/(1-p_j). Reduces to the strictly-decreasing 2PL
  /// b-score when c = 0 (the joint-refit inner step). Bisected via
  /// [_bisectDecreasing]; clamped to [CalibrationParams.bMin]..[bMax].
  (double, bool) _fitDifficultyConditional(
    List<CalibrationResponse> responses,
    double a,
    double cRaw,
    double priorB,
    ExerciseType type,
  ) {
    final double c = type == ExerciseType.mcq ? cRaw : 0.0;
    double score(double b) {
      double s = 0.0;
      for (final CalibrationResponse r in responses) {
        final double g = 1.0 / (1.0 + math.exp(-a * (r.theta - b)));
        final double p = c + (1.0 - c) * g;
        final double w = r.correct ? (1.0 / p) : (-1.0 / (1.0 - p));
        s += -a * (1.0 - c) * w * g * (1.0 - g);
      }
      return s - (b - priorB) / params.priorVariance;
    }

    return _bisectDecreasing(score, priorB, params.bMin, params.bMax);
  }

  /// MAP 2PL/3PL discrimination holding [b] and [cRaw] (mcq-gated): the general
  /// score S(a) = (1-c)*Sum_j w_j*d_j*g_j*(1-g_j) - (a-priorA)/tau_a^2, d_j =
  /// theta_j - b. Reduces to the strictly-decreasing 2PL a-score when c = 0.
  /// Bisected via [_bisectDecreasing]; clamped to [CalibrationParams.aMin]..[aMax]
  /// (aMin > 0 keeps it a valid slope).
  (double, bool) _fitDiscriminationConditional(
    List<CalibrationResponse> responses,
    double b,
    double cRaw,
    double priorA,
    ExerciseType type,
  ) {
    final double c = type == ExerciseType.mcq ? cRaw : 0.0;
    double score(double a) {
      double s = 0.0;
      for (final CalibrationResponse r in responses) {
        final double d = r.theta - b;
        final double g = 1.0 / (1.0 + math.exp(-a * d));
        final double p = c + (1.0 - c) * g;
        final double w = r.correct ? (1.0 / p) : (-1.0 / (1.0 - p));
        s += (1.0 - c) * w * d * g * (1.0 - g);
      }
      return s - (a - priorA) / params.discriminationPriorVariance;
    }

    return _bisectDecreasing(score, priorA, params.aMin, params.aMax);
  }
}
/// One graded response feeding an EAP theta re-estimate: the [item]'s calibrated
/// IRT parameters, the exercise [type] (the mcq-only guessing guard, mirroring
/// [IrtModel.guessingFor]), and the binary [correct] outcome.
class ThetaResponse {
  const ThetaResponse({
    required this.item,
    required this.correct,
    this.type = ExerciseType.mcq,
  });

  /// The item's stored (a, b, c) parameters the response is scored against.
  final IrtItem item;

  /// The exercise type — gates whether the item's guessing floor `c` applies.
  final ExerciseType type;

  /// Whether the answer was correct.
  final bool correct;
}

/// Injectable EAP theta knobs with documented const defaults. `const
/// EapThetaParams()` is the launch profile: a unit-normal theta prior on the
/// logit scale (matching AbilityState's cold-start mean 0.0) over a grid that
/// spans [gridMin, gridMax] OFFSETS around the prior mean (default +/-6), so the
/// no-response posterior mean is exactly the prior mean.
class EapThetaParams {
  const EapThetaParams({
    this.priorMean = 0.0,
    this.priorSd = 1.0,
    this.gridMin = -6.0,
    this.gridMax = 6.0,
    this.gridPoints = 121,
  })  : assert(priorSd > 0, 'priorSd must be > 0'),
        assert(gridMax > gridMin, 'gridMax must be > gridMin'),
        assert(gridPoints >= 3, 'gridPoints must be >= 3');

  /// Theta prior mean (the cold-start / placement prior; AbilityState default 0).
  final double priorMean;

  /// Theta prior standard deviation on the logit scale.
  final double priorSd;

  /// Lower / upper bound of the integration grid, as OFFSETS around [priorMean].
  final double gridMin;
  final double gridMax;

  /// Number of evenly-spaced grid nodes (trapezoidal weights). More = finer.
  final int gridPoints;

  /// Documented launch defaults.
  static const EapThetaParams defaults = EapThetaParams();
}

/// The immutable outcome of an EAP theta re-estimate: the posterior-mean ability
/// [theta], its posterior standard deviation [sd] (a calibrated uncertainty),
/// the [responseCount] used, and the [priorMean] it falls back to when thin.
class EapThetaResult {
  const EapThetaResult({
    required this.theta,
    required this.sd,
    required this.responseCount,
    required this.priorMean,
  });

  /// The posterior-mean theta (the EAP point estimate). Equals [priorMean]
  /// exactly when there are no responses.
  final double theta;

  /// The posterior standard deviation of theta (shrinks as evidence accumulates).
  final double sd;

  /// How many responses fed the estimate.
  final int responseCount;

  /// The prior mean the estimate started from (returned verbatim when thin).
  final double priorMean;

  /// Whether any responses informed the estimate.
  bool get refined => responseCount > 0;
}

/// Pure, deterministic EAP (Expected A Posteriori) theta re-estimator — the batch
/// posterior-mean ability that COMPLEMENTS the online theta step (ability.dart).
/// Construct with `const EapThetaEstimator()` for the launch profile, or inject
/// [params].
///
/// Given a learner's [ThetaResponse]s (each an item's calibrated (a, b, c) + the
/// correct/incorrect outcome) and a Gaussian theta prior, it integrates theta
/// against the posterior on a fixed quadrature grid:
///   posterior(theta) ~ prior(theta) * Prod_j p_j^{y_j}*(1-p_j)^{1-y_j},
/// p_j = c_j + (1-c_j)*sigma(a_j*(theta-b_j)) (guessing gated to mcq), and returns
/// the posterior mean (and SD). The likelihood is accumulated in LOG space with a
/// log-sum-exp shift so many responses never underflow. THIN-DATA SAFE: with no
/// responses the posterior IS the prior, so [EapThetaResult.theta] == the prior
/// mean. Deterministic, clockless, order-independent (a sum) => golden-testable.
class EapThetaEstimator {
  const EapThetaEstimator([this.params = EapThetaParams.defaults]);

  /// The injected prior + grid knobs.
  final EapThetaParams params;

  /// Re-estimate one learner's global theta from their [responses].
  EapThetaResult estimate(List<ThetaResponse> responses) {
    final int n = responses.length;
    final int m = params.gridPoints;
    final double lo = params.priorMean + params.gridMin;
    final double step = (params.gridMax - params.gridMin) / (m - 1);
    final double invTwoVar = 1.0 / (2.0 * params.priorSd * params.priorSd);

    final List<double> nodes = List<double>.filled(m, 0.0);
    final List<double> logW = List<double>.filled(m, 0.0);
    double maxLog = double.negativeInfinity;
    for (int k = 0; k < m; k++) {
      final double theta = lo + step * k;
      nodes[k] = theta;
      final double d = theta - params.priorMean;
      // log unnormalized Gaussian prior + trapezoidal end-weight.
      double lw = -d * d * invTwoVar + math.log((k == 0 || k == m - 1) ? 0.5 : 1.0);
      for (final ThetaResponse r in responses) {
        final double c = r.type == ExerciseType.mcq ? r.item.c : 0.0;
        final double g = 1.0 / (1.0 + math.exp(-r.item.a * (theta - r.item.b)));
        final double p = c + (1.0 - c) * g;
        final double pc =
            p < 1e-12 ? 1e-12 : (p > 1.0 - 1e-12 ? 1.0 - 1e-12 : p);
        lw += r.correct ? math.log(pc) : math.log(1.0 - pc);
      }
      logW[k] = lw;
      if (lw > maxLog) {
        maxLog = lw;
      }
    }

    double w0 = 0.0;
    double w1 = 0.0;
    double w2 = 0.0;
    for (int k = 0; k < m; k++) {
      final double w = math.exp(logW[k] - maxLog);
      w0 += w;
      w1 += w * nodes[k];
      w2 += w * nodes[k] * nodes[k];
    }
    final double mean = w1 / w0;
    double variance = w2 / w0 - mean * mean;
    if (variance < 0.0) {
      variance = 0.0; // numerical floor
    }
    return EapThetaResult(
      theta: mean,
      sd: math.sqrt(variance),
      responseCount: n,
      priorMean: params.priorMean,
    );
  }
}
