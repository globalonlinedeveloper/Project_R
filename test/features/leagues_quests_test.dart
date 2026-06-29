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
  testWidgets('Leagues is an honest no-engine stub (no fake leaderboard)',
      (WidgetTester tester) async {
    await _toTab(tester, 'Leagues');
    expect(find.byKey(const ValueKey<String>('tab-leagues')), findsOneWidget);
    expect(find.text('Leagues are coming'), findsOneWidget);
    expect(find.text('Owner decision'), findsOneWidget);
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
