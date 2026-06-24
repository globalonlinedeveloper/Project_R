// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// PATHSERVE-1 [R-G8] — launch path-serving SELECTION rules. Two pure,
// deterministic intra-unit selection rules layered on the QA'd CEFR macro-spine
// (the macro-spine itself is fixed/QA'd and stays OUT of this core):
//
//   1. ENCODING-PHASE ORDERING (P1-7) — a brand-new skill is practiced BLOCKED
//      (massed) at first exposure to encode it, switching to INTERLEAVED once
//      the per-skill θ crosses an "encoded" threshold (interleaving lifts
//      long-term retention + discrimination but hurts novices at first
//      exposure). Cold-start (never seen) always starts blocked. The threshold
//      is a documented, pilot-tunable default that AUTO-TUNES from ReviewLog at
//      go-live — the auto-tune stays OUT; the default is injected here.
//
//   2. PRODUCTIVE-RETRIEVAL REVIEW BIAS (P1-8) — from A2 up, review defaults to
//      productive item types (translate-production, typed cloze, dictation,
//      speak, word_order) because recall beats recognition for retention;
//      mcq/match are kept for cold-start, the CAT placement and A1 first-
//      exposure (fast + the 3PL guessing model already discounts MCQ).
//      Device/locale-smart: where typing is awkward, favor the non-typing
//      productive types (speak, word_order). The real device/locale SIGNAL
//      stays OUT — it is passed in as an injected hint.
//
// PURITY CONTRACT (what makes this safe build-ahead and trivially testable):
//   * NO I/O, NO database, NO network, NO provider — pure functions over plain
//     values (a θ double, a bool, two enums, an injected config + hint).
//   * NO clock, NO randomness. Given the same inputs it always returns the same
//     decision, so every path is golden-testable exactly.
//   * The encoded-θ threshold, the productive / recognition / typing-heavy type
//     sets, the band cutoff and the device/locale hint are ALL INJECTED behind a
//     const default so callers can use `const PathServingModel()` with nothing
//     to configure.
//
// GO-LIVE STOP — this is the SELECTION LOGIC only. NOT wired here (each lands at
// go-live behind the human dual senior-architect sign-off): the QA'd macro-spine
// ordering that bounds the route; the per-skill θ SOURCE (the online θ ability
// engine / the placement CAT) read into these functions; the live ReviewLog
// auto-tune of the encoded threshold and the productive/recognition mix; the
// actual item-bank draw that turns an allowed type set into a served exercise;
// and the real device/locale signal that sets the typing-awkward hint. This file
// performs none of that — it only maps injected values to a phase + a type set.

import 'package:ratel/content/models/enums.dart' show CefrLevel, ExerciseType;

/// The intra-unit practice ordering for a skill: [blocked] (massed) practice at
/// first exposure to encode a new skill, switching to [interleaved] once the
/// skill is encoded (R-G8 / P1-7).
enum EncodingPhase {
  /// Massed practice — repeated exposures of the same new skill back-to-back,
  /// best for first encoding.
  blocked,

  /// Interleaved practice — the encoded skill mixed among others, best for
  /// long-term retention + discrimination.
  interleaved,
}

/// The selection context a review-type bias is computed for. Recognition types
/// (mcq/match) are kept for [coldStart], the CAT [placement] and A1
/// [firstExposure]; from A2 up an ongoing [review] biases to productive types.
enum SelectionPhase {
  /// No data yet (cold-start) — recognition is favored regardless of band.
  coldStart,

  /// The onboarding / section-entry CAT placement — recognition is favored
  /// (fast, and the 3PL guessing model already discounts MCQ).
  placement,

  /// First exposure to a skill — recognition is favored at A1.
  firstExposure,

  /// Ongoing spaced review / practice — biases to productive from A2 up.
  review,
}

/// An injected device/locale hint. The build-ahead default is "no hint"
/// ([none], the full productive set). The real signal (small screen, awkward
/// IME, locale) is sourced at go-live and passed in here — it is never computed
/// in this core.
class DeviceLocaleHints {
  const DeviceLocaleHints({this.typingAwkward = false});

  /// When true and the result is productive, favor the non-typing productive
  /// types (speak, word_order) over the typing-heavy ones.
  final bool typingAwkward;

  /// The neutral default — no device/locale bias.
  static const DeviceLocaleHints none = DeviceLocaleHints();
}

