import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/quests/quests_controller.dart';
import 'package:ratel/features/quests/quests_screen.dart';
import 'package:ratel/features/friends/friends_controller.dart';
import 'package:ratel/services/social/friends.dart';
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
    // INC-QR1: the DONE power_session shows the EARNED chip ✅ +3💎 (real const);
    // the not-done streak_keeper shows its PENDING +3💎 reward. So exactly one
    // ✅ (earned), one earned-chip key, and two "+3💎" (1 earned + 1 pending).
    expect(find.text('✅'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('quest-reward-earned')),
        findsOneWidget);
    expect(find.text('+3💎'), findsNWidgets(2));
    expect(find.byKey(const ValueKey<String>('quest-reward-slot')),
        findsOneWidget); // the single not-done quest's pending slot
    expect(find.textContaining('DAILY QUESTS · 1/2'), findsOneWidget);
    expect(find.textContaining('40/40 XP today'), findsOneWidget);
  });

  // INC-QR1: the reward slot is now HONEST-REAL, not a placeholder. The 💎
  // wallet credits a genuine amount the first time a quest is completed
  // (`LearnerController._maybeAwardQuestRewards`), so a NOT-done quest discloses
  // the real PENDING reward `🎁 +3💎` (the deterministic `Quest.rewardDiamonds`
  // const the learner WILL earn) under a small "reward" label — clearly a
  // reward to earn, never the wallet balance and never a fabricated figure.
  testWidgets('not-done reward slot shows the REAL pending +3💎 reward',
      (WidgetTester tester) async {
    await _pump(tester);
    // Fresh state = 3 open quests, all not-done → 3 reward slots.
    final Finder slots = find.byKey(const ValueKey<String>('quest-reward-slot'));
    expect(slots, findsNWidgets(3));
    // The REAL pending reward amount (+3💎) shows in every slot; there is NO
    // localized label (the 🎁 glyph marks it as a reward), so no ARB key.
    expect(find.text('+3💎'), findsNWidgets(3));
    // The old muted placeholder copy is gone now that the reward is real.
    expect(find.text('Rewards soon'), findsNothing);
    expect(find.text('reward'), findsNothing);
    // The 🎁 glyph precedes the pending amount in each slot.
    expect(
        find.descendant(of: slots.first, matching: find.text('🎁')),
        findsOneWidget);
    // The ONLY digit shown is the real reward const (3) — no fabricated count.
    final Iterable<Text> texts = tester.widgetList<Text>(
        find.descendant(of: slots.first, matching: find.byType(Text)));
    for (final Text t in texts) {
      final String s = t.data ?? '';
      final Iterable<String> digits =
          RegExp(r'\d').allMatches(s).map((Match m) => m.group(0)!);
      expect(digits.every((String d) => d == '3'), isTrue,
          reason: 'reward slot digit must be the real 3💎 const, not "$s"');
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

  // INC-QF1: when the learner has a REAL friend ahead in this week's league,
  // the FRIEND QUEST section shows a real "out-earn @handle" tile (real handle +
  // real XP gap) and the coming-soon fallback is replaced. Nothing fabricated —
  // the view-model is built only from a real FriendRecord.
  testWidgets('INC-QF1 a real rival ahead shows the out-earn tile; coming-soon replaced',
      (WidgetTester tester) async {
    await _pump(tester, overrides: <Override>[
      friendQuestProvider.overrideWithValue(const FriendQuestView(
        handle: 'mia',
        displayName: 'Mia',
        avatarEmoji: '🦊',
        myWeeklyXp: 120,
        friendWeeklyXp: 200,
      )),
    ]);
    expect(find.byKey(const ValueKey('friend-quest-tile')), findsOneWidget);
    expect(find.text('Out-earn @mia · 80 XP to catch up this week'),
        findsOneWidget);
    // The real tile REPLACES the honest coming-soon card (not shown alongside).
    expect(find.textContaining('coming soon'), findsNothing);
  });

  group('INC-QF1 friendQuest logic', () {
    test('FriendQuestView.gap = friend - me, floored at 0', () {
      expect(
          const FriendQuestView(handle: 'm', displayName: 'M', avatarEmoji: 'x',
              myWeeklyXp: 120, friendWeeklyXp: 200).gap,
          80);
      expect(
          const FriendQuestView(handle: 'm', displayName: 'M', avatarEmoji: 'x',
              myWeeklyXp: 200, friendWeeklyXp: 120).gap,
          0); // never negative
    });

    test('provider picks the CLOSEST rival ahead (last of whoPassedMe)', () {
      final ProviderContainer c = ProviderContainer(overrides: <Override>[
        whoPassedMeProvider.overrideWithValue(const <FriendRecord>[
          FriendRecord(userId: 'u1', handle: 'ana', displayName: 'Ana',
              status: FriendStatus.friends, avatarEmoji: '🐼', weeklyXp: 300),
          FriendRecord(userId: 'u2', handle: 'mia', displayName: 'Mia',
              status: FriendStatus.friends, avatarEmoji: '🦊', weeklyXp: 200),
        ]),
      ]);
      addTearDown(c.dispose);
      final FriendQuestView? fq = c.read(friendQuestProvider);
      expect(fq, isNotNull);
      expect(fq!.handle, 'mia'); // smallest lead still ahead = closest to catch
      expect(fq.friendWeeklyXp, 200);
      expect(fq.gap, fq.friendWeeklyXp - fq.myWeeklyXp); // consistent, real
    });

    test('provider is null with no rival ahead -> honest coming-soon', () {
      final ProviderContainer c = ProviderContainer(overrides: <Override>[
        whoPassedMeProvider.overrideWithValue(const <FriendRecord>[]),
      ]);
      addTearDown(c.dispose);
      expect(c.read(friendQuestProvider), isNull);
    });
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
    // The single quest is done → the EARNED chip ✅ +3💎 shows, and the
    // not-done PENDING reward slot does NOT (that slot is for open quests only).
    expect(find.text('✅'), findsOneWidget);
    expect(find.text('+3💎'), findsOneWidget); // real earned reward const
    expect(find.byKey(const ValueKey<String>('quest-reward-earned')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('quest-reward-slot')), findsNothing);
    expect(find.text('reward'), findsNothing); // the pending label is absent
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
