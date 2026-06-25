import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/app/app_flags.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/auth/auth_service.dart';
import 'package:ratel/features/profile/profile_screen.dart';

import '../auth/fake_auth.dart';

Widget _host(AuthService auth) => ProviderScope(
      overrides: [authServiceProvider.overrideWithValue(auth)],
      child: MaterialApp(theme: RatelTheme.light(), home: const ProfileScreen()),
    );

void main() {
  tearDown(() {
    signedIn.value = false;
    welcomeSeen.value = false;
  });

  testWidgets('profile renders its header (flag-independent)', (tester) async {
    await tester.pumpWidget(_host(FakeAuth()));
    await tester.pump();
    expect(find.byKey(const Key('profile-screen')), findsOneWidget);
    expect(find.text('Your profile'), findsOneWidget);
  });

  // The Account section is gated by authEnabled, so these run only flag-on
  // (--dart-define=RATEL_AUTH=true); they pass trivially in the default CI run.
  testWidgets('authEnabled: guest sees create-account + log-in, no log-out',
      (tester) async {
    if (!authEnabled) return;
    signedIn.value = false;
    await tester.pumpWidget(_host(FakeAuth()));
    await tester.pump();
    expect(find.byKey(const Key('profile-account')), findsOneWidget);
    expect(find.byKey(const Key('profile-create-account')), findsOneWidget);
    expect(find.byKey(const Key('profile-login')), findsOneWidget);
    expect(find.byKey(const Key('profile-logout')), findsNothing);
  });

  testWidgets('authEnabled: a signed-in user sees log-out', (tester) async {
    if (!authEnabled) return;
    signedIn.value = true;
    await tester.pumpWidget(_host(FakeAuth()));
    await tester.pump();
    expect(find.byKey(const Key('profile-logout')), findsOneWidget);
    expect(find.byKey(const Key('profile-create-account')), findsNothing);
  });

  testWidgets('authEnabled: log-out is double-confirmed and signs out',
      (tester) async {
    if (!authEnabled) return;
    final auth = FakeAuth();
    signedIn.value = true;
    await tester.pumpWidget(_host(auth));
    await tester.pump();
    await tester.tap(find.byKey(const Key('profile-logout')));
    await tester.pumpAndSettle(); // dialog animates in (finite)
    expect(find.text('Log out?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('profile-logout-confirm')));
    await tester.pump();
    await tester.pump();
    expect(auth.signOutCalls, 1);
    expect(signedIn.value, isFalse);
  });

  testWidgets('authEnabled: cancelling the dialog does not sign out',
      (tester) async {
    if (!authEnabled) return;
    final auth = FakeAuth();
    signedIn.value = true;
    await tester.pumpWidget(_host(auth));
    await tester.pump();
    await tester.tap(find.byKey(const Key('profile-logout')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(auth.signOutCalls, 0);
    expect(signedIn.value, isTrue);
  });
}
