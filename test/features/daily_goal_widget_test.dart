import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';

/// Drives the real daily-goal UI through the one override seam the provider
/// gives us: meeting the goal must be ACKNOWLEDGED, not silently capped.
Future<void> _toQuests(WidgetTester tester, DailyGoalStatus goal) async {
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[dailyGoalProvider.overrideWithValue(goal)],
    child: const RatelApp(),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Quests'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Quests shows the REACH prompt when the goal is not met',
      (WidgetTester tester) async {
    await _toQuests(tester, const DailyGoalStatus(xpToday: 5, goal: 20));
    expect(find.text('Reach 20 XP today'), findsOneWidget);
    expect(find.text('Daily goal reached! 🎉'), findsNothing);
  });

  testWidgets('Quests acknowledges the goal honestly once it IS met',
      (WidgetTester tester) async {
    await _toQuests(tester, const DailyGoalStatus(xpToday: 30, goal: 20));
    expect(find.text('Daily goal reached! 🎉'), findsOneWidget);
    expect(find.text('Reach 20 XP today'), findsNothing);
  });
}
