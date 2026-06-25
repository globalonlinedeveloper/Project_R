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
}
