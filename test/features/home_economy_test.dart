import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/home/economy_glyph.dart';

// WS2 economy slice (this increment): the top-bar diamonds use the design's
// x.xxk formatting and energy shows ∞ for Pro (SPEC_HOME_PATH §A6/D4). Pure
// helpers + a backward-compatible RatelTopBar.energyLabel. No dummy data.

void main() {
  group('formatCount — design x.xxk rule', () {
    test('below 1000 renders verbatim', () {
      expect(formatCount(0), '0');
      expect(formatCount(7), '7');
      expect(formatCount(999), '999');
    });
    test('>=1000 → thousands, 2dp, one trailing zero stripped', () {
      expect(formatCount(1000), '1.0k');
      expect(formatCount(1200), '1.2k');
      expect(formatCount(1240), '1.24k'); // the design's seed value
      expect(formatCount(1234), '1.23k');
      expect(formatCount(2000), '2.0k');
    });
  });

  group('formatEnergy — ∞ for Pro', () {
    test('unlimited → ∞; otherwise raw', () {
      expect(formatEnergy(5, unlimited: false), '5');
      expect(formatEnergy(0, unlimited: false), '0');
      expect(formatEnergy(5, unlimited: true), '∞');
    });
  });

  Widget host(Widget child) =>
      MaterialApp(theme: RatelTheme.light(), home: Scaffold(body: child));

  testWidgets('EconomyGlyph renders emoji + formatted value',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(host(const EconomyGlyph(emoji: '💎', value: '1.24k')));
    expect(find.text('💎'), findsOneWidget);
    expect(find.text('1.24k'), findsOneWidget);
  });

  testWidgets('RatelTopBar: energyLabel overrides the numeric energy',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(const RatelTopBar(
      flagEmoji: '🦡',
      langCode: 'es',
      energy: 5,
      energyLabel: '∞',
    )));
    expect(find.text('∞'), findsOneWidget);
    expect(find.text('5'), findsNothing);
  });

  testWidgets('RatelTopBar: without energyLabel, shows the numeric energy',
      (WidgetTester tester) async {
    await tester.pumpWidget(host(const RatelTopBar(
      flagEmoji: '🦡',
      langCode: 'es',
      energy: 5,
    )));
    expect(find.text('5'), findsOneWidget);
  });
}
