// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// FSRS-1 [R-G5] — FSRS spaced-repetition scheduler CORE. A pure, deterministic
// implementation of the FSRS-6 memory model (Difficulty / Stability /
// Retrievability) that decides when each item should resurface. One engine
// serves both lesson reviews and saved-word flashcards (R-G5).
//
// PURITY CONTRACT (what makes this safe build-ahead and trivially testable):
//   * NO I/O, NO database, NO network, NO provider — it is just arithmetic.
//   * NO clock. `elapsedDays` (time since the last review) is passed IN by the
//     caller; the engine NEVER reads DateTime.now(). Given the same card, the
//     same rating, the same elapsed and the same weights it always returns the
//     same result — so it can be golden-tested exactly.
//   * The 21 model weights + desired-retention are INJECTED (FsrsParams), with
//     a published-default const so callers need supply nothing.
//
// WEIGHTS — NOT INVENTED. `FsrsParams.fsrs6DefaultWeights` is the published
// FSRS-6 21-weight DEFAULT_PARAMETERS vector from open-spaced-repetition/py-fsrs
// (src .../scheduler.py: FSRS_DEFAULT_DECAY = 0.1542; the 21-tuple verified
// 2026-06-24). Desired-retention defaults to 0.85 (the v1 ~0.85 band).
//
// PIN / UPGRADE SEAM (FSRS-6 now, FSRS-7 later — same "pin known-good, upgrade
// deliberately" discipline as the Flutter/Rive pins): FSRS-7 (35-weight, dual
// forgetting-curve) is the eventual target, but the maintained packages
// (py-fsrs / ts-fsrs / fsrs-rs) still DEFAULT to FSRS-6 (21-weight), so FSRS-6 is
// the proven build-now default. The decay is already parameterized (weight 20),
// the upgrade path: ship an FSRS-7 params vector + dual-curve forgetting formula
// behind this SAME injected `FsrsParams`/`Fsrs` seam once a production-ready
// FSRS-7 Dart port exists. This file does NOT invent FSRS-7 weights.
//
// GO-LIVE STOP — this is the scheduling MATH only. NOT wired here (lands at
// go-live behind the human dual senior-architect sign-off): persisting the
// returned card into the learner-item-state store + the due-queue, sourcing
// `elapsedDays`/`now` from the server clock, the per-user weight RE-FIT after
// ~1,000 reviews (this core runs on the cohort/default weights until then),
// same-day learning/relearning STEP timing (minutes-scale steps) and Anki-style
// interval fuzz. The engine state names map 1:1 onto the stored FsrsState
// {new_, learning, review, relearning}, so wiring is a direct field copy.

import 'dart:math' as math;

import 'package:ratel/content/models/enums.dart' show FsrsState;

/// The learner's graded outcome for one review, mapped from the autoscorer.
/// Values match the stored review-log rating ints (Again 1 .. Easy 4) and the
/// FSRS grade convention used throughout the weight formulas.
enum FsrsRating {
  again(1),
  hard(2),
  good(3),
  easy(4);

  const FsrsRating(this.value);

  /// The 1..4 grade integer (Again=1, Hard=2, Good=3, Easy=4).
  final int value;

  bool get _isRecall => this != FsrsRating.again;
  bool get _isPass => this == FsrsRating.good || this == FsrsRating.easy;
}

/// Immutable per-(user,item) memory state — the FSRS core the stored
/// learner-item-state row carries. `stability`/`difficulty` are null only for a
/// brand-new, never-reviewed card.
class FsrsCard {
  const FsrsCard({
    this.state = FsrsState.new_,
    this.stability,
    this.difficulty,
    this.reps = 0,
    this.lapses = 0,
  });

  /// A fresh, never-reviewed card.
  const FsrsCard.newItem() : this();

  /// FSRS lifecycle state — reused from the stored schema enum so the result
  /// drops straight into the learner-item-state row.
  final FsrsState state;

  /// Memory stability in days (time for retrievability to fall to 0.9). Null
  /// before the first review.
  final double? stability;

  /// Item difficulty on the 1..10 scale. Null before the first review.
  final double? difficulty;

  /// Total number of reviews this card has received.
  final int reps;

  /// Number of lapses (Again pressed while the card was in the review state).
  final int lapses;

  /// True before the first review (no stability/difficulty yet).
  bool get isNew => stability == null || difficulty == null;
}

