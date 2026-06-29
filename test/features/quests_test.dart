import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/quests/quests_controller.dart';
import 'package:ratel/features/quests/quests_screen.dart';
import 'package:ratel/services/quests/quests.dart';

Future<void> _pump(WidgetTester tester, {List<Override> overrides = const <Override>[]}) async {
  tester.view.physicalSize = const Size(440, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: RatelTheme.light(),
      home: const QuestsScreen(),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the REAL daily quests from the engine (fresh = 0/3)',
      (WidgetTester tester) async {
    await _pump(tester);
    expect(find.byKey(const ValueKey<String>('tab-quests')), findsOneWidget);
    // Every catalogue quest renders by its real title.
    expect(find.text('Power session'), findsOneWidget);
    expect(find.text('On fire'), findsOneWidget);
    expect(find.text('Streak keeper'), findsOneWidget);
    // Honest fresh state: none complete.
    expect(find.textContaining('DAILY QUESTS · 0/3'), findsOneWidget);
    // The old "Soon" stub chip is gone; the honesty note is present.
    expect(find.text('Soon'), findsNothing);
    expect(find.textContaining('No fake rewards'), findsOneWidget);
  });

  testWidgets('a completed quest shows ✅ and counts in the header',
      (WidgetTester tester) async {
    const List<QuestProgress> quests = <QuestProgress>[
      QuestProgress(
          Quest(
              id: 'power_session',
              emoji: '⚡',
              title: 'Power session',
              description: 'Earn double your daily goal',
              metric: QuestMetric.xpToday,
              goalMultiple: 2),
          40,
          40),
      QuestProgress(
          Quest(
              id: 'streak_keeper',
              emoji: '🔥',
              title: 'Streak keeper',
              description: 'Practice today to keep your streak',
              metric: QuestMetric.practicedToday),
          0,
          1),
    ];
    await _pump(tester,
        overrides: <Override>[questsProvider.overrideWithValue(quests)]);
    expect(find.text('✅'), findsOneWidget);
    expect(find.textContaining('DAILY QUESTS · 1/2'), findsOneWidget);
    expect(find.textContaining('40/40 XP today'), findsOneWidget);
  });
}
