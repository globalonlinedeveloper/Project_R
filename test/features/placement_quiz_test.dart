import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel;
import 'package:ratel/core/core.dart';
import 'package:ratel/features/onboarding/placement_quiz_screen.dart';

// Covers R-G4 (CAT placement test) + R-G7 (cold-start): the real adaptive
// quiz seeds the learner θ/level through the IRT / CAT / EAP engine.

GoRouter _router() {
  return GoRouter(
    initialLocation: '/placement',
    routes: <RouteBase>[
      GoRoute(
        path: '/placement',
        builder: (BuildContext context, GoRouterState state) =>
            const PlacementQuizScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Center(child: Text('HOME-SINK'))),
      ),
    ],
  );
}

void main() {
  test('seedFromPlacement seeds θ + re-derives CEFR level; reset restores A1',
      () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final LearnerController notifier =
        container.read(learnerControllerProvider.notifier);

    // Brand-new learner cold-starts at A1.
    expect(container.read(learnerControllerProvider).level, CefrLevel.a1);

    // Seed a C1-anchor placement θ.
    notifier.seedFromPlacement(1.5);
    final LearnerSnapshot placed = container.read(learnerControllerProvider);
    expect(placed.theta, 1.5);
    expect(placed.level, CefrLevel.c1);

    // Reset clears the placement → back to A1.
    notifier.reset();
    expect(container.read(learnerControllerProvider).level, CefrLevel.a1);
  });

  testWidgets('runs the adaptive quiz to completion and seeds the learner',
      (WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: _router()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Placement test'), findsOneWidget);
    expect(find.text('Question 1'), findsOneWidget);

    // Answer the first (correct) option until the result screen appears.
    for (int i = 0;
        i < 14 && find.text('Your starting point').evaluate().isEmpty;
        i++) {
      await tester.tap(find.byType(RatelOptionCard).first);
      await tester.pumpAndSettle();
    }

    expect(find.text('Your starting point'), findsOneWidget);
    // All-correct answers push θ above the neutral start → learner was seeded.
    expect(container.read(learnerControllerProvider).theta, greaterThan(0.0));

    await tester.tap(find.text('Start learning'));
    await tester.pumpAndSettle();
    expect(find.text('HOME-SINK'), findsOneWidget);
  });
}
