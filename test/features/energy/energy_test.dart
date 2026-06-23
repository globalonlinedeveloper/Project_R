import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/features/energy/energy_controller.dart';
import 'package:ratel/features/energy/energy_state.dart';

void main() {
  group('EnergyController (gentle-energy R-J*/R-L3)', () {
    test('first daily lesson is free — no charge, marks daily used', () {
      final c = EnergyController(const EnergyState(energy: 5));
      final out = c.commit();
      expect(out.wasFree, isTrue);
      expect(out.energySpent, 0);
      expect(c.state.energy, 5);
      expect(c.state.dailyFreeUsed, isTrue);
    });

    test('a normal (non-first) lesson charges exactly 1 energy', () {
      final c = EnergyController(const EnergyState(energy: 5, dailyFreeUsed: true));
      final out = c.commit();
      expect(out.wasFree, isFalse);
      expect(out.energySpent, 1);
      expect(c.state.energy, 4);
    });

    test('reviews are always free, even after the daily free is used', () {
      final c = EnergyController(const EnergyState(energy: 2, dailyFreeUsed: true));
      final out = c.commit(isReview: true);
      expect(out.energySpent, 0);
      expect(c.state.energy, 2);
    });

    test('start gate blocks ONLY a normal empty-tank lesson', () {
      final empty = EnergyController(
          const EnergyState(energy: 0, dailyFreeUsed: true));
      expect(empty.canStart(), isFalse); // normal lesson, empty -> blocked
      expect(empty.canStart(isReview: true), isTrue); // review always allowed
      final firstDaily = EnergyController(const EnergyState(energy: 0));
      expect(firstDaily.canStart(), isTrue); // first daily always allowed
    });

    test('Pro is unlimited: never charged, never gated', () {
      final c = EnergyController(
          const EnergyState(energy: 0, isPro: true, dailyFreeUsed: true));
      expect(c.canStart(), isTrue);
      final out = c.commit();
      expect(out.energySpent, 0);
      expect(c.state.energy, 0);
      expect(c.state.isUnlimited, isTrue);
    });

    test('energy never goes negative on commit', () {
      final c = EnergyController(const EnergyState(energy: 1, dailyFreeUsed: true));
      c.commit(); // 1 -> 0
      // a further normal commit cannot start, but if forced stays clamped
      final out = c.commit();
      expect(out.energy, isNonNegative);
      expect(c.state.energy, 0);
    });

    test('refill adds energy, capped at the max tank', () {
      final c = EnergyController(const EnergyState(energy: 4, dailyFreeUsed: true));
      c.refill(3);
      expect(c.state.energy, 5); // capped at maxEnergy (5)
    });

    test('free tier sees an interstitial every Nth completion; Pro never does',
        () {
      final free = EnergyController(const EnergyState(energy: 5, dailyFreeUsed: true));
      expect(free.commit().showInterstitial, isFalse); // #1
      expect(free.commit().showInterstitial, isFalse); // #2
      expect(free.commit().showInterstitial, isTrue); // #3 (every 3rd)

      final pro = EnergyController(
          const EnergyState(isPro: true, dailyFreeUsed: true));
      for (var i = 0; i < 3; i++) {
        expect(pro.commit().showInterstitial, isFalse);
      }
    });
  });
}
