// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// SAVEDWORDS-1 [R-G9] — saved-words → flashcards INTAKE core. A pure,
// deterministic core for the tap-to-define/save vocabulary flow: normalize a
// saved word to a per-course dedup key, decide whether it creates a new
// flashcard (and whether it feeds θ), and meter how many backlogged cards drip
// into the spaced-repetition queue each day so a bulk "save all unknown" can
// never bury the scheduler. The auto-generated flashcards feed the SAME FSRS
// spaced-repetition scheduler as everything else (R-G9).
//
// PURITY CONTRACT (what makes this safe build-ahead and trivially testable):
//   * NO I/O, NO database, NO network, NO provider — it is just normalization,
//     set membership and integer arithmetic over plain values.
//   * NO clock. The current day's already-admitted count and the day boundary
//     are passed IN by the caller; this core NEVER reads DateTime.now(). Given
//     the same inputs it always returns the same decision, so every path is
//     golden-testable exactly.
//   * NO randomness.
//   * The lemmatizer, the calibrated catalog and the daily cap are all INJECTED
//     seams. The lemmatizer defaults to an identity passthrough so the core is
//     pure; the real language-specific lemmatizer plugs into the same seam at
//     go-live. The cap defaults to ~20 (a documented, learner-tunable starting
//     value), behind a const default so callers can use `const SavedWordsModel()`.
//
// THE RULES (locked by R-G9):
//   * DEDUP KEY — (courseId, normalizedLemma). Normalization is lemma-form
//     (injected) + surrounding-whitespace trim + Unicode-aware lowercasing, so
//     re-saving "Hola" / "hola" / "  hola  " in the same course is one card.
//     Dedup is scoped PER COURSE: the same word in two courses is two cards.
//   * DEDUP-AND-PROMOTE — a brand-new word is admitted as a learner-curated
//     flashcard that feeds FSRS but NOT θ/IRT, UNLESS its key also matches the
//     calibrated catalog: then it merges to that calibrated Item and DOES feed
//     θ (the only path by which a saved word moves the official skill score).
//     Dedup wins over promote — an already-saved word is always a no-op.
//   * SAVING IS NEVER BLOCKED — a genuinely new word is always admitted (it is
//     never rejected). The daily cap is NOT a save gate; it only meters how many
//     already-saved backlog cards enter the active FSRS queue per day. The rest
//     wait in the "My Words" backlog and drip-feed at the cap on later days.
//   * DAILY INTAKE METER — given today's already-admitted count, the backlog
//     size and the injected daily cap: drip = min(max(0, cap − admittedToday),
//     backlog); the remainder stays in the backlog. A cap of 0 pauses intake.
//
// GO-LIVE STOP — this is the intake/dedup/metering LOGIC only. NOT wired here
// (each lands at go-live behind the human dual senior-architect sign-off): the
// live VocabEntry / personal-vocab read + the calibrated-catalog lookup that
// supplies the real already-saved set and catalog keys; the real per-language
// lemmatizer behind the injected seam; writing the dripped cards into the FSRS
// queue / learner-item-state store and merging a promoted card onto its
// calibrated Item; the "My Words" Vocabulary-Hub backlog view; and sourcing the
// per-day boundary + already-admitted count from the server clock. This file
// performs none of that — it is pure functions over plain values.

import 'dart:math' as math;

/// The injected lemmatizer seam: maps a raw surface word to its lemma (dictionary
/// form). The build-ahead default is identity ([_identityLemma]); the real
/// language-specific lemmatizer plugs in here at go-live without touching callers.
typedef LemmaNormalizer = String Function(String raw);

/// Build-ahead default lemmatizer: a pure passthrough that keeps the core
/// deterministic. Normalization still trims + lowercases on top of this, so the
/// identity lemma already deduplicates case and surrounding whitespace.
String _identityLemma(String raw) => raw;

/// A normalized, per-course dedup key — the identity of a saved-word flashcard.
/// Two saves collapse to one card iff they share a key; value equality makes the
/// key usable directly in a [Set]/[Map].
class SavedWordKey {
  const SavedWordKey({required this.courseId, required this.normalizedLemma});

  /// The course the word was saved in — dedup is scoped per course.
  final String courseId;

  /// The normalized lemma (lemma seam + trim + Unicode lowercasing).
  final String normalizedLemma;

  @override
  bool operator ==(Object other) =>
      other is SavedWordKey &&
      other.courseId == courseId &&
      other.normalizedLemma == normalizedLemma;

  @override
  int get hashCode => Object.hash(courseId, normalizedLemma);

  @override
  String toString() => 'SavedWordKey($courseId, $normalizedLemma)';
}

/// What a saved word resolves to once classified.
enum SavedWordDisposition {
  /// Already saved in this course — a no-op (no duplicate card).
  duplicate,

  /// A new learner-curated card — feeds FSRS only, never θ/IRT.
  admitted,

  /// A new card whose key matches the calibrated catalog — merges to that
  /// calibrated Item and DOES feed θ (the dedup-and-promote rule).
  promoted,
}

/// The classification of one saved word: its dedup [key] and [disposition].
class SavedWordDecision {
  const SavedWordDecision({required this.key, required this.disposition});

