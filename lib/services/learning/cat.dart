// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// CAT-1 [R-G4] — computerized-adaptive placement-test SELECTION math. A pure,
// deterministic core for the onboarding CAT: pick each next item by Maximum
// Fisher Information, re-estimate ability by EAP after every response, and stop
// once the standard error is small enough (within a variable-length envelope).
// It CONSUMES the IRT 1PL/2PL/3PL recall-probability family (irt.dart) and
// produces an ability θ on the same logit scale the online θ ability model
// (ability.dart) and the cold-start anchor priors (cold_start.dart) use.
//
// PURITY CONTRACT (what makes this safe build-ahead and trivially testable):
//   * NO I/O, NO database, NO network, NO provider, NO LLM — it is just
//     arithmetic over plain values and an injected quadrature grid.
//   * NO clock, NO DateTime.now(), NO randomness. The same ability + the same
//     bank + the same answer pattern always return the same selection and the
//     same estimate, so every path can be golden-tested exactly.
//   * The grid, the normal prior, the SE stop threshold and the min/max length
//     are INJECTED (CatConfig) behind a documented const default, so callers
//     can use `const CatModel()` with nothing to configure. Item parameters
//     ride on each item's injected IrtItem.
//
// THE MATH (no constant is invented — each rides on an item or an injected knob):
//   * 3PL ITEM INFORMATION — I(θ) = a²·(Q/P)·((P−c)/(1−c))², with
//     P = the recall probability c + (1−c)·σ(a·(θ−b)) and Q = 1−P. For a 1PL/2PL
//     item (c = 0) this reduces exactly to a²·P·Q, which peaks at θ = b; a higher
//     discrimination a raises the peak (∝ a²); a guessing floor c > 0 shifts the
//     information peak slightly ABOVE b and lowers it. Information is the local
//     precision an item adds about θ — selecting the most informative item is
//     what makes the test converge in as few as the minimum-length items.
//   * MAXIMUM FISHER INFORMATION SELECTION — from the unseen items in the bank,
//     pick the one with the greatest I(θ) at the current ability. Ties break
//     deterministically on the smallest item id, so selection is reproducible.
//   * EAP (Expected A Posteriori) ESTIMATE — over a fixed quadrature grid with a
//     normal prior, weight each grid node by prior × the answer pattern's
//     likelihood (∏ P for a correct response, ∏ (1−P) for a wrong one); the
//     posterior-mean node is the θ estimate and the posterior SD is its standard
//     error. Computed in log-space with a max-subtraction so long patterns can't
//     underflow. With no responses it returns the prior. More-correct patterns
//     push θ up; the SE shrinks as informative items accumulate.
//   * VARIABLE-LENGTH STOP — never stop before the minimum length; always stop at
//     the maximum length; in between, stop once the EAP standard error drops
//     below the injected threshold (default 0.30).
//
// GO-LIVE STOP — this is the placement SELECTION + ESTIMATION math only. NOT
// wired here (each lands at go-live behind the human dual senior-architect
// sign-off): fetching the real placement item bank and its calibrated/cold-start
// item parameters; CONTENT-BALANCING the blueprint across skills/bands and
// EXPOSURE CONTROL (the randomesque exposure draw — the only randomness, and it
// stays out of this deterministic core); the real-CAT-vs-fixed-form readiness
// gate (whether a language's bank is large/spread enough to run the real
// adaptive test at all) and its honesty copy; persisting the seeded θ_global /
// θ_per_skill and the entry point; the cosmetic scaled-score mapping; and the
// EU-AI-Act advisory framing that keeps the placement result non-determinative.
// This file performs none of that — it is pure functions over plain values.

import 'dart:math' as math;

import 'package:ratel/services/learning/irt.dart' show IrtItem, IrtModel;

/// A placement-bank item: a stable [id] (used for the deterministic selection
/// tie-break) plus its injected IRT [params] (difficulty b, discrimination a,
/// pseudo-guessing c).
class CatItem {
  const CatItem({required this.id, required this.params});

