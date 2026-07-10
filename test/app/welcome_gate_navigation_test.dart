import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/auth_gate.dart';
import 'package:ratel/app/ratel_app.dart';

// AUTH-1 (S112): router-level Welcome gate. The gate provider defaults OFF, so
// the pre-existing navigation tests prove the byte-identical no-gate boot;
// these tests flip it ON explicitly (§11 preconditions) and walk each exit.

Future<void> _pump(WidgetTester tester,
    {List<Override> overrides = const <Override>[]}) async {
  await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const RatelApp()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('gate ON: boot redirects to Welcome (home withheld)',
      (WidgetTester tester) async {
    await _pump(tester, overrides: <Override>[
      welcomeGateNeededProvider.overrideWith((ref) => true),
    ]);
    expect(find.byKey(const Key('welcome')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('tab-home')), findsNothing);
  });

  testWidgets('gate ON: account entry stays reachable (Log in renders)',
      (WidgetTester tester) async {
    await _pump(tester, overrides: <Override>[
      welcomeGateNeededProvider.overrideWith((ref) => true),
    ]);
    await tester.tap(find.byKey(const Key('welcome-login')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login')), findsOneWidget);
  });

  testWidgets('gate ON: Continue as guest enters Home and drops the gate',
      (WidgetTester tester) async {
    await _pump(tester, overrides: <Override>[
      welcomeGateNeededProvider.overrideWith((ref) => true),
    ]);
    await tester.tap(find.byKey(const Key('welcome-guest')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('tab-home')), findsOneWidget);
    expect(find.byKey(const Key('welcome')), findsNothing);
  });

  testWidgets('gate OFF (default): boots straight to Home with no Welcome',
      (WidgetTester tester) async {
    await _pump(tester);
    expect(find.byKey(const ValueKey<String>('tab-home')), findsOneWidget);
    expect(find.byKey(const Key('welcome')), findsNothing);
  });
}
