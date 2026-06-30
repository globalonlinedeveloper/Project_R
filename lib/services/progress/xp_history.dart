import 'package:flutter/foundation.dart';

/// One calendar day's earned XP: a date-only [date] and the HONEST [xp] recorded
/// for it (zero is allowed and meaningful — an inactive day, never a gap).
@immutable
class DayXp {
  const DayXp(this.date, this.xp);

  /// Date-only (local midnight) the [xp] belongs to.
  final DateTime date;

  /// Real XP recorded that day (>= 0).
  final int xp;

  @override
  bool operator ==(Object other) =>
      other is DayXp && other.date == date && other.xp == xp;

  @override
  int get hashCode => Object.hash(date, xp);
}

/// Pure, clockless recorder for the learner's per-day XP history (D1 · R-G6 /
/// R-L14). Keyed by a `YYYY-MM-DD` local-date string so it serialises cleanly to
/// the device-local store (mirrors the `AppSettings` CSV pattern). Holds ONLY
/// real recorded XP — inactive days are honestly absent and rendered as zero,
/// never invented.
class XpHistoryModel {
  const XpHistoryModel({this.keepDays = 14});

  /// How many of the most-recent days to retain (older buckets are pruned).
  final int keepDays;

  /// `YYYY-MM-DD` for a date (date-only; the map / storage key).
  static String keyFor(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Parse a `YYYY-MM-DD` key to a date-only [DateTime], or null if malformed.
  static DateTime? parseKey(String s) {
    final DateTime? d = DateTime.tryParse(s);
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }

  /// A NEW history with [xp] added to [day]'s bucket, pruned to the most-recent
  /// [keepDays] dates relative to [day]. A non-positive [xp] is ignored (returns
  /// the SAME instance) so nothing fake is ever recorded.
  Map<String, int> record({
    required Map<String, int> history,
    required DateTime day,
    required int xp,
  }) {
    if (xp <= 0) return history;
    final DateTime today = DateTime(day.year, day.month, day.day);
    final String key = keyFor(today);
    final Map<String, int> next = <String, int>{...history};
    next[key] = (next[key] ?? 0) + xp;
    // Prune anything older than the retention window (date arithmetic, so it is
    // DST-safe and normalises across month/year boundaries).
    final DateTime cutoff =
        DateTime(today.year, today.month, today.day - (keepDays - 1));
    next.removeWhere((String k, int _) {
      final DateTime? d = parseKey(k);
      return d == null || d.isBefore(cutoff);
    });
    return next;
  }

  /// The [n] days ending at [today] (inclusive), oldest -> newest, zero-filled
  /// for days with no recorded XP (honest zeros, never gaps).
  List<DayXp> lastDays({
    required Map<String, int> history,
    required DateTime today,
    int n = 7,
  }) {
    final DateTime end = DateTime(today.year, today.month, today.day);
    final List<DayXp> out = <DayXp>[];
    for (int i = n - 1; i >= 0; i--) {
      final DateTime d = DateTime(end.year, end.month, end.day - i);
      out.add(DayXp(d, history[keyFor(d)] ?? 0));
    }
    return out;
  }

  /// Sum of recorded XP across the [n] days ending at [today].
  int totalOver({
    required Map<String, int> history,
    required DateTime today,
    int n = 7,
  }) =>
      lastDays(history: history, today: today, n: n)
          .fold<int>(0, (int a, DayXp d) => a + d.xp);
}