/// The result of scheduling one review: the updated card plus the next
/// interval. `intervalDays` is the FSRS-6 whole-day interval (>= 1) the card is
/// due in; `rawIntervalDays` is the unrounded fractional interval (the
/// fractional-day value the FSRS-7 upgrade will surface directly).
class FsrsReview {
  const FsrsReview({
    required this.card,
    required this.intervalDays,
    required this.rawIntervalDays,
    required this.retrievability,
  });

  /// The updated memory state after this review.
  final FsrsCard card;

  /// Whole-day interval until the card is next due (>= 1, <= maximum).
  final int intervalDays;

  /// Unrounded fractional interval in days (FSRS-7-ready seam).
  final double rawIntervalDays;

  /// Retrievability at review time (probability the item was recallable). 0 for
  /// the first-ever review of a new card.
  final double retrievability;
}

/// Injectable FSRS parameters: the 21 model weights + the desired-retention
/// target. The default const supplies the published FSRS-6 vector so callers
/// can use `const Fsrs()` with nothing to configure.
class FsrsParams {
  const FsrsParams({
    this.weights = fsrs6DefaultWeights,
    this.desiredRetention = 0.85,
  }) : assert(
          desiredRetention > 0 && desiredRetention < 1,
          'desiredRetention must be in (0, 1)',
        );

  /// The 21 FSRS-6 model weights (index 0..20). FSRS-6 requires exactly 21
  /// (a wrong-length vector throws on first use — the published default is 21).
  final List<double> weights;

  /// Target probability of recall at the moment a card next comes due.
  final double desiredRetention;

  /// Published FSRS-6 DEFAULT_PARAMETERS (open-spaced-repetition/py-fsrs,
  /// scheduler.py; weight 20 = FSRS_DEFAULT_DECAY = 0.1542). Not invented.
  static const List<double> fsrs6DefaultWeights = <double>[
    0.212,
    1.2931,
    2.3065,
    8.2956,
    6.4133,
    0.8334,
    3.0194,
    0.001,
    1.8722,
    0.1666,
    0.796,
    1.4835,
    0.0614,
    0.2629,
    1.6483,
    0.6014,
    1.8729,
    0.5425,
    0.0912,
    0.0658,
    0.1542,
  ];

  /// The proven build-now default: FSRS-6 weights + the v1 0.85 retention band.
  static const FsrsParams fsrs6Default = FsrsParams();

  /// FSRS-6 decay exponent for the power forgetting curve: -weight[20].
  double get decay => -weights[20];

  /// FSRS-6 curve factor, derived so that retrievability == 0.9 when elapsed
  /// equals stability: 0.9^(1/decay) - 1.
  double get factor => math.pow(0.9, 1 / decay).toDouble() - 1;
}

/// Pure, deterministic FSRS-6 spaced-repetition engine. Construct with
/// `const Fsrs()` for the published defaults, or inject custom [params].
class Fsrs {
  const Fsrs([this.params = FsrsParams.fsrs6Default]);

  /// The injected weights + desired-retention.
  final FsrsParams params;

  static const double _stabilityMin = 0.001;
  static const double _minDifficulty = 1.0;
  static const double _maxDifficulty = 10.0;
  static const int _maximumInterval = 36500;

  /// Predicted probability the [card] is recallable after [elapsedDays] days
  /// since its last review. Returns 0 for a never-reviewed card. Monotonically
  /// decreasing in `elapsedDays`; equals 0.9 when `elapsedDays == stability`.
  double retrievability(FsrsCard card, double elapsedDays) {
    final double? s = card.stability;
    if (s == null) {
      return 0.0;
    }
    final double t = elapsedDays < 0 ? 0.0 : elapsedDays;
    return math.pow(1 + params.factor * t / s, params.decay).toDouble();
  }

