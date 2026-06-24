// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// IRT-1 [R-G3] — item-response recall-PROBABILITY family. A pure, deterministic
// 1PL / 2PL / 3PL logistic giving the chance a learner of ability θ answers an
// item of difficulty b correctly, generalizing the Rasch success curve into the
// graduated ladder R-G3 specifies: launch 1PL on priors → add a 2PL
// discrimination slope `a` once an item has ~1,000 answers → add a 3PL
// pseudo-guessing floor `c` for `mcq` only.
//
// PURITY CONTRACT (what makes this safe build-ahead and trivially testable):
//   * NO I/O, NO database, NO network, NO provider, NO LLM — it is just
//     arithmetic over plain values.
//   * NO clock, NO DateTime.now(), NO randomness. The same θ + the same item
//     params always return the same probability, so it can be golden-tested
//     exactly.
//   * The item parameters (a, b, c) are INJECTED per item (IrtItem). The
//     defaults a = 1.0 and c = 0.0 collapse the family to 1PL/Rasch with no
//     configuration — exactly the launch rung of the ladder.
//
// THE FAMILY (one formula, three rungs — no constant is invented):
//   * P(correct | θ) = c + (1 − c)·σ(a·(θ − b)), where σ(x) = 1/(1 + e^(−x)),
//     θ is ability and b the item difficulty (irt_b), both on the standard
//     logit scale (≈ −3 easy … +3 hard).
//   * 1PL / Rasch — a = 1, c = 0 → P = σ(θ − b). This is exactly the existing
//     online θ engine's success curve (the Rasch `AbilityModel.pCorrect`);
//     IRT-1 is its strict generalization, so the launch rung needs no new math.
//   * 2PL — c = 0, a free → P = σ(a·(θ − b)). The discrimination `a` (> 0) is
//     the slope through the midpoint: a > 1 separates abilities more sharply
//     around b, a < 1 more gently. The midpoint P(θ = b) stays 0.5 for every a.
//   * 3PL — c > 0 → P = c + (1 − c)·σ(a·(θ − b)). The pseudo-guessing `c` lifts
//     the LOWER asymptote (P → c as θ → −∞: even a far-below-difficulty learner
//     can guess right) while the UPPER asymptote stays 1 (P → 1 as θ → +∞). The
//     midpoint becomes P(θ = b) = c + (1 − c)/2 = 0.5 + c/2.
//   * MCQ-ONLY GUESSING GUARD — a guessing floor only makes sense where a blind
//     guess can land correct, i.e. multiple-choice. `guessingFor` returns an
//     item's stored c only for `ExerciseType.mcq` and 0 for every other type,
//     so a typed score drops to the 2PL form (c = 0) for a non-mcq item even if
//     a c was stored.
//
// GO-LIVE STOP — this is the recall-PROBABILITY math only. NOT wired here (each
// lands at go-live behind the human dual senior-architect sign-off): CALIBRATING
// a / b / c from the append-only ReviewLog (the staged ladder — 1PL on priors,
// 1PL refine at a few hundred answers, 2PL `a` at ~1,000, 3PL `c` for mcq); the
// gen-time / cold-start prior that seeds b before any answers exist; and any
// item selection / scoring that consumes these probabilities. This file does
// none of that — it is pure functions over plain values.

import 'dart:math' as math;

import 'package:ratel/content/models/enums.dart' show ExerciseType;

/// Immutable IRT parameters for a single item: the difficulty [b] (irt_b,
/// required), the discrimination [a] (irt_a, default 1.0 = the Rasch unit
/// slope) and the pseudo-guessing lower asymptote [c] (irt_c, default 0.0 = no
/// guessing). All on the standard logit scale. The defaults collapse to
/// 1PL/Rasch, so `IrtItem(b: ...)` is a launch-rung item with nothing else to
/// configure.
class IrtItem {
  const IrtItem({
    required this.b,
    this.a = 1.0,
    this.c = 0.0,
  })  : assert(a > 0, 'discrimination a must be > 0'),
        assert(c >= 0 && c < 1, 'pseudo-guessing c must be in [0, 1)');

  /// Item difficulty (irt_b) on the logit scale (≈ −3 easy … +3 hard).
  final double b;

  /// Item discrimination (irt_a) — the slope of the curve through its midpoint.
  /// Strictly > 0; 1.0 is the Rasch unit slope (the 1PL launch rung).
  final double a;

  /// Item pseudo-guessing (irt_c) — the lower asymptote, the chance a learner
  /// far below the difficulty still answers correctly. In [0, 1); 0 outside the
  /// 3PL rung. Only meaningful for a guessable (mcq) item — see
  /// [IrtModel.guessingFor].
  final double c;
}

/// Pure, deterministic IRT recall-probability engine. Construct with
/// `const IrtModel()` — there is nothing to inject; every parameter rides on the
/// per-item [IrtItem]. Generalizes the Rasch `AbilityModel.pCorrect` into the
/// full 1PL / 2PL / 3PL family.
class IrtModel {
  const IrtModel();

  /// The 1PL / 2PL / 3PL recall probability P = c + (1 − c)·σ(a·(θ − b)) that a
  /// learner of ability [theta] answers an item of difficulty [b] correctly.
  /// [a] (> 0) is the discrimination slope (default 1.0 → Rasch unit slope);
  /// [c] (in [0, 1)) is the pseudo-guessing lower asymptote (default 0.0 →
  /// 1PL/2PL). With a = 1, c = 0 this is exactly σ(θ − b), the Rasch curve.
  /// Always in [c, 1) for finite inputs; monotonically increasing in [theta].
  double pCorrect3pl(
    double theta,
    double b, {
    double a = 1.0,
    double c = 0.0,
  }) {
    assert(a > 0, 'discrimination a must be > 0');
    assert(c >= 0 && c < 1, 'pseudo-guessing c must be in [0, 1)');
    return c + (1.0 - c) * _sigma(a * (theta - b));
  }

  /// Recall probability for [item] at ability [theta], applying the item's full
  /// stored (a, b, c) parameters — the 3PL form using the item's own guessing
  /// floor (use [pCorrectForTypedItem] to apply the mcq-only guard instead).
  double pCorrectForItem(double theta, IrtItem item) =>
      pCorrect3pl(theta, item.b, a: item.a, c: item.c);

  /// Recall probability for [item] of exercise [type] at ability [theta] with
  /// the MCQ-ONLY guessing guard: the item's guessing floor is honoured only
  /// when [type] is `mcq`, else the curve drops to its 2PL form (c = 0). Use
  /// this when scoring a typed item so a stored c never lifts a non-mcq floor.
  double pCorrectForTypedItem(double theta, IrtItem item, ExerciseType type) =>
      pCorrect3pl(theta, item.b, a: item.a, c: guessingFor(type, item.c));

  /// The guessing floor that actually applies to an item of [type] carrying a
  /// stored guessing value [c]: [c] for an `mcq` (a blind guess can land
  /// correct), 0 for every other exercise type. The mcq-only 3PL guard R-G3
  /// specifies — the same IrtItem can be scored with or without its floor purely
  /// from the item's type.
  double guessingFor(ExerciseType type, double c) =>
      type == ExerciseType.mcq ? c : 0.0;

  /// The logistic σ(x) = 1/(1 + e^(−x)).
  double _sigma(double x) => 1.0 / (1.0 + math.exp(-x));
}
