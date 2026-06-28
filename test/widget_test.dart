import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/ratel_app.dart';

/// Boot smoke — the app builds and lands on the Home tab inside the 5-tab shell.
void main() {
  testWidgets('app boots to the Home tab with the 5-tab shell',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('tab-home')), findsOneWidget);
    expect(find.text('Library'), findsOneWidget); // bottom-nav label
    expect(find.text('Profile'), findsOneWidget); // bottom-nav label
  });
}
