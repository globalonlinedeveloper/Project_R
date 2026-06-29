import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/app/router.dart';
import 'package:ratel/features/common/coming_soon_screen.dart';

void main() {
  test('/login and /signup are no longer coming-soon stubs', () {
    final Set<String> stubbed =
        kComingSoonRoutes.map((ComingSoonRoute r) => r.path).toSet();
    expect(stubbed.contains('/login'), isFalse);
    expect(stubbed.contains('/signup'), isFalse);
  });

  testWidgets('the router resolves /login + /signup to the REAL screens',
      (WidgetTester tester) async {
    final router = buildRouter();
    await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)));
    await tester.pumpAndSettle();

    router.go('/login');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login')), findsOneWidget);
    expect(find.byType(ComingSoonScreen), findsNothing);

    router.go('/signup');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('signup')), findsOneWidget);
    expect(find.byType(ComingSoonScreen), findsNothing);
  });
}
