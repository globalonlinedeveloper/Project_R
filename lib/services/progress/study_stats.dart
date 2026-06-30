import 'package:flutter/foundation.dart';

/// Cumulative, device-local study statistics (D2 · R-G6 / R-L14): graded-answer
/// accuracy and total study time. Pure + immutable; holds ONLY real recorded
/// values — an empty stat reads as "no data yet", never invented.
@immutable
class StudyStats {
  const StudyStats({this.correct = 0, this.total = 0, this.studySeconds = 0});

  /// Graded answers the learner got right (cumulative).
  final int correct;

  /// Graded answers total (cumulative). Accuracy is [correct]/[total].
  final int total;

  /// Total time spent in lessons, in seconds (the sum of session durations).
  final int studySeconds;

  /// Cumulative accuracy in [0, 1], or null when nothing has been graded yet.
  double? get accuracy => total <= 0 ? null : correct / total;

  /// Fold one finished lesson's tally in (clamped non-negative; [correct] is
  /// capped at [total] so accuracy can never exceed 100%).
  StudyStats recordLesson({
    required int correct,
    required int total,
    required int seconds,
  }) {
    final int t = total < 0 ? 0 : total;
    final int c = correct < 0 ? 0 : (correct > t ? t : correct);
    final int s = seconds < 0 ? 0 : seconds;
    if (t == 0 && s == 0) return this; // nothing real to record
    return StudyStats(
      correct: this.correct + c,
      total: this.total + t,
      studySeconds: studySeconds + s,
    );
  }

  Map<String, int> toMap() => <String, int>{
        'correct': correct,
        'total': total,
        'studySeconds': studySeconds,
      };

  static StudyStats fromMap(Map<String, Object?> m) => StudyStats(
        correct: (m['correct'] as num?)?.toInt() ?? 0,
        total: (m['total'] as num?)?.toInt() ?? 0,
        studySeconds: (m['studySeconds'] as num?)?.toInt() ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      other is StudyStats &&
      other.correct == correct &&
      other.total == total &&
      other.studySeconds == studySeconds;

  @override
  int get hashCode => Object.hash(correct, total, studySeconds);
}
