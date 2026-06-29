import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/achievements/achievements.dart';

// The §4.5 / §6 achievements engine [R-I7] — pure, deterministic milestones over
// the learner's REAL state. A fresh account is all-locked with honest progress;
// badges unlock only when genuinely earned. No fabricated "earned" data.

void main() {
  const AchievementsEngine engine = AchievementsEngine();

  Map<String, AchievementProgress> byId(AchievementStats s) =>
      <String, AchievementProgress>{
        for (final AchievementProgress p in engine.evaluate(s)) p.achievement.id: p
      };

  test('a fresh account has EVERY milestone locked with honest 0 progress', () {
    final List<AchievementProgress> ps = engine.evaluate(AchievementStats.zero);
    expect(ps.length, AchievementsEngine.catalogue.length);
    expect(ps.every((AchievementProgress p) => !p.unlocked), isTrue);
    expect(engine.unlockedCount(AchievementStats.zero), 0);
    expect(ps.first.current, 0);
    expect(ps.first.fraction, 0.0);
  });

  test('finishing the first lesson unlocks "First Steps" and nothing requiring more',
      () {
    const AchievementStats s = AchievementStats(
        lessonsCompleted: 1,
        xpTotal: 20,
        streakDays: 0,
        savedWords: 1,
        cefrOrdinal: 0);
    final Map<String, AchievementProgress> p = byId(s);
    expect(p['first_steps']!.unlocked, isTrue);
    expect(p['scholar']!.unlocked, isFalse); // needs 10 lessons
    expect(engine.unlockedCount(s), 1);
  });

  test('every threshold metric unlocks its badge (lessons/streak/xp/words/level)',
      () {
    const AchievementStats s = AchievementStats(
        lessonsCompleted: 10,
        xpTotal: 500,
        streakDays: 3,
        savedWords: 25,
        cefrOrdinal: 1); // A2
    expect(engine.unlockedCount(s), AchievementsEngine.catalogue.length);
  });

  test('progress fraction reflects the real metric and clamps to [0,1]', () {
    const AchievementStats half = AchievementStats(
        lessonsCompleted: 5,
        xpTotal: 0,
        streakDays: 0,
        savedWords: 0,
        cefrOrdinal: 0);
    final AchievementProgress scholar = byId(half)['scholar']!;
    expect(scholar.current, 5);
    expect(scholar.fraction, closeTo(0.5, 1e-9));
    expect(scholar.unlocked, isFalse);

    const AchievementStats over = AchievementStats(
        lessonsCompleted: 999,
        xpTotal: 0,
        streakDays: 0,
        savedWords: 0,
        cefrOrdinal: 0);
    expect(byId(over)['scholar']!.fraction, 1.0);
  });
}