  /// The normalized per-course key this word resolved to.
  final SavedWordKey key;

  /// Whether the word was a duplicate, a plain admit, or a promote.
  final SavedWordDisposition disposition;

  /// A new flashcard is created unless this was a duplicate (re-save = no-op).
  bool get createsCard => disposition != SavedWordDisposition.duplicate;

  /// True only for a promote — the single case a saved word feeds θ/IRT.
  bool get feedsTheta => disposition == SavedWordDisposition.promoted;
}

/// Injectable daily-intake configuration: the per-day new-card cap entering the
/// FSRS queue. Default ~20 (a documented, learner-tunable starting value); 0
/// pauses new-card intake while the backlog holds. Behind a const default so
/// callers can use `const SavedWordsModel()` with nothing to configure.
class IntakeConfig {
  const IntakeConfig({this.dailyCap = 20})
      : assert(dailyCap >= 0, 'dailyCap must be >= 0');

  /// Max new cards admitted into the active FSRS queue per day.
  final int dailyCap;

  /// Documented, pilot-tunable build-now default (~20/day).
  static const IntakeConfig defaults = IntakeConfig();
}

/// The result of metering the saved-word backlog for one day: how many cards
/// [dripNow] enter the FSRS queue and how many remain in the backlog
/// ([backlogAfter]).
class IntakeDecision {
  const IntakeDecision({required this.dripNow, required this.backlogAfter});

  /// Cards entering the active FSRS queue now — never more than the remaining
  /// daily capacity nor the available backlog.
  final int dripNow;

  /// Cards still waiting in the "My Words" backlog after this drip.
  final int backlogAfter;
}

/// Pure, deterministic saved-words intake engine. Construct with
/// `const SavedWordsModel()` for the identity-lemma default, or inject a
/// [lemmatizer] seam. Holds no mutable state.
class SavedWordsModel {
  const SavedWordsModel({this.lemmatizer = _identityLemma});

  /// The injected lemmatizer seam (identity by default).
  final LemmaNormalizer lemmatizer;

  /// Normalize a raw word to its per-course dedup form: lemma (injected seam) +
  /// surrounding-whitespace trim + Unicode-aware lowercasing.
  String normalize(String raw) => lemmatizer(raw.trim()).trim().toLowerCase();

  /// The per-course dedup [SavedWordKey] for [rawWord] saved in [courseId].
  SavedWordKey keyFor(String courseId, String rawWord) =>
      SavedWordKey(courseId: courseId, normalizedLemma: normalize(rawWord));

  /// Classify one saved word against the [alreadySaved] keys and the optional
  /// [calibratedCatalog]. Dedup wins over promote: an already-saved word is
  /// always a no-op; otherwise a catalog match promotes (feeds θ) and anything
  /// else is a plain admit (FSRS-only). Saving is never blocked — a new word is
  /// never rejected.
  SavedWordDecision classify({
    required String courseId,
    required String rawWord,
    required Set<SavedWordKey> alreadySaved,
    Set<SavedWordKey> calibratedCatalog = const <SavedWordKey>{},
  }) {
    final key = keyFor(courseId, rawWord);
    if (alreadySaved.contains(key)) {
      return SavedWordDecision(
          key: key, disposition: SavedWordDisposition.duplicate);
    }
    if (calibratedCatalog.contains(key)) {
      return SavedWordDecision(
          key: key, disposition: SavedWordDisposition.promoted);
    }
    return SavedWordDecision(
        key: key, disposition: SavedWordDisposition.admitted);
  }

  /// Classify a bulk "save all unknown" batch in order, deduping WITHIN the
  /// batch too (a repeated lemma admits once, then no-ops) so a bulk save can
  /// never create two cards for the same word. Order is preserved.
  List<SavedWordDecision> classifyAll({
    required String courseId,
    required List<String> rawWords,
    required Set<SavedWordKey> alreadySaved,
    Set<SavedWordKey> calibratedCatalog = const <SavedWordKey>{},
  }) {
    final seen = <SavedWordKey>{...alreadySaved};
    final out = <SavedWordDecision>[];
    for (final raw in rawWords) {
      final decision = classify(
        courseId: courseId,
        rawWord: raw,
        alreadySaved: seen,
        calibratedCatalog: calibratedCatalog,
      );
      out.add(decision);
      if (decision.createsCard) {
        seen.add(decision.key);
      }
    }
    return out;
  }

  /// Meter the saved-word backlog for one day. Given today's [admittedToday]
  /// count and the current [backlog], drip in
  /// `min(max(0, cap − admittedToday), backlog)` cards and leave the rest in the
  /// backlog. Saving is never blocked — this only paces the FSRS-queue intake.
  IntakeDecision meter({
    required int admittedToday,
    required int backlog,
    IntakeConfig config = IntakeConfig.defaults,
  }) {
    final remaining = math.max(0, config.dailyCap - admittedToday);
    final pending = math.max(0, backlog);
    final drip = math.min(remaining, pending);
    return IntakeDecision(dripNow: drip, backlogAfter: pending - drip);
  }
}
