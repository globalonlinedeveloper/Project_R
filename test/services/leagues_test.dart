import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/leagues/leagues.dart';

/// Pure-engine tests for the weekly-league ladder [R-I6]. Deterministic — no
/// clock, no fabricated cohort: ranking, zones, tier transitions and the
/// catch-up gap are exact functions of the members' REAL weekly XP.
void main() {
  const LeaguesEngine engine = LeaguesEngine();

  // A strictly-descending cohort (rank == i+1, no tie ambiguity).
  List<LeagueMember> cohortOf(int n) => <LeagueMember>[
        for (int i = 0; i < n; i++)
          LeagueMember(
            id: 'm${i + 100}',
            displayName: 'P$i',
            avatarEmoji: '🦊',
            weeklyXp: (n - i) * 100,
          ),
      ];

  test('ladder is the ten tiers, entry→apex', () {
    expect(LeaguesEngine.ladder.length, 10);
    expect(LeaguesEngine.ladder.first, LeagueTier.bronze);
    expect(LeaguesEngine.ladder.last, LeagueTier.diamond);
    expect(LeagueTier.bronze.isEntry, isTrue);
    expect(LeagueTier.diamond.isApex, isTrue);
  });

  test('ranks by weekly XP desc, ties broken by id asc (deterministic)', () {
    final List<LeagueStanding> r = engine.rank(const <LeagueMember>[
      LeagueMember(id: 'b', displayName: 'B', avatarEmoji: '🐼', weeklyXp: 100),
      LeagueMember(id: 'a', displayName: 'A', avatarEmoji: '🦊', weeklyXp: 100),
      LeagueMember(id: 'c', displayName: 'C', avatarEmoji: '🐱', weeklyXp: 300),
    ]);
    expect(r.map((LeagueStanding s) => s.member.id).toList(),
        <String>['c', 'a', 'b']);
    expect(r.map((LeagueStanding s) => s.rank).toList(), <int>[1, 2, 3]);
  });

  test('15-cohort zones match the design: 1–7 promote, 8–10 hold, 11–15 demote',
      () {
    final List<LeagueStanding> r = engine.rank(cohortOf(15));
    LeagueZone z(int rank) =>
        r.firstWhere((LeagueStanding s) => s.rank == rank).zone;
    for (int rank = 1; rank <= 7; rank++) {
      expect(z(rank), LeagueZone.promotion, reason: 'rank $rank');
    }
    for (int rank = 8; rank <= 10; rank++) {
      expect(z(rank), LeagueZone.hold, reason: 'rank $rank');
    }
    for (int rank = 11; rank <= 15; rank++) {
      expect(z(rank), LeagueZone.demotion, reason: 'rank $rank');
    }
  });

  test('solo cohort is honest: one real member, rank 1, promotion zone', () {
    final List<LeagueStanding> r = engine.rank(const <LeagueMember>[
      LeagueMember(
          id: 'you',
          displayName: 'You',
          avatarEmoji: '🦡',
          weeklyXp: 0,
          isYou: true),
    ]);
    expect(r.length, 1);
    expect(r.single.rank, 1);
    expect(r.single.zone, LeagueZone.promotion);
    expect(r.single.member.isYou, isTrue);
  });

  test('resolveTier promotes the top, demotes the bottom, holds the middle', () {
    expect(engine.resolveTier(LeagueTier.gold, 1, 15), LeagueTier.sapphire);
    expect(engine.resolveTier(LeagueTier.gold, 9, 15), LeagueTier.gold);
    expect(engine.resolveTier(LeagueTier.gold, 13, 15), LeagueTier.silver);
  });

  test('tier transitions clamp at the ladder ends', () {
    expect(engine.resolveTier(LeagueTier.diamond, 1, 15), LeagueTier.diamond);
    expect(engine.resolveTier(LeagueTier.bronze, 15, 15), LeagueTier.bronze);
  });

  test('LeagueWeek.startOf returns the Monday of the week', () {
    expect(LeagueWeek.startOf(DateTime(2026, 6, 30)), DateTime(2026, 6, 29));
    expect(LeagueWeek.startOf(DateTime(2026, 6, 29)), DateTime(2026, 6, 29));
    expect(LeagueWeek.startOf(DateTime(2026, 7, 5)), DateTime(2026, 6, 29));
  });

  test('LeagueWeek.daysRemaining counts Mon(7) down to Sun(1), never 0', () {
    expect(LeagueWeek.daysRemaining(DateTime(2026, 6, 29)), 7);
    expect(LeagueWeek.daysRemaining(DateTime(2026, 7, 3)), 3);
    expect(LeagueWeek.daysRemaining(DateTime(2026, 7, 5)), 1);
  });

  test('xpToRankAbove is the real gap, 0 at the top', () {
    final List<LeagueStanding> r = engine.rank(const <LeagueMember>[
      LeagueMember(id: 'a', displayName: 'A', avatarEmoji: '🦊', weeklyXp: 1390),
      LeagueMember(id: 'b', displayName: 'B', avatarEmoji: '🐼', weeklyXp: 1240),
    ]);
    expect(engine.xpToRankAbove(r, 2), 150);
    expect(engine.xpToRankAbove(r, 1), 0);
  });
}
