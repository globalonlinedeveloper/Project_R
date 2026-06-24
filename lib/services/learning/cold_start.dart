// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// COLDSTART-1 [R-G7] — cold-start difficulty/ability PRIORS. A pure,
// deterministic mapping from a CEFR band to (a) a never-seen item's cold-start
// `irt_b` difficulty prior and (b) a learner's cold-start θ ability prior, so
// the app is genuinely adaptive on day one with no answer data yet (R-G7).
//
// PURITY CONTRACT (what makes this safe build-ahead and trivially testable):
//   * NO I/O, NO database, NO network, NO provider, NO LLM — it is just a
//     table lookup plus a clamp. The gen-time LLM/feature difficulty guess is
//     NOT called here; the caller passes its result IN as `rawOffset`, exactly
//     as the FSRS core takes `elapsedDays` in — so this stays pure and can be
//     golden-tested exactly.
//   * NO clock, NO DateTime.now(), NO randomness. The same band + the same
//     offset + the same anchors always returns the same `irt_b`.
//   * The anchor table + the offset bound are INJECTED (CefrAnchors) with a
//     documented const default, so callers can use `const ColdStartModel()`
//     with nothing to configure.
//
// THE SCALE + THE CLAMP (the P0-8 cold-start anchor table — pins both):
//   * `irt_b` and learner θ live on the standard logit scale (≈ −3 easy …
//     +3 hard). Each CEFR band has a fixed anchor — A1 −2.5 · A2 −1.5 ·
//     B1 −0.5 · B2 +0.5 · C1 +1.5 · C2 +2.5 (even 1.0-logit spacing).
//   * A never-seen item's estimated difficulty is its band anchor plus a
//     BOUNDED offset of magnitude ≤ 0.5 logits (the gen-time guess). The offset
//     is CLAMPED to ±offsetBound, so each band owns a 1.0-logit slice (e.g.
//     B1 = [−1.0, 0.0]) and a cold-start item CANNOT cross into a neighbour
//     band. (offsetBound defaults to half the 1.0 inter-anchor spacing = 0.5.)
//   * A learner's cold-start ability prior is the band anchor θ — an ability at
//     which a mid-band item is ~50% likely. This is the value that seeds the
//     online θ engine's cold-start (AbilityState.coldStart) when there is no
//     placement result.
//   * Anchors + the offset bound are documented, pilot-tunable starting values.
//
// GO-LIVE STOP — this is the cold-start PRIOR math only. NOT wired here (each
// lands at go-live behind the human dual senior-architect sign-off): the live
// LLM/feature model that produces the raw `irt_b` offset for a never-seen item;
// validating the cold-start priors against the fixed published anchor set
// before fan-out (the placement sanity-check); the staged recalibration ladder
// that sharpens `irt_b` from real answers; and seeding a learner's ability
// cold-start from the CAT placement θ (this CEFR prior is only the
// no-placement fallback). This file performs none of that — it is pure
// functions over plain values.

import 'package:ratel/content/models/enums.dart' show CefrLevel;

/// Injectable cold-start anchor table: the per-CEFR-band `irt_b` anchor on the
/// logit scale, plus the maximum distance a gen-time difficulty guess may sit
/// from its band anchor. The const default supplies the documented,
/// pilot-tunable P0-8 starting values (A1 −2.5 … C2 +2.5 on even 1.0-logit
/// spacing; a ±0.5 offset bound) so callers can use `const ColdStartModel()`
/// with nothing to configure.
class CefrAnchors {
  const CefrAnchors({
    this.a1 = -2.5,
    this.a2 = -1.5,
    this.b1 = -0.5,
    this.b2 = 0.5,
    this.c1 = 1.5,
    this.c2 = 2.5,
    this.offsetBound = 0.5,
  }) : assert(offsetBound >= 0, 'offsetBound must be >= 0');

  /// A1 difficulty anchor on the logit scale.
  final double a1;

  /// A2 difficulty anchor on the logit scale.
  final double a2;

  /// B1 difficulty anchor on the logit scale.
  final double b1;

  /// B2 difficulty anchor on the logit scale.
  final double b2;

  /// C1 difficulty anchor on the logit scale.
  final double c1;

  /// C2 difficulty anchor on the logit scale.
  final double c2;

  /// Maximum |offset| (logits) a cold-start guess may sit from its band anchor.
  /// With even 1.0-logit anchor spacing, the default 0.5 makes each band own a
  /// 1.0-logit slice that exactly tiles the scale, so a clamped prior can never
  /// cross into a neighbour band.
  final double offsetBound;

  /// Documented, pilot-tunable build-now defaults (the P0-8 anchor table).
  static const CefrAnchors defaults = CefrAnchors();

  /// The `irt_b` anchor for [band] on the logit scale (total and non-null).
  double anchorFor(CefrLevel band) => switch (band) {
        CefrLevel.a1 => a1,
        CefrLevel.a2 => a2,
        CefrLevel.b1 => b1,
        CefrLevel.b2 => b2,
        CefrLevel.c1 => c1,
        CefrLevel.c2 => c2,
      };
}

/// Pure, deterministic cold-start prior engine. Construct with
/// `const ColdStartModel()` for the defaults, or inject a custom [anchors]
/// table.
class ColdStartModel {
  const ColdStartModel([this.anchors = CefrAnchors.defaults]);

  /// The injected anchor table + offset bound.
  final CefrAnchors anchors;

  /// The cold-start `irt_b` difficulty prior for a never-seen item in [band]
  /// whose gen-time guess sits [rawOffset] logits from the band anchor. The
  /// offset is CLAMPED to ±`anchors.offsetBound`, so the result always stays in
  /// the band's slice `[anchor − bound, anchor + bound]` and never crosses into
  /// a neighbour band. With the default [rawOffset] of 0 it returns the exact
  /// band anchor.
  double irtBForItem(CefrLevel band, [double rawOffset = 0.0]) =>
      anchors.anchorFor(band) + _clampOffset(rawOffset);

  /// The cold-start ability θ prior for a learner placed (or self-declared) at
  /// [band], on the same logit scale as `irt_b`: the band anchor — an ability
  /// at which a mid-band item is ~50% likely. Seeds the online θ engine's
  /// cold-start when there is no placement result.
  double priorThetaForBand(CefrLevel band) => anchors.anchorFor(band);

  /// The band whose cold-start slice `[anchor − bound, anchor + bound]` owns
  /// [irtB], or null if [irtB] lies outside every band's slice. A value exactly
  /// on a shared boundary resolves to the LOWER band (ties broken by ascending
  /// band order). The inverse-ish companion to [irtBForItem] — a validity check
  /// that a prior has not left its band.
  CefrLevel? bandFor(double irtB) {
    CefrLevel? best;
    double bestDistance = double.infinity;
    for (final CefrLevel band in CefrLevel.values) {
      final double distance = (irtB - anchors.anchorFor(band)).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        best = band;
      }
    }
    return bestDistance <= anchors.offsetBound ? best : null;
  }

  double _clampOffset(double offset) {
    final double bound = anchors.offsetBound;
    if (offset > bound) {
      return bound;
    }
    if (offset < -bound) {
      return -bound;
    }
    return offset;
  }
}