  /// Stable item identifier — the deterministic tie-break key when two unseen
  /// items carry equal information (the smaller id wins).
  final String id;

  /// The item's injected IRT parameters (the difficulty/discrimination/guessing
  /// that drive both its information and its recall probability).
  final IrtItem params;
}

/// One graded placement response: the [item] that was shown and whether it was
/// answered [correct]ly. The atomic unit the EAP estimator consumes.
class CatResponse {
  const CatResponse({required this.item, required this.correct});

  /// The item that was administered.
  final CatItem item;

  /// Whether the learner answered it correctly.
  final bool correct;
}

/// An EAP ability estimate: the posterior-mean ability [theta] and its posterior
/// standard deviation [se] (the standard error of the estimate that drives the
/// stop rule). Both on the IRT logit scale.
class EapEstimate {
  const EapEstimate({required this.theta, required this.se});

  /// Posterior-mean ability on the logit scale.
  final double theta;

  /// Posterior standard deviation — the standard error of [theta].
  final double se;
}

/// Injectable CAT configuration: the fixed EAP quadrature grid (inclusive
/// [gridMin]..[gridMax] in [gridStep] increments), the normal prior
/// ([priorMean], [priorSd]), the SE stop [seThreshold], and the variable-length
/// envelope ([minLength]..[maxLength]). The const default supplies documented,
/// pilot-tunable starting values so callers can use `const CatModel()`.
class CatConfig {
  const CatConfig({
    this.gridMin = -4.0,
    this.gridMax = 4.0,
    this.gridStep = 0.1,
    this.priorMean = 0.0,
    this.priorSd = 1.0,
    this.seThreshold = 0.30,
    this.minLength = 8,
    this.maxLength = 25,
  })  : assert(gridMin < gridMax, 'gridMin must be < gridMax'),
        assert(gridStep > 0, 'gridStep must be > 0'),
        assert(priorSd > 0, 'priorSd must be > 0'),
        assert(seThreshold > 0, 'seThreshold must be > 0'),
        assert(minLength >= 0, 'minLength must be >= 0'),
        assert(maxLength >= minLength, 'maxLength must be >= minLength');

  /// Lowest ability node on the quadrature grid (logit scale).
  final double gridMin;

  /// Highest ability node on the quadrature grid (logit scale).
  final double gridMax;

  /// Spacing between adjacent grid nodes.
  final double gridStep;

  /// Mean of the normal ability prior.
  final double priorMean;

  /// Standard deviation of the normal ability prior (> 0).
  final double priorSd;

  /// Stop once the EAP standard error drops below this (real-CAT stop rule).
  final double seThreshold;

  /// Minimum number of items before the SE stop can fire.
  final int minLength;

  /// Maximum number of items; the test always stops here.
  final int maxLength;

  /// Documented, pilot-tunable build-now defaults (min 8 / max 25, SE < 0.30,
  /// a standard normal prior on a −4…+4 grid in 0.1-logit steps).
  static const CatConfig defaults = CatConfig();
}

/// Pure, deterministic CAT selection + estimation engine. Construct with
/// `const CatModel()` for the defaults, or inject a custom [config]. Reuses the
/// IRT recall-probability family for every probability it needs.
class CatModel {
  const CatModel([this.config = CatConfig.defaults]);

  /// The injected grid / prior / stop-rule configuration.
  final CatConfig config;

  static const IrtModel _irt = IrtModel();

  /// Fisher information I(θ) that [item] contributes at ability [theta] under the
  /// 3PL model: I = a²·(Q/P)·((P−c)/(1−c))², with P the recall probability and
  /// Q = 1−P. For a 1PL/2PL item (c = 0) this is exactly a²·P·Q. Always ≥ 0;
  /// peaks at θ = b for 1PL and just above b when c > 0. Higher a raises the peak.
  double information(double theta, IrtItem item) {
    final double p = _irt.pCorrectForItem(theta, item);
    final double q = 1.0 - p;
    final double a = item.a;
    final double c = item.c;
    if (c == 0.0) {
      return a * a * p * q;
    }
    final double ratio = (p - c) / (1.0 - c);
    return a * a * (q / p) * ratio * ratio;
  }

