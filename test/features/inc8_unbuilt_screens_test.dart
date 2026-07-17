import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel;
import 'package:ratel/app/course_switch.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/chat/chat_screen.dart';
import 'package:ratel/features/courses/courses_screen.dart';
import 'package:ratel/features/energy/energy_screen.dart';
import 'package:ratel/features/streak/streak_screen.dart';
import 'package:ratel/services/ai_relay/ai_relay.dart';
import 'package:ratel/services/economy/energy.dart';

// INC-8 — the four unbuilt screens (Streak / Energy / Courses / Chat).
//
// Every screen is verified to render REAL injected snapshot data and its
// HONEST states — never a fabricated number, calendar, per-course XP, refill
// price, or chat reply. Routes are asserted to resolve. Screens can't be run
// against a live backend here (CI runs the widget layer); this file gates on a
// clean analyze + these render/route assertions.

/// A minimal test controller that returns a FIXED [LearnerSnapshot] so the
/// screens read deterministic REAL data (the same fields the top-bar chips do).
class _FixedLearner extends Notifier<LearnerSnapshot>
    implements LearnerController {
  _FixedLearner(this._snap);
  final LearnerSnapshot _snap;
  @override
  LearnerSnapshot build() => _snap;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A relay that reports available, to exercise the "connected" chat header path
/// WITHOUT ever producing a reply (complete() is never called by the scaffold).
class _AvailableRelay implements AiRelay {
  const _AvailableRelay();
  @override
  bool get isAvailable => true;
  @override
  Future<RelayText> complete(String prompt) async =>
      throw StateError('never called in the scaffold');
}

LearnerSnapshot _snap({
  int streakDays = 7,
  int streakFreezes = 2,
  int energy = 4,
}) =>
    LearnerSnapshot(
      theta: 0,
      level: CefrLevel.a1,
      streakDays: streakDays,
      streakFreezes: streakFreezes,
      energy: energy,
    );

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  LearnerSnapshot? snapshot,
  bool isPro = false,
  bool relayAvailable = false,
  String currentCourse = 'es',
  List<String> availableCourses = const <String>['es', 'fr'],
}) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final LearnerSnapshot snap = snapshot ?? _snap();
  Widget app = MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: screen,
  );
  // Courses reads the CourseSwitchScope from the tree (above the app).
  app = CourseSwitchScope(
    current: currentCourse,
    available: availableCourses,
    switchCourse: (_) async {},
    child: app,
  );

  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[
      learnerControllerProvider.overrideWith(() => _FixedLearner(snap)),
      isProProvider.overrideWithValue(isPro),
      if (relayAvailable)
        aiRelayProvider.overrideWithValue(const _AvailableRelay()),
    ],
    child: app,
  ));
  await tester.pumpAndSettle();
}

