// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// CALIBRATION-1 [R-G3] — batch IRT item re-calibration. The periodic re-fit the
// online θ engine (ability.dart) and the recall-probability family (irt.dart)
// both name in their GO-LIVE STOP: recompute an item's difficulty (irt_b) from
// the append-only ReviewLog, following the staged ladder R-G3 specifies —
// 1PL on priors, a 1PL b refine once an item has a few hundred answers, a 2PL
// discrimination `a` fit at ~1,000, a 3PL guessing `c` for mcq later.
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
// THE ESTIMATOR (1PL difficulty b — no constant invented):
//   * For an item with responses {(θ_j, y_j)}, y_j ∈ {1 correct, 0 wrong}, the
//     1PL log-likelihood is Σ_j [ y_j·log σ(θ_j−b) + (1−y_j)·log(1−σ(θ_j−b)) ],
//     σ(x)=1/(1+e^(−x)). Adding a Gaussian prior b ~ N(b0, τ²) centered on the
//     current difficulty b0 gives the MAP objective, whose score (derivative in
//     b) is
//         S(b) = Σ_j ( σ(θ_j − b) − y_j )  −  (b − b0) / τ²
//     which is STRICTLY DECREASING in b (every σ term falls as b rises, so does
//     the prior term) ⇒ a UNIQUE root ⇒ deterministic bisection. b0 is both the
//     prior mean and the initial bracket center; the root is clamped to
//     [bMin, bMax].
//   * τ² ([CalibrationParams.priorVariance]) is the prior width on the logit
//     scale: small τ² trusts the authored difficulty (strong shrinkage), large
//     τ² trusts the data. τ² → ∞ recovers the raw MLE; the const default is a
//     deliberately conservative width for launch-thin data.
//
// GO-LIVE STOP — this is the 1PL difficulty re-fit ONLY. NOT done here (each a
// later rung behind the human dual senior-architect sign-off): the 2PL
// discrimination `a` joint fit at ~1,000 answers and the 3PL mcq guessing `c`
// (this pass REPORTS eligibility for them via the rung but fits only b, keeping
// a/c at their priors); the EAP θ re-estimate that complements the online step;
// and the wiring that reads the ReviewLog out of Supabase, writes the calibrated
// irt_b back onto the item bank, and schedules the batch. Pure values only.

import 'dart:math' as math;

import 'package:ratel/content/models/enums.dart' show ExerciseType;
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
///     item now has enough answers to warrant a 2PL discrimination `a` fit — a
///     later rung, REPORTED here, not performed.
///   * [eligible3pl] — an `mcq` item at/above the 3PL threshold: as
///     [eligible2pl] plus enough answers for a 3PL guessing `c` fit (mcq only),
///     likewise reported not performed.
enum CalibrationRung { insufficientData, refined1pl, eligible2pl, eligible3pl }

/// The immutable, auditable outcome of re-calibrating ONE item. Carries the
/// resulting parameters ([b]/[a]/[c]), the [rung] the data supported, the
/// [responseCount] used, the [priorB] it started from (so [delta] = the signed
/// move), and whether the solver [converged] — everything a review dashboard
/// needs to see WHY a difficulty did (or did not) change.
class CalibrationResult {
  const CalibrationResult({
    required this.b,
    required this.a,
    required this.c,
    required this.rung,
    required this.responseCount,
    required this.priorB,
    required this.converged,
  });

  /// The calibrated difficulty — or, at [CalibrationRung.insufficientData], the
  /// authored [priorB] returned verbatim.
  final double b;

  /// Discrimination — passed through unchanged this rung (1PL fits only `b`).
  final double a;

  /// Guessing floor — passed through unchanged this rung (1PL fits only `b`).
  final double c;

  /// The ladder rung the response count supported.
  final CalibrationRung rung;

  /// How many responses fed the fit.
  final int responseCount;

  /// The authored difficulty the fit started from (the prior mean).
  final double priorB;

  /// Whether the bisection reached tolerance (always true when the prior was
  /// kept or the root was clamped to a bound).
  final bool converged;

  /// Signed difficulty change from the prior (0.0 when the prior was kept).
  double get delta => b - priorB;

  /// Whether the calibrator actually re-fit the difficulty (false at
  /// [CalibrationRung.insufficientData], where the authored value is verbatim).
  bool get refined => rung != CalibrationRung.insufficientData;
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
    this.minResponsesToRefine = 200,
    this.twoPlThreshold = 1000,
    this.threePlThreshold = 2000,
    this.bMin = -6.0,
    this.bMax = 6.0,
    this.tolerance = 1e-9,
    this.maxIterations = 200,
  })  : assert(priorVariance > 0, 'priorVariance (τ²) must be > 0'),
        assert(minResponsesToRefine >= 0, 'minResponsesToRefine must be >= 0'),
        assert(twoPlThreshold >= minResponsesToRefine,
            'twoPlThreshold must be >= minResponsesToRefine'),
        assert(threePlThreshold >= twoPlThreshold,
            'threePlThreshold must be >= twoPlThreshold'),
        assert(bMax > bMin, 'bMax must be > bMin'),
        assert(tolerance > 0, 'tolerance must be > 0'),
        assert(maxIterations > 0, 'maxIterations must be > 0');

  /// τ² — the Gaussian prior variance on `b` (logit scale). Small = trust the
  /// authored difficulty (strong shrinkage); large = trust the data.
  final double priorVariance;

  /// Minimum responses before `b` is re-fit at all; below this the authored
  /// difficulty is kept verbatim (the thin-data floor).
  final int minResponsesToRefine;

  /// Responses at/above which the item is eligible for a 2PL `a` fit (reported).
  final int twoPlThreshold;

  /// Responses at/above which an mcq item is eligible for a 3PL `c` fit
  /// (reported).
  final int threePlThreshold;

  /// Lower / upper clamp on the fitted difficulty (finite ceiling for
  /// separated data).
  final double bMin;
  final double bMax;

  /// Bisection stopping tolerance on |S(b)| and the bracket width.
  final double tolerance;

  /// Bisection iteration cap (a safety bound; the strictly-monotone score
  /// converges well within it).
  final int maxIterations;

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
  /// 3PL eligibility). With fewer than [CalibrationParams.minResponsesToRefine]
  /// responses the authored [priorB] is returned UNCHANGED; at/above it the 1PL
  /// difficulty is MAP-refit toward the data but shrunk to [priorB] by the
  /// Gaussian prior. `a`/`c` always pass through unchanged this rung.
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
        converged: true,
      );
    }

    final (double b, bool converged) = _fitDifficulty(responses, priorB);
    return CalibrationResult(
      b: b,
      a: priorA,
      c: priorC,
      rung: rung,
      responseCount: n,
      priorB: priorB,
      converged: converged,
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
}
