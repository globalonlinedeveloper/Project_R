/// Pure, clockless daily-streak transition (R-I2).
///
/// A streak counts CONSECUTIVE calendar days on which the learner met their
/// daily XP goal. Like every engine in `lib/services/learning`, this holds no
/// clock and no state: callers pass the current streak, the date the goal was
/// last met (`null` = never), and today's date, and receive back either the
/// streak after meeting the goal *today* ([afterGoalMet]) or the honest streak
/// to DISPLAY before today's goal is met ([current], which lapses to zero once
/// a whole day has gone by with no goal met). A held streak-freeze can absorb a
/// missed day so the run survives — see [applyFreezes] (R-I2).
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

  /// Resolve the streak across a (possibly missed) gap using available freezes
  /// (R-I2 streak-freeze). Given the day the streak last advanced ([lastMet]),
  /// [today] and how many [freezes] are held, returns the [lastMet] to STORE and
  /// the number of freezes CONSUMED so the run survives:
  ///
  /// - met today/yesterday (no day missed) → nothing changes (0 consumed);
  /// - one freeze is needed per missed day (`gap - 1`); when enough are held the
  ///   whole gap is covered — [lastMet] rolls to yesterday so [current] reads
  ///   the run as alive — and that many freezes are spent;
  /// - too few to cover the gap → nothing is spent (freezes are kept for a
  ///   coverable gap) and the run is left to lapse honestly.
  ({DateTime? lastMet, int freezesConsumed}) applyFreezes({
    required DateTime? lastMet,
    required DateTime today,
    required int freezes,
  }) {
    if (lastMet == null || freezes <= 0) {
      return (lastMet: lastMet, freezesConsumed: 0);
    }
    final int needed = _dayOrdinal(today) - _dayOrdinal(lastMet) - 1;
    if (needed <= 0 || needed > freezes) {
      return (lastMet: lastMet, freezesConsumed: 0);
    }
    // Cover every missed day: the run reads as alive (lastMet = yesterday) and
    // one freeze is spent per missed day.
    return (
      lastMet: DateTime(today.year, today.month, today.day - 1),
      freezesConsumed: needed,
    );
  }

  /// Whole days since the Unix epoch for the date-only part of [d] (built at
  /// UTC midnight so the subtraction of two ordinals is exact and DST-proof).
  static int _dayOrdinal(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;
}
