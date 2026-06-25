import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/app/app_flags.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/auth/auth_service.dart';
import 'package:ratel/features/auth/login_screen.dart';

import 'fake_auth.dart';

Widget _host(Widget child, AuthService auth) => ProviderScope(
      overrides: [authServiceProvider.overrideWithValue(auth)],
      child: MaterialApp(theme: RatelTheme.light(), home: child),
    );

void main() {
  testWidgets('renders the password login form by default', (tester) async {
    await tester.pumpWidget(_host(const LoginScreen(), FakeAuth()));
    await tester.pump();
    expect(find.byKey(const Key('login')), findsOneWidget);
    expect(find.byKey(const Key('login-email')), findsOneWidget);
    expect(find.byKey(const Key('login-password')), findsOneWidget);
    expect(find.text('Log in'), findsWidgets);
  });

  testWidgets('empty email blocks submit with a validation message',
      (tester) async {
    final auth = FakeAuth();
    await tester.pumpWidget(_host(const LoginScreen(), auth));
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);
    expect(auth.signInCalls, 0);
  });

  testWidgets('empty password is rejected', (tester) async {
    final auth = FakeAuth();
    await tester.pumpWidget(_host(const LoginScreen(), auth));
    await tester.enterText(find.byKey(const Key('login-email')), 'sam@ratel.app');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    expect(find.text('Enter your password'), findsOneWidget);
    expect(auth.signInCalls, 0);
  });

  testWidgets('valid password login with a session fires onAuthenticated',
      (tester) async {
    final auth = FakeAuth(outcome: AuthOutcome.session);
    var authed = false;
    await tester.pumpWidget(
        _host(LoginScreen(onAuthenticated: () => authed = true), auth));
    await tester.enterText(find.byKey(const Key('login-email')), 'sam@ratel.app');
    await tester.enterText(find.byKey(const Key('login-password')), 'pw-correct');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    await tester.pump();
    expect(auth.signInCalls, 1);
    expect(auth.lastEmail, 'sam@ratel.app');
    expect(auth.lastPassword, 'pw-correct');
    expect(authed, isTrue);
  });

  testWidgets('bad credentials surface the failure message', (tester) async {
    final auth = FakeAuth(error: const AuthFailure('Invalid login credentials'));
    await tester.pumpWidget(_host(const LoginScreen(), auth));
    await tester.enterText(find.byKey(const Key('login-email')), 'sam@ratel.app');
    await tester.enterText(find.byKey(const Key('login-password')), 'nope');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('login-error')), findsOneWidget);
    expect(find.text('Invalid login credentials'), findsOneWidget);
  });

  testWidgets('magic-link mode hides the password field and sends a link',
      (tester) async {
    final auth = FakeAuth();
    await tester.pumpWidget(_host(const LoginScreen(), auth));
    await tester.tap(find.byKey(const Key('login-mode-toggle')));
    await tester.pump();
    expect(find.byKey(const Key('login-password')), findsNothing);
    await tester.enterText(find.byKey(const Key('login-email')), 'sam@ratel.app');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();
    await tester.pump();
    expect(auth.magicCalls, 1);
    expect(auth.signInCalls, 0);
    expect(find.byKey(const Key('login-sent')), findsOneWidget);
  });

  testWidgets('forgot-password sends a reset link', (tester) async {
    final auth = FakeAuth();
    await tester.pumpWidget(_host(const LoginScreen(), auth));
    await tester.enterText(find.byKey(const Key('login-email')), 'sam@ratel.app');
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
    expect(find.textContaining('password-reset link'), findsOneWidget);
  });

  testWidgets('renders without overflow at 360px width', (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_host(const LoginScreen(), FakeAuth()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  // Router wiring: only meaningful behind authEnabled. Passes trivially in the
  // default CI run (RATEL_AUTH unset); exercised with --dart-define=RATEL_AUTH=true.
  testWidgets('authEnabled: Welcome -> Log in -> Sign up cross-links',
      (tester) async {
    if (!authEnabled) return;
    onboardingComplete.value = false;
    welcomeSeen.value = false;
    addTearDown(() {
      welcomeSeen.value = false;
      onboardingComplete.value = false;
    });
    await tester.pumpWidget(ProviderScope(
      overrides: [authServiceProvider.overrideWithValue(FakeAuth())],
      child: const RatelApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login')), findsOneWidget);
    await tester.tap(find.byKey(const Key('login-signup-instead')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('signup')), findsOneWidget);
  });

  testWidgets('authEnabled: a restored session skips Welcome (route guard)',
      (tester) async {
    if (!authEnabled) return;
    onboardingComplete.value = false;
    welcomeSeen.value = false;
    signedIn.value = true; // a session restored at launch
    addTearDown(() {
      signedIn.value = false;
      welcomeSeen.value = false;
      onboardingComplete.value = false;
    });
    await tester.pumpWidget(ProviderScope(
      overrides: [authServiceProvider.overrideWithValue(FakeAuth())],
      child: const RatelApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('welcome')), findsNothing);
    expect(find.byKey(const Key('onboarding')), findsOneWidget);
  });
}
