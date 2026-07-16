// INC-3 (design #9/#10 "Practice hub"): the skill-strength + drills landing
// that REPLACES the old `/practice` saved-words review (now demoted to the
// "My Words" leaf). Pins that the hub renders — the "Always free · never costs
// energy" subtitle, the SKILL STRENGTH panel, all SEVEN drill rows (incl.
// "My Words"), and the "⚡ Smart review" CTA — AND that the HONESTY holds:
// dataless tiles show an honest empty/stub state, NEVER a fabricated number
// (no invented per-skill %, no faked accuracy), while the real-wired stats
// (Words learned / This week XP / Accuracy) show genuine engine values. Also
// pins that "My Words" reaches the REAL FSRS saved-words review, and that a
// backend-less drill routes to an honest empty leaf rather than a faked
// exercise. [AUDIT P-1..P-5 · P-2/P-3/P-4 honest-stub · P-8 My Words]
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/features/practice/my_words_screen.dart';
import 'package:ratel/features/practice/practice_drill_leaf_screen.dart';
import 'package:ratel/features/practice/practice_hub_screen.dart';

/// A pinned wall clock so anything FSRS-touching is deterministic.
final DateTime _t0 = DateTime(2026, 6, 29, 12, 0, 0);

/// A minimal router carrying ONLY the three Practice routes, so a real
/// `context.push('/my-words')` / `/practice-drill` from the hub is exercised
/// end-to-end (no whole-app shell needed). Starts on the hub.
GoRouter _router() => GoRouter(
      initialLocation: '/practice',
      routes: <RouteBase>[
        GoRoute(
          path: '/practice',
          builder: (BuildContext c, GoRouterState s) =>
              const PracticeHubScreen(),
        ),
        GoRoute(
          path: '/my-words',
          builder: (BuildContext c, GoRouterState s) => const MyWordsScreen(),
        ),
        GoRoute(
          path: '/practice-drill',
          builder: (BuildContext c, GoRouterState s) {
            final PracticeDrill drill = switch (s.extra) {
              'mistakes' => PracticeDrill.mistakes,
              'weak' => PracticeDrill.weak,
              'smart' => PracticeDrill.smart,
              _ => PracticeDrill.mistakes,
            };
            return PracticeDrillLeafScreen(drill: drill);
          },
        ),
        // A stub the roleplay drill can land on (real app routes to /roleplay).
        GoRoute(
          path: '/roleplay',
          builder: (BuildContext c, GoRouterState s) =>
              const Scaffold(body: Text('ROLEPLAY-LIST')),
        ),
        GoRoute(
          path: '/daily-quiz',
          builder: (BuildContext c, GoRouterState s) =>
              const Scaffold(body: Text('LESSON-RUNNER')),
        ),
      ],
    );

