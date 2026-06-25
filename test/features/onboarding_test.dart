import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/app/app_flags.dart';
import 'package:ratel/app/ratel_app.dart';

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
}
