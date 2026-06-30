import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';

/// The league week's XP is REAL (R-I6): it accumulates the learner's earned XP
/// and resets at the Monday boundary, mirroring xpToday. A guest session never
/// persists, so this is a pure in-memory derive over the injected clock.
void main() {
  test('weekly XP accumulates earned XP within the league week', () {
    final DateTime monday = DateTime(2026, 6, 29, 9);
    final ProviderContainer c = ProviderContainer(
      overrides: <Override>[clockProvider.overrideWithValue(() => monday)],
    );
    addTearDown(c.dispose);
    expect(c.read(learnerControllerProvider).xpWeekEarned, 0);
    c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 30);
    expect(c.read(learnerControllerProvider).xpWeekEarned, 30);
    c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
    expect(c.read(learnerControllerProvider).xpWeekEarned, 50);
  });

  test('weekly XP resets when the league week rolls over', () {
    DateTime now = DateTime(2026, 6, 29, 9); // Monday
    final ProviderContainer c = ProviderContainer(
      overrides: <Override>[clockProvider.overrideWithValue(() => now)],
    );
    addTearDown(c.dispose);
    c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 40);
    expect(c.read(learnerControllerProvider).xpWeekEarned, 40);
    now = DateTime(2026, 7, 6, 9); // the following Monday
    c.read(learnerControllerProvider.notifier).refreshDay();
    expect(c.read(learnerControllerProvider).xpWeekEarned, 0);
  });
}
