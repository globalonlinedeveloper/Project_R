/// Pure, deterministic in-app notification engine (R-L11 inbox — design spec
/// §4.5 / §6). Every notification is PROJECTED from the learner's REAL state —
/// lessons completed, total XP, day-streak, and the CEFR level derived from θ —
/// exactly like the [AchievementsEngine]: a fresh account honestly shows an
/// EMPTY inbox, and an item appears only when the learner has genuinely passed
/// that milestone. No fabricated events, no fake timestamps, and no clock: this
/// engine holds no time, like every other `lib/services` learning engine.
///
/// Read-state (which items the learner has seen) is the only durable bit; it is
/// persisted device-locally with the other `AppSettings` (the same flagged
/// go-live wiring as every R-O1 preference). PUSH delivery, opt-in categories
/// and per-platform delivery profiles (a separate, owner/$$-gated Stage-3
/// item) have NO engine and stay an
/// honest owner/$$ decision — surfaced as a note in the inbox, never faked.
///
/// Derived-feed semantics (shared with the achievements grid): because the feed
/// is projected from CURRENT real state, a non-monotonic metric that drops (a
/// lapsed streak, a level regression) removes its item, exactly as a badge
/// re-locks. Lesson- and XP-milestones are monotonic and never vanish.
library;

/// The REAL learner counters / derived level a notification is measured against.
/// Mirrors `AchievementStats`.
class NotificationStats {
  const NotificationStats({
    required this.lessonsCompleted,
    required this.xpTotal,
    required this.streakDays,
    required this.cefrOrdinal,
  });

  final int lessonsCompleted;
  final int xpTotal;
  final int streakDays;

  /// 0 = A1, 1 = A2, … 5 = C2 — the index of the derived CEFR level.
  final int cefrOrdinal;

  static const NotificationStats zero = NotificationStats(
    lessonsCompleted: 0,
    xpTotal: 0,
    streakDays: 0,
    cefrOrdinal: 0,
  );
}

/// Which REAL metric a milestone reads.
enum NotificationMetric { lessons, xp, streak, level }

/// A milestone notification definition — an honest threshold over one real
/// metric, with a fixed [rank] for a deterministic biggest-first inbox order.
class NotificationDef {
  const NotificationDef({
    required this.id,
    required this.emoji,
    required this.title,
    required this.body,
    required this.metric,
    required this.threshold,
    required this.rank,
  });

  final String id;
  final String emoji;
  final String title;
  final String body;
  final NotificationMetric metric;
  final int threshold;

  /// Higher = surfaced nearer the top of the inbox (bigger milestones first).
  final int rank;
}

/// One projected notification: a genuinely-earned milestone + its read flag.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.emoji,
    required this.title,
    required this.body,
    required this.read,
    this.earnedAt,
  });

  final String id;
  final String emoji;
  final String title;
  final String body;
  final bool read;

  /// The REAL moment the learner was observed crossing this milestone's
  /// threshold (device-local stamp, D-13) — supplied by the caller, never by
  /// this clockless engine. Null ⇒ unknown (earned before the stamps shipped,
  /// or on another device): the row honestly shows no time label rather than
  /// a fabricated one.
  final DateTime? earnedAt;
}

/// The clockless in-app notification engine.
class NotificationsEngine {
  const NotificationsEngine();

