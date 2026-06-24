// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// LEARNERSTATE-1 [R-G6] — learner-state ENTITY value-objects + pure append-only
// / derive transitions. The records that hold a learner's progress, anchored by
// an APPEND-ONLY immutable answer-log spine from which memory, ability and
// difficulty are all DERIVABLE. This file is the pure, build-ahead slice: the
// immutable value-objects + the pure folds that recompute derived state from a
// log slice by COMPOSING the existing learning engines — it invents no new
// scheduling/ability/IRT math of its own.
//
// THE ENTITIES (R-G6 — immutable, value-equal, Set/Map-usable):
//   * ReviewLogEntry — one row of the append-only spine: the frozen
//     grade / elapsed / theta_before / irt_b_at_review / source, plus the row
//     identity (itemId, skill) and the binary outcome (correct) any answer row
//     carries, and a `feedsTheta` flag (a calibrated graded item feeds θ; a
//     learner-curated saved word or ungraded reading does not).
//   * UserItemState — the FSRS-core memory state for one (user, item): the
//     scheduler card + its last whole-day interval.
//   * UserCourse — per-course progress: the global θ + the sparse per-skill θ
//     map (the stored `theta_per_skill`).
//   * PlacementSession — the CAT placement trace + its EAP estimate.
//
// THE TRANSITIONS (pure — append-only + derive-by-compose):
//   * APPEND-ONLY — `append` returns a NEW, unmodifiable log with the entry
//     added; the prior log is never mutated. The immutable history is the
//     trustworthy single source of truth: scheduling and scores are always
//     recomputable or auditable from it.
//   * DERIVE-BY-COMPOSE — `deriveItemState` folds the FSRS scheduler over an
//     item's entries; `deriveAbility` / `deriveCourse` fold the online θ ability
//     model over the log (an entry that does not feed θ is a no-op, so ungraded
//     reading never moves θ); `derivePlacement` runs the CAT EAP estimator over
//     a placement trace; `predictedRecall` recomputes the IRT recall-probability
//     the model expected at answer time from the frozen θ-before + difficulty.
//     Every one of these COMPOSES an already-built, already-tested engine — no
//     new math is introduced here.
//
// PURITY CONTRACT (what makes this safe build-ahead and trivially testable):
//   * NO I/O, NO database, NO network, NO provider — value-objects + pure folds.
//   * NO clock. `elapsedMs` (time since an item's previous review) is carried ON
//     the immutable log row, frozen at answer time; this core NEVER reads
//     DateTime.now(). Given the same log it always derives the same state, so
//     every fold is golden-testable exactly.
//   * NO randomness.
//   * The composed engines (the FSRS scheduler, the online θ ability model, the
//     IRT recall-probability family, the CAT placement estimator) are INJECTED
//     behind const defaults, so callers can use `const LearnerStateModel()`.
//
// GO-LIVE STOP — this is the entity SHAPES + the derive/append LOGIC only. NOT
// wired here (each lands at go-live behind the human dual senior-architect
// sign-off): the Postgres DDL for these tables — the ReviewLog BORN range-
// partitioned by month (pg_partman auto-creating each month's sub-table, kept
// forever) with a (user_id, created_at) index per partition, and the
// UserItemState (user_id, due) partial + covering due-queue index; the
// schema-first schema.json → migration pinning all of the above behind the
// zero-DDL conformance CI gate; persisting/reading these rows and sourcing
// elapsed/now + the frozen θ/difficulty from the server clock at answer time;
// and replacing the free-form `source` tag with the concrete stored enum. This
// file performs none of that — it is pure value-objects + pure functions.

import 'package:ratel/services/learning/ability.dart' show AbilityModel, AbilityState;
import 'package:ratel/services/learning/cat.dart'
    show CatItem, CatModel, CatResponse, EapEstimate;
import 'package:ratel/services/learning/fsrs.dart'
    show Fsrs, FsrsCard, FsrsRating, FsrsReview;
import 'package:ratel/services/learning/irt.dart' show IrtItem, IrtModel;

/// One row of the append-only immutable answer-log spine — the single source of
/// truth from which FSRS / θ / IRT state are all derivable. Carries the frozen
/// spine values (grade, elapsed, theta-before, irt-b-at-review, source) plus the
/// row identity (itemId, skill) and the binary outcome (correct) any answer row
/// needs. Value-equal + Set/Map-usable; treated as immutable (never mutated once
/// appended).
class ReviewLogEntry {
  const ReviewLogEntry({
    required this.itemId,
    required this.skill,
    required this.grade,
    required this.correct,
    required this.elapsedMs,
    required this.thetaBefore,
    required this.irtBAtReview,
    required this.source,
    this.feedsTheta = true,
  }) : assert(elapsedMs >= 0, 'elapsedMs must be >= 0');

