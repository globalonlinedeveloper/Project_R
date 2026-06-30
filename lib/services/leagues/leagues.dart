/// Pure, deterministic weekly-LEAGUE engine (design spec §4.3 / §6 item 2,
/// "leagues / leaderboards" [R-I6]). It ranks a cohort by each member's REAL
/// weekly XP, classifies promotion / hold / demotion zones, and resolves the
/// end-of-week tier move — all exact, clockless functions holding no state (the
/// week boundary + the durable cohort store are the same go-live wiring as every
/// other R-O1 counter, owned by the controller). Honesty (charter "don't fake
/// depth"): this engine invents NO members and NO XP — a solo learner is an
/// honest cohort of one (rank 1), never a fabricated leaderboard. The ten-tier
/// ladder mirrors the design (Bronze → Diamond).
library;

/// One of the ten league tiers, entry (bronze) → apex (diamond). The emoji is
/// the design's badge glyph; per-tier COLOURS live in lib/core/theme (tokens are
/// the sole raw-hex home), never here — this layer stays pure Dart.
enum LeagueTier {
  bronze('Bronze', '🥉'),
  silver('Silver', '🥈'),
  gold('Gold', '🥇'),
  sapphire('Sapphire', '💙'),
  ruby('Ruby', '❤️'),
  emerald('Emerald', '💚'),
  amethyst('Amethyst', '💜'),
  pearl('Pearl', '🤍'),
  obsidian('Obsidian', '🖤'),
  diamond('Diamond', '💎');

  const LeagueTier(this.label, this.emoji);

  final String label;
  final String emoji;

  /// 0 = bronze (entry) … 9 = diamond (apex).
  int get ladderIndex => index;
  bool get isApex => this == LeagueTier.diamond;
  bool get isEntry => this == LeagueTier.bronze;

  /// One tier up, clamped at the apex.
  LeagueTier get promoted => isApex ? this : LeagueTier.values[index + 1];

  /// One tier down, clamped at the entry tier.
  LeagueTier get demoted => isEntry ? this : LeagueTier.values[index - 1];
}

/// Where a rank sits relative to the weekly promotion / demotion cut-offs.
enum LeagueZone { promotion, hold, demotion }

/// The weekly cohort rules: how many ranks promote / relegate, and the intended
/// cohort size. Defaults mirror the design (top 7 climb, bottom 5 drop).
class LeagueRules {
  const LeagueRules({
    this.promoteTop = 7,
    this.demoteBottom = 5,
    this.cohortTarget = 30,
  });

  final int promoteTop;
  final int demoteBottom;
  final int cohortTarget;

  static const LeagueRules standard = LeagueRules();
}

/// A cohort member and their REAL weekly XP. [isYou] marks the signed-in user.
class LeagueMember {
  const LeagueMember({
    required this.id,
    required this.displayName,
    required this.avatarEmoji,
    required this.weeklyXp,
    this.isYou = false,
  });

  final String id;
  final String displayName;
  final String avatarEmoji;
  final int weeklyXp;
  final bool isYou;
}

/// A member's ranked standing within the cohort.
class LeagueStanding {
  const LeagueStanding({
    required this.member,
    required this.rank,
    required this.zone,
  });

  final LeagueMember member;
  final int rank;
  final LeagueZone zone;

  bool get isPromotion => zone == LeagueZone.promotion;
  bool get isDemotion => zone == LeagueZone.demotion;
}

/// The clockless weekly-league engine.
class LeaguesEngine {
  const LeaguesEngine({this.rules = LeagueRules.standard});

  final LeagueRules rules;

  /// All ten tiers, entry → apex.
  static const List<LeagueTier> ladder = LeagueTier.values;

  /// The zone for a 1-based [rank] in a cohort of [cohortSize]. Promotion takes
  /// precedence, so a cohort smaller than the promote cut never reports anyone
  /// as demoting (an honest solo cohort: rank 1 promotes).
  LeagueZone zoneFor(int rank, int cohortSize) {
    if (rank <= rules.promoteTop) {
      return LeagueZone.promotion;
    }
    if (rank > cohortSize - rules.demoteBottom) {
      return LeagueZone.demotion;
    }
    return LeagueZone.hold;
  }

  /// Rank a cohort by weekly XP (descending), ties broken by id (ascending) for
  /// a stable, deterministic order; assign a 1-based rank + zone.
  List<LeagueStanding> rank(List<LeagueMember> cohort) {
    final List<LeagueMember> sorted = List<LeagueMember>.of(cohort)
      ..sort((LeagueMember a, LeagueMember b) {
        final int byXp = b.weeklyXp.compareTo(a.weeklyXp);
        return byXp != 0 ? byXp : a.id.compareTo(b.id);
      });
    final int n = sorted.length;
    return <LeagueStanding>[
      for (int i = 0; i < n; i++)
        LeagueStanding(member: sorted[i], rank: i + 1, zone: zoneFor(i + 1, n)),
    ];
  }

  /// The tier a member moves to when the week closes at [rank] of [cohortSize]:
  /// promote (top), demote (bottom) or hold — clamped at the ladder ends.
  LeagueTier resolveTier(LeagueTier current, int rank, int cohortSize) =>
      switch (zoneFor(rank, cohortSize)) {
        LeagueZone.promotion => current.promoted,
        LeagueZone.demotion => current.demoted,
        LeagueZone.hold => current,
      };

  /// Weekly XP needed to catch the member ranked one place above [rank] (0 when
  /// already first, or when the gap is non-positive / the rank is absent).
  int xpToRankAbove(List<LeagueStanding> standings, int rank) {
    if (rank <= 1) {
      return 0;
    }
    LeagueStanding? me;
    LeagueStanding? above;
    for (final LeagueStanding s in standings) {
      if (s.rank == rank) {
        me = s;
      } else if (s.rank == rank - 1) {
        above = s;
      }
    }
    if (me == null || above == null) {
      return 0;
    }
    final int gap = above.member.weeklyXp - me.member.weeklyXp;
    return gap < 0 ? 0 : gap;
  }
}

/// Pure ISO-week math for the weekly league reset (Monday 00:00 boundary). The
/// caller passes the wall-clock date, so this stays clockless like the rest of
/// the engine.
class LeagueWeek {
  const LeagueWeek._();

  /// The Monday (date-only) of the league week containing [date].
  static DateTime startOf(DateTime date) {
    final DateTime d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }

  /// Whole days remaining until the next reset (next Monday): 7 on the reset day
  /// itself, 1 on the final Sunday — always >= 1, never a confusing 0.
  static int daysRemaining(DateTime date) {
    final DateTime d = DateTime(date.year, date.month, date.day);
    return DateTime.daysPerWeek - (d.weekday - DateTime.monday);
  }
}
