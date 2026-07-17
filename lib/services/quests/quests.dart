/// Pure, deterministic DAILY-quest engine (design spec §4.4 / §6 "quests"
/// [R-I7]). Every quest is measured from the learner's REAL session metrics —
/// the XP earned today and whether they have practised today — so a fresh day
/// honestly shows the quests open with real progress, and a quest completes
/// only when it has genuinely been earned. No fabricated progress and no hidden
/// state: this engine holds no clock, exactly like the [AchievementsEngine] and
/// the other lib/services learning engines (the daily reset + the durable
/// cross-restart store are the same flagged go-live wiring as every other R-O1
/// counter). Quest REWARDS beyond the XP already earned (💎 diamonds, reward
/// chests, friend quests) have NO engine yet — an owner decision (§6), and are
/// never faked here.
library;

/// The REAL daily metrics a quest is measured against.
class QuestStats {
  const QuestStats({
    required this.xpToday,
    required this.streakDays,
    required this.dailyGoal,
  });

  /// XP genuinely earned today (resets at the day boundary — go-live wiring).
  final int xpToday;

  /// Current day-streak length (used for the streak quest's copy).
  final int streakDays;

  /// The learner's chosen daily XP goal (Casual 10 … Intense 50).
  final int dailyGoal;

  static const QuestStats zero =
      QuestStats(xpToday: 0, streakDays: 0, dailyGoal: 20);
}

/// Which REAL signal a quest reads.
enum QuestMetric {
  /// Progress = XP earned today; target = a multiple of the daily goal.
  xpToday,

  /// Progress = 1 once any XP has been earned today (keeps the streak alive).
  practicedToday,
}

/// A daily-quest definition — an honest target over one real daily metric.
class Quest {
  const Quest({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.metric,
    this.goalMultiple = 1,
    this.rewardDiamonds = 3,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;
  final QuestMetric metric;

  /// For [QuestMetric.xpToday] the target is `goalMultiple * dailyGoal`.
  final int goalMultiple;

  /// The 💎 the learner genuinely earns the first time this quest is completed
  /// on a given day (R-I4, INC-QR1). A pure, honest constant — the SAME small
  /// flat amount for every quest, mirroring the auditable [DiamondsModel]
  /// reward constants. It is a real, deterministic reward the learner WILL
  /// receive, never a fabricated balance; the engine stays clockless and holds
  /// no wallet — the [LearnerController] owns the credit + its idempotency.
  final int rewardDiamonds;
}

/// One evaluated quest: the learner's current value vs the target.
class QuestProgress {
  const QuestProgress(this.quest, this.current, this.target);

  final Quest quest;
  final int current;
  final int target;

  bool get done => current >= target;

  /// Progress toward the target, clamped to [0, 1].
  double get fraction {
    if (target <= 0) {
      return 1;
    }
    return (current / target).clamp(0.0, 1.0).toDouble();
  }
}

/// The clockless daily-quest engine.
class QuestsEngine {
  const QuestsEngine();

  /// Daily quest board — every entry reads a REAL daily metric. The standalone
  /// "Daily goal" card on the Quests screen already covers the 1× goal, so
  /// these are the stretch + streak quests. League / friend / reward-economy
  /// quests are deliberately absent (they have no engine, §6).
  static const List<Quest> catalogue = <Quest>[
    Quest(
      id: 'power_session',
      emoji: '⚡',
      title: 'Power session',
      description: 'Earn double your daily goal',
      metric: QuestMetric.xpToday,
      goalMultiple: 2,
    ),
    Quest(
      id: 'on_fire',
      emoji: '🚀',
      title: 'On fire',
      description: 'Earn triple your daily goal',
      metric: QuestMetric.xpToday,
      goalMultiple: 3,
    ),
    Quest(
      id: 'streak_keeper',
      emoji: '🔥',
      title: 'Streak keeper',
      description: 'Practice today to keep your streak',
      metric: QuestMetric.practicedToday,
    ),
  ];

  int _current(Quest q, QuestStats s) => switch (q.metric) {
        QuestMetric.xpToday => s.xpToday,
        QuestMetric.practicedToday => s.xpToday > 0 ? 1 : 0,
      };

  int _target(Quest q, QuestStats s) => switch (q.metric) {
        QuestMetric.xpToday =>
          (q.goalMultiple * s.dailyGoal) < 1 ? 1 : q.goalMultiple * s.dailyGoal,
        QuestMetric.practicedToday => 1,
      };

  /// Evaluate the whole board against the learner's real [stats].
  List<QuestProgress> evaluate(QuestStats stats) => <QuestProgress>[
        for (final Quest q in catalogue)
          QuestProgress(q, _current(q, stats), _target(q, stats)),
      ];

  /// How many quests are genuinely completed.
  int completedCount(QuestStats stats) =>
      evaluate(stats).where((QuestProgress p) => p.done).length;
}