  /// The item this answer was for — the per-item key for the FSRS fold.
  final String itemId;

  /// The skill this answer exercised — the per-skill key for the θ fold.
  final String skill;

  /// The graded outcome on the FSRS 1..4 scale (the spine's `grade`).
  final FsrsRating grade;

  /// The binary correctness that feeds the θ Elo step (the spine's outcome,
  /// frozen at answer time — kept explicit rather than inferred from [grade] so
  /// this core invents no grade→correct mapping).
  final bool correct;

  /// Milliseconds since this item's previous review (the spine's `elapsed_ms`),
  /// frozen at answer time. Converted to days for the FSRS engine via
  /// [elapsedDays]; this core reads no clock.
  final int elapsedMs;

  /// The learner's global θ frozen at answer time (the spine's `theta_before`).
  final double thetaBefore;

  /// The item's difficulty (irt_b) frozen at answer time (the spine's
  /// `irt_b_at_review`) — the difficulty the θ Elo step and the recall
  /// prediction use.
  final double irtBAtReview;

  /// The answer's origin tag (the spine's `source`), e.g. 'lesson', 'review',
  /// 'placement', 'saved_word'. A free-form string here; the concrete stored
  /// enum is a schema / go-live seam.
  final String source;

  /// Whether this entry feeds the online θ / IRT estimate. True for a calibrated
  /// graded item; false for a learner-curated saved-word card or ungraded
  /// reading (which feed the FSRS scheduler but never move the official skill
  /// score). Drives the θ fold's per-entry graded flag.
  final bool feedsTheta;

  /// Time since the item's previous review in days — the FSRS scheduler input,
  /// derived purely from the frozen [elapsedMs] (no clock).
  double get elapsedDays => elapsedMs / Duration.millisecondsPerDay;

  @override
  bool operator ==(Object other) =>
      other is ReviewLogEntry &&
      other.itemId == itemId &&
      other.skill == skill &&
      other.grade == grade &&
      other.correct == correct &&
      other.elapsedMs == elapsedMs &&
      other.thetaBefore == thetaBefore &&
      other.irtBAtReview == irtBAtReview &&
      other.source == source &&
      other.feedsTheta == feedsTheta;

  @override
  int get hashCode => Object.hash(itemId, skill, grade, correct, elapsedMs,
      thetaBefore, irtBAtReview, source, feedsTheta);

  @override
  String toString() =>
      'ReviewLogEntry($source $itemId/$skill grade=$grade correct=$correct)';
}

/// The FSRS-core memory state for one (user, item): the scheduler [card] plus
/// the last whole-day [intervalDays] it was scheduled to (0 before any review).
/// Value-equal (over the card's fields) + Set/Map-usable; immutable.
class UserItemState {
  const UserItemState({
    required this.itemId,
    required this.card,
    this.intervalDays = 0,
  });

  /// The item this state belongs to.
  final String itemId;

  /// The FSRS memory card (state / stability / difficulty / reps / lapses).
  final FsrsCard card;

  /// The most-recent whole-day interval the card was scheduled to (0 if never
  /// reviewed).
  final int intervalDays;

  @override
  bool operator ==(Object other) =>
      other is UserItemState &&
      other.itemId == itemId &&
      other.intervalDays == intervalDays &&
      other.card.state == card.state &&
      other.card.stability == card.stability &&
      other.card.difficulty == card.difficulty &&
      other.card.reps == card.reps &&
      other.card.lapses == card.lapses;

  @override
  int get hashCode => Object.hash(itemId, intervalDays, card.state,
      card.stability, card.difficulty, card.reps, card.lapses);

  @override
  String toString() =>
      'UserItemState($itemId ${card.state} reps=${card.reps} due=$intervalDays)';
}

/// Per-course learner progress: the global θ plus the sparse per-skill θ map
/// (the stored `theta_per_skill`). Value-equal (deep over the θ map) +
/// Set/Map-usable; immutable.
class UserCourse {
  const UserCourse({
    required this.courseId,
    this.thetaGlobal = 0.0,
    this.thetaPerSkill = const <String, double>{},
  });

