import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/app/app_flags.dart';
import 'package:ratel/app/ratel_app.dart';

void main() {
  setUp(() {
    welcomeSeen.value = true; // flag-robust: skip the auth Welcome gate
    onboardingComplete.value = true;
  });
  tearDown(() {
    welcomeSeen.value = false;
    onboardingComplete.value = false;
  });

  testWidgets('app boots into the Learn tab shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-screen')), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
