import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/app/app_flags.dart';
import 'package:ratel/app/ratel_app.dart';

void main() {
  setUp(() => onboardingComplete.value = true);
  tearDown(() => onboardingComplete.value = false);

  testWidgets('app boots into the Learn tab shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-screen')), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