  /// Apply one graded review to [card] and return the updated card + interval.
  /// [elapsedDays] is the time since the card's last review (passed in — the
  /// engine reads no clock). Pure: identical inputs always yield identical
  /// output.
  FsrsReview schedule(FsrsCard card, FsrsRating rating, double elapsedDays) {
    final double nextStability;
    final double nextDifficulty;
    final double r;
    if (card.isNew) {
      r = 0.0;
      nextStability = _clampStability(_initialStability(rating));
      nextDifficulty = _clampDifficulty(_initialDifficulty(rating));
    } else {
      final double s = card.stability!;
      final double d = card.difficulty!;
      r = retrievability(card, elapsedDays);
      final double rawStability = elapsedDays < 1
          ? _shortTermStability(s, rating)
          : _nextStability(d, s, r, rating);
      nextStability = _clampStability(rawStability);
      nextDifficulty = _clampDifficulty(_nextDifficulty(d, rating));
    }

    final bool isLapse = card.state == FsrsState.review && rating == FsrsRating.again;
    final FsrsCard nextCard = FsrsCard(
      state: _nextState(card.state, rating),
      stability: nextStability,
      difficulty: nextDifficulty,
      reps: card.reps + 1,
      lapses: card.lapses + (isLapse ? 1 : 0),
    );

    final double raw = _rawInterval(nextStability);
    return FsrsReview(
      card: nextCard,
      intervalDays: _wholeDayInterval(raw),
      rawIntervalDays: raw,
      retrievability: r,
    );
  }

  // --- FSRS-6 memory-model math (formulas: py-fsrs scheduler.py) -------------

  double _initialStability(FsrsRating rating) => params.weights[rating.value - 1];

  double _initialDifficulty(FsrsRating rating) =>
      params.weights[4] - math.exp(params.weights[5] * (rating.value - 1)) + 1;

  // Mean-reversion target: initial difficulty for Easy, left unclamped.
  double _initialDifficultyEasyUnclamped() =>
      params.weights[4] - math.exp(params.weights[5] * (FsrsRating.easy.value - 1)) + 1;

  double _nextDifficulty(double difficulty, FsrsRating rating) {
    final double deltaDifficulty = -(params.weights[6] * (rating.value - 3));
    final double damped = difficulty + (10.0 - difficulty) * deltaDifficulty / 9.0;
    return params.weights[7] * _initialDifficultyEasyUnclamped() +
        (1 - params.weights[7]) * damped;
  }

  double _nextStability(double difficulty, double stability, double r, FsrsRating rating) =>
      rating._isRecall
          ? _recallStability(difficulty, stability, r, rating)
          : _forgetStability(difficulty, stability, r);

  double _recallStability(double difficulty, double stability, double r, FsrsRating rating) {
    final double hardPenalty = rating == FsrsRating.hard ? params.weights[15] : 1.0;
    final double easyBonus = rating == FsrsRating.easy ? params.weights[16] : 1.0;
    return stability *
        (1 +
            math.exp(params.weights[8]) *
                (11 - difficulty) *
                math.pow(stability, -params.weights[9]).toDouble() *
                (math.exp((1 - r) * params.weights[10]) - 1) *
                hardPenalty *
                easyBonus);
  }

  double _forgetStability(double difficulty, double stability, double r) {
    final double longTerm = params.weights[11] *
        math.pow(difficulty, -params.weights[12]).toDouble() *
        (math.pow(stability + 1, params.weights[13]).toDouble() - 1) *
        math.exp((1 - r) * params.weights[14]);
    final double shortTerm =
        stability / math.exp(params.weights[17] * params.weights[18]);
    return math.min(longTerm, shortTerm);
  }

  double _shortTermStability(double stability, FsrsRating rating) {
    double increase = math.exp(params.weights[17] * (rating.value - 3 + params.weights[18])) *
        math.pow(stability, -params.weights[19]).toDouble();
    if (rating._isPass && increase < 1.0) {
      increase = 1.0;
    }
    return stability * increase;
  }

  double _rawInterval(double stability) =>
      (stability / params.factor) *
      (math.pow(params.desiredRetention, 1 / params.decay).toDouble() - 1);

  int _wholeDayInterval(double raw) {
    final int rounded = raw.round();
    if (rounded < 1) {
      return 1;
    }
    return rounded > _maximumInterval ? _maximumInterval : rounded;
  }

  double _clampStability(double s) => s < _stabilityMin ? _stabilityMin : s;

  double _clampDifficulty(double d) {
    if (d < _minDifficulty) {
      return _minDifficulty;
    }
    return d > _maxDifficulty ? _maxDifficulty : d;
  }

  FsrsState _nextState(FsrsState current, FsrsRating rating) => switch (current) {
        FsrsState.new_ ||
        FsrsState.learning =>
          rating._isPass ? FsrsState.review : FsrsState.learning,
        FsrsState.review =>
          rating == FsrsRating.again ? FsrsState.relearning : FsrsState.review,
        FsrsState.relearning =>
          rating._isPass ? FsrsState.review : FsrsState.relearning,
      };
}
