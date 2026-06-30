import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/services/progress/xp_history_store.dart';

/// D1 evidence — the XP-history controller + the lesson-complete hook that feeds
/// the Progress "Last 7 days" chart (R-G6 / R-L14). Honest: only real earned XP.
void main() {
  final DateTime fixed = DateTime(2026, 6, 30, 9);

  ProviderContainer container({XpHistoryStore? store}) =>
      ProviderContainer(overrides: <Override>[
        clockProvider.overrideWithValue(() => fixed),
        if (store != null) xpHistoryStoreProvider.overrideWithValue(store),
      ]);

  test('recordToday accumulates today and lastDays zero-fills the rest', () {
    final ProviderContainer c = container();
    addTearDown(c.dispose);
    final XpHistoryController n = c.read(xpHistoryControllerProvider.notifier);
    n.recordToday(20);
    n.recordToday(10); // same day accumulates
    final List<DayXp> days = c.read(last7DaysXpProvider);
    expect(days.length, 7);
    expect(days.last.xp, 30); // today
    expect(days.take(6).every((DayXp d) => d.xp == 0), isTrue); // honest zeros
    expect(n.totalOver(), 30);
  });

  test('completing a lesson records into the 7-day history (the hook)', () {
    final ProviderContainer c = container();
    addTearDown(c.dispose);
    c.read(learnerControllerProvider.notifier).recordLessonComplete(xp: 20);
    expect(c.read(last7DaysXpProvider).last.xp, 20);
  });

  test('non-positive XP is a no-op (never fabricated)', () {
    final ProviderContainer c = container();
    addTearDown(c.dispose);
    final XpHistoryController n = c.read(xpHistoryControllerProvider.notifier);
    n.recordToday(0);
    n.recordToday(-5);
    expect(c.read(last7DaysXpProvider).every((DayXp d) => d.xp == 0), isTrue);
  });

  test('rehydrates recorded history from the store at build', () {
    final InMemoryXpHistoryStore store = InMemoryXpHistoryStore(
        <String, int>{'2026-06-30': 40, '2026-06-29': 15});
    final ProviderContainer c = container(store: store);
    addTearDown(c.dispose);
    final List<DayXp> days = c.read(last7DaysXpProvider);
    expect(days.last.xp, 40); // 06-30
    expect(days[days.length - 2].xp, 15); // 06-29
    expect(c.read(xpHistoryControllerProvider.notifier).totalOver(), 55);
  });

  test('writes through to the store', () {
    final InMemoryXpHistoryStore store = InMemoryXpHistoryStore();
    final ProviderContainer c = container(store: store);
    addTearDown(c.dispose);
    c.read(xpHistoryControllerProvider.notifier).recordToday(25);
    expect(store.current['2026-06-30'], 25);
  });
}