  /// The course this progress belongs to.
  final String courseId;

  /// Running global ability on the IRT logit scale.
  final double thetaGlobal;

  /// Sparse per-skill ability on the logit scale, keyed by skill id (the stored
  /// `theta_per_skill`). A skill absent from the map falls back to [thetaGlobal].
  final Map<String, double> thetaPerSkill;

  /// Effective per-skill ability: the stored per-skill θ, else the global θ for
  /// a never-graded skill (cold-start partial pooling).
  double thetaForSkill(String skill) => thetaPerSkill[skill] ?? thetaGlobal;

  @override
  bool operator ==(Object other) =>
      other is UserCourse &&
      other.courseId == courseId &&
      other.thetaGlobal == thetaGlobal &&
      _mapDoubleEq(other.thetaPerSkill, thetaPerSkill);

  @override
  int get hashCode =>
      Object.hash(courseId, thetaGlobal, _mapDoubleHash(thetaPerSkill));

  @override
  String toString() =>
      'UserCourse($courseId theta=$thetaGlobal skills=${thetaPerSkill.length})';
}

/// One response in a placement (CAT) trace: the item's id + frozen IRT params
/// (difficulty b, discrimination a, pseudo-guessing c) and whether it was
/// answered correctly. Value-equal + Set/Map-usable; immutable. The defaults
/// (a = 1, c = 0) collapse to the launch 1PL rung.
class PlacementResponse {
  const PlacementResponse({
    required this.itemId,
    required this.irtB,
    required this.correct,
    this.irtA = 1.0,
    this.irtC = 0.0,
  })  : assert(irtA > 0, 'irtA must be > 0'),
        assert(irtC >= 0 && irtC < 1, 'irtC must be in [0, 1)');

  /// The administered item's id.
  final String itemId;

  /// The item difficulty (irt_b) on the logit scale.
  final double irtB;

  /// Whether the learner answered correctly.
  final bool correct;

  /// The item discrimination (irt_a); 1.0 is the Rasch unit slope.
  final double irtA;

  /// The item pseudo-guessing (irt_c); 0.0 outside the 3PL rung.
  final double irtC;

  @override
  bool operator ==(Object other) =>
      other is PlacementResponse &&
      other.itemId == itemId &&
      other.irtB == irtB &&
      other.correct == correct &&
      other.irtA == irtA &&
      other.irtC == irtC;

  @override
  int get hashCode => Object.hash(itemId, irtB, correct, irtA, irtC);

  @override
  String toString() => 'PlacementResponse($itemId b=$irtB correct=$correct)';
}

/// A placement (CAT) session: the ordered [responses] trace + its final EAP
/// [estimate] (θ and SE). Value-equal (deep over the trace + the estimate's
/// θ/SE) + Set/Map-usable; immutable.
class PlacementSession {
  const PlacementSession({
    required this.sessionId,
    required this.responses,
    required this.estimate,
  });

  /// A stable session identifier.
  final String sessionId;

  /// The ordered placement trace.
  final List<PlacementResponse> responses;

  /// The final EAP ability estimate derived from the trace.
  final EapEstimate estimate;

  @override
  bool operator ==(Object other) =>
      other is PlacementSession &&
      other.sessionId == sessionId &&
      other.estimate.theta == estimate.theta &&
      other.estimate.se == estimate.se &&
      _listEq(other.responses, responses);

  @override
  int get hashCode => Object.hash(
      sessionId, estimate.theta, estimate.se, Object.hashAll(responses));

  @override
  String toString() =>
      'PlacementSession($sessionId n=${responses.length} theta=${estimate.theta})';
}

/// Pure, deterministic learner-state engine: the append-only log transition +
/// the derive-by-compose folds. Construct with `const LearnerStateModel()` for
/// the default engines, or inject custom ones. Holds no mutable state.
class LearnerStateModel {
  const LearnerStateModel({
    this.fsrs = const Fsrs(),
    this.ability = const AbilityModel(),
    this.irt = const IrtModel(),
    this.cat = const CatModel(),
  });

  /// The FSRS scheduler the item-state fold composes.
  final Fsrs fsrs;

  /// The online θ ability model the course fold composes.
  final AbilityModel ability;

  /// The IRT recall-probability family the recall prediction composes.
  final IrtModel irt;

  /// The CAT placement estimator the placement fold composes.
  final CatModel cat;

