import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/app/app_flags.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/auth/welcome_screen.dart';

Widget _host(Widget child) =>
    ProviderScope(child: MaterialApp(theme: RatelTheme.light(), home: child));

void main() {
  // --- Widget-level coverage: flag-independent, always runs (mirrors
  //     home_test.dart). No looping animation here, so pump() is sufficient. ---
  testWidgets('welcome renders brand + guest-first primary CTA (R-L1)',
      (tester) async {
    await tester.pumpWidget(_host(WelcomeScreen(onContinueAsGuest: () {})));
    await tester.pump();
    expect(find.byKey(const Key('welcome')), findsOneWidget);
    expect(find.text('Welcome to Ratel'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
    // Account path is a seam: hidden until onSignIn is provided (queue #4).
    expect(find.text('I already have an account'), findsNothing);
  });

  testWidgets('guest CTA fires onContinueAsGuest', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
        _host(WelcomeScreen(onContinueAsGuest: () => tapped = true)));
    await tester.pump();
    await tester.tap(find.text('Continue as guest'));
    expect(tapped, isTrue);
  });

  testWidgets('account affordance appears once onSignIn is wired', (tester) async {
    await tester.pumpWidget(
        _host(WelcomeScreen(onContinueAsGuest: () {}, onSignIn: () {})));
    await tester.pump();
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('renders without overflow at 360px width', (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_host(WelcomeScreen(onContinueAsGuest: () {})));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  // --- Router wiring: only meaningful behind authEnabled. Returns early (passes
  //     trivially) in the default CI run where RATEL_AUTH is unset, so `main`
  //     stays green; exercised with `flutter test --dart-define=RATEL_AUTH=true`. ---
  testWidgets('authEnabled: first launch shows Welcome, guest enters onboarding',
      (tester) async {
    if (!authEnabled) return; // default CI: flag off -> nothing to assert.
    onboardingComplete.value = false;
    welcomeSeen.value = false;
    addTearDown(() {
      welcomeSeen.value = false;
      onboardingComplete.value = false;
    });
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('welcome')), findsOneWidget);
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();
    expect(welcomeSeen.value, isTrue);
    expect(find.byKey(const Key('onboarding')), findsOneWidget);
  });
}
