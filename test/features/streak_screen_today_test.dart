import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel;
import 'package:ratel/core/core.dart';
import 'package:ratel/features/streak/streak_screen.dart';

// INC-STK1 — the deadline card's real "streak safe today" state.
//
// The card reads dailyGoalProvider.met (== xpToday >= dailyGoal). With a live
// streak AND today's goal met it shows the shipped streakTodayDone line
// ("Today's goal is met — your streak is safe.") and drops the generic
// before-midnight body; not-met keeps the deadline note; a zero streak still
// shows the start-your-streak state regardless of met. The daily goal defaults
// to 20 (AppSettings), so xpToday >= 20 drives met=true here without touching
// the settings controller.

/// A minimal test controller returning a FIXED [LearnerSnapshot] so the screen
/// reads deterministic REAL data — including [xpToday], which (with the default
/// goal of 20) is what dailyGoalProvider derives `met` from.
class _FixedLearner extends Notifier<LearnerSnapshot>
    implements LearnerController {
  _FixedLearner(this._snap);
  final LearnerSnapshot _snap;
  @override
  LearnerSnapshot build() => _snap;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LearnerSnapshot _snap({int streakDays = 7, int xpToday = 0}) => LearnerSnapshot(
      theta: 0,
      level: CefrLevel.a1,
      streakDays: streakDays,
      xpToday: xpToday,
    );

Future<void> _pump(WidgetTester tester, {required LearnerSnapshot snap}) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[
      learnerControllerProvider.overrideWith(() => _FixedLearner(snap)),
      isProProvider.overrideWithValue(false),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const StreakScreen(),
    ),
  ));
  await tester.pumpAndSettle();
}

// The exact shipped copy, so a silent ARB rename would red this test.
const String _safeLine = "Today's goal is met — your streak is safe.";
const String _deadlineBody =
    'Meet your daily goal before midnight to extend your streak.';
const String _zeroTitle = 'Start your streak today';

void main() {
  group('Streak deadline card — real "safe today" state (INC-STK1)', () {
    testWidgets(
        'live streak + goal MET -> shows the safe line, drops the deadline body',
        (WidgetTester tester) async {
      // xpToday 20 >= default goal 20 -> dailyGoalProvider.met == true.
      await _pump(tester, snap: _snap(streakDays: 7, xpToday: 20));

      expect(find.text(_safeLine), findsOneWidget);
      // The generic before-midnight note is NOT shown once the day is safe.
      expect(find.text(_deadlineBody), findsNothing);
    });

    testWidgets(
        'live streak + goal NOT met -> shows the deadline body, not the safe '
        'line', (WidgetTester tester) async {
      // xpToday 0 < goal 20 -> met == false.
      await _pump(tester, snap: _snap(streakDays: 7, xpToday: 0));

      expect(find.text(_deadlineBody), findsOneWidget);
      expect(find.text(_safeLine), findsNothing);
    });

    testWidgets(
        'zero streak keeps the start-your-streak state even when goal is met',
        (WidgetTester tester) async {
      // days == 0 -> !hasStreak wins regardless of met (xpToday 20 >= 20).
      await _pump(tester, snap: _snap(streakDays: 0, xpToday: 20));

      // streakZeroTitle appears both in the hero and in the deadline card.
      expect(find.text(_zeroTitle), findsWidgets);
      expect(find.text(_safeLine), findsNothing);
    });
  });
}
