import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/economy/economy.dart';

/// Pure-engine tests for the display-only energy model [R-I3]. Deterministic:
/// regen is a function of elapsed time, spend floors at 0, and the model never
/// blocks (it only computes the counter). No clock here.
void main() {
  const EnergyModel e = EnergyModel();

  test('caps at 5; a lesson costs 1', () {
    expect(EnergyModel.cap, 5);
    expect(EnergyModel.lessonCost, 1);
    expect(e.afterLesson(energy: 5), 4);
    expect(e.afterLesson(energy: 1), 0);
  });

  test('spending never drops below zero (non-blocking)', () {
    expect(e.afterLesson(energy: 0), 0);
    expect(e.afterLesson(energy: -3), 0);
  });

  test('regenerates one energy per interval, capped at 5', () {
    final Duration one = EnergyModel.regenInterval;
    expect(e.regenerated(energy: 2, elapsed: Duration.zero), 2);
    expect(e.regenerated(energy: 2, elapsed: one), 3);
    expect(e.regenerated(energy: 2, elapsed: one * 2), 4);
    expect(e.regenerated(energy: 2, elapsed: one * 10), 5);
    expect(e.regenerated(energy: 5, elapsed: one * 3), 5);
  });

  test('partial intervals grant no energy (floor)', () {
    final Duration half =
        Duration(minutes: EnergyModel.regenInterval.inMinutes ~/ 2);
    expect(e.regenerated(energy: 1, elapsed: half), 1);
  });

  test('clamps malformed input into [0, cap]', () {
    expect(e.regenerated(energy: -2, elapsed: Duration.zero), 0);
    expect(e.regenerated(energy: 99, elapsed: Duration.zero), 5);
  });
}
