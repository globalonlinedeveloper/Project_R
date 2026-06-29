import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/ratel_app.dart';

Future<void> _toProfile(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: RatelApp()));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Profile'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('surfaces the REAL guest snapshot (cold-start A1, zero counters)',
      (WidgetTester tester) async {
    await _toProfile(tester);
    expect(find.byKey(const ValueKey<String>('tab-profile')), findsOneWidget);
    // Honest identity: a fresh install is a guest, NOT the mockup's "Alex Rivera".
    expect(find.text('Guest'), findsOneWidget);
    // Real cold-start CEFR level pill (A1, not the mockup's A2).
    expect(find.text('A1'), findsWidgets);
    // Real engine-derived stat labels.
    expect(find.text('Day streak'), findsOneWidget);
    expect(find.text('Saved words'), findsOneWidget);
  });

  testWidgets('a no-engine destination opens an honest "coming soon" stub',
      (WidgetTester tester) async {
    await _toProfile(tester);
    // The Shop row is below the fold in a lazy ListView — scroll it into view
    // before tapping (the finder cannot see unbuilt children).
    final Finder shop = find.text('Shop');
    await tester.scrollUntilVisible(shop, 150,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(shop);
    await tester.pumpAndSettle();
    expect(find.text('Coming soon'), findsOneWidget);
  });

  testWidgets('the achievements grid is REAL — a fresh account is all-locked with honest progress',
      (WidgetTester tester) async {
    await _toProfile(tester);
    final Finder firstSteps =
        find.byKey(const ValueKey<String>('achievement-first_steps'));
    await tester.scrollUntilVisible(firstSteps, 150,
        scrollable: find.byType(Scrollable).first);
    expect(firstSteps, findsOneWidget);
    expect(find.text('First Steps'), findsOneWidget);
    // Nothing fabricated as earned on a brand-new account.
    expect(find.text('Unlocked'), findsNothing);
    expect(find.text('0/1'), findsWidgets); // First Steps needs 1 lesson
  });
}
