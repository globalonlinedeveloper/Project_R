import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/auth/login_screen.dart';
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
  testWidgets('renders the login form by default (no unavailable banner)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(const LoginScreen(), auth: FakeAuth()));
    await tester.pump();
    expect(find.byKey(const Key('login')), findsOneWidget);
    expect(find.byKey(const Key('login-email')), findsOneWidget);
    expect(find.byKey(const Key('login-password')), findsOneWidget);
    expect(find.text('Log in'), findsWidgets);
    expect(find.byKey(const Key('auth-unavailable')), findsNothing);
  });

  testWidgets('empty email blocks submit with a validation message',
      (WidgetTester tester) async {
    final FakeAuth auth = FakeAuth();
    await tester.pumpWidget(_host(const LoginScreen(), auth: auth));
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);
    expect(auth.signInCalls, 0);
  });

  testWidgets('empty password is rejected', (WidgetTester tester) async {
    final FakeAuth auth = FakeAuth();
    await tester.pumpWidget(_host(const LoginScreen(), auth: auth));
    await tester.enterText(
        find.byKey(const Key('login-email')), 'sam@ratel.app');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    expect(find.text('Enter your password'), findsOneWidget);
    expect(auth.signInCalls, 0);
  });

  testWidgets('valid password login with a session fires onAuthenticated',
      (WidgetTester tester) async {
    final FakeAuth auth = FakeAuth(outcome: AuthOutcome.session);
    bool authed = false;
    await tester.pumpWidget(_host(
        LoginScreen(onAuthenticated: () => authed = true),
        auth: auth,
        id: FakeIdentity()));
    await tester.enterText(
        find.byKey(const Key('login-email')), 'sam@ratel.app');
    await tester.enterText(
        find.byKey(const Key('login-password')), 'pw-correct');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    await tester.pump();
    expect(auth.signInCalls, 1);
    expect(auth.lastEmail, 'sam@ratel.app');
    expect(auth.lastPassword, 'pw-correct');
    expect(authed, isTrue);
  });

  testWidgets('bad credentials surface the failure message',
      (WidgetTester tester) async {
    final FakeAuth auth =
        FakeAuth(error: const AuthFailure('Invalid login credentials'));
    await tester.pumpWidget(
        _host(const LoginScreen(), auth: auth, id: FakeIdentity()));
    await tester.enterText(
        find.byKey(const Key('login-email')), 'sam@ratel.app');
    await tester.enterText(find.byKey(const Key('login-password')), 'nope');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('login-error')), findsOneWidget);
    expect(find.text('Invalid login credentials'), findsOneWidget);
  });

  testWidgets('forgot password switches to reset mode and sends a reset link',
      (WidgetTester tester) async {
    final FakeAuth auth = FakeAuth();
    await tester.pumpWidget(_host(const LoginScreen(), auth: auth));
    await tester.enterText(
        find.byKey(const Key('login-email')), 'sam@ratel.app');
    await tester.tap(find.byKey(const Key('login-forgot')));
    await tester.pump();
    expect(find.byKey(const Key('login-password')), findsNothing);
    expect(find.text('Send reset link'), findsWidgets);
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    await tester.pump();
    expect(auth.resetCalls, 1);
    expect(auth.lastEmail, 'sam@ratel.app');
    expect(find.byKey(const Key('login-sent')), findsOneWidget);
  });

  testWidgets('TS-11: a real session mints + claims the anonymous state',
      (WidgetTester tester) async {
    final FakeAuth auth = FakeAuth(outcome: AuthOutcome.session);
    final FakeIdentity id = FakeIdentity(mintToken: 'srv_login_merge');
    await tester.pumpWidget(
        _host(LoginScreen(onAuthenticated: () {}), auth: auth, id: id));
    await tester.enterText(
        find.byKey(const Key('login-email')), 'sam@ratel.app');
    await tester.enterText(
        find.byKey(const Key('login-password')), 'pw-correct');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    await tester.pump();
    expect(id.mintCalls, 1);
    expect(id.claimed, isNotNull);
    expect(id.claimed!.value, 'srv_login_merge');
  });

  testWidgets('honest: an unconfigured backend shows the banner and fail-closes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 1500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    bool authed = false;
    await tester.pumpWidget(_host(
        LoginScreen(onAuthenticated: () => authed = true),
        auth: const UnconfiguredAuthService(),
        id: const AnonymousIdentity()));
    await tester.pump();
    expect(find.byKey(const Key('auth-unavailable')), findsOneWidget);
    await tester.enterText(
        find.byKey(const Key('login-email')), 'sam@ratel.app');
    await tester.enterText(
        find.byKey(const Key('login-password')), 'whatever1');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('login-error')), findsOneWidget);
    expect(authed, isFalse);
  });

  testWidgets('social sign-in is an honest no-op (never a fake session)',
      (WidgetTester tester) async {
    bool authed = false;
    await tester.pumpWidget(_host(
        LoginScreen(onAuthenticated: () => authed = true),
        auth: FakeAuth()));
    await tester.tap(find.byKey(const Key('auth-google')));
    await tester.pump();
    expect(find.textContaining('coming soon'), findsOneWidget);
    expect(authed, isFalse);
  });

  testWidgets('renders without overflow at 360px width',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_host(const LoginScreen(), auth: FakeAuth()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