/// Pump the hub (via the mini-router) on a TALL surface so the whole lazy
/// ListView lays out — every drill row + the Smart-review CTA are reachable by
/// a finder without scrolling (S37/S39 lazy-list gotcha).
Future<void> _pumpHub(
  WidgetTester tester, {
  List<Override> overrides = const <Override>[],
}) async {
  tester.view.physicalSize = const Size(440, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[
      clockProvider.overrideWithValue(() => _t0),
      ...overrides,
    ],
    child: MaterialApp.router(routerConfig: _router()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('INC-3 Practice hub renders (design #9/#10)', () {
    testWidgets('subtitle + skill-strength panel + all 7 drills + Smart review',
        (WidgetTester tester) async {
      await _pumpHub(tester);

      // The hub, not the old review screen.
      expect(find.byKey(const ValueKey<String>('screen-practice')),
          findsOneWidget);
      // "Always free · never costs energy" subtitle.
      expect(find.text('Always free · never costs energy'), findsOneWidget);
      // SKILL STRENGTH panel is present (section header up-cases the label).
      expect(find.byKey(const ValueKey<String>('practice-skill-strength')),
          findsOneWidget);
      expect(find.text('SKILL STRENGTH'), findsOneWidget);

      // All SEVEN drill rows render, each with its designed title.
      const List<String> drillKeys = <String>[
        'practice-drill-mistakes',
        'practice-drill-weak',
        'practice-drill-listening',
        'practice-drill-speaking',
        'practice-drill-roleplay',
        'practice-drill-mywords',
        'practice-drill-writing',
      ];
      for (final String k in drillKeys) {
        expect(find.byKey(ValueKey<String>(k)), findsOneWidget,
            reason: 'drill row "$k" must render');
      }
      expect(find.text('Mistakes review'), findsOneWidget);
      expect(find.text('Weak words'), findsOneWidget);
      expect(find.text('Listening drill'), findsOneWidget);
      expect(find.text('Speaking drill'), findsOneWidget);
      expect(find.text('Roleplay drill'), findsOneWidget);
      expect(find.text('My Words'), findsOneWidget);
      expect(find.text('Guided writing'), findsOneWidget);

      // The "⚡ Smart review" CTA.
      expect(find.byKey(const ValueKey<String>('practice-smart-review')),
          findsOneWidget);
      expect(find.text('Smart review'), findsOneWidget);
      expect(find.text("Adaptive mix of everything you're forgetting"),
          findsOneWidget);
    });

    testWidgets(
        'dataless tiles are HONEST — no fabricated skill % / accuracy on a '
        'fresh learner', (WidgetTester tester) async {
      await _pumpHub(tester);

      // Skill strength: an honest empty note, NOT the mockup 82/58/71/44 bars.
      expect(find.byKey(const ValueKey<String>('practice-skill-nodata')),
          findsOneWidget);
      expect(find.textContaining('no score is shown'), findsOneWidget);
      for (final String pct in <String>['82%', '58%', '71%', '44%']) {
        expect(find.text(pct), findsNothing,
            reason: 'must not fabricate a per-skill percentage ($pct)');
      }

      // 3-stat row: Words learned / This week XP are REAL zeros on a fresh
      // learner; Accuracy is honestly "—" (no graded answers yet), NOT "89%".
      expect(find.text('Words learned'), findsOneWidget);
      expect(find.text('This week XP'), findsOneWidget);
      expect(find.text('Accuracy'), findsOneWidget);
      expect(find.text('—'), findsOneWidget); // honest empty accuracy
      // Never the mockup's fabricated stat values.
      expect(find.text('612'), findsNothing);
      expect(find.text('340 XP'), findsNothing);
      expect(find.text('89%'), findsNothing);
    });

    testWidgets('real-wired stats reflect genuine engine state (Words learned)',
        (WidgetTester tester) async {
      // Precondition set EXPLICITLY: the store starts empty (fresh learner),
      // then we save two REAL cards through the dedup intake (the only
      // card-creating path) so "Words learned" shows the true count, not a
      // guess. We reach the live container the pumped hub is actually reading.
      await _pumpHub(tester);
      // Fresh: Words learned == 0 (renders among the stat/CTA zeros).
      expect(find.text('0'), findsWidgets);

      final Element ctx = tester.element(
          find.byKey(const ValueKey<String>('practice-skill-strength')));
      final ProviderContainer container = ProviderScope.containerOf(ctx);
      container
          .read(savedWordsControllerProvider.notifier)
          .save('manzana', glyph: '🍎');
      container
          .read(savedWordsControllerProvider.notifier)
          .save('gato', glyph: '🐱');
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget,
          reason: 'Words learned must be the REAL saved-words count');
    });

    testWidgets('My Words drill reaches the REAL FSRS saved-words review',
        (WidgetTester tester) async {
      await _pumpHub(tester);

      await tester.tap(find.byKey(const ValueKey<String>(
          'practice-drill-mywords')));
      await tester.pumpAndSettle();

      // We are on the demoted FSRS review leaf (its own screen key), showing
      // its honest empty state — never a fabricated queue.
      expect(find.byKey(const ValueKey<String>('screen-my-words')),
          findsOneWidget);
      expect(find.text('No saved words yet'), findsOneWidget);
    });

    testWidgets(
        'a backend-less drill routes to an HONEST empty leaf, not a fake exercise',
        (WidgetTester tester) async {
      await _pumpHub(tester);

      await tester.tap(find.byKey(const ValueKey<String>(
          'practice-drill-mistakes')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('screen-practice-drill')),
          findsOneWidget);
      expect(find.text('Nothing to review yet'), findsOneWidget);
      // Honest go-live note; no invented exercise on screen.
      expect(find.textContaining('honest empty state'), findsOneWidget);
    });

    testWidgets('Smart review CTA opens its honest adaptive leaf',
        (WidgetTester tester) async {
      await _pumpHub(tester);

      await tester.tap(find.byKey(const ValueKey<String>(
          'practice-smart-review')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('screen-practice-drill')),
          findsOneWidget);
      // The Smart-review leaf names its one REAL backing queue (FSRS due).
      expect(find.textContaining('adaptive queue is empty'), findsOneWidget);
    });
  });
}
