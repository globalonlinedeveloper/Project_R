import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/data_access/supabase_learner_state_store.dart';

void main() {
  group('SupabaseLearnerStateStore.rowsFor', () {
    test('stamps the owning user_id on every row', () {
      final rows = SupabaseLearnerStateStore.rowsFor(
        <Object?>[
          <String, Object?>{'item_id': 'it_a', 'state': 'review'},
          <String, Object?>{'item_id': 'it_b', 'state': 'new'},
        ],
        'user-123',
      );
      expect(rows, hasLength(2));
      expect(rows.every((row) => row['user_id'] == 'user-123'), isTrue);
      expect(rows.first['item_id'], 'it_a');
    });

    test('non-list / empty input yields no rows (save no-ops)', () {
      expect(SupabaseLearnerStateStore.rowsFor(null, 'u1'), isEmpty);
      expect(SupabaseLearnerStateStore.rowsFor('nope', 'u1'), isEmpty);
      expect(SupabaseLearnerStateStore.rowsFor(<Object?>[], 'u1'), isEmpty);
    });

    test('skips non-map entries and overrides a caller-supplied user_id', () {
      final rows = SupabaseLearnerStateStore.rowsFor(
        <Object?>[
          <String, Object?>{'item_id': 'it_a', 'user_id': 'spoofed'},
          42,
          'skip',
        ],
        'real-user',
      );
      expect(rows, hasLength(1));
      // RLS-safe: the seam can never persist a row for another user.
      expect(rows.single['user_id'], 'real-user');
    });
  });

  group('SupabaseLearnerStateStore.upsertBatches', () {
    // Regression guard for the INC-15 live write-bug: a per-course row
    // (xp/lessons/theta) and the __global__ row (streak/diamonds) have DISJOINT
    // column sets. A single bulk upsert of them fails on real PostgREST — the
    // union of keys is sent as `columns`, so the NOT-NULL column each row omits
    // (e.g. streak_days on the course row) is written NULL -> error 23502.
    // save() must split heterogeneous rows into homogeneous batches.
    bool homogeneous(List<Map<String, Object?>> batch) {
      final Set<String> shape = batch.first.keys.toSet();
      return batch.every(
        (r) => r.keys.toSet().length == shape.length && shape.containsAll(r.keys),
      );
    }

    test('splits disjoint-column rows (course + __global__) into homogeneous '
        'batches so no bulk upsert mixes columns', () {
      final courseRow = <String, Object?>{
        'user_id': 'u1',
        'target_locale': 'es',
        'xp_total': 100,
        'lessons_completed': 4,
        'theta_per_skill': <String, Object?>{},
      };
      final globalRow = <String, Object?>{
        'user_id': 'u1',
        'target_locale': '__global__',
        'streak_days': 5,
        'streak_last_active': '2026-07-17',
        'diamonds': 20,
        'streak_freezes': 2,
      };
      final batches = SupabaseLearnerStateStore.upsertBatches(
        <Map<String, Object?>>[courseRow, globalRow],
      );
      expect(batches, hasLength(2),
          reason: 'disjoint column sets must not share a bulk upsert');
      expect(batches.every(homogeneous), isTrue,
          reason: 'every row in a batch shares the exact column set');
      // No row is dropped.
      expect(batches.expand((b) => b), hasLength(2));
    });

    test('two per-course rows of the SAME shape stay one batch', () {
      final es = <String, Object?>{
        'user_id': 'u1', 'target_locale': 'es', 'xp_total': 100,
      };
      final fr = <String, Object?>{
        'user_id': 'u1', 'target_locale': 'fr', 'xp_total': 250,
      };
      final batches = SupabaseLearnerStateStore.upsertBatches(
        <Map<String, Object?>>[es, fr],
      );
      expect(batches, hasLength(1));
      expect(batches.single, hasLength(2));
      expect(homogeneous(batches.single), isTrue);
    });

    test('empty input yields no batches', () {
      expect(
        SupabaseLearnerStateStore.upsertBatches(<Map<String, Object?>>[]),
        isEmpty,
      );
    });
  });
}