  /// Maximum Fisher Information selection: from [bank], among items whose id is
  /// NOT in [seen], return the one carrying the greatest [information] at
  /// [theta]. Deterministic tie-break — when two unseen items tie on information,
  /// the smaller id wins. Returns null when every bank item has been seen (the
  /// caller then stops or falls back). Pure: no randomness, no exposure draw.
  CatItem? selectNext(List<CatItem> bank, double theta, Set<String> seen) {
    CatItem? best;
    double bestInfo = double.negativeInfinity;
    for (final CatItem candidate in bank) {
      if (seen.contains(candidate.id)) {
        continue;
      }
      final double info = information(theta, candidate.params);
      if (best == null ||
          info > bestInfo ||
          (info == bestInfo && candidate.id.compareTo(best.id) < 0)) {
        best = candidate;
        bestInfo = info;
      }
    }
    return best;
  }

  /// EAP (Expected A Posteriori) ability estimate from a [responses] pattern,
  /// integrated over the fixed quadrature grid with the normal prior. Returns the
  /// posterior-mean θ and its posterior SD (the standard error). With no
  /// responses it returns the prior (mean [CatConfig.priorMean], SD
  /// [CatConfig.priorSd], up to grid truncation). Pure + deterministic; computed
  /// in log-space with a max-subtraction so long patterns cannot underflow.
  EapEstimate eap(List<CatResponse> responses) {
    final List<double> grid = _grid();
    final List<double> logWeights = List<double>.filled(grid.length, 0.0);
    double maxLog = double.negativeInfinity;
    for (int i = 0; i < grid.length; i++) {
      final double theta = grid[i];
      double logLike = _logPriorKernel(theta);
      for (final CatResponse r in responses) {
        final double p = _irt.pCorrectForItem(theta, r.item.params);
        logLike += r.correct ? math.log(p) : math.log(1.0 - p);
      }
      logWeights[i] = logLike;
      if (logLike > maxLog) {
        maxLog = logLike;
      }
    }

    double sumW = 0.0;
    double sumWTheta = 0.0;
    final List<double> weights = List<double>.filled(grid.length, 0.0);
    for (int i = 0; i < grid.length; i++) {
      final double w = math.exp(logWeights[i] - maxLog);
      weights[i] = w;
      sumW += w;
      sumWTheta += grid[i] * w;
    }
    final double mean = sumWTheta / sumW;

    double sumWVar = 0.0;
    for (int i = 0; i < grid.length; i++) {
      final double d = grid[i] - mean;
      sumWVar += weights[i] * d * d;
    }
    final double variance = sumWVar / sumW;
    return EapEstimate(theta: mean, se: math.sqrt(variance));
  }

  /// The variable-length stop rule: given the number of items [answered] and the
  /// current EAP standard error [se], whether the CAT should stop. Never stops
  /// before [CatConfig.minLength]; always stops at [CatConfig.maxLength]; in
  /// between, stops once [se] is strictly below [CatConfig.seThreshold]. Pure.
  bool shouldStop(int answered, double se) {
    if (answered < config.minLength) {
      return false;
    }
    if (answered >= config.maxLength) {
      return true;
    }
    return se < config.seThreshold;
  }

  /// The fixed quadrature grid: θ from [CatConfig.gridMin] to
  /// [CatConfig.gridMax] inclusive in [CatConfig.gridStep] increments.
  List<double> _grid() {
    final int count =
        ((config.gridMax - config.gridMin) / config.gridStep).round() + 1;
    return List<double>.generate(
      count,
      (int i) => config.gridMin + i * config.gridStep,
    );
  }

  /// Log of the unnormalized normal prior kernel at [theta]; the normalizing
  /// constant is dropped because it cancels in the posterior normalization.
  double _logPriorKernel(double theta) {
    final double z = (theta - config.priorMean) / config.priorSd;
    return -0.5 * z * z;
  }
}
