/// Pure, clockless daily-streak transition (R-I2).
///
/// A streak counts CONSECUTIVE calendar days on which the learner met their
/// daily XP goal. Like every engine in `lib/services/learning`, this holds no
/// clock and no state: callers pass the current streak, the date the goal was
/// last met (`null` = never), and today's date, and receive back either the
/// streak after meeting the goal *today* ([afterGoalMet]) or the honest streak
/// to DISPLAY before today's goal is met ([current], which lapses to zero once
/// a whole day has gone by with no goal met).
///
/// Calendar-day math only: the two dates are compared by their (year, month,
/// day) — wall-clock time and timezone are irrelevant, so a streak never
/// flickers on the hour or across DST.
class StreakModel {
  const StreakModel();

  /// The streak after the daily goal is met on [today], given the prior
  /// [streak] and the [lastMet] date (the day the streak last advanced; `null`
  /// if it never has).
  ///
  /// - already counted today (or a backwards clock) → unchanged (idempotent)
  /// - last met exactly yesterday → `streak + 1` (the run continues)
  /// - last met earlier, or never → `1` (a fresh run starts today)
  int afterGoalMet({
    required int streak,
    required DateTime? lastMet,
    required DateTime today,
  }) {
    if (lastMet == null) return 1;
    final int gap = _dayOrdinal(today) - _dayOrdinal(lastMet);
    if (gap <= 0) return streak < 1 ? 1 : streak; // already advanced today
    if (gap == 1) return streak + 1; // consecutive day → extend
    return 1; // a day was missed → the run restarts at today
  }

  /// The honest streak to DISPLAY, given the stored [streak], the [lastMet]
  /// date and [today]. The run is alive only while the goal was met today or
  /// yesterday; once a full day passes with no goal met it has lapsed → `0`.
  ///
  /// A legacy row that carries a non-zero [streak] but no [lastMet] (rows
  /// written before goal-gating existed) is shown as-is — backward-compatible,
  /// never silently zeroed.
  int current({
    required int streak,
    required DateTime? lastMet,
    required DateTime today,
  }) {
    if (lastMet == null) return streak;
    final int gap = _dayOrdinal(today) - _dayOrdinal(lastMet);
    return gap <= 1 ? streak : 0;
  }

  /// Whole days since the Unix epoch for the date-only part of [d] (built at
  /// UTC midnight so the subtraction of two ordinals is exact and DST-proof).
  static int _dayOrdinal(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;
}
