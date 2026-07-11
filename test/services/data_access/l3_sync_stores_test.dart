import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/adventures/adventure_progress_store.dart';
import 'package:ratel/services/data_access/supabase_user_state_stores.dart';
import 'package:ratel/services/notifications/earned_stamps_store.dart';

// S131d (L-3 clubbed): the two new sync decorators' pure mappers + honest
// merge rules, and guest (null-db) passthrough — mirrors the U-lane test
// posture (mapper-level, no fake client).

void main() {
  final DateTime early = DateTime.utc(2026, 7, 1, 10);
  final DateTime late = DateTime.utc(2026, 7, 9, 9);

  group('SupabaseEarnedStampsStore', () {
    test('mergeStamps: per-id EARLIEST wins, both directions', () {
      final Map<String, DateTime> merged = SupabaseEarnedStampsStore
          .mergeStamps(<String, DateTime>{'a': late, 'b': early},
              <String, DateTime>{'a': early, 'c': late});
      expect(merged['a'], early); // remote earlier -> wins
      expect(merged['b'], early); // local-only kept
      expect(merged['c'], late); // remote-only kept
    });

    test('rows round-trip; malformed rows skipped never faked', () {
      final List<Map<String, Object?>> rows = SupabaseEarnedStampsStore
          .stampRowsFor(<String, DateTime>{'streak:7': early}, 'u1');
      expect(rows.single['user_id'], 'u1');
      expect(rows.single['notification_id'], 'streak:7');
      expect(rows.single['earned_at'], early.toIso8601String());
      final Map<String, DateTime> back =
          SupabaseEarnedStampsStore.stampsFromRows(<Map<String, dynamic>>[
        <String, dynamic>{'notification_id': 'streak:7',
            'earned_at': early.toIso8601String()},
        <String, dynamic>{'notification_id': '', 'earned_at': 'x'},
        <String, dynamic>{'notification_id': 'bad', 'earned_at': 'not-a-date'},
        <String, dynamic>{'earned_at': early.toIso8601String()},
      ]);
      expect(back, <String, DateTime>{'streak:7': early});
    });

    test('changedStamps: only differing ids push', () {
      expect(
          SupabaseEarnedStampsStore.changedStamps(
              previous: <String, DateTime>{'a': early},
              next: <String, DateTime>{'a': early, 'b': late}),
          <String, DateTime>{'b': late});
    });

    test('guest (null db): load/save ride the local store untouched',
        () async {
      final InMemoryEarnedStampsStore local = InMemoryEarnedStampsStore();
      final SupabaseEarnedStampsStore store =
          SupabaseEarnedStampsStore(null, local);
      await store.save(<String, DateTime>{'a': early});
      expect(store.load(), <String, DateTime>{'a': early});
      await store.hydrate(); // no-op, never throws
      expect(local.current, <String, DateTime>{'a': early});
    });
  });

  group('SupabaseAdventureProgressStore', () {
    test('exploredRowsFor sorts + exploredFromRows skips malformed', () {
      final List<Map<String, Object?>> rows = SupabaseAdventureProgressStore
          .exploredRowsFor(<String>{'z', 'a'}, 'u1');
      expect(rows.map((Map<String, Object?> r) => r['scenario_id']),
          <String>['a', 'z']);
      expect(
          SupabaseAdventureProgressStore
              .exploredFromRows(<Map<String, dynamic>>[
            <String, dynamic>{'scenario_id': 'adv1'},
            <String, dynamic>{'scenario_id': ''},
            <String, dynamic>{'nope': 1},
          ]),
          <String>{'adv1'});
    });

    test('guest (null db): union semantics stay local-only', () async {
      final InMemoryAdventureProgressStore local =
          InMemoryAdventureProgressStore(<String>{'seed'});
      final SupabaseAdventureProgressStore store =
          SupabaseAdventureProgressStore(null, local);
      await store.save(<String>{'seed', 'new'});
      expect(store.load(), <String>{'seed', 'new'});
      await store.hydrate(); // no-op, never throws
      expect(local.current, <String>{'seed', 'new'});
    });
  });
}
