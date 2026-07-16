import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ratel/services/adventures/adventure_progress_store.dart';
import 'package:ratel/services/adventures/exploration.dart';
import 'package:ratel/services/adventures/prefs_adventure_progress_store.dart';

// L-4 (design 4.12 districts + explored progress): the pure exploration
// engine + the device-local persistence seam. Engine is clockless and
// UI-free; districts group by the owner's four NAMED districts in FIXED
// order (Café & Food · Market Square · On the Move · Making Friends, S153),
// with empty districts hidden. Derivation from real scenario text lives in
// the feature layer; the engine receives an already-resolved kind per ref.

// Two Café & Food refs (data order preserved), one Market Square, one On the
// Move. Deliberately supplied out of district order to prove the engine emits
// them in the FIXED kAdventureDistrictOrder regardless of input order.
const List<AdventureRef> _refs = <AdventureRef>[
  AdventureRef(id: 'mv', kind: AdventureDistrictKind.move),
  AdventureRef(id: 'cf1', kind: AdventureDistrictKind.cafe),
  AdventureRef(id: 'cf2', kind: AdventureDistrictKind.cafe),
  AdventureRef(id: 'mk', kind: AdventureDistrictKind.market),
];

void main() {
  const AdventureExplorationEngine engine = AdventureExplorationEngine();

  group('AdventureExplorationEngine.districts', () {
    test('groups by named district in FIXED order, data order within one', () {
      final List<AdventureDistrict> d = engine.districts(_refs, <String>{});
      // Emitted in kAdventureDistrictOrder (cafe, market, move) — NOT input
      // order (mv, cf1, cf2, mk); empty "friends" district is hidden.
      expect(
          d.map((AdventureDistrict x) => x.kind),
          <AdventureDistrictKind>[
            AdventureDistrictKind.cafe,
            AdventureDistrictKind.market,
            AdventureDistrictKind.move,
          ]);
      expect(d.map((AdventureDistrict x) => x.id),
          <String>['cafe', 'market', 'move']);
      expect(
          d.first.refs.map((AdventureRef r) => r.id), <String>['cf1', 'cf2']);
      expect(d.first.total, 2);
    });

    test('explored counts + allDone + the design current-district walk', () {
      final List<AdventureDistrict> d =
          engine.districts(_refs, <String>{'cf1', 'cf2'});
      expect(d[0].doneCount, 2);
      expect(d[0].allDone, isTrue);
      expect(d[0].isCurrent, isFalse); // done districts are never current
      expect(d[1].isCurrent, isTrue); // first NOT-all-done wins the mascot
      expect(d[2].isCurrent, isFalse); // only one current at a time
    });

    test('partially explored first district stays current', () {
      final List<AdventureDistrict> d =
          engine.districts(_refs, <String>{'cf1'});
      expect(d[0].doneCount, 1);
      expect(d[0].allDone, isFalse);
      expect(d[0].isCurrent, isTrue);
      expect(d[1].isCurrent, isFalse);
    });

    test('everything explored: no current district, all pills', () {
      final List<AdventureDistrict> d =
          engine.districts(_refs, <String>{'cf1', 'cf2', 'mk', 'mv'});
      expect(d.every((AdventureDistrict x) => x.allDone), isTrue);
      expect(d.any((AdventureDistrict x) => x.isCurrent), isFalse);
    });

    test('empty course projects to an empty list (honest empty state)', () {
      expect(engine.districts(const <AdventureRef>[], <String>{}), isEmpty);
    });
  });

  test('isNewlyExplored is the once-per-adventure reward crossing', () {
    expect(engine.isNewlyExplored(<String>{}, 'cf1'), isTrue);
    expect(engine.isNewlyExplored(<String>{'cf1'}, 'cf1'), isFalse);
  });

  group('stores', () {
    test('InMemoryAdventureProgressStore roundtrips + copies defensively',
        () async {
      final InMemoryAdventureProgressStore store =
          InMemoryAdventureProgressStore(<String>{'seed'});
      expect(store.load(), <String>{'seed'});
      await store.save(<String>{'a', 'b'});
      expect(store.current, <String>{'a', 'b'});
      final Set<String> loaded = store.load()..add('mutated');
      expect(loaded, contains('mutated'));
      expect(store.current, <String>{'a', 'b'}); // mutation never leaks back
    });

    test('PrefsAdventureProgressStore roundtrips through one sorted CSV key',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final PrefsAdventureProgressStore store =
          PrefsAdventureProgressStore(prefs);
      expect(store.load(), isEmpty);
      await store.save(<String>{'scenario_en_b1_adv1', 'scenario_en_a1_adv'});
      expect(prefs.getString('ratel.adventures.explored'),
          'scenario_en_a1_adv,scenario_en_b1_adv1');
      expect(store.load(),
          <String>{'scenario_en_a1_adv', 'scenario_en_b1_adv1'});
    });

    test('PrefsAdventureProgressStore skips empty fragments, never fakes',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'ratel.adventures.explored': ',scenario_en_a1_adv,,',
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(PrefsAdventureProgressStore(prefs).load(),
          <String>{'scenario_en_a1_adv'});
    });
  });
}
