import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/features/notifications/notifications_controller.dart';

Future<void> _toProfile(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: RatelApp()));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Profile'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('surfaces the REAL guest snapshot (cold-start A1, zero counters)',
      (WidgetTester tester) async {
    await _toProfile(tester);
    expect(find.byKey(const ValueKey<String>('tab-profile')), findsOneWidget);
    // Honest identity: a fresh install is a guest, NOT the mockup's "Alex Rivera".
    expect(find.text('Guest'), findsOneWidget);
    // Real cold-start CEFR level pill (A1, not the mockup's A2).
    expect(find.text('A1'), findsWidgets);
    // Real engine-derived stat labels.
    expect(find.text('Day streak'), findsOneWidget);
    expect(find.text('Saved words'), findsOneWidget);
  });

  testWidgets('the Friends row opens the REAL friends screen (last stub retired)',
      (WidgetTester tester) async {
    await _toProfile(tester);
    // Friends is now a REAL screen (S64 / R-I9 + R-L8) — the last §6 stub
    // retired. It is below the fold in a lazy ListView, so scroll it into view
    // before tapping (the finder cannot see unbuilt children).
    final Finder dest = find.text('Friends');
    await tester.scrollUntilVisible(dest, 150,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(dest);
    await tester.pumpAndSettle();
    expect(find.text('Coming soon'), findsNothing);
    // A fresh guest sees the honest empty social graph, never fake friends.
    expect(find.text('No friends yet'), findsOneWidget);
  });

  testWidgets('the Notifications row opens the REAL in-app inbox',
      (WidgetTester tester) async {
    await _toProfile(tester);
    // Notifications is now a real screen (the in-app milestone inbox), no longer
    // a stub — a fresh guest sees the honest empty state, never fake alerts.
    final Finder notif = find.text('Notifications');
    await tester.scrollUntilVisible(notif, 150,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(notif);
    await tester.pumpAndSettle();
    expect(find.text('Coming soon'), findsNothing);
    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('E-1: the notifications unread badge shows the real count',
      (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        unreadNotificationsCountProvider.overrideWithValue(3),
      ],
      child: const RatelApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    final Finder notif = find.text('Notifications');
    await tester.scrollUntilVisible(notif, 150,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    // Before the fix the coral chip rendered the literal "\$count".
    expect(find.text(r'$count'), findsNothing);
    expect(find.text('3'), findsWidgets);
  });

  testWidgets('the Shop row opens the REAL streak-freeze spend sink',
      (WidgetTester tester) async {
    await _toProfile(tester);
    // Shop is now a real screen (the diamond spend sink), no longer a stub.
    final Finder shop = find.text('Shop');
    await tester.scrollUntilVisible(shop, 150,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(shop);
    await tester.pumpAndSettle();
    expect(find.text('Coming soon'), findsNothing);
    expect(find.text('Streak Freeze'), findsOneWidget);
    expect(find.text('Your diamonds'), findsOneWidget);
  });

  testWidgets('the achievements grid is REAL — a fresh account is all-locked with honest progress',
      (WidgetTester tester) async {
    await _toProfile(tester);
    final Finder firstSteps =
        find.byKey(const ValueKey<String>('achievement-first_steps'));
    await tester.scrollUntilVisible(firstSteps, 150,
        scrollable: find.byType(Scrollable).first);
    expect(firstSteps, findsOneWidget);
    expect(find.text('First Steps'), findsOneWidget);
    // Nothing fabricated as earned on a brand-new account.
    expect(find.text('Unlocked'), findsNothing);
    expect(find.text('0/1'), findsWidgets); // First Steps needs 1 lesson
  });
}