/// Injectable path-serving configuration: the encoded-θ threshold, the CEFR band
/// from which review turns productive, and the productive / recognition /
/// typing-heavy exercise-type sets. All are documented, pilot-tunable starting
/// values behind a const default so callers can use `const PathServingModel()`.
class PathServingConfig {
  const PathServingConfig({
    this.encodedThreshold = -1.0,
    this.productiveFromBand = CefrLevel.a2,
    this.productiveTypes = _defaultProductiveTypes,
    this.recognitionTypes = _defaultRecognitionTypes,
    this.typingProductiveTypes = _defaultTypingProductiveTypes,
  });

  /// The per-skill θ (logit scale) at/above which a seen skill is "encoded" and
  /// practice switches blocked → interleaved. Documented pilot-tunable default
  /// (≈ −1.0 logits — past the A1 novice band on the cold-start CEFR-anchor
  /// scale); auto-tunes from ReviewLog at go-live.
  final double encodedThreshold;

  /// The CEFR band from which an ongoing review defaults to productive types
  /// (A2 and up); below it (A1) recognition is kept.
  final CefrLevel productiveFromBand;

  /// Productive (recall) review types — the A2+ review default (R-G8 / P1-8).
  final Set<ExerciseType> productiveTypes;

  /// Recognition review types kept for cold-start, the placement and A1
  /// first-exposure.
  final Set<ExerciseType> recognitionTypes;

  /// The typing-heavy subset of [productiveTypes]; dropped when the injected
  /// device/locale hint reports typing is awkward, leaving the non-typing
  /// productive types (speak, word_order).
  final Set<ExerciseType> typingProductiveTypes;

  /// Documented, pilot-tunable build-now default.
  static const PathServingConfig defaults = PathServingConfig();

  static const Set<ExerciseType> _defaultProductiveTypes = <ExerciseType>{
    ExerciseType.translate,
    ExerciseType.cloze,
    ExerciseType.dictation,
    ExerciseType.speak,
    ExerciseType.wordOrder,
  };

  static const Set<ExerciseType> _defaultRecognitionTypes = <ExerciseType>{
    ExerciseType.mcq,
    ExerciseType.match,
  };

  static const Set<ExerciseType> _defaultTypingProductiveTypes =
      <ExerciseType>{
    ExerciseType.translate,
    ExerciseType.cloze,
    ExerciseType.dictation,
  };
}

/// Pure, deterministic path-serving selection engine. Construct with
/// `const PathServingModel()` for the documented defaults, or inject a [config].
/// Holds no mutable state.
class PathServingModel {
  const PathServingModel({this.config = PathServingConfig.defaults});

  /// The injected configuration (threshold, band cutoff + type sets).
  final PathServingConfig config;

  /// ENCODING-PHASE ORDERING (R-G8 / P1-7). A skill is practiced [blocked]
  /// (massed) until it is encoded, then [interleaved]. A never-seen skill
  /// ([hasSeen] == false, cold-start) is always blocked; a seen skill is blocked
  /// while its [perSkillTheta] is below [PathServingConfig.encodedThreshold] and
  /// interleaved once it reaches it.
  EncodingPhase encodingPhase({
    required bool hasSeen,
    required double perSkillTheta,
  }) {
    if (!hasSeen) {
      return EncodingPhase.blocked;
    }
    return perSkillTheta < config.encodedThreshold
        ? EncodingPhase.blocked
        : EncodingPhase.interleaved;
  }

  /// PRODUCTIVE-RETRIEVAL REVIEW BIAS (R-G8 / P1-8). Returns the biased set of
  /// allowed review exercise types for the given CEFR [band], selection [phase]
  /// and injected device/locale [hints]: recognition types (mcq/match) for
  /// cold-start / placement / A1; productive types from A2 up; and where typing
  /// is awkward the productive set narrows to its non-typing types.
  Set<ExerciseType> reviewTypes({
    required CefrLevel band,
    required SelectionPhase phase,
    DeviceLocaleHints hints = DeviceLocaleHints.none,
  }) {
    if (_favorsRecognition(phase, band)) {
      return config.recognitionTypes;
    }
    if (hints.typingAwkward) {
      return config.productiveTypes.difference(config.typingProductiveTypes);
    }
    return config.productiveTypes;
  }

  /// True when [phase]/[band] is a recognition-favored context: cold-start, the
  /// CAT placement, or any band below the productive cutoff (A1 — which covers
  /// A1 first-exposure and A1 review).
  bool _favorsRecognition(SelectionPhase phase, CefrLevel band) =>
      phase == SelectionPhase.coldStart ||
      phase == SelectionPhase.placement ||
      band.index < config.productiveFromBand.index;
}
