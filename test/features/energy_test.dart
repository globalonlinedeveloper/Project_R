import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/services/economy/economy.dart';

/// Energy is REAL (R-I3) and DISPLAY-ONLY / NON-BLOCKING (S60): a lesson spends
/// one ⚡, it regenerates over time, caps at 5, and NEVER blocks a lesson — a
/// pure in-memory derive over the injected clock (a guest never persists).
void main() {
  test('a fresh learner starts at full energy', () {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(learnerControllerProvider).energy, EnergyModel.cap);
  });

  test('each lesson spends one ⚡; lessons keep working at zero (non-blocking)',
      () {
    final DateTime now = DateTime(2026, 6, 30, 9);
    final ProviderContainer c = ProviderContainer(
      overrides: <Override>[clockProvider.overrideWithValue(() => now)],
    );
    addTearDown(c.dispose);
    final LearnerController ctl = c.read(learnerControllerProvider.notifier);
    for (int i = 0; i < 5; i++) {
      ctl.recordLessonComplete(xp: 10);
    }
    expect(c.read(learnerControllerProvider).energy, 0); // 5 → 0, floored
    final int before = c.read(learnerControllerProvider).lessonsCompleted;
    ctl.recordLessonComplete(xp: 10); // still works at zero energy
    expect(c.read(learnerControllerProvider).lessonsCompleted, before + 1);
    expect(c.read(learnerControllerProvider).energy, 0);
  });

  test('energy regenerates over real time toward the cap', () {
    DateTime now = DateTime(2026, 6, 30, 9);
    final ProviderContainer c = ProviderContainer(
      overrides: <Override>[clockProvider.overrideWithValue(() => now)],
    );
    addTearDown(c.dispose);
    final LearnerController ctl = c.read(learnerControllerProvider.notifier);
    ctl.recordLessonComplete(xp: 10);
    expect(c.read(learnerControllerProvider).energy, 4);
    now = now.add(EnergyModel.regenInterval * 2); // +2 ⚡ → capped at 5
    ctl.refreshDay();
    expect(c.read(learnerControllerProvider).energy, 5);
  });
}
