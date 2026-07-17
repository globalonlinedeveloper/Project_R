import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel;
import 'package:ratel/core/core.dart';
import 'package:ratel/features/streak/streak_screen.dart';
import 'package:ratel/services/progress/xp_history_store.dart';

// INC-STK-WEEKGRID — the 7-day activity grid on the Streak screen renders REAL
// data from the existing xp_history (last7DaysXpProvider), oldest -> newest,
// zero-filled. An "active" day is one the learner earned XP (DayXp.xp > 0):
// filled teal; inactive days are a faint cream3 dot (honest zeros, never a
// gap); the last cell is marked as today only when its date is genuinely the
// clock's today. No per-day flame / goal-met is fabricated.
//
// The grid harness mirrors two shipped harnesses: the StreakScreen pump from
// streak_screen_today_test.dart (fixed LearnerSnapshot + delegates), and the
// xp-history store + clock overrides from xp_history_controller_test.dart.

/// A minimal fixed learner so the hero/freeze/deadline cards render
/// deterministically. The grid reads xp_history (via the store), NOT the
/// learner snapshot, so the two are independent here.
class _FixedLearner extends Notifier<LearnerSnapshot>
    implements LearnerController {
  _FixedLearner(this._snap);
  final LearnerSnapshot _snap;
  @override
  LearnerSnapshot build() => _snap;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// A fixed clock so "today" is deterministic. 2026-06-30 is a Tuesday; the
// 7-day window is 2026-06-24 (Wed) .. 2026-06-30 (Tue, today).
final DateTime _fixedNow = DateTime(2026, 6, 30, 9);

Future<void> _pump(
  WidgetTester tester, {
  required Map<String, int> history,
  int streakDays = 3,
}) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[
      learnerControllerProvider.overrideWith(
          () => _FixedLearner(LearnerSnapshot(
                theta: 0,
                level: CefrLevel.a1,
                streakDays: streakDays,
              ))),
      isProProvider.overrideWithValue(false),
      clockProvider.overrideWithValue(() => _fixedNow),
      xpHistoryStoreProvider
          .overrideWithValue(InMemoryXpHistoryStore(history)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const StreakScreen(),
    ),
  ));
  await tester.pumpAndSettle();
}

// Cells expose a ValueKey 'streak-day-YYYY-MM-DD-(active|empty)[-today]'.
Iterable<String> _cellKeys(WidgetTester tester) => tester
    .widgetList<Container>(find.byType(Container))
    .map((Container c) => c.key)
    .whereType<ValueKey<String>>()
    .map((ValueKey<String> k) => k.value)
    .where((String v) => v.startsWith('streak-day-'));

// The honest caption that replaced the now-false per-day-log disclaimer.
const String _honestNote =
    'Your day count and freezes are your real numbers. '
    'Active days are days you earned XP — nothing is invented.';

void main() {
  group('Streak week grid — real xp_history (INC-STK-WEEKGRID)', () {
    testWidgets(
        'mixed history -> exactly the active days are teal, the rest empty',
        (WidgetTester tester) async {
      // 3 active days in the last-7 window (06-24 .. 06-30); others zero.
      await _pump(tester, history: <String, int>{
        '2026-06-24': 20, // Wed (in window)
        '2026-06-27': 40, // Sat (in window)
        '2026-06-30': 15, // Tue = today (in window)
        '2026-06-20': 99, // OUTSIDE the 7-day window -> must not count
      });

      final List<String> keys = _cellKeys(tester).toList();
      expect(keys.length, 7, reason: 'always exactly 7 cells');
      final int active =
          keys.where((String k) => k.contains('-active')).length;
      final int empty = keys.where((String k) => k.contains('-empty')).length;
      expect(active, 3, reason: 'three days earned XP inside the window');
      expect(empty, 4, reason: 'the other four days are honest zeros');
    });

    testWidgets(
        'empty history -> 7 empty cells, no crash, honest caption present',
        (WidgetTester tester) async {
      await _pump(tester, history: <String, int>{}, streakDays: 0);

      final List<String> keys = _cellKeys(tester).toList();
      expect(keys.length, 7);
      expect(keys.where((String k) => k.contains('-active')), isEmpty);
      expect(keys.where((String k) => k.contains('-empty')).length, 7);
      // The stale "no per-day activity log" line is gone; the honest one is up.
      expect(find.text(_honestNote), findsOneWidget);
    });

    testWidgets('the last cell is marked as today (clock-today)',
        (WidgetTester tester) async {
      await _pump(tester, history: <String, int>{'2026-06-30': 30});

      final List<String> keys = _cellKeys(tester).toList();
      // Exactly one cell is the today cell, and it is 06-30 (the clock today).
      final List<String> today =
          keys.where((String k) => k.endsWith('-today')).toList();
      expect(today.length, 1);
      expect(today.single, 'streak-day-2026-06-30-active-today');
    });

    testWidgets('an empty today still marks the today cell (no fake activity)',
        (WidgetTester tester) async {
      await _pump(tester, history: <String, int>{'2026-06-27': 20});

      final List<String> keys = _cellKeys(tester).toList();
      final List<String> today =
          keys.where((String k) => k.endsWith('-today')).toList();
      expect(today.length, 1);
      // Today earned no XP -> empty marker, but still flagged as today.
      expect(today.single, 'streak-day-2026-06-30-empty-today');
    });
  });
}
