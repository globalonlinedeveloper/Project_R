import 'exercise.dart';

/// Pure-Dart lesson core loop (R-L3) — no Flutter, no AI, no DB.
///
/// Rules (frozen with the SESSION-14 design):
///  - Exercises are graded on-device against [Exercise.accepted].
///  - A wrong answer is RE-ASKED later in the same lesson.
///  - At [missCap] misses on one exercise the engine AUTO-REVEALS the answer and
///    force-resolves it (change #30) so a learner is never hard-stuck.
///  - A [LessonResult] exists ONLY once [isComplete]; quitting early commits
///    nothing (the caller charges no energy on an incomplete run).
class LessonEngine {
  LessonEngine(List<Exercise> exercises, {this.missCap = 2})
      : _all = List<Exercise>.unmodifiable(exercises),
        _order = List<int>.generate(exercises.length, (i) => i) {
    for (final ex in _all) {
      _progress[ex.itemId] = _Progress();
    }
    _phase = _all.isEmpty ? LessonPhase.complete : LessonPhase.question;
  }

  final List<Exercise> _all;
  final int missCap;
  final List<int> _order; // ask order; a miss appends the same index (re-ask)
  final Map<String, _Progress> _progress = {};
  int _cursor = 0;
  late LessonPhase _phase;
  Feedback? _lastFeedback;

  LessonPhase get phase => _phase;
  bool get isComplete => _phase == LessonPhase.complete;
  Feedback? get lastFeedback => _lastFeedback;

  Exercise get current => _all[_order[_cursor]];

  int get totalCount => _all.length;
  int get resolvedCount => _progress.values.where((p) => p.resolved).length;

  /// Grade [answer] for the current exercise. Valid only in the question phase.
  Feedback submit(String answer) {
    assert(_phase == LessonPhase.question, 'submit() only valid in question phase');
    final ex = current;
    final p = _progress[ex.itemId]!;
    final correct = ex.accepted.contains(_normalize(answer));
    if (correct) {
      if (p.firstAttempt) p.firstTryCorrect = true;
      p.resolved = true;
      _lastFeedback = Feedback(
        correct: true,
        whyCard: ex.whyCard,
        correctAnswer: ex.canonicalAnswer,
        revealed: false,
      );
    } else {
      p.misses++;
      if (p.misses >= missCap) {
        p.autoRevealed = true;
        p.resolved = true;
        _lastFeedback = Feedback(
          correct: false,
          whyCard: ex.whyCard,
          correctAnswer: ex.canonicalAnswer,
          revealed: true,
        );
      } else {
        _order.add(_order[_cursor]); // re-ask at lesson end
        _lastFeedback = Feedback(
          correct: false,
          whyCard: ex.whyCard,
          correctAnswer: ex.canonicalAnswer,
          revealed: false,
        );
      }
    }
    p.firstAttempt = false;
    _phase = LessonPhase.feedback;
    return _lastFeedback!;
  }

  /// Advance from feedback to the next exercise (or complete).
  void proceed() {
    assert(_phase == LessonPhase.feedback, 'proceed() only valid in feedback phase');
    _cursor++;
    _phase =
        _cursor >= _order.length ? LessonPhase.complete : LessonPhase.question;
  }

  /// Run result; meaningful once [isComplete].
  LessonResult get result {
    final total = _all.length;
    final ftc = _progress.values.where((p) => p.firstTryCorrect).length;
    final xp = _progress.values.fold<int>(
      0,
      (s, p) => s + (p.firstTryCorrect ? 10 : (p.autoRevealed ? 0 : 5)),
    );
    return LessonResult(
      xp: xp,
      accuracy: total == 0 ? 0 : ftc / total,
      total: total,
      firstTryCorrect: ftc,
    );
  }

  String _normalize(String s) => s.trim().toLowerCase();
}

class _Progress {
  int misses = 0;
  bool resolved = false;
  bool autoRevealed = false;
  bool firstAttempt = true;
  bool firstTryCorrect = false;
}
