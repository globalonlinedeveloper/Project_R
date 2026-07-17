import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/quests/quests.dart';

/// Pure-engine tests for the daily-quest board [R-I7]. Every assertion is over
/// REAL metrics — no clock, no fabricated progress.
void main() {
  const QuestsEngine engine = QuestsEngine();

  test('fresh day: every quest open with zero progress', () {
    final List<QuestProgress> r = engine.evaluate(QuestStats.zero);
    expect(r.length, 3);
    expect(r.every((QuestProgress p) => !p.done), isTrue);
    expect(r.every((QuestProgress p) => p.current == 0), isTrue);
    expect(engine.completedCount(QuestStats.zero), 0);
  });

  test('xp quests scale with the chosen daily goal', () {
    final List<QuestProgress> r = engine.evaluate(
        const QuestStats(xpToday: 0, streakDays: 0, dailyGoal: 20));
    expect(r.firstWhere((QuestProgress p) => p.quest.id == 'power_session').target, 40);
    expect(r.firstWhere((QuestProgress p) => p.quest.id == 'on_fire').target, 60);
  });

  test('power session completes at 2x goal; triple still open', () {
    final List<QuestProgress> r = engine.evaluate(
        const QuestStats(xpToday: 40, streakDays: 1, dailyGoal: 20));
    final QuestProgress power =
        r.firstWhere((QuestProgress p) => p.quest.id == 'power_session');
    expect(power.done, isTrue);
    expect(power.fraction, 1.0);
    final QuestProgress fire =
        r.firstWhere((QuestProgress p) => p.quest.id == 'on_fire');
    expect(fire.done, isFalse);
    expect(fire.fraction, closeTo(40 / 60, 1e-9));
    expect(engine.completedCount(
        const QuestStats(xpToday: 40, streakDays: 1, dailyGoal: 20)), 2);
  });

  test('streak keeper completes once any XP is earned today', () {
    bool keeper(int xp) => engine
        .evaluate(QuestStats(xpToday: xp, streakDays: 5, dailyGoal: 20))
        .firstWhere((QuestProgress p) => p.quest.id == 'streak_keeper')
        .done;
    expect(keeper(0), isFalse);
    expect(keeper(1), isTrue);
  });

  test('non-positive goal never divides by zero and stays in [0,1]', () {
    final List<QuestProgress> r = engine.evaluate(
        const QuestStats(xpToday: 0, streakDays: 0, dailyGoal: 0));
    expect(r.every((QuestProgress p) => p.target >= 1), isTrue);
    expect(
        r.every((QuestProgress p) => p.fraction >= 0 && p.fraction <= 1),
        isTrue);
  });

  // INC-QR1: every quest carries an honest, non-negative reward const — the
  // REAL 💎 the learner earns the first time it is completed. Pure data on the
  // Quest (the engine stays clockless); the flat amount is 3 for every quest.
  test('every quest has a non-negative rewardDiamonds const (flat 3)', () {
    expect(QuestsEngine.catalogue, isNotEmpty);
    for (final Quest q in QuestsEngine.catalogue) {
      expect(q.rewardDiamonds, greaterThanOrEqualTo(0),
          reason: 'quest ${q.id} reward must be non-negative');
      expect(q.rewardDiamonds, 3, reason: 'INC-QR1 resolved: 3💎 flat per quest');
    }
  });
}
