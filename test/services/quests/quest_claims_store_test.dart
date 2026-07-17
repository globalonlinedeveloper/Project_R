import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ratel/services/quests/quest_claims_store.dart';
import 'package:ratel/services/quests/prefs_quest_claims_store.dart';

// INC-QR1 — the device-local DURABLE quest-claims store: an in-memory default
// and a SharedPreferences JSON impl (ISO date + quest-id list). Honesty guard:
// an absent OR malformed value loads as QuestClaims.empty (never a fabricated
// claim). The durable set survives a relaunch so a paid quest never re-pays.

final QuestClaims _claims = QuestClaims(
  day: DateTime(2026, 6, 29),
  ids: <String>{'streak_keeper', 'power_session'},
);

void main() {
  group('QuestClaims JSON', () {
    test('round-trips day + ids', () {
      final QuestClaims back =
          QuestClaims.fromJson(jsonDecode(jsonEncode(_claims.toJson())));
      expect(back, _claims);
      expect(back.day, DateTime(2026, 6, 29));
      expect(back.ids, <String>{'streak_keeper', 'power_session'});
    });

    test('equality is by CALENDAR DAY (date-only), not wall-clock instant', () {
      final QuestClaims a =
          QuestClaims(day: DateTime(2026, 6, 29), ids: const <String>{'q'});
      // A stored value only ever carries a date-only day; a round-trip of a
      // time-of-day instant normalises to local midnight on decode.
      final QuestClaims decoded = QuestClaims.fromJson(jsonDecode(jsonEncode(
          QuestClaims(day: DateTime(2026, 6, 29, 14, 30), ids: const <String>{'q'})
              .toJson())));
      expect(decoded, a);
    });

    test('malformed shape ⇒ empty (never a fabricated claim)', () {
      expect(QuestClaims.fromJson('not a map'), QuestClaims.empty);
      expect(QuestClaims.fromJson(null), QuestClaims.empty);
      expect(QuestClaims.fromJson(<String, dynamic>{}), QuestClaims.empty);
    });

    test('bad/absent day drops to null (⇒ stale ⇒ fresh day); bad ids skipped',
        () {
      final QuestClaims r = QuestClaims.fromJson(<String, dynamic>{
        'day': 'not-a-date',
        'ids': <Object?>['ok', 42, '', null, 'ok2'],
      });
      expect(r.day, isNull);
      expect(r.ids, <String>{'ok', 'ok2'});
    });

    test('missing ids ⇒ empty set (day still parsed)', () {
      final QuestClaims r =
          QuestClaims.fromJson(<String, dynamic>{'day': '2026-06-29'});
      expect(r.day, DateTime(2026, 6, 29));
      expect(r.ids, isEmpty);
    });
  });

  group('InMemoryQuestClaimsStore', () {
    test('empty by default', () {
      expect(InMemoryQuestClaimsStore().load(), QuestClaims.empty);
    });

    test('save then load returns the claims (survives a shared instance)',
        () async {
      final InMemoryQuestClaimsStore store = InMemoryQuestClaimsStore();
      await store.save(_claims);
      expect(store.load(), _claims);
      expect(store.current, _claims);
    });

    test('seeded ctor loads the seed', () {
      expect(InMemoryQuestClaimsStore(_claims).load(), _claims);
    });
  });

  group('PrefsQuestClaimsStore', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('absent key ⇒ empty', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(PrefsQuestClaimsStore(prefs).load(), QuestClaims.empty);
    });

    test('save/load round-trip through SharedPreferences', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final PrefsQuestClaimsStore store = PrefsQuestClaimsStore(prefs);
      await store.save(_claims);
      // The raw stored value is JSON under the documented key.
      expect(prefs.getString(PrefsQuestClaimsStore.prefsKey), isNotNull);
      expect(store.load(), _claims);
    });

    test('malformed JSON ⇒ empty (honest, no faked claim)', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PrefsQuestClaimsStore.prefsKey: '{not valid json',
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(PrefsQuestClaimsStore(prefs).load(), QuestClaims.empty);
    });
  });
}
