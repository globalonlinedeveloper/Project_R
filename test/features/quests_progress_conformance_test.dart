import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/progress/progress_screen.dart';
import 'package:ratel/features/quests/quests_screen.dart';

/// §C increment 3 — Quests + Progress design conformance (D-1/D-2/D-3/D-5/D-11)
/// + layout gauntlets at 430/460/800 (§11). Anchored to the owner-bundle Quests
/// render (design_spec/shots/Quests.png): DAILY REFRESH above DAILY GOAL, an
/// inline white "Start" pill, a real "Resets in Xh Ym" countdown, an amber
/// gradient goal card with a remaining fragment; Progress hero gains the CEFR
/// ladder A1…C2.

Future<void> _pumpQuests(WidgetTester t, Size size) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(ProviderScope(
    child: MaterialApp(theme: RatelTheme.light(), home: const QuestsScreen()),
  ));
  await t.pumpAndSettle();
}

Future<void> _pumpProgress(WidgetTester t, Size size, ProviderContainer c) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: const MaterialApp(home: ProgressScreen()),
  ));
  await t.pump();
}

void main() {
  // D-2: the reset countdown is a PURE next-local-midnight derive (honest, no
  // faked timer). Fixed clocks prove the format + math.
  test('D-2 refreshResetsLabel — honest next-midnight countdown', () {
    expect(refreshResetsLabel(DateTime(2026, 1, 1, 13, 7)), 'Resets in 10h 53m');
    expect(refreshResetsLabel(DateTime(2026, 1, 1, 23, 59)), 'Resets in 0h 1m');
    expect(refreshResetsLabel(DateTime(2026, 1, 1, 0, 0)), 'Resets in 24h 0m');
  });

  group('Quests §4.4 conformance', () {
    testWidgets('D-1 DAILY REFRESH sits above DAILY GOAL', (WidgetTester t) async {
      await _pumpQuests(t, const Size(460, 2200));
      final double refreshY = t.getTopLeft(find.text('DAILY REFRESH')).dy;
      final double goalY = t.getTopLeft(find.text('DAILY GOAL')).dy;
      expect(refreshY, lessThan(goalY));
    });

    testWidgets('D-3 inline Start pill + D-2 countdown on the refresh card',
        (WidgetTester t) async {
      await _pumpQuests(t, const Size(460, 2200));
      expect(find.text('Start'), findsOneWidget);
      // The old full-width "Start the daily refresh" button label is gone.
      expect(find.text('Start the daily refresh'), findsNothing);
      expect(find.textContaining('Resets in'), findsOneWidget);
    });

    testWidgets('D-5 goal card shows an honest remaining-XP fragment',
        (WidgetTester t) async {
      await _pumpQuests(t, const Size(460, 2200));
      expect(find.textContaining('XP to go'), findsOneWidget);
    });

    testWidgets('layout gauntlet @430/460/800 — no overflow',
        (WidgetTester t) async {
      for (final Size s in <Size>[
        const Size(430, 2200),
        const Size(460, 2200),
        const Size(800, 2200)
      ]) {
        await _pumpQuests(t, s);
        expect(t.takeException(), isNull, reason: 'quests overflow @${s.width}');
        expect(find.byKey(const ValueKey<String>('tab-quests')), findsOneWidget);
      }
    });
  });

  group('Progress §4.13 conformance', () {
    testWidgets('CEFR ladder is HIDDEN (Duolingo lock, S161 INC-P2)',
        (WidgetTester t) async {
      final ProviderContainer c = ProviderContainer();
      addTearDown(c.dispose);
      await _pumpProgress(t, const Size(460, 1600), c);
      // The A1-C2 CEFR ladder + the CEFR-level stat card were removed; no CEFR
      // band is shown anywhere on the dashboard (Duolingo lock).
      expect(find.text('B1'), findsNothing);
      expect(find.text('B2'), findsNothing);
      expect(find.text('C1'), findsNothing);
      expect(find.text('C2'), findsNothing);
      expect(find.textContaining('CEFR'), findsNothing);
    });

    testWidgets('layout gauntlet @430/460/800 — no overflow',
        (WidgetTester t) async {
      for (final Size s in <Size>[
        const Size(430, 1600),
        const Size(460, 1600),
        const Size(800, 1600)
      ]) {
        final ProviderContainer c = ProviderContainer();
        addTearDown(c.dispose);
        await _pumpProgress(t, s, c);
        expect(t.takeException(), isNull, reason: 'progress overflow @${s.width}');
        expect(
            find.byKey(const ValueKey<String>('screen-progress')), findsOneWidget);
      }
    });
  });
}
