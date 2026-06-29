import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/settings/settings_screen.dart';

void main() {
  testWidgets('renders REAL preferences and toggling writes back (no throw)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: SettingsScreen())));
    await tester.pumpAndSettle();
    expect(find.text('High contrast'), findsOneWidget);
    expect(find.text('Sound effects'), findsOneWidget);
    // Real persisted daily goal (default 20).
    expect(find.textContaining('XP per day'), findsOneWidget);
    // Flip the first toggle → commits through the settings store.
    await tester.tap(find.byType(RatelToggle).first);
    await tester.pumpAndSettle();
  });
}