  /// The launch catalogue — every entry reads a REAL metric. Social / league /
  /// economy alerts are deliberately absent (they have no engine, §6).
  static const List<NotificationDef> catalogue = <NotificationDef>[
    // Lessons completed (monotonic — never vanish).
    NotificationDef(id: 'lessons:1', emoji: '🌱', title: 'First lesson complete', body: 'You finished your first lesson — great start!', metric: NotificationMetric.lessons, threshold: 1, rank: 10),
    NotificationDef(id: 'lessons:5', emoji: '📗', title: '5 lessons done', body: "You've completed 5 lessons. Keep the momentum going.", metric: NotificationMetric.lessons, threshold: 5, rank: 20),
    NotificationDef(id: 'lessons:10', emoji: '📚', title: '10 lessons done', body: 'Ten lessons in — you are building a real habit.', metric: NotificationMetric.lessons, threshold: 10, rank: 30),
    NotificationDef(id: 'lessons:25', emoji: '🏅', title: '25 lessons done', body: 'Twenty-five lessons completed. Impressive dedication!', metric: NotificationMetric.lessons, threshold: 25, rank: 40),
    NotificationDef(id: 'lessons:50', emoji: '🎖️', title: '50 lessons done', body: 'Fifty lessons — you are well on your way.', metric: NotificationMetric.lessons, threshold: 50, rank: 60),
    // Day-streak.
    NotificationDef(id: 'streak:3', emoji: '🔥', title: '3-day streak!', body: 'Three days in a row. Consistency is everything.', metric: NotificationMetric.streak, threshold: 3, rank: 15),
    NotificationDef(id: 'streak:7', emoji: '🔥', title: '7-day streak!', body: 'A full week of daily practice. Outstanding!', metric: NotificationMetric.streak, threshold: 7, rank: 25),
    NotificationDef(id: 'streak:14', emoji: '🔥', title: '14-day streak!', body: 'Two weeks straight — you are unstoppable.', metric: NotificationMetric.streak, threshold: 14, rank: 35),
    NotificationDef(id: 'streak:30', emoji: '🔥', title: '30-day streak!', body: 'A whole month of daily practice. Incredible.', metric: NotificationMetric.streak, threshold: 30, rank: 55),
    // Total XP (monotonic).
    NotificationDef(id: 'xp:100', emoji: '⭐', title: '100 XP earned', body: 'Your first hundred XP — momentum is building.', metric: NotificationMetric.xp, threshold: 100, rank: 12),
    NotificationDef(id: 'xp:500', emoji: '🌟', title: '500 XP earned', body: 'Five hundred XP. You are putting in the work.', metric: NotificationMetric.xp, threshold: 500, rank: 28),
    NotificationDef(id: 'xp:1000', emoji: '💫', title: '1,000 XP earned', body: 'A thousand XP milestone reached!', metric: NotificationMetric.xp, threshold: 1000, rank: 38),
    NotificationDef(id: 'xp:2500', emoji: '✨', title: '2,500 XP earned', body: 'Twenty-five hundred XP — serious progress.', metric: NotificationMetric.xp, threshold: 2500, rank: 50),
    // CEFR level reached (cefrOrdinal: a2 = 1 … c2 = 5).
    NotificationDef(id: 'level:1', emoji: '🎓', title: 'Reached level A2', body: 'Your ability grew from A1 to A2. Onward!', metric: NotificationMetric.level, threshold: 1, rank: 22),
    NotificationDef(id: 'level:2', emoji: '🎓', title: 'Reached level B1', body: 'You are now an intermediate learner (B1).', metric: NotificationMetric.level, threshold: 2, rank: 32),
    NotificationDef(id: 'level:3', emoji: '🎓', title: 'Reached level B2', body: 'Upper-intermediate (B2) reached. Brilliant.', metric: NotificationMetric.level, threshold: 3, rank: 42),
    NotificationDef(id: 'level:4', emoji: '🎓', title: 'Reached level C1', body: 'Advanced (C1) — your Spanish is strong.', metric: NotificationMetric.level, threshold: 4, rank: 52),
    NotificationDef(id: 'level:5', emoji: '🎓', title: 'Reached level C2', body: 'Proficiency (C2) — the top of the scale!', metric: NotificationMetric.level, threshold: 5, rank: 62),
  ];

  int metricValue(NotificationMetric m, NotificationStats s) => switch (m) {
        NotificationMetric.lessons => s.lessonsCompleted,
        NotificationMetric.xp => s.xpTotal,
        NotificationMetric.streak => s.streakDays,
        NotificationMetric.level => s.cefrOrdinal,
      };

  /// True iff the learner has genuinely passed [def]'s threshold.
  bool earned(NotificationDef def, NotificationStats stats) =>
      metricValue(def.metric, stats) >= def.threshold;

  /// The inbox: every milestone the learner has genuinely earned, ordered
  /// biggest-first (descending [rank]), each flagged read iff its id is in
  /// [readIds]. A fresh account ⇒ an empty list (honest).
  List<AppNotification> project(
    NotificationStats stats,
    Set<String> readIds, {
    Map<String, DateTime> earnedAt = const <String, DateTime>{},
  }) {
    final List<NotificationDef> earnedDefs = <NotificationDef>[
      for (final NotificationDef d in catalogue)
        if (earned(d, stats)) d,
    ]..sort((NotificationDef a, NotificationDef b) => b.rank.compareTo(a.rank));
    return <AppNotification>[
      for (final NotificationDef d in earnedDefs)
        AppNotification(
          id: d.id,
          emoji: d.emoji,
          title: d.title,
          body: d.body,
          read: readIds.contains(d.id),
          earnedAt: earnedAt[d.id],
        ),
    ];
  }

  /// Count of earned notifications not yet marked read.
  int unreadCount(NotificationStats stats, Set<String> readIds) {
    int n = 0;
    for (final NotificationDef d in catalogue) {
      if (earned(d, stats) && !readIds.contains(d.id)) n++;
    }
    return n;
  }

  /// Every earned id (the screen passes these to "mark all read").
  Set<String> earnedIds(NotificationStats stats) => <String>{
        for (final NotificationDef d in catalogue)
          if (earned(d, stats)) d.id,
      };

  /// Ids whose threshold is crossed in [after] but was NOT in [before] — the
  /// genuine earn moments a caller may stamp against a real clock (D-13).
  /// Pure and clockless: the diff carries no time; the caller records it.
  Set<String> newlyEarned(NotificationStats before, NotificationStats after) =>
      <String>{
        for (final NotificationDef d in catalogue)
          if (!earned(d, before) && earned(d, after)) d.id,
      };
}

/// Compact relative age of an earn stamp, matching the design mock's per-row
/// labels (`2h` / `5h` / `1d` — `Ratel App.dc.html` notifications rows): under
/// a minute ⇒ `now`, under an hour ⇒ `Xm`, under a day ⇒ `Xh`, else `Xd`.
/// Pure — [now] is injected, so the engine file stays clockless. A stamp in
/// the future (clock skew) clamps to `now`.
String relativeEarnedLabel(DateTime earnedAt, DateTime now) {
  final Duration age = now.difference(earnedAt);
  if (age.inMinutes < 1) return 'now';
  if (age.inHours < 1) return '${age.inMinutes}m';
  if (age.inDays < 1) return '${age.inHours}h';
  return '${age.inDays}d';
}
