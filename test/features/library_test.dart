import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';

Future<void> _toLibrary(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: RatelApp()));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Library'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows AI Tutor with the REAL PRO gate + a FREE Adventures badge',
      (WidgetTester tester) async {
    await _toLibrary(tester);
    expect(find.byKey(const ValueKey<String>('tab-library')), findsOneWidget);
    expect(find.text('AI Tutor'), findsOneWidget);
    // Free user (default billing entitlement) ⇒ PRO badge on the gated entry.
    expect(find.text('PRO'), findsWidgets);
    expect(find.text('FREE'), findsWidgets);
  });

  testWidgets('Read & listen: dense section headers + honest browse rows',
      (WidgetTester tester) async {
    await _toLibrary(tester);
    // Owner-approved dense rebuild (UXA S115-L5): READ & LISTEN is now three
    // REAL sections. With the default empty course each shows its header + an
    // honest "all …" browse row — never a fabricated item list.
    final Finder graded = find.text('GRADED STORIES');
    await tester.scrollUntilVisible(graded, 200,
        scrollable: find.byType(Scrollable).first);
    expect(graded, findsOneWidget);
    final Finder allStories = find.text('All stories');
    await tester.scrollUntilVisible(allStories, 200,
        scrollable: find.byType(Scrollable).first);
    expect(allStories, findsOneWidget);
    final Finder allPods = find.text('All podcasts');
    await tester.scrollUntilVisible(allPods, 200,
        scrollable: find.byType(Scrollable).first);
    expect(allPods, findsOneWidget);
    final Finder allVids = find.text('All videos');
    await tester.scrollUntilVisible(allVids, 200,
        scrollable: find.byType(Scrollable).first);
    expect(allVids, findsOneWidget);
    // Honest: no fabricated video-engine stub, no faked Continue card (§E).
    expect(find.textContaining('video engine'), findsNothing);
  });

  testWidgets('Library top bar shows the 🔔 bell that opens the REAL inbox',
      (WidgetTester tester) async {
    await _toLibrary(tester);
    // The bell is wired on the Library top bar; a fresh account ⇒ no badge.
    expect(find.byIcon(RatelIcons.notifications), findsOneWidget);
    await tester.tap(find.byIcon(RatelIcons.notifications));
    await tester.pumpAndSettle();
    // Lands on the S54 in-app inbox — honest empty state, never faked.
    expect(find.text('No notifications yet'), findsOneWidget);
  });
}
