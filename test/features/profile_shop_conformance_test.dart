import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/core/core.dart';

/// UXA increment 5 (S115-L3) — Profile / Shop / shared-component design
/// conformance. Findings: E-2 (level pill), E-4 (menu order + no ACCOUNT
/// header), E-5 (Achievements title), E-11 (green diamond price chip),
/// E-12 (ProgressRing scale-down), A-7 (section-header letter-spacing).
///
/// HONEST per anti-goal §E: Identity exposes only uid + isAuthenticated (no
/// handle, no joined date), so the header shows ONLY the real cold-start
/// level pill (course-derived name + real CEFR level) — never a fabricated
/// handle/joined line.

void _sizeTall(WidgetTester tester, double width) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 4000);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _toProfile(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: RatelApp()));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Profile'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('E-2 · Profile header HIDES the CEFR level (Duolingo lock)',
      (WidgetTester tester) async {
    _sizeTall(tester, 500);
    await _toProfile(tester);
    expect(find.textContaining('Level A'), findsNothing);
  });

  testWidgets('E-4 · menu order Friends,Shop,Notifications,Settings; no ACCOUNT',
      (WidgetTester tester) async {
    _sizeTall(tester, 500);
    await _toProfile(tester);
    expect(find.text('ACCOUNT'), findsNothing);
    final double friends = tester.getTopLeft(find.text('Friends')).dy;
    final double shop = tester.getTopLeft(find.text('Shop')).dy;
    final double notifs = tester.getTopLeft(find.text('Notifications')).dy;
    final double settings = tester.getTopLeft(find.text('Settings')).dy;
    expect(friends < shop, isTrue, reason: 'Friends before Shop');
    expect(shop < notifs, isTrue, reason: 'Shop before Notifications');
    expect(notifs < settings, isTrue, reason: 'Notifications before Settings');
  });

  testWidgets('E-5 · Achievements is a mixed-case title, not the uppercased header',
      (WidgetTester tester) async {
    _sizeTall(tester, 500);
    await _toProfile(tester);
    expect(find.text('Achievements'), findsOneWidget);
    expect(find.text('ACHIEVEMENTS'), findsNothing);
  });

  testWidgets('A-7 · RatelSectionHeader label uses w700 + wide letter-spacing',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: RatelTheme.light(),
      home: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: RatelSectionHeader(label: 'learning'),
        ),
      ),
    ));
    final Text label = tester.widget<Text>(find.text('LEARNING'));
    expect(label.style?.fontWeight, FontWeight.w700);
    expect(label.style?.letterSpacing, greaterThanOrEqualTo(1.2));
  });

  testWidgets('E-12 · ProgressRing scales a large center label down (no overflow)',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: RatelTheme.light(),
      home: const Scaffold(
        body: Center(
          child: SizedBox(
            width: 48,
            height: 48,
            child: RatelProgressRing(
              value: 0.5,
              size: 48,
              center: Text('88888/99999'),
            ),
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.text('88888/99999'), findsOneWidget);
  });

  testWidgets('E-11 · Shop renders a green filled diamond price chip',
      (WidgetTester tester) async {
    _sizeTall(tester, 500);
    await _toProfile(tester);
    await tester.tap(find.text('Shop'));
    await tester.pumpAndSettle();
    final Iterable<RatelChip> chips =
        tester.widgetList<RatelChip>(find.byType(RatelChip));
    expect(
      chips.any((RatelChip c) =>
          c.tone == RatelChipTone.green && c.filled && c.leadingEmoji == '💎'),
      isTrue,
      reason: 'Shop must show at least one green filled diamond price chip',
    );
  });

  testWidgets('layout gauntlet · Profile @460 no overflow',
      (WidgetTester tester) async {
    _sizeTall(tester, 460);
    await _toProfile(tester);
    expect(tester.takeException(), isNull, reason: 'Profile overflow @460');
  });

  testWidgets('layout gauntlet · Profile @800 no overflow',
      (WidgetTester tester) async {
    _sizeTall(tester, 800);
    await _toProfile(tester);
    expect(tester.takeException(), isNull, reason: 'Profile overflow @800');
  });

  // Separate per-width tests (not a re-pump loop): go_router's route info
  // persists within one test binding, so a second pump after navigating to the
  // pushed /shop route would still be on Shop (no 'Profile' tab). A fresh test
  // resets the binding + location.
  testWidgets('layout gauntlet · Shop @460 no overflow',
      (WidgetTester tester) async {
    _sizeTall(tester, 460);
    await _toProfile(tester);
    await tester.tap(find.text('Shop'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Shop overflow @460');
  });

  testWidgets('layout gauntlet · Shop @800 no overflow',
      (WidgetTester tester) async {
    _sizeTall(tester, 800);
    await _toProfile(tester);
    await tester.tap(find.text('Shop'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Shop overflow @800');
  });
}
