import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/content/models/enums.dart' show ExerciseType;
import 'package:ratel/services/learning/calibration.dart';
import 'package:ratel/services/learning/irt.dart' show IrtItem;
import 'package:ratel/services/learning/learner_state.dart' show ReviewLogEntry;

/// Batch IRT re-calibration ORCHESTRATION (R-G3 go-live tail) — the wiring that
/// composes the two shipped pure engines into the pass the `irt.dart`/
/// `ability.dart` GO-LIVE STOPs name: read the append-only ReviewLog -> run
/// [IrtCalibrator.calibrateBatchJoint] + [EapThetaEstimator] -> write the
/// calibrated `irt_a`/`irt_b`/`irt_c` back to the item bank + persist theta ->
/// schedule the batch.
///
/// This layer is PURE ORCHESTRATION: deterministic given the store's contents,
/// it owns NO I/O, clock, or randomness — all durability crosses the
/// [CalibrationStore] seam (mirroring [ReviewLogSink] / [SavedWordsStore]).
/// The default [calibrationStoreProvider] is an honestly-empty in-memory store,
/// so nothing runs against production and the app boots byte-identically
/// (nothing consumes these providers at runtime yet — a build-ahead leaf).
///
/// HONEST GO-LIVE TAIL (owner-gated — needs prod schema + real answer volume):
/// a durable item-bank table with updatable `irt_a`/`irt_b`/`irt_c` columns (it
/// does NOT exist yet — item difficulty is authored content today), a
/// cross-user aggregate READ of the own-row `review_log` table via a SECURITY
/// DEFINER (own-row RLS forbids a broad client SELECT — the leagues-cohort
/// lesson), a theta persistence column, and a `pg_cron` schedule for the batch.
/// Plug those behind [CalibrationStore] and this orchestration goes live
/// unchanged.

/// One item's re-calibrated parameters, ready to write back to the durable item
/// bank, tagged with the [rung] and [responseCount] that produced them so the
/// durable side records calibration provenance. Only items the staged ladder
/// actually re-fit (rung > [CalibrationRung.insufficientData]) are ever emitted
/// — the thin-data guard travels WITH the write, so a sound authored difficulty
/// is never overwritten by small-sample noise.
class CalibratedItem {
  const CalibratedItem({
    required this.b,
    required this.a,
    required this.c,
    required this.rung,
    required this.responseCount,
  });

  /// Build the write-back record from a calibrator [CalibrationResult].
  factory CalibratedItem.fromResult(CalibrationResult r) => CalibratedItem(
        b: r.b,
        a: r.a,
        c: r.c,
        rung: r.rung,
        responseCount: r.responseCount,
      );

  /// Re-calibrated difficulty (`irt_b`).
  final double b;

  /// Re-calibrated discrimination (`irt_a`).
  final double a;

  /// Re-calibrated guessing floor (`irt_c`).
  final double c;

  /// The ladder rung that produced these params (calibration provenance).
  final CalibrationRung rung;

  /// How many responses fed the fit.
  final int responseCount;

  /// The parameters as an [IrtItem] (a valid slope/floor by the calibrator's
  /// clamps — a > 0, c in [0, 1)).
  IrtItem get item => IrtItem(b: b, a: a, c: c);

  @override
  bool operator ==(Object other) =>
      other is CalibratedItem &&
      other.b == b &&
      other.a == a &&
      other.c == c &&
      other.rung == rung &&
      other.responseCount == responseCount;

  @override
  int get hashCode => Object.hash(b, a, c, rung, responseCount);

  @override
  String toString() =>
      'CalibratedItem(b=$b a=$a c=$c ${rung.name} n=$responseCount)';
}

/// The auditable outcome of one batch item-calibration pass: every item's full
/// [CalibrationResult] (verbatim items included, so a dashboard sees WHY each
/// item did or did not move) plus the set of ids actually [written] back (the
/// refined subset — the verbatim thin-data items are deliberately NOT written).
class CalibrationRunReport {
  const CalibrationRunReport({required this.results, required this.written});

  /// Every calibrated item's full result, keyed by item id.
  final Map<String, CalibrationResult> results;

  /// The ids whose params were written back (rung > insufficientData).
  final Set<String> written;

  /// Total items considered.
  int get itemCount => results.length;

  /// Items whose params were re-fit and written back.
  int get writtenCount => written.length;

  /// Items the thin-data ladder kept verbatim (never written).
  int get verbatimCount => results.length - written.length;

  /// Whether this pass wrote anything (false on empty / all-thin data).
  bool get anyWritten => written.isNotEmpty;
}

