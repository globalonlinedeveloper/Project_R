// R-I6 / R-M3 · Build-ahead Supabase leagues store — pure row-mapping cover (no
// live client: validates the own-row `user_id` stamping that RLS requires) plus
// the in-memory default's load/save round-trip.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/data_access/supabase_leagues_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A fake client whose every call throws — proves [SupabaseLeaguesStore.readCohort]
/// fails SAFE (honest solo) rather than propagating a Postgrest error.
class _ThrowingClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw PostgrestException(
        message: 'function public.read_league_cohort() does not exist',
        code: '42883',
      );
}

void main() {
  group('SupabaseLeaguesStore.rowsFor (own-row stamping)', () {
    test('stamps the owning user_id and coerces map entries', () {
      final List<Map<String, Object?>> rows =
          SupabaseLeaguesStore.rowsFor(<Object?>[
        <String, Object?>{'week_start': '2026-06-29', 'tier': 'bronze', 'weekly_xp': 120},
        'not-a-map', // skipped
      ], 'uid-1');
      expect(rows.length, 1);
      expect(rows.single['user_id'], 'uid-1'); // RLS: user_id = auth.uid()
      expect(rows.single['tier'], 'bronze');
      expect(rows.single['weekly_xp'], 120);
    });

    test('on a non-list contributes no rows', () {
      expect(SupabaseLeaguesStore.rowsFor('nope', 'u'), isEmpty);
    });
  });

  group('InMemoryLeaguesStore (local default — honest solo cohort)', () {
    test('a fresh learner loads an empty seam-map (no fabricated rivals)',
        () async {
      final InMemoryLeaguesStore store = InMemoryLeaguesStore();
      expect(await store.load('fresh-uid'), isEmpty);
    });

    test('save then load round-trips the membership for that user only',
        () async {
      final InMemoryLeaguesStore store = InMemoryLeaguesStore();
      await store.save('uid-1', <String, Object?>{
        kLeagueMembershipKey: <Map<String, Object?>>[
          <String, Object?>{'week_start': '2026-06-29', 'tier': 'bronze', 'weekly_xp': 50},
        ],
      });
      final Map<String, Object?> back = await store.load('uid-1');
      expect((back[kLeagueMembershipKey] as List).length, 1);
      // Isolated by key: a different user is still empty.
      expect(await store.load('uid-2'), isEmpty);
    });

    test('readCohort is empty: no cross-user backend -> honest solo cohort',
        () async {
      final InMemoryLeaguesStore store = InMemoryLeaguesStore();
      // Even after persisting an own standing, the in-memory store exposes NO
      // cross-user cohort (the real leaderboard is a SECURITY DEFINER read).
      await store.save('uid-1', <String, Object?>{
        kLeagueMembershipKey: <Map<String, Object?>>[
          <String, Object?>{'week_start': '2026-06-29', 'tier': 'bronze', 'weekly_xp': 50},
        ],
      });
      expect(await store.readCohort('uid-1'), isEmpty);
    });
  });

  group('SupabaseLeaguesStore.readCohort (fail-safe cross-user read)', () {
    test('a thrown PostgrestException degrades to the honest solo cohort ([])',
        () async {
      final SupabaseLeaguesStore store = SupabaseLeaguesStore(_ThrowingClient());
      // The RPC blows up (missing fn / offline) -> NOT a throw, an empty cohort.
      expect(await store.readCohort('uid-1'), isEmpty);
    });

    test('cohortRowsFrom maps definer rows and coerces a non-list to empty', () {
      final List<Map<String, Object?>> rows =
          SupabaseLeaguesStore.cohortRowsFrom(<Object?>[
        <String, Object?>{'member_id': 'm1', 'weekly_xp': 40, 'is_you': true},
        'not-a-map', // skipped
      ]);
      expect(rows.length, 1);
      expect(rows.single['member_id'], 'm1');
      expect(rows.single['is_you'], true);
      expect(SupabaseLeaguesStore.cohortRowsFrom('nope'), isEmpty);
    });
  });
}
