import '../../../content/models/models.dart' show ExerciseType;

/// Value types for the lesson core loop (R-L3). Kept pure-Dart (no Flutter) so
/// the loop is exhaustively unit-testable off-device.

/// A presentable, on-device-gradable exercise built from a content `Item`.
class Exercise {
  const Exercise({
    required this.itemId,
    required this.type,
    required this.prompt,
    required this.options,
    required this.accepted,
    required this.whyCard,
  });

  final String itemId;
  final ExerciseType type;
  final String prompt;

  /// Selectable answers shown to the learner (mcq/cloze).
  final List<String> options;

  /// Normalized accepted answers (trimmed + lower-cased). Never empty.
  final List<String> accepted;

  /// The FREE why-card explanation (R-L3 / §H honesty). The deeper Pro
  /// "Explain my answer" generation is a separate, gated feature.
  final String whyCard;

  String get canonicalAnswer => accepted.first;
}

/// LessonFeedback returned by `LessonEngine.submit`.
class LessonFeedback {
  const LessonFeedback({
    required this.correct,
    required this.whyCard,
    required this.correctAnswer,
    required this.revealed,
  });

  final bool correct;
  final String whyCard;
  final String correctAnswer;

  /// True when the engine auto-revealed after the miss cap (change #30).
  final bool revealed;
}

/// Where the run is — drives the UI.
enum LessonPhase { question, feedback, complete }

/// Committed ONLY when a lesson completes. Quitting yields no result, so a quit
/// commits nothing and costs no energy (R-L3 / R-J*).
class LessonResult {
  const LessonResult({
    required this.xp,
    required this.accuracy,
    required this.total,
    required this.firstTryCorrect,
  });

  final int xp;
  final double accuracy; // 0..1 first-try correctness
  final int total;
  final int firstTryCorrect;
}
