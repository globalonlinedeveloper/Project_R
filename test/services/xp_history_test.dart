import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/progress/prefs_xp_history_store.dart';
import 'package:ratel/services/progress/xp_history.dart';
import 'package:ratel/services/progress/xp_history_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// D1 evidence — the device-local 7-day XP recorder (R-G6 / R-L14): real
/// recorded XP only, honest zeros for inactive days, pruned to the window.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('XpHistoryModel', () {
    const XpHistoryModel m = XpHistoryModel(keepDays: 14);

    test('keyFor / parseKey round-trip', () {
      final DateTime d = DateTime(2026, 6, 5);
      expect(XpHistoryModel.keyFor(d), '2026-06-05');
      expect(XpHistoryModel.parseKey('2026-06-05'), d);
      expect(XpHistoryModel.parseKey('nonsense'), isNull);
    });

    test('record accumulates same-day and ignores non-positive', () {
      final DateTime day = DateTime(2026, 6, 30);
      Map<String, int> h = <String, int>{};
      h = m.record(history: h, day: day, xp: 20);
      h = m.record(history: h, day: day, xp: 10);
      expect(h['2026-06-30'], 30);
      final Map<String, int> same = m.record(history: h, day: day, xp: 0);
      expect(identical(same, h), isTrue); // no-op returns the SAME instance
    });

    test('record prunes outside the retention window', () {
      final DateTime today = DateTime(2026, 6, 30);
      Map<String, int> h = <String, int>{'2026-06-01': 99}; // 29 days back
      h = m.record(history: h, day: today, xp: 5);
      expect(h.containsKey('2026-06-01'), isFalse); // pruned
      expect(h['2026-06-30'], 5);
    });

    test('lastDays returns n days oldest->newest, zero-filled', () {
      final DateTime today = DateTime(2026, 6, 30);
      final Map<String, int> h = <String, int>{
        '2026-06-30': 20,
        '2026-06-28': 5,
      };
      final List<DayXp> days = m.lastDays(history: h, today: today, n: 7);
      expect(days.length, 7);
      expect(days.first.date, DateTime(2026, 6, 24));
      expect(days.last.date, DateTime(2026, 6, 30));
      expect(days.last.xp, 20);
      expect(days[days.length - 3].xp, 5); // 06-28
      expect(days[0].xp, 0); // 06-24 inactive -> honest zero
      expect(m.totalOver(history: h, today: today), 25);
    });
  });

  group('InMemoryXpHistoryStore', () {
    test('save then load round-trips a copy', () async {
      final InMemoryXpHistoryStore s = InMemoryXpHistoryStore();
      await s.save(<String, int>{'2026-06-30': 12});
      expect(s.load(), <String, int>{'2026-06-30': 12});
    });
  });

  group('PrefsXpHistoryStore', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('save then load round-trips via the single CSV key', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await PrefsXpHistoryStore(prefs)
          .save(<String, int>{'2026-06-30': 40, '2026-06-29': 15});
      // A fresh store over the same prefs reads it back (survives a relaunch).
      expect(PrefsXpHistoryStore(prefs).load(),
          <String, int>{'2026-06-29': 15, '2026-06-30': 40});
    });

    test('skips malformed / non-positive entries (never fabricated)', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'ratel.progress.xpHistory': '2026-06-30:40,bad,2026-06-29:-3,xxxx:5',
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(PrefsXpHistoryStore(prefs).load(), <String, int>{'2026-06-30': 40});
    });
  });
}
