// R-I6 / R-M3 — Leagues cohort-close SLICE 2: the leagues controller now CONSUMES
// the LeaguesStore seam. Signed-in -> it persists the learner's own weekly standing
// and reads the REAL cross-user cohort (the SECURITY DEFINER read, faked here);
// guest / in-memory -> the honest solo baseline is byte-identical to before.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/features/leagues/leagues_controller.dart';
import 'package:ratel/features/shop/outfits_controller.dart';
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

  test(
    'signed-in: leagueStatus becomes the REAL cohort + persisted tier',
    () async {
      final FakeLeaguesStore store = FakeLeaguesStore(
        loadData: <String, Object?>{
          kLeagueMembershipKey: <Map<String, Object?>>[
            <String, Object?>{
              'week_start': week,
              'tier': 'silver',
              'weekly_xp': 100,
            },
          ],
        },
        cohort: <Map<String, Object?>>[
          <String, Object?>{
            'member_id': 'm-bob',
            'display_name': 'Bob',
            'avatar_emoji': '🦊',
            'weekly_xp': 200,
            'tier': 'silver',
            'is_you': false,
          },
          <String, Object?>{
            'member_id': 'm-you',
            'display_name': 'Badger',
            'avatar_emoji': '🦡',
            'weekly_xp': 100,
            'tier': 'silver',
            'is_you': true,
          },
          <String, Object?>{
            'member_id': 'm-cara',
            'display_name': 'Cara',
            'avatar_emoji': '🐼',
            'weekly_xp': 50,
            'tier': 'silver',
            'is_you': false,
          },
        ],
      );
      final ProviderContainer c = ProviderContainer(
        overrides: <Override>[
          clockProvider.overrideWithValue(() => monday),
          identityProvider.overrideWithValue(FakeIdentity()),
          leaguesStoreProvider.overrideWithValue(store),
        ],
      );
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
          (store.saves.last[kLeagueMembershipKey] as List).first
              as Map<Object?, Object?>;
      expect(saved['week_start'], week);
      expect(saved['tier'], 'silver');
    },
  );

  test(
    'cohort member with no display_name -> empty name (localized at render, '
    'never a baked English "Learner")',
    () async {
      final FakeLeaguesStore store = FakeLeaguesStore(
        cohort: <Map<String, Object?>>[
          <String, Object?>{
            'member_id': 'm-anon',
            // no display_name key: the controller must NOT bake 'Learner'.
            'avatar_emoji': '\u{1F9A1}',
            'weekly_xp': 10,
            'tier': 'bronze',
            'is_you': false,
          },
          <String, Object?>{
            'member_id': 'm-you',
            'display_name': 'Badger',
            'avatar_emoji': '\u{1F9A1}',
            'weekly_xp': 5,
            'tier': 'bronze',
            'is_you': true,
          },
        ],
      );
      final ProviderContainer c = ProviderContainer(
        overrides: <Override>[
          clockProvider.overrideWithValue(() => monday),
          identityProvider.overrideWithValue(FakeIdentity()),
          leaguesStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(c.dispose);
      c.read(leaguesSyncProvider);
      await _settle();
      final LeagueStatus status = c.read(leagueStatusProvider);
      final LeagueStanding anon =
          status.standings.firstWhere((LeagueStanding s) => s.member.id == 'm-anon');
      expect(anon.member.displayName, ''); // render maps ''->profileLearner
    },
  );

  test(
    'guest: the honest solo cohort is byte-identical (no persistence)',
    () async {
      // Even a populated cohort is never read for a guest (uid == null).
      final FakeLeaguesStore store = FakeLeaguesStore(
        cohort: <Map<String, Object?>>[
          <String, Object?>{
            'member_id': 'x',
            'display_name': 'Ghost',
            'avatar_emoji': '👻',
            'weekly_xp': 999,
            'is_you': false,
          },
        ],
      );
      final ProviderContainer c = ProviderContainer(
        overrides: <Override>[
          clockProvider.overrideWithValue(() => monday),
          leaguesStoreProvider.overrideWithValue(store),
          // no identity override -> AnonymousIdentity (uid null)
        ],
      );
      addTearDown(c.dispose);

      c.listen(leagueStatusProvider, (_, _) {}, fireImmediately: true);
      await _settle();

      final LeagueStatus status = c.read(leagueStatusProvider);
      expect(status.isSolo, true);
      expect(status.cohortSize, 1);
      expect(status.tier, LeagueTier.bronze);
      expect(status.you.member.isYou, true);
      expect(store.saves, isEmpty); // a guest persists nothing
    },
  );

  test(
    'signed-in, no cross-user backend: solo baseline but OWN standing persisted',
    () async {
      final FakeLeaguesStore store =
          FakeLeaguesStore(); // empty cohort -> honest solo
      final ProviderContainer c = ProviderContainer(
        overrides: <Override>[
          clockProvider.overrideWithValue(() => monday),
          identityProvider.overrideWithValue(FakeIdentity()),
          leaguesStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(c.dispose);

      // Earn real weekly XP first, then let the sync persist it.
      c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 30);
      c.listen(leagueStatusProvider, (_, _) {}, fireImmediately: true);
      await _settle();

      final LeagueStatus status = c.read(leagueStatusProvider);
      expect(status.isSolo, true); // no fabricated rivals
      expect(store.saves, isNotEmpty);
      final Map<Object?, Object?> saved =
          (store.saves.last[kLeagueMembershipKey] as List).first
              as Map<Object?, Object?>;
      expect(saved['weekly_xp'], 30); // the REAL weekly XP was persisted
      expect(saved['week_start'], week);
    },
  );

  test(
    'refresh re-syncs: re-persists own standing + surfaces new cohort members',
    () async {
      // A store whose cohort GROWS on the 2nd read — a rival joining between opens.
      // refresh() must surface them WITHOUT a full reload (own-row RLS blocks a true
      // stream, so the live update is a re-poll of read_league_cohort).
      final GrowingCohortStore store = GrowingCohortStore();
      final ProviderContainer c = ProviderContainer(
        overrides: <Override>[
          clockProvider.overrideWithValue(() => monday),
          identityProvider.overrideWithValue(FakeIdentity()),
          leaguesStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(c.dispose);

      c.listen(leagueStatusProvider, (_, _) {}, fireImmediately: true);
      await _settle();
      expect(
        c.read(leagueStatusProvider).cohortSize,
        1,
      ); // first read: just you
      final int savesAfterBuild = store.saves.length;
      expect(savesAfterBuild, greaterThan(0));

      await c.read(leaguesSyncProvider.notifier).refresh();
      await _settle();

      expect(c.read(leagueStatusProvider).cohortSize, 2); // rival surfaced live
      expect(
        store.saves.length,
        greaterThan(savesAfterBuild),
      ); // own standing re-persisted
    },
  );

  test('refresh for a guest is an honest no-op (nothing persisted)', () async {
    final FakeLeaguesStore store = FakeLeaguesStore(
      cohort: <Map<String, Object?>>[
        <String, Object?>{
          'member_id': 'x',
          'display_name': 'Ghost',
          'avatar_emoji': '👻',
          'weekly_xp': 999,
          'is_you': false,
        },
      ],
    );
    final ProviderContainer c = ProviderContainer(
      overrides: <Override>[
        clockProvider.overrideWithValue(() => monday),
        leaguesStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(c.dispose);

    c.listen(leagueStatusProvider, (_, _) {}, fireImmediately: true);
    await _settle();
    await c.read(leaguesSyncProvider.notifier).refresh();
    await _settle();

    expect(
      c.read(leagueStatusProvider).isSolo,
      true,
    ); // never a fabricated cohort
    expect(store.saves, isEmpty); // a guest persists nothing, even on refresh
  });

  // INC-LG1: the solo "You" row shows the learner's REAL chosen avatar, resolved
  // exactly as Profile does (settings.avatarEmoji, else the equipped outfit emoji),
  // instead of the hardcoded 🦡. Honesty-safe: only the learner's OWN row.
  group('INC-LG1 own avatar in leagueCohortProvider', () {
    LeagueMember you(ProviderContainer c) => c
        .read(leagueCohortProvider)
        .firstWhere((LeagueMember m) => m.isYou);

    test('picked avatar emoji drives the "You" row', () async {
      final ProviderContainer c = ProviderContainer();
      addTearDown(c.dispose);
      await c
          .read(appSettingsControllerProvider.notifier)
          .setAvatarEmoji('🦊');
      expect(you(c).avatarEmoji, '🦊'); // the learner's own chosen emoji
    });

    test(
      'empty avatar emoji falls back to the equipped outfit emoji (not 🦡)',
      () async {
        // avatarEmoji stays '' (AppSettings default) so the fallback branch runs;
        // override the equipped outfit to Wizard 🧙 so the asserted value can ONLY
        // come from equippedOutfitProvider — never the old hardcoded badger.
        final ProviderContainer c = ProviderContainer(
          overrides: <Override>[
            equippedOutfitProvider
                .overrideWithValue(OutfitCatalogue.byId('wizard')),
          ],
        );
        addTearDown(c.dispose);
        expect(
          c.read(appSettingsControllerProvider).avatarEmoji,
          '',
        ); // precondition: empty -> fallback path
        expect(you(c).avatarEmoji, '🧙'); // equipped outfit emoji, via fallback
      },
    );
  });
}

/// A [LeaguesStore] whose cross-user cohort GROWS on the 2nd read — proves that
/// refresh() re-polls read_league_cohort and surfaces new members live.
class GrowingCohortStore implements LeaguesStore {
  int _reads = 0;
  final List<Map<String, Object?>> saves = <Map<String, Object?>>[];

  @override
  Future<Map<String, Object?>> load(String userId) async =>
      const <String, Object?>{};

  @override
  Future<void> save(String userId, Map<String, Object?> data) async =>
      saves.add(data);

  @override
  Future<List<Map<String, Object?>>> readCohort(String userId) async {
    _reads++;
    return <Map<String, Object?>>[
      <String, Object?>{
        'member_id': 'm-you',
        'display_name': 'Badger',
        'avatar_emoji': '🦡',
        'weekly_xp': 100,
        'tier': 'bronze',
        'is_you': true,
      },
      if (_reads >= 2)
        <String, Object?>{
          'member_id': 'm-bob',
          'display_name': 'Bob',
          'avatar_emoji': '🦊',
          'weekly_xp': 50,
          'tier': 'bronze',
          'is_you': false,
        },
    ];
  }
}
