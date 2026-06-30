// R-I6 / R-M3 — Leagues cohort-close SLICE 2: the leagues controller now CONSUMES
// the LeaguesStore seam. Signed-in -> it persists the learner's own weekly standing
// and reads the REAL cross-user cohort (the SECURITY DEFINER read, faked here);
// guest / in-memory -> the honest solo baseline is byte-identical to before.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/features/leagues/leagues_controller.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/leagues/leagues.dart';

import 'auth/fake_identity.dart';

/// A [LeaguesStore] double: seeds [load], records [save] payloads, and returns a
/// fixed cross-user [cohort] from readCohort (the SECURITY DEFINER stand-in).
class FakeLeaguesStore implements LeaguesStore {
  FakeLeaguesStore({
    this.loadData = const <String, Object?>{},
    this.cohort = const <Map<String, Object?>>[],
  });

  final Map<String, Object?> loadData;
  final List<Map<String, Object?>> cohort;
  final List<Map<String, Object?>> saves = <Map<String, Object?>>[];

  @override
  Future<Map<String, Object?>> load(String userId) async => loadData;

  @override
  Future<void> save(String userId, Map<String, Object?> data) async =>
      saves.add(data);

  @override
  Future<List<Map<String, Object?>>> readCohort(String userId) async => cohort;
}

/// Let the fire-and-forget sync settle.
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  final DateTime monday = DateTime(2026, 6, 29, 9); // a league-week Monday
  const String week = '2026-06-29';

  test('signed-in: leagueStatus becomes the REAL cohort + persisted tier',
      () async {
    final FakeLeaguesStore store = FakeLeaguesStore(
      loadData: <String, Object?>{
        kLeagueMembershipKey: <Map<String, Object?>>[
          <String, Object?>{'week_start': week, 'tier': 'silver', 'weekly_xp': 100},
        ],
      },
      cohort: <Map<String, Object?>>[
        <String, Object?>{'member_id': 'm-bob', 'display_name': 'Bob', 'avatar_emoji': '🦊', 'weekly_xp': 200, 'tier': 'silver', 'is_you': false},
        <String, Object?>{'member_id': 'm-you', 'display_name': 'Badger', 'avatar_emoji': '🦡', 'weekly_xp': 100, 'tier': 'silver', 'is_you': true},
        <String, Object?>{'member_id': 'm-cara', 'display_name': 'Cara', 'avatar_emoji': '🐼', 'weekly_xp': 50, 'tier': 'silver', 'is_you': false},
      ],
    );
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      clockProvider.overrideWithValue(() => monday),
      identityProvider.overrideWithValue(FakeIdentity()),
      leaguesStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(c.dispose);

    // Keep the provider chain alive (as the screen's watch would) so the
    // fire-and-forget sync's state update propagates; first frame is solo.
    c.listen(leagueStatusProvider, (_, _) {}, fireImmediately: true);
    expect(c.read(leagueStatusProvider).isSolo, true);
    await _settle();

    final LeagueStatus status = c.read(leagueStatusProvider);
    expect(status.cohortSize, 3); // the REAL multi-member cohort
    expect(status.tier, LeagueTier.silver); // persisted tier consumed
    expect(status.you.member.isYou, true);
    expect(status.you.rank, 2); // 200 > 100(you) > 50
    expect(status.standings.first.member.weeklyXp, 200); // ranked desc
    // The learner's OWN standing was persisted (the dormant store is now live).
    expect(store.saves, isNotEmpty);
    final Map<Object?, Object?> saved =
        (store.saves.last[kLeagueMembershipKey] as List).first as Map<Object?, Object?>;
    expect(saved['week_start'], week);
    expect(saved['tier'], 'silver');
  });

  test('guest: the honest solo cohort is byte-identical (no persistence)',
      () async {
    // Even a populated cohort is never read for a guest (uid == null).
    final FakeLeaguesStore store = FakeLeaguesStore(
      cohort: <Map<String, Object?>>[
        <String, Object?>{'member_id': 'x', 'display_name': 'Ghost', 'avatar_emoji': '👻', 'weekly_xp': 999, 'is_you': false},
      ],
    );
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      clockProvider.overrideWithValue(() => monday),
      leaguesStoreProvider.overrideWithValue(store),
      // no identity override -> AnonymousIdentity (uid null)
    ]);
    addTearDown(c.dispose);

    c.listen(leagueStatusProvider, (_, _) {}, fireImmediately: true);
    await _settle();

    final LeagueStatus status = c.read(leagueStatusProvider);
    expect(status.isSolo, true);
    expect(status.cohortSize, 1);
    expect(status.tier, LeagueTier.bronze);
    expect(status.you.member.isYou, true);
    expect(store.saves, isEmpty); // a guest persists nothing
  });

  test('signed-in, no cross-user backend: solo baseline but OWN standing persisted',
      () async {
    final FakeLeaguesStore store = FakeLeaguesStore(); // empty cohort -> honest solo
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      clockProvider.overrideWithValue(() => monday),
      identityProvider.overrideWithValue(FakeIdentity()),
      leaguesStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(c.dispose);

    // Earn real weekly XP first, then let the sync persist it.
    c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 30);
    c.listen(leagueStatusProvider, (_, _) {}, fireImmediately: true);
    await _settle();

    final LeagueStatus status = c.read(leagueStatusProvider);
    expect(status.isSolo, true); // no fabricated rivals
    expect(store.saves, isNotEmpty);
    final Map<Object?, Object?> saved =
        (store.saves.last[kLeagueMembershipKey] as List).first as Map<Object?, Object?>;
    expect(saved['weekly_xp'], 30); // the REAL weekly XP was persisted
    expect(saved['week_start'], week);
  });
}
