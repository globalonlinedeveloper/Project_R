// R-I9 / R-L8 · Friends / social — route promotion + real screen widget cover.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/router.dart';
import 'package:ratel/features/common/coming_soon_screen.dart';
import 'package:ratel/features/friends/friends_screen.dart';

void main() {
  test('/friends is no longer a coming-soon stub (none remain)', () {
    final Set<String> stubbed =
        kComingSoonRoutes.map((ComingSoonRoute r) => r.path).toSet();
    expect(stubbed.contains('/friends'), isFalse);
    expect(stubbed, isEmpty);
  });

  Future<void> openFriends(WidgetTester tester) async {
    final router = buildRouter();
    await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    router.go('/friends');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('renders the REAL Friends screen with an honest empty graph',
      (WidgetTester tester) async {
    await openFriends(tester);
    expect(find.byType(ComingSoonScreen), findsNothing);
    expect(find.byType(FriendsScreen), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('friend-add-field')),
        findsOneWidget);
    expect(find.text('No friends yet'), findsOneWidget);
  });

  testWidgets('sending a request to a valid @handle adds a real pending row',
      (WidgetTester tester) async {
    await openFriends(tester);
    await tester.enterText(
        find.byKey(const ValueKey<String>('friend-add-field')), '@mia');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('@mia'), findsOneWidget); // pending row title
    expect(find.text('Request sent'), findsOneWidget);
  });

  testWidgets('an invalid handle is rejected honestly (no fake request)',
      (WidgetTester tester) async {
    await openFriends(tester);
    await tester.enterText(
        find.byKey(const ValueKey<String>('friend-add-field')), 'x');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    expect(find.textContaining('Enter a handle'), findsOneWidget);
    expect(find.text('Request sent'), findsNothing);
  });
}
