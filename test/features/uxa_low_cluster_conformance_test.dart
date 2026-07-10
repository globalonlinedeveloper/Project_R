import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/leagues/leagues_screen.dart';
import 'package:ratel/features/quests/quests_screen.dart';
import 'package:ratel/features/themes/themes_screen.dart';
import 'package:ratel/features/tutor/ai_tutor_screen.dart';
import 'package:ratel/services/analytics/analytics.dart';

/// UXA S115-L10 — "Low cluster" design conformance + layout gauntlets (§11).
///  D-9  Leagues "View all 10 tiers" is a soft teal-tinted pill (not a bare
///       secondary text link) — design_spec/shots/Leagues_full.png.
///  D-16 Leagues + Quests TopBars surface the REAL diamonds wallet (the same
///       honest LearnerSnapshot Home already shows) — owner bundle b-home/Leagues.
///  A-12 Themes header uses the screen-title scale (24), not card-title (18).
///  F-4  AI Tutor "Talk" subtitle matches the design copy (owner HTML).
///  F-5  AI Tutor back affordance is a circular button (Tutor_full.png).
class _NoopAnalytics implements Analytics {
  @override
  void logEvent(String name,
      {Map<String, Object?> props = const <String, Object?>{}}) {}
}

final List<Override> _themeOv = <Override>[
  analyticsProvider.overrideWithValue(_NoopAnalytics()),
];

Future<void> _pump(WidgetTester t, Widget screen, Size size,
    {List<Override> overrides = const <Override>[]}) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(ProviderScope(
    overrides: overrides,
    child: MaterialApp(theme: RatelTheme.light(), home: screen),
  ));
  await t.pump();
  await t.pump(const Duration(milliseconds: 50));
}

void main() {
  group('UXA Low cluster (S115-L10)', () {
    testWidgets('D-9 Leagues tier ladder is a tinted pill', (WidgetTester t) async {
      await _pump(t, const LeaguesScreen(), const Size(460, 2600));
      expect(find.byKey(const ValueKey<String>('leagues-tier-pill')),
          findsOneWidget);
      expect(find.textContaining('View all 10 tiers'), findsOneWidget);
    });

    testWidgets('D-16 Leagues TopBar shows the real diamonds wallet',
        (WidgetTester t) async {
      await _pump(t, const LeaguesScreen(), const Size(460, 2600));
      final RatelTopBar bar = t.widget<RatelTopBar>(find.byType(RatelTopBar));
      expect(bar.diamonds, isNotNull);
    });

    testWidgets('D-16 Quests TopBar shows the real diamonds wallet',
        (WidgetTester t) async {
      await _pump(t, const QuestsScreen(), const Size(460, 2600));
      final RatelTopBar bar = t.widget<RatelTopBar>(find.byType(RatelTopBar));
      expect(bar.diamonds, isNotNull);
    });

    testWidgets('A-12 Themes header uses the screen-title scale',
        (WidgetTester t) async {
      await _pump(t, const ThemesScreen(), const Size(430, 4400),
          overrides: _themeOv);
      final Text title = t.widget<Text>(find.text('Themes'));
      expect(title.style?.fontSize, RatelType.screenTitle);
    });

    testWidgets('F-4 AI Tutor Talk subtitle matches the design copy',
        (WidgetTester t) async {
      await _pump(t, const AiTutorScreen(), const Size(460, 2200));
      expect(find.text('Live voice & video speaking practice'), findsOneWidget);
    });

    testWidgets('F-5 AI Tutor back affordance is circular',
        (WidgetTester t) async {
      await _pump(t, const AiTutorScreen(), const Size(460, 2200));
      expect(
          find.descendant(
              of: find.byType(AppBar), matching: find.byType(CircleAvatar)),
          findsOneWidget);
    });

    testWidgets('gauntlet — Leagues/Quests/Tutor @430/460/800 no overflow',
        (WidgetTester t) async {
      for (final double w in <double>[430, 460, 800]) {
        await _pump(t, const LeaguesScreen(), Size(w, 2600));
        expect(t.takeException(), isNull, reason: 'Leagues @$w');
        await _pump(t, const QuestsScreen(), Size(w, 2600));
        expect(t.takeException(), isNull, reason: 'Quests @$w');
        await _pump(t, const AiTutorScreen(), Size(w, 2200));
        expect(t.takeException(), isNull, reason: 'Tutor @$w');
      }
    });

    testWidgets('gauntlet — Themes @460/800 no overflow', (WidgetTester t) async {
      for (final double w in <double>[460, 800]) {
        await _pump(t, const ThemesScreen(), Size(w, 4400), overrides: _themeOv);
        expect(t.takeException(), isNull, reason: 'Themes @$w');
      }
    });
  });
}
