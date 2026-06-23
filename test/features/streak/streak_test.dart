import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/features/streak/streak_controller.dart';

DateTime _d(int y, int m, int day) => DateTime(y, m, day, 9, 30); // local mid-morning

void main() {
  group('StreakController (R-L8, device-local midnight)', () {
    test('first activity starts a streak of 1', () {
      final c = StreakController();
      c.recordActivity(_d(2026, 6, 23));
      expect(c.state.current, 1);
      expect(c.state.longest, 1);
    });

    test('same-day repeats do not double-count', () {
      final c = StreakController();
      c.recordActivity(_d(2026, 6, 23));
      c.recordActivity(DateTime(2026, 6, 23, 23, 59)); // later same local day
      expect(c.state.current, 1);
    });

    test('consecutive days extend the streak', () {
      final c = StreakController();
      c.recordActivity(_d(2026, 6, 23));
      c.recordActivity(_d(2026, 6, 24));
      c.recordActivity(_d(2026, 6, 25));
      expect(c.state.current, 3);
      expect(c.state.longest, 3);
    });

    test('a missed day resets current but keeps longest', () {
      final c = StreakController();
      c.recordActivity(_d(2026, 6, 23));
      c.recordActivity(_d(2026, 6, 24)); // current 2
      c.recordActivity(_d(2026, 6, 27)); // gap -> reset to 1
      expect(c.state.current, 1);
      expect(c.state.longest, 2);
    });

    test('crosses month boundaries correctly', () {
      final c = StreakController();
      c.recordActivity(_d(2026, 6, 30));
      c.recordActivity(_d(2026, 7, 1));
      expect(c.state.current, 2);
    });
  });
}