/// Portability seam: the durable side of batch re-calibration. Every method is
/// an async port the pure [CalibrationRunner] reads/writes through; the default
/// [InMemoryCalibrationStore] is an honest empty store (dormant), and go-live
/// plugs a Supabase-backed implementation behind the SAME interface.
abstract interface class CalibrationStore {
  /// The course's WHOLE append-only ReviewLog (EVERY learner) — item
  /// calibration pools all learners' answers per item. On the durable side this
  /// is a cross-user aggregate read of the own-row `review_log` table, so it
  /// needs a SECURITY DEFINER (own-row RLS forbids a broad client SELECT).
  Future<List<ReviewLogEntry>> loadReviewLog(String courseId);

  /// The current authored / last-calibrated (a, b, c) + exercise type per item
  /// id — the priors the batch refit shrinks toward.
  Future<Map<String, ItemPrior>> loadItemBank(String courseId);

  /// ONE learner's own ReviewLog slice (own-row RLS = a plain client select) —
  /// the theta re-estimate scores this learner's answers against current params.
  Future<List<ReviewLogEntry>> loadLearnerReviewLog(
      String courseId, String userId);

  /// Write the re-calibrated (a, b, c) back to the durable item bank (the
  /// `irt_a`/`irt_b`/`irt_c` columns). Only refined items are ever passed here.
  Future<void> writeCalibratedItems(
      String courseId, Map<String, CalibratedItem> items);

  /// Persist one learner's re-estimated global theta (EAP posterior mean + SD).
  Future<void> persistTheta(
      String courseId, String userId, EapThetaResult theta);
}

/// Default (local / dormant): an in-memory store that is empty unless seeded, so
/// a run against the default provider is a genuine no-op (nothing to calibrate,
/// nothing written — byte-identical live). Seedable + write-capturing, so it
/// doubles as a faithful integration double: [writeCalibratedItems] also updates
/// the in-memory bank, so a later [loadItemBank] reflects the calibrated params
/// exactly as a durable store would.
class InMemoryCalibrationStore implements CalibrationStore {
  InMemoryCalibrationStore({
    Map<String, List<ReviewLogEntry>>? reviewLog,
    Map<String, Map<String, ItemPrior>>? itemBank,
    Map<String, Map<String, List<ReviewLogEntry>>>? learnerReviewLog,
  }) {
    reviewLog?.forEach((String k, List<ReviewLogEntry> v) =>
        _reviewLog[k] = List<ReviewLogEntry>.of(v));
    itemBank?.forEach((String k, Map<String, ItemPrior> v) =>
        _itemBank[k] = Map<String, ItemPrior>.of(v));
    learnerReviewLog?.forEach((String k, Map<String, List<ReviewLogEntry>> v) {
      final Map<String, List<ReviewLogEntry>> byUser =
          _learnerReviewLog[k] ??= <String, List<ReviewLogEntry>>{};
      v.forEach((String u, List<ReviewLogEntry> log) =>
          byUser[u] = List<ReviewLogEntry>.of(log));
    });
  }

  final Map<String, List<ReviewLogEntry>> _reviewLog =
      <String, List<ReviewLogEntry>>{};
  final Map<String, Map<String, ItemPrior>> _itemBank =
      <String, Map<String, ItemPrior>>{};
  final Map<String, Map<String, List<ReviewLogEntry>>> _learnerReviewLog =
      <String, Map<String, List<ReviewLogEntry>>>{};

  /// Captured write-backs per course (the calibrated item bank the durable side
  /// would persist). Empty on the dormant default.
  final Map<String, Map<String, CalibratedItem>> writtenItems =
      <String, Map<String, CalibratedItem>>{};

  /// Captured theta persists per course -> user.
  final Map<String, Map<String, EapThetaResult>> persistedTheta =
      <String, Map<String, EapThetaResult>>{};

  @override
  Future<List<ReviewLogEntry>> loadReviewLog(String courseId) async =>
      List<ReviewLogEntry>.unmodifiable(
          _reviewLog[courseId] ?? const <ReviewLogEntry>[]);

  @override
  Future<Map<String, ItemPrior>> loadItemBank(String courseId) async =>
      Map<String, ItemPrior>.unmodifiable(
          _itemBank[courseId] ?? const <String, ItemPrior>{});

  @override
  Future<List<ReviewLogEntry>> loadLearnerReviewLog(
          String courseId, String userId) async =>
      List<ReviewLogEntry>.unmodifiable(
          _learnerReviewLog[courseId]?[userId] ?? const <ReviewLogEntry>[]);

