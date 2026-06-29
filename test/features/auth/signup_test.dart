import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/auth/signup_screen.dart';
import 'package:ratel/services/auth/auth.dart';
import 'package:ratel/services/identity/identity.dart';

import 'fake_auth.dart';
import 'fake_identity.dart';

Widget _host(Widget child, {AuthService? auth, Identity? id}) => ProviderScope(
      overrides: <Override>[
        if (auth != null) authServiceProvider.overrideWithValue(auth),
        if (id != null) identityProvider.overrideWithValue(id),
      ],
      child: MaterialApp(theme: RatelTheme.light(), home: child),
    );

void main() {
  testWidgets('renders the signup form by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(const SignupScreen(), auth: FakeAuth()));
    await tester.pump();
    expect(find.byKey(const Key('signup')), findsOneWidget);
    expect(find.byKey(const Key('signup-email')), findsOneWidget);
    expect(find.byKey(const Key('signup-password')), findsOneWidget);
    expect(find.text('Create account'), findsWidgets);
    expect(find.byKey(const Key('auth-unavailable')), findsNothing);
  });

  testWidgets('empty email blocks submit', (WidgetTester tester) async {
    final FakeAuth auth = FakeAuth();
    await tester.pumpWidget(_host(const SignupScreen(), auth: auth));
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);
    expect(auth.signUpCalls, 0);
  });

  testWidgets('a too-short password is rejected', (WidgetTester tester) async {
    final FakeAuth auth = FakeAuth();
    await tester.pumpWidget(_host(const SignupScreen(), auth: auth));
    await tester.enterText(
        find.byKey(const Key('signup-email')), 'sam@ratel.app');
    await tester.enterText(find.byKey(const Key('signup-password')), 'short');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    expect(find.text('At least 8 characters'), findsOneWidget);
    expect(auth.signUpCalls, 0);
  });

  testWidgets('valid signup with a session fires onAuthenticated',
      (WidgetTester tester) async {
    final FakeAuth auth = FakeAuth(outcome: AuthOutcome.session);
    bool authed = false;
    await tester.pumpWidget(_host(
        SignupScreen(onAuthenticated: () => authed = true),
        auth: auth,
        id: FakeIdentity()));
    await tester.enterText(
        find.byKey(const Key('signup-email')), 'sam@ratel.app');
    await tester.enterText(
        find.byKey(const Key('signup-password')), 'longenough1');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    await tester.pump();
    expect(auth.signUpCalls, 1);
    expect(auth.lastEmail, 'sam@ratel.app');
    expect(authed, isTrue);
  });

  testWidgets('email-confirmation signup shows the "confirm your email" notice',
      (WidgetTester tester) async {
    final FakeAuth auth = FakeAuth(outcome: AuthOutcome.emailSent);
    await tester.pumpWidget(
        _host(const SignupScreen(), auth: auth, id: FakeIdentity()));
    await tester.enterText(
        find.byKey(const Key('signup-email')), 'sam@ratel.app');
    await tester.enterText(
        find.byKey(const Key('signup-password')), 'longenough1');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    await tester.pump();
    expect(auth.signUpCalls, 1);
    expect(find.byKey(const Key('signup-sent')), findsOneWidget);
    expect(find.text('Confirm your email'), findsOneWidget);
  });

  testWidgets('a rejected signup surfaces the failure message',
      (WidgetTester tester) async {
    final FakeAuth auth =
        FakeAuth(error: const AuthFailure('Email already registered'));
    await tester.pumpWidget(
        _host(const SignupScreen(), auth: auth, id: FakeIdentity()));
    await tester.enterText(
        find.byKey(const Key('signup-email')), 'sam@ratel.app');
    await tester.enterText(
        find.byKey(const Key('signup-password')), 'longenough1');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('signup-error')), findsOneWidget);
    expect(find.text('Email already registered'), findsOneWidget);
  });

  testWidgets('TS-11: a real session mints + claims the anonymous state',
      (WidgetTester tester) async {
    final FakeAuth auth = FakeAuth(outcome: AuthOutcome.session);
    final FakeIdentity id = FakeIdentity(mintToken: 'srv_signup_merge');
    await tester.pumpWidget(
        _host(SignupScreen(onAuthenticated: () {}), auth: auth, id: id));
    await tester.enterText(
        find.byKey(const Key('signup-email')), 'sam@ratel.app');
    await tester.enterText(
        find.byKey(const Key('signup-password')), 'longenough1');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    await tester.pump();
    expect(id.mintCalls, 1);
    expect(id.claimed, isNotNull);
    expect(id.claimed!.value, 'srv_signup_merge');
  });

  testWidgets('honest: an unconfigured backend shows the banner and fail-closes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 1500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    bool authed = false;
    await tester.pumpWidget(_host(
        SignupScreen(onAuthenticated: () => authed = true),
        auth: const UnconfiguredAuthService(),
        id: const AnonymousIdentity()));
    await tester.pump();
    expect(find.byKey(const Key('auth-unavailable')), findsOneWidget);
    await tester.enterText(
        find.byKey(const Key('signup-email')), 'sam@ratel.app');
    await tester.enterText(
        find.byKey(const Key('signup-password')), 'longenough1');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('signup-error')), findsOneWidget);
    expect(authed, isFalse);
  });

  testWidgets('renders without overflow at 360px width',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_host(const SignupScreen(), auth: FakeAuth()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
