import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/settings/settings_screen.dart';
import 'package:ratel/services/auth/auth.dart';
import 'package:ratel/services/identity/identity.dart';

import '../auth/fake_auth.dart';
import '../auth/fake_identity.dart';

// INC-SET1: the authed log-out row now opens a confirm sheet and calls the REAL
// AuthService.signOut() (previously it just pushed /onboarding, never signing
// out). Guest keeps the direct push. Zero new ARB strings.

Future<void> _pump(WidgetTester tester, FakeAuth auth,
    {required bool authed}) async {
  tester.view.physicalSize = const Size(800, 4200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final GoRouter router = GoRouter(
    initialLocation: '/settings',
    routes: <RouteBase>[
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(
          path: '/onboarding',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('onboarding-screen')))),
    ],
  );
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[
      authServiceProvider.overrideWithValue(auth),
      if (authed) identityProvider.overrideWithValue(FakeIdentity()),
    ],
    child: MaterialApp.router(theme: RatelTheme.light(), routerConfig: router),
  ));
  await tester.pumpAndSettle();
}

Future<void> _tapAccountRow(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey<String>('settings-account-row')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('authed log-out shows a confirm sheet; Cancel does NOT sign out',
      (WidgetTester tester) async {
    final FakeAuth auth = FakeAuth();
    await _pump(tester, auth, authed: true);
    await _tapAccountRow(tester);
    expect(find.byKey(const ValueKey<String>('settings-logout-sheet')),
        findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('settings-logout-cancel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('settings-logout-sheet')),
        findsNothing);
    expect(auth.signOutCalls, 0);
    expect(find.text('onboarding-screen'), findsNothing);
  });

  testWidgets('confirming log-out signs out and routes to onboarding',
      (WidgetTester tester) async {
    final FakeAuth auth = FakeAuth();
    await _pump(tester, auth, authed: true);
    await _tapAccountRow(tester);
    await tester
        .tap(find.byKey(const ValueKey<String>('settings-logout-confirm')));
    await tester.pumpAndSettle();
    expect(auth.signOutCalls, 1);
    expect(find.text('onboarding-screen'), findsOneWidget);
  });

  testWidgets('guest account row pushes onboarding directly (no sheet)',
      (WidgetTester tester) async {
    final FakeAuth auth = FakeAuth();
    await _pump(tester, auth, authed: false);
    await _tapAccountRow(tester);
    expect(find.byKey(const ValueKey<String>('settings-logout-sheet')),
        findsNothing);
    expect(find.text('onboarding-screen'), findsOneWidget);
    expect(auth.signOutCalls, 0);
  });
}
