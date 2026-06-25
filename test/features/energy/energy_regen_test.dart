import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/features/energy/energy_controller.dart';
import 'package:ratel/features/energy/energy_state.dart';

/// The energy refill timer is backed by a REAL wall-clock model on EnergyState
/// (epoch-ms `refillAtMs`), never a faked decrementing number. These pin the
/// pure regen maths (clock injected) + the daily-goal XP credit.
void main() {
  const regenMs = 1500 * 1000; // 25 min in ms

  group('energy regen (real wall-clock, not a fake countdown)', () {
    test('below max with no clock -> starts the regen clock (no energy yet)', () {
      const s = EnergyState(energy: 2, dailyFreeUsed: true);
      final r = s.regenerated(10000);
      expect(r.energy, 2);
      expect(r.refillAtMs, 10000 + regenMs);
    });

    test('credits +1 exactly at the threshold and advances the clock', () {
      const s = EnergyState(energy: 2, dailyFreeUsed: true, refillAtMs: 1000);
      final r = s.regenerated(1000);
      expect(r.energy, 3);
      expect(r.refillAtMs, 1000 + regenMs);
    });

    test('catches up multiple elapsed intervals', () {
      const s = EnergyState(energy: 1, dailyFreeUsed: true, refillAtMs: 1000);
      final r = s.regenerated(1000 + regenMs); // thresholds 1000 and 1000+reg
      expect(r.energy, 3);
      expect(r.refillAtMs, 1000 + 2 * regenMs);
    });

    test('reaching the full tank clears the clock', () {
      const s = EnergyState(energy: 4, dailyFreeUsed: true, refillAtMs: 1000);
      final r = s.regenerated(1000 + 5 * regenMs);
      expect(r.energy, 5);
      expect(r.refillAtMs, isNull);
    });

    test('a full tank never schedules a refill', () {
      const s = EnergyState(energy: 5, refillAtMs: 1000);
      final r = s.regenerated(9999999999);
      expect(r.energy, 5);
      expect(r.refillAtMs, isNull);
    });

    test('nothing due yet -> identical state (no spurious rebuild)', () {
      const s = EnergyState(energy: 2, dailyFreeUsed: true, refillAtMs: 1000000);
      final r = s.regenerated(500000);
      expect(identical(r, s), isTrue);
    });

    test('remainingRefillSeconds ceils the real gap', () {
      const s = EnergyState(energy: 2, refillAtMs: 10000);
      expect(s.remainingRefillSeconds(5000), 5);
      expect(s.remainingRefillSeconds(9500), 1);
      expect(s.remainingRefillSeconds(10000), 0);
    });

    test('controller.applyRegen credits real elapsed energy', () {
      final c = EnergyController(
          const EnergyState(energy: 2, dailyFreeUsed: true, refillAtMs: 1000));
      c.applyRegen(nowMs: 1000);
      expect(c.state.energy, 3);
    });
  });

  group('daily-goal XP (real, lessons only)', () {
    test('a normal lesson commit credits base XP toward the goal', () {
      final c = EnergyController(const EnergyState(energy: 5));
      c.commit();
      expect(c.state.xpToday, 20);
    });

    test('a review commit does NOT credit daily-goal XP', () {
      final c =
          EnergyController(const EnergyState(energy: 3, dailyFreeUsed: true));
      c.commit(isReview: true);
      expect(c.state.xpToday, 0);
    });

    test('spending below full starts the regen clock on commit', () {
      final c =
          EnergyController(const EnergyState(energy: 3, dailyFreeUsed: true));
      c.commit(); // paid lesson 3 -> 2
      expect(c.state.energy, 2);
      expect(c.state.refillAtMs, isNotNull);
    });
  });
}
