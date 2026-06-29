/// Pure, deterministic achievement engine (design spec §4.5 / §6 "achievements"
/// [R-I7]). Every milestone is evaluated from the learner's REAL state — lessons
/// completed, XP, day-streak, saved words, and the CEFR level derived from θ —
/// so a fresh account honestly shows everything LOCKED with real progress, and a
/// badge unlocks only when the learner has genuinely earned it. No fabricated
/// data and no hidden state: this engine holds no clock, exactly like the other
/// `lib/services` learning engines (the durable cross-restart store is the same
/// flagged go-live wiring as every other R-O1 counter).
library;

/// The REAL learner counters / derived level a milestone is measured against.
class AchievementStats {
  const AchievementStats({
    required this.lessonsCompleted,
    required this.xpTotal,
    required this.streakDays,
    required this.savedWords,
    required this.cefrOrdinal,
  });

  final int lessonsCompleted;
  final int xpTotal;
  final int streakDays;
  final int savedWords;

  /// 0 = A1, 1 = A2, … 5 = C2 — the index of the derived CEFR level.
  final int cefrOrdinal;

  static const AchievementStats zero = AchievementStats(
    lessonsCompleted: 0,
    xpTotal: 0,
    streakDays: 0,
    savedWords: 0,
    cefrOrdinal: 0,
  );
}

/// Which REAL metric a milestone reads.
enum AchievementMetric { lessons, xp, streak, words, level }

/// A milestone definition — an honest threshold over one real metric.
class Achievement {
  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.metric,
    required this.target,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;
  final AchievementMetric metric;
  final int target;
}

/// One evaluated achievement: the learner's current value vs the target.
class AchievementProgress {
  const AchievementProgress(this.achievement, this.current);

  final Achievement achievement;
  final int current;

  int get target => achievement.target;
  bool get unlocked => current >= achievement.target;

  /// Progress toward the target, clamped to [0, 1].
  double get fraction {
    if (achievement.target <= 0) {
      return 1;
    }
    return (current / achievement.target).clamp(0.0, 1.0).toDouble();
  }
}

/// The clockless achievement engine.
class AchievementsEngine {
  const AchievementsEngine();

  /// The launch catalogue — every entry reads a REAL metric. League / social /
  /// economy milestones are deliberately absent (they have no engine, §6).
  static const List<Achievement> catalogue = <Achievement>[
    Achievement(
      id: 'first_steps',
      emoji: '🌱',
      title: 'First Steps',
      description: 'Finish your first lesson',
      metric: AchievementMetric.lessons,
      target: 1,
    ),
    Achievement(
      id: 'scholar',
      emoji: '📚',
      title: 'Scholar',
      description: 'Complete 10 lessons',
      metric: AchievementMetric.lessons,
      target: 10,
    ),
    Achievement(
      id: 'wildfire',
      emoji: '🔥',
      title: 'Wildfire',
      description: 'Keep a 3-day streak',
      metric: AchievementMetric.streak,
      target: 3,
    ),
    Achievement(
      id: 'point_maker',
      emoji: '⭐',
      title: 'Point Maker',
      description: 'Earn 500 XP',
      metric: AchievementMetric.xp,
      target: 500,
    ),
    Achievement(
      id: 'collector',
      emoji: '🗃️',
      title: 'Collector',
      description: 'Save 25 words',
      metric: AchievementMetric.words,
      target: 25,
    ),
    Achievement(
      id: 'rising_star',
      emoji: '🎓',
      title: 'Rising Star',
      description: 'Reach level A2',
      metric: AchievementMetric.level,
      target: 1,
    ),
  ];

  /// The learner's current value for a metric.
  int metricValue(AchievementMetric m, AchievementStats s) => switch (m) {
        AchievementMetric.lessons => s.lessonsCompleted,
        AchievementMetric.xp => s.xpTotal,
        AchievementMetric.streak => s.streakDays,
        AchievementMetric.words => s.savedWords,
        AchievementMetric.level => s.cefrOrdinal,
      };

  /// Evaluate the whole catalogue against the learner's real [stats].
  List<AchievementProgress> evaluate(AchievementStats stats) =>
      <AchievementProgress>[
        for (final Achievement a in catalogue)
          AchievementProgress(a, metricValue(a.metric, stats)),
      ];

  /// How many milestones are genuinely unlocked.
  int unlockedCount(AchievementStats stats) =>
      evaluate(stats).where((AchievementProgress p) => p.unlocked).length;
}
