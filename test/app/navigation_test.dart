import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/ratel_app.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: RatelApp()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('boots on the Home branch (others offstage)',
      (WidgetTester tester) async {
    await _pump(tester);
    expect(find.byKey(const ValueKey<String>('tab-home')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('tab-profile')), findsNothing);
  });

  testWidgets('tapping each tab switches the visible branch',
      (WidgetTester tester) async {
    await _pump(tester);
    const List<(String, String)> tabs = <(String, String)>[
      ('Library', 'tab-library'),
      ('Leagues', 'tab-leagues'),
      ('Quests', 'tab-quests'),
      ('Profile', 'tab-profile'),
      ('Home', 'tab-home'),
    ];
    for (final (String label, String key) in tabs) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey<String>(key)), findsOneWidget,
          reason: 'after tapping $label');
    }
  });
}
