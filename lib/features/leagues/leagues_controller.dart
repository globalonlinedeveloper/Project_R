import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/services/leagues/leagues.dart';

/// Bridges the REAL learner weekly XP to the pure [LeaguesEngine] (design spec
/// §4.3 [R-I6]). Honesty (charter "don't fake depth"): the cohort is the
/// signed-in learner ALONE — one real member with their real weekly XP — never a
/// fabricated leaderboard of bots. Promotion / demotion zones, the ten-tier
/// ladder and the catch-up gap are all REAL engine output; they simply describe
/// a cohort of one until other learners join. The current tier stays the entry
/// tier (Bronze): the weekly cohort CLOSE that promotes / relegates is the same
/// scheduled go-live wiring as every other durable R-O1 counter — not faked.
const LeaguesEngine _engine = LeaguesEngine();

/// The honest weekly cohort: just you, carrying your REAL weekly XP.
final leagueCohortProvider = Provider<List<LeagueMember>>((ref) {
  final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
  return <LeagueMember>[
    LeagueMember(
      id: 'you',
      displayName: 'You',
      avatarEmoji: '🦡',
      weeklyXp: snap.xpWeekEarned,
      isYou: true,
    ),
  ];
});

/// The ranked standings (a real engine ranking of the cohort).
final leagueStandingsProvider = Provider<List<LeagueStanding>>(
    (ref) => _engine.rank(ref.watch(leagueCohortProvider)));

/// Immutable view-model for the Leagues screen: the learner's tier, their own
/// standing, the whole cohort, the weekly rules and the days left this week.
class LeagueStatus {
  const LeagueStatus({
    required this.tier,
    required this.you,
    required this.standings,
    required this.rules,
    required this.daysRemaining,
  });

  final LeagueTier tier;
  final LeagueStanding you;
  final List<LeagueStanding> standings;
  final LeagueRules rules;
  final int daysRemaining;

  int get cohortSize => standings.length;
  bool get isSolo => cohortSize <= 1;

  /// Weekly XP still needed to overtake the rank above (0 when you are first).
  int get xpToRankAbove => _engine.xpToRankAbove(standings, you.rank);
}

final leagueStatusProvider = Provider<LeagueStatus>((ref) {
  final List<LeagueStanding> standings = ref.watch(leagueStandingsProvider);
  final DateTime now = ref.watch(clockProvider)();
  final LeagueStanding you = standings.firstWhere(
    (LeagueStanding s) => s.member.isYou,
    orElse: () => standings.first,
  );
  return LeagueStatus(
    tier: LeagueTier.bronze,
    you: you,
    standings: standings,
    rules: _engine.rules,
    daysRemaining: LeagueWeek.daysRemaining(now),
  );
});