void main() {
  // ---------------------------------------------------------------- STREAK ---
  group('Streak screen (/streak · A-S)', () {
    testWidgets('renders REAL streak days + freezes from the snapshot',
        (WidgetTester tester) async {
      await _pump(tester, const StreakScreen(),
          snapshot: _snap(streakDays: 7, streakFreezes: 2));

      expect(find.byKey(const ValueKey<String>('screen-streak')),
          findsOneWidget);
      // Real day count in the hero + "DAY STREAK" label.
      expect(find.text('7'), findsOneWidget);
      expect(find.text('DAY STREAK'), findsOneWidget);
      // Real freeze count.
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Streak freezes'), findsOneWidget);
    });

    testWidgets('shows the HONEST no-calendar note and honest Streak Society',
        (WidgetTester tester) async {
      await _pump(tester, const StreakScreen());
      // Honest note: no fabricated day-by-day calendar.
      expect(
          find.textContaining('does not show a day-by-day calendar'),
          findsOneWidget);
      // Streak Society is an honest not-built note (no fake leaderboard/social).
      expect(find.text('Streak Society'), findsOneWidget);
      expect(find.textContaining('is not built yet'), findsOneWidget);
    });

    testWidgets('zero streak shows an honest start-your-streak state',
        (WidgetTester tester) async {
      await _pump(tester, const StreakScreen(),
          snapshot: _snap(streakDays: 0, streakFreezes: 0));
      expect(find.text('0'), findsWidgets);
      expect(find.text('Start your streak today'), findsWidgets);
    });

    testWidgets('the hero flame is CENTERED (regression: it was left-aligned '
        'under the stretch column while the count/label re-centered)',
        (WidgetTester tester) async {
      await _pump(tester, const StreakScreen(),
          snapshot: _snap(streakDays: 0, streakFreezes: 0));
      // Two 🔥 exist (hero + Streak-Society card); the hero is the 64px one.
      final Finder heroFlame = find.byWidgetPredicate((Widget w) =>
          w is Text && w.data == '🔥' && w.style?.fontSize == 64);
      expect(heroFlame, findsOneWidget);
      expect(tester.widget<Text>(heroFlame).textAlign, TextAlign.center);
    });
  });

  // ---------------------------------------------------------------- ENERGY ---
  group('Energy screen (/energy · A-E · info-only)', () {
    testWidgets('renders REAL current energy of the real cap',
        (WidgetTester tester) async {
      await _pump(tester, const EnergyScreen(), snapshot: _snap(energy: 4));
      expect(find.byKey(const ValueKey<String>('screen-energy')),
          findsOneWidget);
      // Real "4 of 5 energy" (cap = EnergyModel.cap).
      expect(find.text('4 of ${EnergyModel.cap} energy'), findsOneWidget);
      // Never-blocks honesty is on-screen.
      expect(find.text('Energy never blocks learning'), findsOneWidget);
    });

    testWidgets('does NOT invent a refill countdown or price (§9.4)',
        (WidgetTester tester) async {
      await _pump(tester, const EnergyScreen(), snapshot: _snap(energy: 4));
      // No fabricated numbers the app can't back.
      expect(find.textContaining('35:10'), findsNothing);
      expect(find.textContaining('every 60 min'), findsNothing);
      expect(find.textContaining('350'), findsNothing);
      // Honest note explaining the omission.
      expect(find.textContaining("doesn't show a refill price or timer"),
          findsOneWidget);
    });

    testWidgets('PRO shows unlimited (∞) energy, no counter',
        (WidgetTester tester) async {
      await _pump(tester, const EnergyScreen(), isPro: true);
      expect(find.text('Unlimited energy'), findsOneWidget);
      expect(find.text('You have unlimited energy'), findsOneWidget);
    });
  });

  // --------------------------------------------------------------- COURSES ---
  group('Courses screen (/courses · A-C)', () {
    testWidgets('lists the REAL available courses with Active/Switch',
        (WidgetTester tester) async {
      await _pump(tester, const CoursesScreen(),
          currentCourse: 'es', availableCourses: const <String>['es', 'fr']);
      expect(find.byKey(const ValueKey<String>('screen-courses')),
          findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);
      expect(find.text('French'), findsOneWidget);
      // The active course carries the Active pill; the other offers Switch.
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Switch'), findsOneWidget);
    });

    testWidgets('shows the shared streak & XP note; no fabricated per-course XP',
        (WidgetTester tester) async {
      await _pump(tester, const CoursesScreen());
      expect(find.textContaining('streak & XP are shared across courses'),
          findsOneWidget);
      // No invented per-course level/XP rows (§9.5).
      expect(find.textContaining('1,240 XP'), findsNothing);
      expect(find.textContaining('Level A2'), findsNothing);
    });

    testWidgets('ADD A COURSE is an honest note, not a fake 50+ catalog',
        (WidgetTester tester) async {
      await _pump(tester, const CoursesScreen());
      expect(find.text('ADD A COURSE'), findsOneWidget);
      expect(find.textContaining('only lists courses it actually ships'),
          findsOneWidget);
      expect(find.textContaining('50+ courses'), findsOneWidget);
    });
  });

  // ------------------------------------------------------------------ CHAT ---
  group('Chat scaffold (/chat · C-C · fail-closed)', () {
    testWidgets('renders intro bubble + quick chips + composer',
        (WidgetTester tester) async {
      await _pump(tester, const ChatScreen());
      expect(
          find.byKey(const ValueKey<String>('screen-chat')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('chat-composer')),
          findsOneWidget);
      expect(find.byKey(const ValueKey<String>('chat-send')), findsOneWidget);
      // Quick-reply chips.
      expect(find.text('How do you say…?'), findsOneWidget);
      expect(find.text('Correct my sentence'), findsOneWidget);
    });

    testWidgets(
        'fail-closed: relay unavailable → honest offline note, NO fake reply',
        (WidgetTester tester) async {
      await _pump(tester, const ChatScreen(), relayAvailable: false);
      expect(find.text("The tutor chat isn't connected yet"), findsOneWidget);
      expect(find.textContaining('no reply is ever simulated'), findsOneWidget);
    });

    testWidgets(
        'sending a message never fabricates a reply (honest blocked state)',
        (WidgetTester tester) async {
      await _pump(tester, const ChatScreen(), relayAvailable: false);
      await tester.enterText(
          find.byKey(const ValueKey<String>('chat-composer')), 'Hola Ratel');
      await tester.tap(find.byKey(const ValueKey<String>('chat-send')));
      await tester.pumpAndSettle();
      // The composer is cleared and an honest blocked note is shown — but there
      // is NO synthesized assistant reply bubble echoing "Hola Ratel" back.
      expect(find.textContaining('no reply is simulated'), findsWidgets);
      expect(find.text('Hola Ratel'), findsNothing);
    });

    testWidgets('connected header state does not by itself produce replies',
        (WidgetTester tester) async {
      await _pump(tester, const ChatScreen(), relayAvailable: true);
      // The header shows "Chat with Ratel"; even when the relay reports
      // available, the scaffold never fabricates a turn on its own.
      expect(find.text('Chat with Ratel'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------- ROUTES ---
  group('routes resolve', () {
    for (final String path in const <String>[
      '/streak',
      '/energy',
      '/courses',
      '/chat',
    ]) {
      testWidgets('$path resolves to a real screen',
          (WidgetTester tester) async {
        final GoRouter router = GoRouter(
          initialLocation: path,
          routes: <RouteBase>[
            GoRoute(
                path: '/streak',
                builder: (_, _) => const StreakScreen()),
            GoRoute(
                path: '/energy',
                builder: (_, _) => const EnergyScreen()),
            GoRoute(
                path: '/courses',
                builder: (_, _) => const CoursesScreen()),
            GoRoute(path: '/chat', builder: (_, _) => const ChatScreen()),
          ],
        );
        Widget app = MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        );
        app = CourseSwitchScope(
          current: 'es',
          available: const <String>['es', 'fr'],
          switchCourse: (_) async {},
          child: app,
        );
        await tester.pumpWidget(ProviderScope(
          overrides: <Override>[
            learnerControllerProvider.overrideWith(() => _FixedLearner(_snap())),
            isProProvider.overrideWithValue(false),
          ],
          child: app,
        ));
        await tester.pumpAndSettle();
        // Each path resolved to its screen key (no ComingSoon / no crash).
        final String key = switch (path) {
          '/streak' => 'screen-streak',
          '/energy' => 'screen-energy',
          '/courses' => 'screen-courses',
          _ => 'screen-chat',
        };
        expect(find.byKey(ValueKey<String>(key)), findsOneWidget);
      });
    }
  });
}
