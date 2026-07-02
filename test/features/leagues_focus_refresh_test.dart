// R-I6 / R-M3 — Leagues FOCUS-REFRESH (S77): re-poll the live cross-user cohort
// when the Leagues tab REGAINS focus, complementing the S76 pull-to-refresh.
// RatelShell publishes the active branch via activeTabIndexProvider;
// LeaguesSyncController listens and re-syncs on the rising edge into /leagues.
// Rising-edge only, coalesced, and a guest is an honest no-op.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/navigation_focus.dart';
import 'package:ratel/features/leagues/leagues_controller.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/identity/identity.dart';

import 'auth/fake_identity.dart';

/// A [LeaguesStore] whose cross-user cohort GROWS on the 2nd read — proves a
/// focus re-poll (not the initial build sync) surfaced a new rival live.
class _GrowingStore implements LeaguesStore {
  int reads = 0;
  final List<Map<String, Object?>> saves = <Map<String, Object?>>[];

  @override
  Future<Map<String, Object?>> load(String userId) async =>
      const <String, Object?>{};

  @override
  Future<void> save(String userId, Map<String, Object?> data) async =>
      saves.add(data);

  @override
  Future<List<Map<String, Object?>>> readCohort(String userId) async {
    reads++;
    return <Map<String, Object?>>[
      <String, Object?>{
        'member_id': 'm-you',
        'display_name': 'Badger',
        'avatar_emoji': '🦡',
        'weekly_xp': 100,
        'tier': 'bronze',
        'is_you': true,
      },
      if (reads >= 2)
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

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  final DateTime monday = DateTime(2026, 6, 29, 9); // a league-week Monday

  ProviderContainer signedIn(_GrowingStore store) => ProviderContainer(
        overrides: <Override>[
          clockProvider.overrideWithValue(() => monday),
          identityProvider.overrideWithValue(FakeIdentity()),
          leaguesStoreProvider.overrideWithValue(store),
        ],
      );

  test('re-entering the Leagues tab re-polls the cohort (focus-refresh)',
      () async {
    final _GrowingStore store = _GrowingStore();
    final ProviderContainer c = signedIn(store);
    addTearDown(c.dispose);

    c.listen(leagueStatusProvider, (_, _) {}, fireImmediately: true);
    await _settle();
    expect(c.read(leagueStatusProvider).cohortSize, 1); // initial sync: just you
    final int savesAfterBuild = store.saves.length;
    expect(savesAfterBuild, greaterThan(0));

    // Leave to another tab, then return to Leagues (the rising edge).
    c.read(activeTabIndexProvider.notifier).setActive(RatelTab.home);
    c.read(activeTabIndexProvider.notifier).setActive(RatelTab.leagues);
    await _settle();

    // The focus re-poll surfaced the rival who joined between opens — no reload.
    expect(c.read(leagueStatusProvider).cohortSize, 2);
    expect(store.saves.length, greaterThan(savesAfterBuild)); // own row re-persisted
  });

  test('switching to a non-Leagues tab does NOT re-poll', () async {
    final _GrowingStore store = _GrowingStore();
    final ProviderContainer c = signedIn(store);
    addTearDown(c.dispose);

    c.listen(leagueStatusProvider, (_, _) {}, fireImmediately: true);
    await _settle();
    final int savesAfterBuild = store.saves.length;

    c.read(activeTabIndexProvider.notifier).setActive(RatelTab.home);
    c.read(activeTabIndexProvider.notifier).setActive(RatelTab.quests);
    await _settle();

    // No focus into Leagues -> no re-sync -> cohort + persistence unchanged.
    expect(c.read(leagueStatusProvider).cohortSize, 1);
    expect(store.saves.length, savesAfterBuild);
  });

  test('re-selecting the already-active Leagues tab does not double-poll',
      () async {
    final _GrowingStore store = _GrowingStore();
    final ProviderContainer c = signedIn(store);
    addTearDown(c.dispose);

    c.listen(leagueStatusProvider, (_, _) {}, fireImmediately: true);
    await _settle();

    c.read(activeTabIndexProvider.notifier).setActive(RatelTab.leagues);
    await _settle();
    final int savesAfterFocus = store.saves.length;

    // Re-set to Leagues while already active -> no value change -> no re-poll.
    c.read(activeTabIndexProvider.notifier).setActive(RatelTab.leagues);
    await _settle();
    expect(store.saves.length, savesAfterFocus);
  });

  test('guest focus-refresh is an honest no-op (nothing persisted)', () async {
    final _GrowingStore store = _GrowingStore();
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

    c.read(activeTabIndexProvider.notifier).setActive(RatelTab.home);
    c.read(activeTabIndexProvider.notifier).setActive(RatelTab.leagues);
    await _settle();

    expect(c.read(leagueStatusProvider).isSolo, true); // never a fake cohort
    expect(store.saves, isEmpty); // a guest persists nothing, even on focus
  });
}
