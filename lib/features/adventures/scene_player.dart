import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'adventure_model.dart';

/// Where a scripted scene is (mirrors the lesson loop's phases).
enum ScenePhase { choosing, replying, complete }

class ScenePlayerState {
  const ScenePlayerState({
    required this.phase,
    required this.stepIndex,
    required this.total,
    required this.lastChoice,
    required this.lastWasBest,
  });

  final ScenePhase phase;
  final int stepIndex;
  final int total;
  final int? lastChoice;
  final bool lastWasBest;

  bool get isComplete => phase == ScenePhase.complete;
  double get progress => total == 0 ? 1 : (stepIndex / total).clamp(0.0, 1.0);

  ScenePlayerState copyWith({
    ScenePhase? phase,
    int? stepIndex,
    int? lastChoice,
    bool? lastWasBest,
  }) =>
      ScenePlayerState(
        phase: phase ?? this.phase,
        stepIndex: stepIndex ?? this.stepIndex,
        total: total,
        lastChoice: lastChoice,
        lastWasBest: lastWasBest ?? this.lastWasBest,
      );
}

/// Walks a scripted-roleplay [Scene] on rails (no grading gate — immersion
/// practice; the "best" choice is highlighted but any choice advances).
class ScenePlayer extends StateNotifier<ScenePlayerState> {
  ScenePlayer(this.scene)
      : super(ScenePlayerState(
          phase:
              scene.steps.isEmpty ? ScenePhase.complete : ScenePhase.choosing,
          stepIndex: 0,
          total: scene.steps.length,
          lastChoice: null,
          lastWasBest: false,
        ));

  final Scene scene;

  /// The step in focus (valid while not complete).
  SceneStep get currentStep => scene.steps[state.stepIndex];

  void choose(int choiceIndex) {
    if (state.phase != ScenePhase.choosing) return;
    final step = scene.steps[state.stepIndex];
    state = state.copyWith(
      phase: ScenePhase.replying,
      lastChoice: choiceIndex,
      lastWasBest: choiceIndex == step.bestIndex,
    );
  }

  void advance() {
    if (state.phase != ScenePhase.replying) return;
    final next = state.stepIndex + 1;
    state = state.copyWith(
      stepIndex: next,
      phase: next >= state.total ? ScenePhase.complete : ScenePhase.choosing,
      lastChoice: null,
      lastWasBest: false,
    );
  }
}

final scenePlayerProvider = StateNotifierProvider.autoDispose
    .family<ScenePlayer, ScenePlayerState, String>((ref, sceneId) {
  final scene = findScene(sceneId) ??
      const Scene(id: '', title: '', steps: <SceneStep>[]);
  return ScenePlayer(scene);
});
