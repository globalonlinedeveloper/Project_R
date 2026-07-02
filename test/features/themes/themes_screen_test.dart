// Themes picker (design spec §(d)-5/§(d)-6) — a 2-col world-card grid replacing
// the retired `_pickWorld` sheet. Pro-gated (locked → /paywall), unlocked → live
// preview select. Grounds R-WT3 (persisted world-theme selection) over the
// R-WT1 world-theme seam (palette · traveller vehicle · ✓/🔒 gating).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/router.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/common/coming_soon_screen.dart';
import 'package:ratel/features/paywall/paywall_screen.dart';
import 'package:ratel/features/themes/themes_screen.dart';
import 'package:ratel/services/analytics/analytics.dart';
import 'package:ratel/services/billing/billing.dart';
import 'package:ratel/services/preferences/app_settings.dart';

class _NoopAnalytics implements Analytics {
  @override
  void logEvent(String name,
      {Map<String, Object?> props = const <String, Object?>{}}) {}
}

class _AlwaysProEntitlements implements Entitlements {
  const _AlwaysProEntitlements();
  @override
  bool get isPro => true;
}

/// Pump the real router, navigate to /themes. A tall+narrow surface forces the
/// lazy GridView to build all 31 cards so counts are reliable (session-craft §11).
Future<GoRouter> _openThemes(WidgetTester tester, {bool pro = false}) async {
  tester.view.physicalSize = const Size(430, 4400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final GoRouter router = buildRouter();
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[
      analyticsProvider.overrideWithValue(_NoopAnalytics()),
      if (pro)
        entitlementsProvider.overrideWithValue(const _AlwaysProEntitlements()),
    ],
    child: MaterialApp.router(routerConfig: router),
  ));
  await tester.pump();
  router.go('/themes');
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  return router;
}

void main() {
  test('/themes is a real screen, never a coming-soon stub', () {
    final Set<String> stubbed =
        kComingSoonRoutes.map((ComingSoonRoute r) => r.path).toSet();
    expect(stubbed.contains('/themes'), isFalse);
    expect(kComingSoonRoutes, isEmpty);
  });

  testWidgets('renders all 31 world cards + the live-preview header',
      (WidgetTester tester) async {
    await _openThemes(tester);
    expect(find.byType(ThemesScreen), findsOneWidget);
    expect(find.byType(ComingSoonScreen), findsNothing);
    expect(find.text('Themes'), findsOneWidget);
    expect(find.textContaining('tap to preview live'), findsOneWidget);
    expect(find.textContaining('Vehicle · '), findsNWidgets(31));
  });

  testWidgets('non-Pro: 29 worlds show 🔒 PRO, the 2 free worlds do not',
      (WidgetTester tester) async {
    await _openThemes(tester);
    expect(find.text('🔒 PRO'), findsNWidgets(29));
  });

  testWidgets('Pro: no world is locked', (WidgetTester tester) async {
    await _openThemes(tester, pro: true);
    expect(find.text('🔒 PRO'), findsNothing);
  });

  testWidgets('the active world card shows the ✓ badge (default = light)',
      (WidgetTester tester) async {
    await _openThemes(tester);
    expect(find.text('✓'), findsOneWidget);
  });

  testWidgets('each card paints its own bg→bg2 gradient swatch',
      (WidgetTester tester) async {
    await _openThemes(tester);
    final Container swatch = tester.widget<Container>(
        find.byKey(const ValueKey<String>('theme-swatch-galaxy')));
    final BoxDecoration dec = swatch.decoration! as BoxDecoration;
    final LinearGradient g = dec.gradient! as LinearGradient;
    final WorldPalette p = kThemeWorlds['galaxy']!.palette;
    expect(g.colors, <Color>[p.bg, p.bg2]);
  });

  testWidgets('tapping a LOCKED Pro world routes to the paywall + selects nothing',
      (WidgetTester tester) async {
    await _openThemes(tester);
    final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(ThemesScreen)));
    final WorldTheme before = container.read(worldThemeProvider);
    final Finder galaxy =
        find.byKey(const ValueKey<String>('theme-card-galaxy'));
    await tester.ensureVisible(galaxy);
    await tester.tap(galaxy);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(PaywallScreen), findsOneWidget);
    expect(container.read(worldThemeProvider), before);
  });

  testWidgets('tapping a FREE world selects it live (persists, no paywall, no pop)',
      (WidgetTester tester) async {
    await _openThemes(tester);
    final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(ThemesScreen)));
    final Finder savanna =
        find.byKey(const ValueKey<String>('theme-card-savanna'));
    await tester.ensureVisible(savanna);
    await tester.tap(savanna);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(PaywallScreen), findsNothing);
    expect(find.byType(ThemesScreen), findsOneWidget);
    expect(container.read(worldThemeProvider), WorldTheme.values.byName('savanna'));
  });

  testWidgets('a Pro learner can select a premium world (no paywall)',
      (WidgetTester tester) async {
    await _openThemes(tester, pro: true);
    final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(ThemesScreen)));
    final Finder galaxy =
        find.byKey(const ValueKey<String>('theme-card-galaxy'));
    await tester.ensureVisible(galaxy);
    await tester.tap(galaxy);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(PaywallScreen), findsNothing);
    expect(container.read(worldThemeProvider), WorldTheme.values.byName('galaxy'));
  });

  testWidgets('cards expose button + selected semantics (a11y, matches the shared-component convention)',
      (WidgetTester tester) async {
    final handle = tester.ensureSemantics();
    await _openThemes(tester);
    // The active world (default light) is a SELECTED button.
    expect(
      tester.getSemantics(
          find.byKey(const ValueKey<String>('theme-card-light'))),
      isSemantics(isButton: true, isSelected: true),
    );
    // Any other world is a button, not selected (locked worlds are still
    // tappable — they route to the paywall).
    expect(
      tester.getSemantics(
          find.byKey(const ValueKey<String>('theme-card-galaxy'))),
      isSemantics(isButton: true, isSelected: false),
    );
    handle.dispose();
  });
}
