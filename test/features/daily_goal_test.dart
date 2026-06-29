import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';

/// The daily goal is now REAL: a pure `xpToday >= goal` derive (no clock, no
/// fake data). Boundaries are the contract every ring depends on.
void main() {
  group('DailyGoalStatus (pure derive)', () {
    test('below goal: not met, fraction is the ratio', () {
      const DailyGoalStatus s = DailyGoalStatus(xpToday: 5, goal: 20);
      expect(s.met, isFalse);
      expect(s.fraction, closeTo(0.25, 1e-9));
    });
    test('one short of the goal is still not met', () {
      expect(const DailyGoalStatus(xpToday: 19, goal: 20).met, isFalse);
    });
    test('exactly at the goal counts as met (boundary)', () {
      const DailyGoalStatus s = DailyGoalStatus(xpToday: 20, goal: 20);
      expect(s.met, isTrue);
      expect(s.fraction, 1.0);
    });
    test('above the goal: met, fraction clamps to 1.0 (no overflow)', () {
      const DailyGoalStatus s = DailyGoalStatus(xpToday: 35, goal: 20);
      expect(s.met, isTrue);
      expect(s.fraction, 1.0);
    });
    test('zero XP: not met, empty ring', () {
      const DailyGoalStatus s = DailyGoalStatus(xpToday: 0, goal: 20);
      expect(s.met, isFalse);
      expect(s.fraction, 0.0);
    });
    test('value equality (same xp + goal)', () {
      expect(const DailyGoalStatus(xpToday: 10, goal: 20),
          const DailyGoalStatus(xpToday: 10, goal: 20));
      expect(const DailyGoalStatus(xpToday: 10, goal: 20),
          isNot(const DailyGoalStatus(xpToday: 11, goal: 20)));
    });
  });

  group('dailyGoalProvider', () {
    test('fresh account derives 0 XP toward the default 20 goal, not met', () {
      final ProviderContainer c = ProviderContainer();
      addTearDown(c.dispose);
      final DailyGoalStatus s = c.read(dailyGoalProvider);
      expect(s.xpToday, 0);
      expect(s.goal, 20);
      expect(s.met, isFalse);
    });
  });
}
