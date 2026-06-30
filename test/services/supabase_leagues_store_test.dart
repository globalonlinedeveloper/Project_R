// R-I6 / R-M3 · Build-ahead Supabase leagues store — pure row-mapping cover (no
// live client: validates the own-row `user_id` stamping that RLS requires) plus
// the in-memory default's load/save round-trip.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/data_access/supabase_leagues_store.dart';

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
  });
}