  @override
  Future<void> writeCalibratedItems(
      String courseId, Map<String, CalibratedItem> items) async {
    (writtenItems[courseId] ??= <String, CalibratedItem>{}).addAll(items);
    final Map<String, ItemPrior> bank =
        _itemBank[courseId] ??= <String, ItemPrior>{};
    items.forEach((String id, CalibratedItem ci) {
      final ItemPrior? prev = bank[id];
      bank[id] = ItemPrior(
        b: ci.b,
        a: ci.a,
        c: ci.c,
        type: prev?.type ?? ExerciseType.mcq,
      );
    });
  }

  @override
  Future<void> persistTheta(
      String courseId, String userId, EapThetaResult theta) async {
    (persistedTheta[courseId] ??= <String, EapThetaResult>{})[userId] = theta;
  }
}

/// Pure orchestration over a [CalibrationStore] — composes the shipped batch
/// calibrator + EAP theta estimator into the go-live re-calibration pass. Inject
/// tuned engines for a pilot; the const default is the launch profile.
class CalibrationRunner {
  const CalibrationRunner({
    this.calibrator = const IrtCalibrator(),
    this.thetaEstimator = const EapThetaEstimator(),
  });

  /// The batch (a, b, c) joint re-fit engine.
  final IrtCalibrator calibrator;

  /// The batch EAP theta re-estimator.
  final EapThetaEstimator thetaEstimator;

  /// Run ONE batch item re-calibration pass for [courseId]: read the whole
  /// ReviewLog + current item bank, fold (feedsTheta-gated) into per-item
  /// responses, joint-refit (a, b, c) to a fixed point, and write back ONLY the
  /// items the staged ladder actually re-fit. Items the thin-data ladder kept
  /// verbatim are reported but never written. Returns an auditable report.
  Future<CalibrationRunReport> runItemCalibration(
    CalibrationStore store,
    String courseId,
  ) async {
    final List<ReviewLogEntry> log = await store.loadReviewLog(courseId);
    final Map<String, ItemPrior> priors = await store.loadItemBank(courseId);
    final Map<String, List<CalibrationResponse>> grouped =
        IrtCalibrator.groupResponses(log);
    final Map<String, CalibrationResult> results = calibrator.calibrateBatchJoint(
      priors: priors,
      responsesByItem: grouped,
    );

    final Map<String, CalibratedItem> writes = <String, CalibratedItem>{};
    results.forEach((String id, CalibrationResult r) {
      // Thin-data guard: only write items the ladder actually re-fit; the
      // verbatim (insufficientData) set keeps its authored params untouched.
      if (r.refined) {
        writes[id] = CalibratedItem.fromResult(r);
      }
    });
    if (writes.isNotEmpty) {
      await store.writeCalibratedItems(courseId, writes);
    }
    return CalibrationRunReport(results: results, written: writes.keys.toSet());
  }

  /// Re-estimate ONE learner's global theta for [courseId]: score their
  /// feedsTheta answers against the CURRENT item-bank params (EAP posterior
  /// mean) and persist it. Unknown items (no bank entry) are skipped — the
  /// runner never invents parameters; no responses ⇒ the prior mean, persisted
  /// honestly. Returns the estimate.
  Future<EapThetaResult> runThetaReestimate(
    CalibrationStore store,
    String courseId,
    String userId,
  ) async {
    final List<ReviewLogEntry> log =
        await store.loadLearnerReviewLog(courseId, userId);
    final Map<String, ItemPrior> bank = await store.loadItemBank(courseId);
    final List<ThetaResponse> responses = <ThetaResponse>[];
    for (final ReviewLogEntry e in log) {
      if (!e.feedsTheta) {
        continue;
      }
      final ItemPrior? p = bank[e.itemId];
      if (p == null) {
        continue; // unknown item — never invent params
      }
      responses.add(ThetaResponse(
        item: IrtItem(b: p.b, a: p.a, c: p.c),
        correct: e.correct,
        type: p.type,
      ));
    }
    final EapThetaResult result = thetaEstimator.estimate(responses);
    await store.persistTheta(courseId, userId, result);
    return result;
  }
}

/// The re-calibration store seam. Defaults to the dormant in-memory store; go-
/// live overrides it with a Supabase-backed implementation (in
/// `backendOverridesForClient`, like the other durable seams).
final calibrationStoreProvider =
    Provider<CalibrationStore>((ref) => InMemoryCalibrationStore());

/// The re-calibration orchestrator (pure; const launch profile).
final calibrationRunnerProvider =
    Provider<CalibrationRunner>((ref) => const CalibrationRunner());
