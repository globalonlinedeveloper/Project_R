import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/core.dart';
import 'package:go_router/go_router.dart';
import 'package:ratel/features/onboarding/onboarding_screen.dart';

// Covers R-L2 (onboarding flow), R-G7 (brand-new cold-start), R-G4
// (placement-test entry), R-I7 (daily goal).

GoRouter _testRouter() {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: <RouteBase>[
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Center(child: Text('HOME-SINK'))),
      ),
      GoRoute(
        path: '/placement',
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Center(child: Text('PLACEMENT-SINK'))),
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Center(child: Text('LOGIN-SINK'))),
      ),
    ],
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp.router(routerConfig: _testRouter()),
  ));
  await tester.pumpAndSettle();
}

Future<void> _toPlacement(WidgetTester tester) async {
  await tester.tap(find.text('Get started')); // Welcome
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue')); // Language
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue')); // Reason
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue')); // Goal
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('walks Welcome → Language → Reason → Goal → Placement and lands '
      'home on "brand new"', (WidgetTester tester) async {
    await _pump(tester);

    // Welcome
    expect(find.text("Hi, I'm Ratel!"), findsOneWidget);
    expect(find.text('Try without an account →'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    // Language (English selected by default — single English course, S144)
    expect(find.text('What do you want to learn?'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Reason
    expect(find.text('Why are you learning?'), findsOneWidget);
    await tester.tap(find.text('Career'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Goal
    expect(find.text('Pick a daily goal'), findsOneWidget);
    await tester.tap(find.text('Serious'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Placement — choose "brand new" then finish → home
    expect(find.text('Find your starting point'), findsOneWidget);
    await tester.tap(find.text("I'm brand new"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start learning'));
    await tester.pumpAndSettle();

    expect(find.text('HOME-SINK'), findsOneWidget);
  });

  testWidgets('the placement-test branch routes to the adaptive quiz',
      (WidgetTester tester) async {
    await _pump(tester);
    await _toPlacement(tester);

    // Default selection is "Take a placement test".
    expect(find.text('Find your starting point'), findsOneWidget);
    await tester.tap(find.text('Start learning'));
    await tester.pumpAndSettle();

    expect(find.text('PLACEMENT-SINK'), findsOneWidget);
  });

  testWidgets('the back chevron returns to the previous step',
      (WidgetTester tester) async {
    await _pump(tester);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('What do you want to learn?'), findsOneWidget);

    await tester.tap(find.byIcon(RatelIcons.arrowBack));
    await tester.pumpAndSettle();
    expect(find.text("Hi, I'm Ratel!"), findsOneWidget);
  });
}
