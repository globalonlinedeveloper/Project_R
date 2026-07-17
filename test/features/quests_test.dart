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

  // INC-QST1: the honest reward placeholder. A NOT-done quest shows a muted
  // "🎁 Rewards soon" disclosure in its trailing slot — it must carry NO
  // diamond count and NO 💎, because reward chests need a backend economy the
  // app doesn't have (§6). This proves the reward is disclosed, never faked.
  testWidgets('reward slot renders for each not-done quest with NO digit/💎',
      (WidgetTester tester) async {
    await _pump(tester);
    // Fresh state = 3 open quests, all not-done → 3 reward slots.
    final Finder slots = find.byKey(const ValueKey<String>('quest-reward-slot'));
    expect(slots, findsNWidgets(3));
    // The muted disclosure copy is present.
    expect(find.text('Rewards soon'), findsNWidgets(3));
    // No slot contains any digit (would imply a fake diamond/chest count)…
    expect(
        find.descendant(
            of: slots.first, matching: find.textContaining(RegExp(r'\d'))),
        findsNothing);
    // …and none contains a 💎 glyph anywhere in the screen's reward slots.
    for (int i = 0; i < 3; i++) {
      expect(
          find.descendant(
              of: slots.at(i), matching: find.textContaining('💎')),
          findsNothing);
    }
    // Belt-and-braces: read every Text in the first slot's subtree and assert
    // it is exactly the disclosure glyph or copy — nothing numeric/diamond.
    final Iterable<Text> texts = tester
        .widgetList<Text>(find.descendant(of: slots.first, matching: find.byType(Text)));
    for (final Text t in texts) {
      final String s = t.data ?? '';
      expect(s.contains('💎'), isFalse, reason: 'reward slot must not show 💎');
      expect(RegExp(r'\d').hasMatch(s), isFalse,
          reason: 'reward slot must not show a digit (no fake count)');
      expect(<String>['🎁', 'Rewards soon'].contains(s), isTrue,
          reason: 'unexpected reward-slot text: "$s"');
    }
  });

  // INC-QST1: the FRIEND QUEST section is an honest coming-soon disclosure —
  // a header + one muted card. NO fabricated partner (e.g. "Mia") and NO
  // progress, because friend quests need a social backend the app lacks.
  testWidgets('FRIEND QUEST header + honest coming-soon card, no fake partner',
      (WidgetTester tester) async {
    await _pump(tester);
    // Header renders (RatelSectionHeader upper-cases the label).
    expect(find.text('FRIEND QUEST'), findsOneWidget);
    // The card discloses it is coming soon and that no fake partners are shown.
    expect(find.textContaining('coming soon'), findsOneWidget);
    expect(find.textContaining('No fake partners'), findsOneWidget);
    // No fabricated partner name / progress leaks in.
    expect(find.textContaining('Mia'), findsNothing);
    expect(find.textContaining('Alex'), findsNothing);
  });

  // INC-QST1: a DONE quest shows ✅ in its trailing slot and does NOT render the
  // reward-pending disclosure (no slot, no 🎁 "Rewards soon" for that quest).
  testWidgets('a done quest shows ✅ and NOT the reward-pending slot',
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
    ];
    await _pump(tester,
        overrides: <Override>[questsProvider.overrideWithValue(quests)]);
    // The single quest is done → ✅ present, and NO reward slot exists.
    expect(find.text('✅'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('quest-reward-slot')), findsNothing);
    expect(find.text('Rewards soon'), findsNothing);
  });

  // INC-QST1: layout gauntlet — the new narrow trailing slot + the long
  // FRIEND QUEST copy must not overflow at tight widths (S130b precedent).
  testWidgets('layout gauntlet @360-460 — reward slot + friend copy no overflow',
      (WidgetTester tester) async {
    for (final double w in <double>[360, 400, 430, 460]) {
      tester.view.physicalSize = Size(w, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: RatelTheme.light(),
          home: const QuestsScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'quests overflow @${w}px');
      expect(find.byKey(const ValueKey<String>('tab-quests')), findsOneWidget);
      // The honest surfaces are still present at every width.
      expect(find.byKey(const ValueKey<String>('quest-reward-slot')),
          findsNWidgets(3));
      expect(find.text('FRIEND QUEST'), findsOneWidget);
    }
  });
}
