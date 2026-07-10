import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';

Future<void> _toTab(WidgetTester tester, String label) async {
  await tester.pumpWidget(const ProviderScope(child: RatelApp()));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Leagues shows the REAL solo cohort (no fabricated rivals)',
      (WidgetTester tester) async {
    await _toTab(tester, 'Leagues');
    expect(find.byKey(const ValueKey<String>('tab-leagues')), findsOneWidget);
    // A fresh learner: entry tier (Bronze) + an honest cohort of one.
    expect(find.text('Bronze League'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.textContaining('only learner in your group'), findsOneWidget);
    // Honesty: the design mock's fabricated rivals never appear, and the old
    // no-engine stub copy is gone.
    expect(find.text('Sofía M.'), findsNothing);
    expect(find.text('Kenji T.'), findsNothing);
    expect(find.text('Leagues are coming'), findsNothing);
  });

  testWidgets('Leagues ladder sheet lists all ten tiers',
      (WidgetTester tester) async {
    await _toTab(tester, 'Leagues');
    await tester.tap(find.text('🏆 View all 10 tiers ›'));
    await tester.pumpAndSettle();
    expect(find.text('League tiers'), findsOneWidget);
    expect(find.text('Diamond League'), findsOneWidget);
    // Bronze shows in the header card AND as a ladder row → at least one.
    expect(find.text('Bronze League'), findsWidgets);
  });

  testWidgets('Quests surfaces the REAL daily-goal progress',
      (WidgetTester tester) async {
    await _toTab(tester, 'Quests');
    expect(find.byKey(const ValueKey<String>('tab-quests')), findsOneWidget);
    // Real engine state: today's XP toward the persisted daily goal.
    expect(find.textContaining('XP today'), findsWidgets);
  });

  testWidgets('Leagues top bar shows the 🔔 bell that opens the REAL inbox',
      (WidgetTester tester) async {
    await _toTab(tester, 'Leagues');
    expect(find.byIcon(RatelIcons.notifications), findsOneWidget);
    await tester.tap(find.byIcon(RatelIcons.notifications));
    await tester.pumpAndSettle();
    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('Quests top bar shows the 🔔 bell that opens the REAL inbox',
      (WidgetTester tester) async {
    await _toTab(tester, 'Quests');
    expect(find.byIcon(RatelIcons.notifications), findsOneWidget);
    await tester.tap(find.byIcon(RatelIcons.notifications));
    await tester.pumpAndSettle();
    expect(find.text('No notifications yet'), findsOneWidget);
  });
}
