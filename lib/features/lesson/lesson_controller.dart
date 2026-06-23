import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../content/repository/content_providers.dart';
import 'engine/exercise.dart';
import 'engine/exercise_builder.dart';
import 'engine/lesson_engine.dart';

/// Immutable snapshot of a lesson run for the UI.
class LessonState {
  const LessonState({
    required this.phase,
    required this.current,
    required this.feedback,
    required this.resolved,
    required this.total,
    required this.result,
  });

  final LessonPhase phase;
  final Exercise? current; // null only when complete
  final LessonFeedback? feedback; // set in the feedback phase
  final int resolved;
  final int total;
  final LessonResult? result; // non-null once complete

  factory LessonState.of(LessonEngine e) => LessonState(
        phase: e.phase,
        current: e.isComplete ? null : e.current,
        feedback: e.phase == LessonPhase.feedback ? e.lastFeedback : null,
        resolved: e.resolvedCount,
        total: e.totalCount,
        result: e.isComplete ? e.result : null,
      );

  double get progress => total == 0 ? 1 : resolved / total;
}

/// Thin controller: the engine owns the rules, this exposes immutable state.
class LessonController extends StateNotifier<LessonState> {
  LessonController(this._engine) : super(LessonState.of(_engine));
  final LessonEngine _engine;

  void submit(String answer) {
    if (_engine.phase != LessonPhase.question) return;
    _engine.submit(answer);
    state = LessonState.of(_engine);
  }

  void proceed() {
    if (_engine.phase != LessonPhase.feedback) return;
    _engine.proceed();
    state = LessonState.of(_engine);
  }
}

/// Exercises for the current lesson, built off the local EN seed batch (R-L3).
final lessonExercisesProvider =
    FutureProvider.autoDispose<List<Exercise>>((ref) async {
  final batch = await ref.watch(seedBatchProvider.future);
  return buildLessonExercises(batch);
});

/// The active lesson controller. The screen reads this only after
/// [lessonExercisesProvider] has data, so `requireValue` is safe.
final lessonControllerProvider =
    StateNotifierProvider.autoDispose<LessonController, LessonState>((ref) {
  final exercises = ref.watch(lessonExercisesProvider).requireValue;
  return LessonController(LessonEngine(exercises));
});
