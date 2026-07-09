import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/data_access/supabase_user_state_stores.dart';
import 'package:ratel/services/economy/outfits.dart';
import 'package:ratel/services/economy/outfits_store.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';
import 'package:ratel/services/progress/study_stats.dart';
import 'package:ratel/services/progress/study_stats_store.dart';
import 'package:ratel/services/progress/xp_history_store.dart';

void main() {
  group('SupabaseSettingsStore mappers', () {
    const AppSettings s = AppSettings(
      highContrast: true,
      sound: false,
      haptics: false,
      dailyGoal: 50,
      themeMode: ThemeMode.dark,
      readNotifications: <String>{'n2', 'n1'},
      recentSearches: <String>['café mañana', 'b,c', 'a'],
      reduceMotion: true,
      mutedNotifications: <String>{'league'},
      displayName: 'Raja',
      worldTheme: WorldTheme.space,
    );

    test('row round-trips through settingsFromRow (incl. encoding + enums)', () {
      final Map<String, Object?> row =
          SupabaseSettingsStore.settingsRowFor(s, 'u1');
      expect(row['user_id'], 'u1');
      expect(row['daily_goal'], 50);
      expect(row['theme_mode'], 'dark');
      expect(row['world_theme'], 'galaxy'); // space == galaxy alias
      expect(row['read_notifications'], <String>['n1', 'n2']); // sorted
      expect(row['recent_searches'], <String>['café mañana', 'b,c', 'a']);
      final AppSettings back = SupabaseSettingsStore.settingsFromRow(
          row.map((String k, Object? v) => MapEntry(k, v)));
      expect(back, s); // value-equal round trip (order of recents preserved)
    });

    test('unknown enum names + nulls fall back to defaults', () {
      final AppSettings back =
          SupabaseSettingsStore.settingsFromRow(<String, dynamic>{
        'theme_mode': 'plasma',
        'world_theme': 'atlantis-9',
        'recent_searches': null,
        'read_notifications': 'not-a-list',
      });
      expect(back.themeMode, const AppSettings().themeMode);
      expect(back.worldTheme, const AppSettings().worldTheme);
      expect(back.recentSearches, isEmpty);
      expect(back.readNotifications, isEmpty);
    });

    test('guest decorator (null client) stays byte-identical to local', () async {
      final InMemorySettingsStore local = InMemorySettingsStore();
      final SupabaseSettingsStore store = SupabaseSettingsStore(null, local);
      await store.save(s);
      expect(store.load(), s);
      expect(local.current, s);
      await store.hydrate(); // no-op, must not throw
      expect(store.load(), s);
    });
  });

  group('SupabaseOutfitsStore mappers + merge', () {
    test('mergeOutfits unions owned, remote selected wins', () {
      final OutfitState merged = SupabaseOutfitsStore.mergeOutfits(
        local: OutfitState(owned: <String>{'ninja'}, selected: 'ninja'),
        remote: OutfitState(owned: <String>{'astro'}, selected: 'astro'),
      );
      expect(merged.owned, containsAll(<String>{'classic', 'ninja', 'astro'}));
      expect(merged.selected, 'astro');
    });

    test('row round-trips (classic re-baked by the model)', () {
      final OutfitState s = OutfitState(owned: <String>{'b', 'a'}, selected: 'a');
      final Map<String, Object?> row =
          SupabaseOutfitsStore.outfitsRowFor(s, 'u1');
      expect(row['owned'], <String>['a', 'b', 'classic']);
      final OutfitState back = SupabaseOutfitsStore.outfitsFromRow(
          <String, dynamic>{'owned': row['owned'], 'selected': row['selected']});
      expect(back, s);
    });

    test('garbage row degrades to defaults', () {
      final OutfitState back = SupabaseOutfitsStore.outfitsFromRow(
          <String, dynamic>{'owned': 42, 'selected': null});
      expect(back.owned, <String>{'classic'});
      expect(back.selected, 'classic');
    });

    test('guest decorator (null client) delegates + hydrate no-ops', () async {
      final InMemoryOutfitsStore local = InMemoryOutfitsStore();
      final SupabaseOutfitsStore store = SupabaseOutfitsStore(null, local);
      final OutfitState s = OutfitState(owned: <String>{'x'}, selected: 'x');
      await store.save(s);
      await store.hydrate();
      expect(store.load(), s);
    });
  });

  group('SupabaseXpHistoryStore merge + delta', () {
    test('mergeXpHistory takes the per-day MAX', () {
      expect(
        SupabaseXpHistoryStore.mergeXpHistory(
          <String, int>{'2026-07-01': 30, '2026-07-02': 10},
          <String, int>{'2026-07-02': 25, '2026-07-03': 5},
        ),
        <String, int>{'2026-07-01': 30, '2026-07-02': 25, '2026-07-03': 5},
      );
    });

    test('changedDays pushes only deltas', () {
      expect(
        SupabaseXpHistoryStore.changedDays(
          previous: <String, int>{'2026-07-01': 30, '2026-07-02': 10},
          next: <String, int>{'2026-07-01': 30, '2026-07-02': 20},
        ),
        <String, int>{'2026-07-02': 20},
      );
    });

    test('rows round-trip; timestamps clip to YYYY-MM-DD', () {
      final List<Map<String, Object?>> rows = SupabaseXpHistoryStore.xpRowsFor(
          <String, int>{'2026-07-04': 40}, 'u1');
      expect(rows.single['user_id'], 'u1');
      expect(rows.single['day'], '2026-07-04');
      expect(
        SupabaseXpHistoryStore.xpHistoryFromRows(<Map<String, dynamic>>[
          <String, dynamic>{'day': '2026-07-04T00:00:00', 'xp': 40},
        ]),
        <String, int>{'2026-07-04': 40},
      );
    });

    test('guest decorator (null client) delegates', () async {
      final InMemoryXpHistoryStore local = InMemoryXpHistoryStore();
      final SupabaseXpHistoryStore store = SupabaseXpHistoryStore(null, local);
      await store.save(<String, int>{'2026-07-04': 15});
      await store.hydrate();
      expect(store.load(), <String, int>{'2026-07-04': 15});
    });
  });

  group('SupabaseStudyStatsStore merge', () {
    test('per-counter MAX with correct<=total clamp', () {
      final StudyStats merged = SupabaseStudyStatsStore.mergeStudyStats(
        const StudyStats(correct: 9, total: 9, studySeconds: 100),
        const StudyStats(correct: 2, total: 6, studySeconds: 300),
      );
      expect(merged.correct, 9);
      expect(merged.total, 9);
      expect(merged.studySeconds, 300);
      final StudyStats clamped = SupabaseStudyStatsStore.mergeStudyStats(
        const StudyStats(correct: 9, total: 9),
        const StudyStats(correct: 0, total: 3),
      );
      expect(clamped.correct <= clamped.total, isTrue);
    });

    test('row round-trips', () {
      const StudyStats s = StudyStats(correct: 3, total: 7, studySeconds: 42);
      final Map<String, Object?> row =
          SupabaseStudyStatsStore.statsRowFor(s, 'u1');
      expect(row['user_id'], 'u1');
      final StudyStats back = SupabaseStudyStatsStore.statsFromRow(
          <String, dynamic>{'correct': 3, 'total': 7, 'study_seconds': 42});
      expect(back, s);
    });

    test('guest decorator (null client) delegates', () async {
      final InMemoryStudyStatsStore local = InMemoryStudyStatsStore();
      final SupabaseStudyStatsStore store =
          SupabaseStudyStatsStore(null, local);
      const StudyStats s = StudyStats(correct: 1, total: 2, studySeconds: 3);
      await store.save(s);
      await store.hydrate();
      expect(store.load(), s);
    });
  });
}
