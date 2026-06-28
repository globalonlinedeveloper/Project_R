import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/ratel_app.dart';

void main() {
  testWidgets('Home renders the path with node 0 active (real lessonsCompleted=0)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('tab-home')), findsOneWidget);
    // active=0 ⇒ the first unit is current and node 0 carries the START bubble.
    expect(find.textContaining('Greetings'), findsWidgets);
    expect(find.text('START'), findsOneWidget);
  });

  testWidgets('tapping the active node opens the lesson-preview sheet (§4.6)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('home-active-node')));
    await tester.pumpAndSettle();
    expect(find.text('Hello & goodbye'), findsOneWidget); // first lesson title
    expect(find.text('Start lesson'), findsOneWidget);
  });
}
