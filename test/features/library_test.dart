import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/ratel_app.dart';

Future<void> _toLibrary(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: RatelApp()));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Library'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows AI Tutor with the REAL PRO gate + a FREE Adventures badge',
      (WidgetTester tester) async {
    await _toLibrary(tester);
    expect(find.byKey(const ValueKey<String>('tab-library')), findsOneWidget);
    expect(find.text('AI Tutor'), findsOneWidget);
    // Free user (default billing entitlement) ⇒ PRO badge on the gated entry.
    expect(find.text('PRO'), findsWidgets);
    expect(find.text('FREE'), findsWidgets);
  });

  testWidgets('the media section is an honest no-engine stub',
      (WidgetTester tester) async {
    await _toLibrary(tester);
    final Finder stub = find.textContaining('media / audio engine');
    await tester.scrollUntilVisible(stub, 200,
        scrollable: find.byType(Scrollable).first);
    expect(stub, findsOneWidget);
  });

  testWidgets('Library top bar shows the 🔔 bell that opens the REAL inbox',
      (WidgetTester tester) async {
    await _toLibrary(tester);
    // The bell is wired on the Library top bar; a fresh account ⇒ no badge.
    expect(find.text('🔔'), findsOneWidget);
    await tester.tap(find.text('🔔'));
    await tester.pumpAndSettle();
    // Lands on the S54 in-app inbox — honest empty state, never faked.
    expect(find.text('No notifications yet'), findsOneWidget);
  });
}
