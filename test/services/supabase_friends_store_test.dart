// R-I9 / R-M3 · Build-ahead Supabase friends store — pure row-mapping cover
// (no live client: validates the own-row `user_id` stamping that RLS requires).
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/data_access/supabase_friends_store.dart';

void main() {
  test('rowsFor stamps the owning user_id and coerces map entries', () {
    final List<Map<String, Object?>> rows =
        SupabaseFriendsStore.rowsFor(<Object?>[
      <String, Object?>{'friend_id': 'mia', 'status': 'friends'},
      'not-a-map', // skipped
    ], 'uid-1');
    expect(rows.length, 1);
    expect(rows.single['user_id'], 'uid-1'); // RLS: user_id = auth.uid()
    expect(rows.single['friend_id'], 'mia');
    expect(rows.single['status'], 'friends');
  });

  test('rowsFor on a non-list contributes no rows', () {
    expect(SupabaseFriendsStore.rowsFor('nope', 'u'), isEmpty);
  });
}
