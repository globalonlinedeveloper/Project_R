import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/models/enums.dart';
import '../../services/learning/path_serving.dart';
import '../../services/learning/saved_words.dart';

/// Immutable saved-words state: the set of deduped [saved] word keys for this
/// session and how many were [admittedToday] (drives the daily-cap meter).
class SavedWordsState {
  const SavedWordsState({
    this.saved = const <SavedWordKey>{},
    this.admittedToday = 0,
  });

  final Set<SavedWordKey> saved;
  final int admittedToday;

  int get count => saved.length;
}

/// Saved-words intake (R-G9): dedups each saved word through the build-ahead
/// [SavedWordsModel] (a repeat is a no-op) and meters new cards against the
/// daily cap. In-memory for the local-now slice; binds to the #7 store once
/// authEnabled. Surfaced as real Profile data.
class SavedWordsController extends StateNotifier<SavedWordsState> {
  SavedWordsController() : super(const SavedWordsState());

  final SavedWordsModel _model = const SavedWordsModel();

  /// Save [rawWord] for [courseId]; a duplicate (per the dedup key) is a no-op.
  /// Returns the engine's decision so callers can react (a promote feeds θ).
  SavedWordDecision save(String courseId, String rawWord) {
    final SavedWordDecision decision = _model.classify(
      courseId: courseId,
      rawWord: rawWord,
      alreadySaved: state.saved,
    );
    if (decision.createsCard) {
      state = SavedWordsState(
        saved: <SavedWordKey>{...state.saved, decision.key},
        admittedToday: state.admittedToday + 1,
      );
    }
    return decision;
  }

  /// Today's FSRS-queue drip given the daily cap and the saved backlog (R-G9).
  IntakeDecision meterToday() => _model.meter(
        admittedToday: state.admittedToday,
        backlog: state.count,
      );
}

/// Productive-retrieval review-type bias (R-G8): the allowed review exercise
/// types for the learner's [band] / [phase], delegating to the build-ahead
/// [PathServingModel] (recognition for cold-start / placement / A1; productive
/// from A2 up). This is the Practice queue's review-type selector.
Set<ExerciseType> reviewTypesFor({
  required CefrLevel band,
  required SelectionPhase phase,
  DeviceLocaleHints hints = DeviceLocaleHints.none,
  PathServingModel model = const PathServingModel(),
}) =>
    model.reviewTypes(band: band, phase: phase, hints: hints);

/// The session saved-words controller (real Profile / Practice data, R-G9).
final savedWordsControllerProvider =
    StateNotifierProvider<SavedWordsController, SavedWordsState>(
        (ref) => SavedWordsController());
