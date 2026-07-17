import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ratel/services/library/last_read_store.dart';
import 'package:ratel/services/library/prefs_last_read_store.dart';

// s163 INC-C1 — the device-local LAST-READ pointer store: an in-memory default
// and a SharedPreferences JSON impl. Honesty guard: an absent OR malformed
// value loads as null (never a fabricated pointer).

const LastReadRef _ref = LastReadRef(
  courseCode: 'es',
  passageId: 's2',
  title: 'La receta',
  cefr: 'A2',
  kind: 'story',
);

void main() {
  group('LastReadRef JSON', () {
    test('round-trips all five fields', () {
      final LastReadRef back =
          LastReadRef.fromJson(jsonDecode(jsonEncode(_ref.toJson())))!;
      expect(back, _ref);
      expect(back.courseCode, 'es');
      expect(back.passageId, 's2');
      expect(back.title, 'La receta');
      expect(back.cefr, 'A2');
      expect(back.kind, 'story');
    });

    test('missing/blank passageId ⇒ null (never fabricated)', () {
      expect(LastReadRef.fromJson(<String, dynamic>{'courseCode': 'es'}), isNull);
      expect(
          LastReadRef.fromJson(<String, dynamic>{'passageId': ''}), isNull);
      expect(LastReadRef.fromJson('not a map'), isNull);
      expect(LastReadRef.fromJson(null), isNull);
    });

    test('absent kind defaults to story', () {
      final LastReadRef? r = LastReadRef.fromJson(
          <String, dynamic>{'passageId': 'x', 'courseCode': 'es'});
      expect(r, isNotNull);
      expect(r!.kind, 'story');
    });
  });

  group('InMemoryLastReadStore', () {
    test('empty by default', () {
      expect(InMemoryLastReadStore().load(), isNull);
    });

    test('save then load returns the pointer; clear empties it', () async {
      final InMemoryLastReadStore store = InMemoryLastReadStore();
      await store.save(_ref);
      expect(store.load(), _ref);
      expect(store.current, _ref);
      await store.clear();
      expect(store.load(), isNull);
    });
  });

  group('PrefsLastReadStore', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('absent key ⇒ null', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(PrefsLastReadStore(prefs).load(), isNull);
    });

    test('save/load round-trip through SharedPreferences', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final PrefsLastReadStore store = PrefsLastReadStore(prefs);
      await store.save(_ref);
      // The raw stored value is JSON under the documented key.
      expect(prefs.getString(PrefsLastReadStore.prefsKey), isNotNull);
      expect(store.load(), _ref);
    });

    test('malformed JSON ⇒ null (honest, no faked pointer)', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PrefsLastReadStore.prefsKey: '{not valid json',
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(PrefsLastReadStore(prefs).load(), isNull);
    });

    test('valid JSON missing passageId ⇒ null', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PrefsLastReadStore.prefsKey: jsonEncode(<String, dynamic>{
          'courseCode': 'es',
          'title': 'x',
        }),
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(PrefsLastReadStore(prefs).load(), isNull);
    });

    test('clear removes the key', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final PrefsLastReadStore store = PrefsLastReadStore(prefs);
      await store.save(_ref);
      await store.clear();
      expect(prefs.getString(PrefsLastReadStore.prefsKey), isNull);
      expect(store.load(), isNull);
    });
  });
}
