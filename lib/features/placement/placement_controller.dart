import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/models/enums.dart';
import '../../services/data_access/data_access.dart';
import '../../services/learning/ability.dart';
import '../../services/learning/cold_start.dart';

/// Immutable placement/ability state: the online θ [ability] estimate plus how
/// many graded items have been [answered] this session.
class PlacementState {
  const PlacementState({this.ability = const AbilityState(), this.answered = 0});

  final AbilityState ability;
  final int answered;

  double get thetaGlobal => ability.thetaGlobal;
  Map<String, double> get thetaPerSkill => ability.thetaPerSkill;
}

/// Placement session (R-G2/R-G3/R-G4): seeds θ from the learner's declared CEFR
/// band (the cold-start anchor) and refines global + per-skill θ through the
/// online θ engine as placement items are graded. The derived θ becomes the live
/// `user_course.theta_per_skill` once persisted via the #7 store -- this wires
/// the θ/IRT/CAT engines to live data. Pure in-memory until persisted.
class PlacementController extends StateNotifier<PlacementState> {
  PlacementController({double priorTheta = 0.0})
      : super(PlacementState(ability: AbilityState.coldStart(priorTheta)));

  /// Seed the cold-start prior from a declared CEFR [band] (R-G3 anchor).
  factory PlacementController.forBand(
    CefrLevel band, {
    ColdStartModel coldStart = const ColdStartModel(),
  }) =>
      PlacementController(priorTheta: coldStart.priorThetaForBand(band));

  final AbilityModel _model = const AbilityModel();

  /// Record one graded placement answer; refines global + per-skill θ (R-G2/G4).
  void answer({
    required String skill,
    required double itemDifficulty,
    required bool correct,
  }) {
    state = PlacementState(
      ability: _model.update(
        state.ability,
        skill: skill,
        itemDifficulty: itemDifficulty,
        correct: correct,
      ),
      answered: state.answered + 1,
    );
  }

  /// The `user_course` row (theta_per_skill) this placement produces, in the
  /// shape the #7 store persists.
  Map<String, Object?> courseRow(String targetLocale) => <String, Object?>{
        'target_locale': targetLocale,
        'theta_per_skill': Map<String, Object?>.from(state.thetaPerSkill),
      };
}

/// Persist a placement result to live `user_course` via the #7 store seam (every
/// row keyed on `auth.uid()`).
Future<void> persistPlacement(
  LearnerStateStore store,
  String userId,
  Map<String, Object?> row,
) =>
    store.save(userId, <String, Object?>{
      'courses': <Map<String, Object?>>[row],
    });

/// The placement controller (cold-start at A1 until the onboarding band is wired
/// in #10); overridden in the onboarding flow / tests with the real band.
final placementControllerProvider =
    StateNotifierProvider<PlacementController, PlacementState>(
        (ref) => PlacementController.forBand(CefrLevel.a1));
