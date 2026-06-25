import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/app/app_flags.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/identity/supabase_identity.dart';

void main() {
  setUp(() {
    welcomeSeen.value = true; // flag-robust: skip the auth Welcome gate
    onboardingComplete.value = false;
  });
  tearDown(() {
    welcomeSeen.value = false;
    onboardingComplete.value = false;
  });

  testWidgets('first launch redirects to onboarding (R-L2)', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('onboarding')), findsOneWidget);
  });

  testWidgets('onboarding reaches a first win off the loader and enters the app',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();

    // Step 0: language (English default) -> Continue
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 1: motivation
    await tester.tap(find.text('Travel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 2: goal
    await tester.tap(find.text('Regular - 10 min'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 3: first win — the correct answer ("eat") comes off the seed batch.
    expect(find.text('Your first win!'), findsOneWidget);
    await tester.tap(find.text('eat'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(onboardingComplete.value, isTrue);
    expect(find.byKey(const Key('home-screen')), findsOneWidget);
  });

  // Placement wiring (#9): only meaningful behind authEnabled. Trivially passes
  // in the default CI run (RATEL_AUTH unset); exercised with RATEL_AUTH=true.
  testWidgets(
      'authEnabled: completing onboarding persists placement θ under auth.uid()',
      (tester) async {
    if (!authEnabled) return;
    final store = InMemoryLearnerStateStore();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        identityProvider
            .overrideWithValue(SupabaseIdentity(currentUserId: () => 'uid-1')),
        learnerStateStoreProvider.overrideWithValue(store),
      ],
      child: const RatelApp(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue')); // step 0: language (English)
    await tester.pumpAndSettle();
    await tester.tap(find.text('Travel')); // step 1: motivation
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Regular - 10 min')); // step 2: goal
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('eat')); // step 3: first win (correct anchor)
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final loaded = await store.load('uid-1');
    expect(loaded['courses'], isA<List<Object?>>());
    final courses = loaded['courses']! as List<Object?>;
    expect(courses.length, 1);
    final row = courses.first! as Map<String, Object?>;
    expect(row['target_locale'], 'en');
    expect(
      (row['theta_per_skill']! as Map<String, Object?>).containsKey('vocab'),
      isTrue,
    );
  });
}
