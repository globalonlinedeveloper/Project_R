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

  testWidgets('Read & listen: real Stories + Podcasts + Watch tiles',
      (WidgetTester tester) async {
    await _toLibrary(tester);
    // INF-6: Stories (text + browser read-aloud) is a REAL, un-gated tile.
    // INF-8 added a Roleplay tile above Read & listen, so Stories can start
    // below the fold — scroll to it (mirrors the Podcasts/video-stub checks).
    final Finder stories = find.text('Stories');
    await tester.scrollUntilVisible(stories, 200,
        scrollable: find.byType(Scrollable).first);
    expect(stories, findsOneWidget);
    // INF-7: Podcasts (real audio + transcript) is now a REAL, un-gated tile.
    final Finder podcasts = find.text('Podcasts');
    await tester.scrollUntilVisible(podcasts, 200,
        scrollable: find.byType(Scrollable).first);
    expect(podcasts, findsOneWidget);
    // INF-9: Watch (real R2 video + transcript) is now a REAL, un-gated tile
    // (replaced the honest "coming soon" video stub).
    final Finder watch = find.text('Watch');
    await tester.scrollUntilVisible(watch, 200,
        scrollable: find.byType(Scrollable).first);
    expect(watch, findsOneWidget);
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
