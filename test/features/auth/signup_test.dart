import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/app/app_flags.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/auth/auth_service.dart';
import 'package:ratel/features/auth/signup_screen.dart';

import 'fake_auth.dart';

Widget _host(Widget child, AuthService auth) => ProviderScope(
      overrides: [authServiceProvider.overrideWithValue(auth)],
      child: MaterialApp(theme: RatelTheme.light(), home: child),
    );

void main() {
  testWidgets('renders the password sign-up form by default', (tester) async {
    await tester.pumpWidget(_host(const SignupScreen(), FakeAuth()));
    await tester.pump();
    expect(find.byKey(const Key('signup')), findsOneWidget);
    expect(find.byKey(const Key('signup-email')), findsOneWidget);
    expect(find.byKey(const Key('signup-password')), findsOneWidget);
    expect(find.text('Create account'), findsWidgets);
  });

  testWidgets('empty email blocks submit with a validation message',
      (tester) async {
    final auth = FakeAuth();
    await tester.pumpWidget(_host(const SignupScreen(), auth));
    await tester.pump();
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);
    expect(auth.signUpCalls, 0);
  });

  testWidgets('invalid email is rejected before any service call',
      (tester) async {
    final auth = FakeAuth();
    await tester.pumpWidget(_host(const SignupScreen(), auth));
    await tester.enterText(find.byKey(const Key('signup-email')), 'not-an-email');
    await tester.enterText(find.byKey(const Key('signup-password')), 'longenough');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(auth.signUpCalls, 0);
  });

  testWidgets('short password is rejected', (tester) async {
    final auth = FakeAuth();
    await tester.pumpWidget(_host(const SignupScreen(), auth));
    await tester.enterText(find.byKey(const Key('signup-email')), 'a@b.co');
    await tester.enterText(find.byKey(const Key('signup-password')), 'short');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    expect(find.text('At least 8 characters'), findsOneWidget);
    expect(auth.signUpCalls, 0);
  });

  testWidgets('valid password sign-up with a live session fires onAuthenticated',
      (tester) async {
    final auth = FakeAuth(outcome: AuthOutcome.session);
    var authed = false;
    await tester.pumpWidget(
        _host(SignupScreen(onAuthenticated: () => authed = true), auth));
    await tester.enterText(find.byKey(const Key('signup-email')), 'sam@ratel.app');
    await tester.enterText(find.byKey(const Key('signup-password')), 'supersecret');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    await tester.pump();
    expect(auth.signUpCalls, 1);
    expect(auth.lastEmail, 'sam@ratel.app');
    expect(auth.lastPassword, 'supersecret');
    expect(authed, isTrue);
  });

  testWidgets('password sign-up needing confirmation shows the inbox notice',
      (tester) async {
    final auth = FakeAuth(outcome: AuthOutcome.emailSent);
    await tester.pumpWidget(_host(const SignupScreen(), auth));
    await tester.enterText(find.byKey(const Key('signup-email')), 'sam@ratel.app');
    await tester.enterText(find.byKey(const Key('signup-password')), 'supersecret');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('signup-sent')), findsOneWidget);
    expect(find.text('Confirm your email'), findsOneWidget);
  });

  testWidgets('magic-link mode hides the password field and sends a link',
      (tester) async {
    final auth = FakeAuth(outcome: AuthOutcome.emailSent);
    await tester.pumpWidget(_host(const SignupScreen(), auth));
    await tester.tap(find.byKey(const Key('signup-mode-toggle')));
    await tester.pump();
    expect(find.byKey(const Key('signup-password')), findsNothing);
    await tester.enterText(find.byKey(const Key('signup-email')), 'sam@ratel.app');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    await tester.pump();
    expect(auth.magicCalls, 1);
    expect(auth.signUpCalls, 0);
    expect(find.byKey(const Key('signup-sent')), findsOneWidget);
    expect(find.text('Check your inbox'), findsOneWidget);
  });

  testWidgets('a rejected sign-up surfaces the failure message', (tester) async {
    final auth = FakeAuth(error: const AuthFailure('Email already registered'));
    await tester.pumpWidget(_host(const SignupScreen(), auth));
    await tester.enterText(find.byKey(const Key('signup-email')), 'sam@ratel.app');
    await tester.enterText(find.byKey(const Key('signup-password')), 'supersecret');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('signup-error')), findsOneWidget);
    expect(find.text('Email already registered'), findsOneWidget);
  });

  testWidgets('an unexpected error shows a generic message', (tester) async {
    final auth = FakeAuth(error: Exception('network down'));
    await tester.pumpWidget(_host(const SignupScreen(), auth));
    await tester.enterText(find.byKey(const Key('signup-email')), 'sam@ratel.app');
    await tester.enterText(find.byKey(const Key('signup-password')), 'supersecret');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    await tester.pump();
    expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
  });

  testWidgets('renders without overflow at 360px width', (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_host(const SignupScreen(), FakeAuth()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  // Router wiring: only meaningful behind authEnabled. Passes trivially in the
  // default CI run (RATEL_AUTH unset); exercised with --dart-define=RATEL_AUTH=true.
  testWidgets('authEnabled: Welcome -> Create an account -> Sign-up screen',
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
    expect(find.byKey(const Key('welcome')), findsOneWidget);
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('signup')), findsOneWidget);
  });
}
