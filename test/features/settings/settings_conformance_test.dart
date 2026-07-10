// UXA §4.9 Settings conformance (E-8 / E-9):
//   E-8 — rows grouped into per-section cards with hairline dividers, aligned to
//         the design's five sections (LEARNING / SUBSCRIPTION / ACCESSIBILITY /
//         NOTIFICATIONS / APPEARANCE & ACCOUNT). Was one card per row.
//   E-9 — the reduce-motion row carries the "Master switch — turns off every
//         animation" subtitle.
// Plus layout gauntlets at 460 & 800 px (§11). Honest/additive rows (World,
// Course) stay (§D-4) — the "World" row keeps its own dedicated push test.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/settings/settings_screen.dart';

Future<void> _pump(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 4200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: SettingsScreen())));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('E-8: rows are grouped into 5 per-section cards with dividers',
      (WidgetTester tester) async {
    await _pump(tester, 800);
    // Exactly five grouped section cards (previously ~one RatelCard per toggle).
    expect(find.byType(RatelCard), findsNWidgets(5));
    // Rows inside a section are separated by hairline dividers.
    expect(find.byType(Divider), findsWidgets);
    // Section headers align to the design (RatelSectionHeader uppercases).
    for (final String h in <String>[
      'LEARNING',
      'SUBSCRIPTION',
      'ACCESSIBILITY',
      'NOTIFICATIONS',
      'APPEARANCE & ACCOUNT',
    ]) {
      expect(find.text(h), findsOneWidget, reason: h);
    }
    // Rows that moved sections still render (Haptics→Learning, subscription→
    // Subscription, reduce-motion/high-contrast→Accessibility).
    expect(find.text('Haptics'), findsOneWidget);
    expect(find.text('Manage subscription'), findsOneWidget);
    expect(find.text('High contrast'), findsOneWidget);
  });

  testWidgets('E-9: reduce-motion carries the "Master switch" subtitle',
      (WidgetTester tester) async {
    await _pump(tester, 800);
    expect(find.text('Reduce motion'), findsOneWidget);
    expect(find.text('Master switch — turns off every animation'),
        findsOneWidget);
  });

  testWidgets('layout gauntlet @460 — no overflow, builds top→bottom',
      (WidgetTester tester) async {
    await _pump(tester, 460);
    expect(tester.takeException(), isNull);
    expect(find.text('Reduce motion'), findsOneWidget);
    expect(find.text('Help & support'), findsOneWidget); // built to the bottom
  });

  testWidgets('layout gauntlet @800 — no overflow',
      (WidgetTester tester) async {
    await _pump(tester, 800);
    expect(tester.takeException(), isNull);
    expect(find.text('Help & support'), findsOneWidget);
  });
}