  /// Append [entry] to [log], returning a NEW, unmodifiable log. The input [log]
  /// is never mutated — the append-only invariant: existing entries are frozen
  /// for all time.
  List<ReviewLogEntry> append(List<ReviewLogEntry> log, ReviewLogEntry entry) =>
      List<ReviewLogEntry>.unmodifiable(<ReviewLogEntry>[...log, entry]);

  /// Recompute the FSRS memory state for [itemId] by folding the FSRS scheduler
  /// over that item's [log] entries in order (entries for other items are
  /// skipped). Composes the FSRS engine — no new scheduling math. Deterministic.
  UserItemState deriveItemState(String itemId, Iterable<ReviewLogEntry> log) {
    FsrsCard card = const FsrsCard.newItem();
    int interval = 0;
    for (final ReviewLogEntry e in log) {
      if (e.itemId != itemId) {
        continue;
      }
      final FsrsReview review = fsrs.schedule(card, e.grade, e.elapsedDays);
      card = review.card;
      interval = review.intervalDays;
    }
    return UserItemState(itemId: itemId, card: card, intervalDays: interval);
  }

  /// Recompute the full online θ ability state by folding the ability model over
  /// the whole [log] in order, starting from [initial]. An entry that does not
  /// feed θ ([ReviewLogEntry.feedsTheta] false) is applied as an ungraded no-op,
  /// so ungraded reading / learner-curated saved words never move θ. Composes
  /// the ability engine — no new math. Order-faithful + deterministic.
  AbilityState deriveAbility(
    Iterable<ReviewLogEntry> log, {
    AbilityState initial = const AbilityState(),
  }) {
    AbilityState state = initial;
    for (final ReviewLogEntry e in log) {
      state = ability.update(
        state,
        skill: e.skill,
        itemDifficulty: e.irtBAtReview,
        correct: e.correct,
        graded: e.feedsTheta,
      );
    }
    return state;
  }

  /// Recompute the stored per-course progress [UserCourse] for [courseId] from
  /// the [log] (optionally seeded with an [initial] cold-start ability),
  /// projecting the derived ability into the global θ + the `theta_per_skill`
  /// map. Deterministic.
  UserCourse deriveCourse(
    String courseId,
    Iterable<ReviewLogEntry> log, {
    AbilityState initial = const AbilityState(),
  }) {
    final AbilityState state = deriveAbility(log, initial: initial);
    return UserCourse(
      courseId: courseId,
      thetaGlobal: state.thetaGlobal,
      thetaPerSkill: state.thetaPerSkill,
    );
  }

  /// Derive a [PlacementSession] from a placement [trace] by running the CAT EAP
  /// estimator over it (composing the placement engine). The stored trace is
  /// made unmodifiable. Deterministic.
  PlacementSession derivePlacement(
    String sessionId,
    List<PlacementResponse> trace,
  ) {
    final List<CatResponse> responses = <CatResponse>[
      for (final PlacementResponse r in trace)
        CatResponse(
          item: CatItem(
            id: r.itemId,
            params: IrtItem(b: r.irtB, a: r.irtA, c: r.irtC),
          ),
          correct: r.correct,
        ),
    ];
    final EapEstimate estimate = cat.eap(responses);
    return PlacementSession(
      sessionId: sessionId,
      responses: List<PlacementResponse>.unmodifiable(trace),
      estimate: estimate,
    );
  }

  /// The recall probability the model expected at the moment [entry] was
  /// answered, recomputed from the immutable spine's frozen θ-before + item
  /// difficulty (composing the IRT recall-probability family at the launch 1PL
  /// rung). Pure + deterministic.
  double predictedRecall(ReviewLogEntry entry) =>
      irt.pCorrect3pl(entry.thetaBefore, entry.irtBAtReview);
}

/// Order-independent deep equality for a `theta_per_skill` map.
bool _mapDoubleEq(Map<String, double> a, Map<String, double> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (final MapEntry<String, double> entry in a.entries) {
    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

/// Order-independent hash for a `theta_per_skill` map (commutative over entries
/// so it agrees with [_mapDoubleEq]).
int _mapDoubleHash(Map<String, double> m) {
  int h = 0;
  for (final MapEntry<String, double> entry in m.entries) {
    h = h ^ Object.hash(entry.key, entry.value);
  }
  return h;
}

/// Element-wise equality for a placement trace.
bool _listEq(List<PlacementResponse> a, List<PlacementResponse> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
