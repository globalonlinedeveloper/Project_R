// R-J2 / R-J6 / R-J1 · RATEL PRO paywall — price catalogue + honest store-clean
// paywall (real prices, NO fake purchase) + the /paywall route promotion.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/router.dart';
import 'package:ratel/features/common/coming_soon_screen.dart';
import 'package:ratel/features/paywall/paywall_screen.dart';
import 'package:ratel/services/analytics/analytics.dart';
import 'package:ratel/services/billing/billing.dart';

/// Capturing analytics sink (still taxonomy-enforced via [AllowListAnalytics]).
class _CapturingAnalytics implements Analytics {
  final List<(String, Map<String, Object?>)> events = <(String, Map<String, Object?>)>[];
  @override
  void logEvent(String name, {Map<String, Object?> props = const <String, Object?>{}}) {
    events.add((name, props));
  }
}

void main() {
  group('R-J2 price catalogue', () {
    test('tier-1 / mid / low-PPP carry the locked prices + SKUs', () {
      expect(ProCatalog.tier1.monthly, 6.99);
      expect(ProCatalog.tier1.annual, 44.99);
      expect(ProCatalog.mid.monthly, 2.99);
      expect(ProCatalog.mid.annual, 17.99);
      expect(ProCatalog.lowPpp.monthly, 1.49);
      expect(ProCatalog.lowPpp.annual, 8.99);
      expect(ProSku.monthly, 'com.learnwithratel.ratel.pro.monthly');
      expect(ProSku.annual, 'com.learnwithratel.ratel.pro.annual');
      expect(ProSku.forPlan(ProPlan.annual), ProSku.annual);
      expect(ProSku.forPlan(ProPlan.monthly), ProSku.monthly);
      expect(kProTrialDays, 7);
    });

    test('derived display: annual /mo + saving %', () {
      expect(ProCatalog.tier1.annualPerMonthDisplay, '\$3.75');
      expect(ProCatalog.tier1.annualSavingPercent, 46);
      expect(ProCatalog.tier1.monthlyDisplay, '\$6.99');
      expect(ProCatalog.tier1.annualDisplay, '\$44.99');
      expect(ProCatalog.of(ProBand.lowPpp).band, ProBand.lowPpp);
      expect(ProCatalog.displayDefault.band, ProBand.tier1);
    });
  });

  test('R-J7 default checkout seam refuses honestly (no money moves)', () async {
    final CheckoutResult r = await const UnavailableProCheckout()
        .start(plan: ProPlan.annual, band: ProBand.tier1);
    expect(r.status, CheckoutStatus.unavailable);
    expect(r.isAvailable, isFalse);
    expect(r.message, contains('Checkout opens at launch'));
  });

  Future<_CapturingAnalytics> openPaywall(WidgetTester tester,
      {String path = '/paywall?source=tutor', bool pro = false}) async {
    // Tall + narrow surface (R-J6 paywall is a long scroll): a default 800x600
    // viewport lazily builds only above-the-fold ListView children, so probes for
    // the CTA / links would miss them (session-craft §11). 390px also exercises a
    // narrow phone width.
    tester.view.physicalSize = const Size(390, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final _CapturingAnalytics analytics = _CapturingAnalytics();
    final router = buildRouter();
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        analyticsProvider.overrideWithValue(analytics),
        if (pro)
          entitlementsProvider
              .overrideWithValue(const _AlwaysProEntitlements()),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump();
    router.go(path);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    return analytics;
  }

  testWidgets('/paywall resolves to the REAL paywall (no stub) at locked prices',
      (WidgetTester tester) async {
    await openPaywall(tester);
    expect(find.byType(ComingSoonScreen), findsNothing);
    expect(find.byType(PaywallScreen), findsOneWidget);
    // Both prices shown up front (R-J6).
    expect(find.textContaining('44.99'), findsWidgets);
    expect(find.textContaining('6.99'), findsWidgets);
    // Trial timeline (annual default) + the single CTA + restore + legal links.
    expect(find.textContaining('7-day free trial'), findsWidgets);
    expect(find.byKey(const ValueKey<String>('paywall-cta')), findsOneWidget);
    expect(find.text('Restore purchases'), findsOneWidget);
    expect(find.text('Terms'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
  });

  testWidgets('paywall_viewed fires once with the entry source (R-M1)',
      (WidgetTester tester) async {
    final _CapturingAnalytics a =
        await openPaywall(tester, path: '/paywall?source=settings');
    final List<(String, Map<String, Object?>)> viewed = a.events
        .where((e) => e.$1 == 'paywall_viewed')
        .toList();
    expect(viewed.length, 1);
    expect(viewed.single.$2['source'], 'settings');
  });

  testWidgets('CTA NEVER fakes a purchase — entitlement stays free, honest note',
      (WidgetTester tester) async {
    await openPaywall(tester);
    final finder = find.byKey(const ValueKey<String>('paywall-cta'));
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('Checkout opens at launch'), findsWidgets);
    // The entitlement is still free — no fake Pro unlock.
    final container = ProviderScope.containerOf(
        tester.element(find.byType(PaywallScreen)));
    expect(container.read(isProProvider), isFalse);
  });

  testWidgets('selecting Monthly drops the trial timeline + swaps the CTA',
      (WidgetTester tester) async {
    await openPaywall(tester);
    expect(find.textContaining('How the 7-day free trial works'), findsOneWidget);
    final monthly = find.byKey(const ValueKey<String>('paywall-plan-monthly'));
    await tester.ensureVisible(monthly);
    await tester.tap(monthly);
    await tester.pump();
    expect(find.textContaining('How the 7-day free trial works'), findsNothing);
    expect(find.textContaining('Go Pro'), findsWidgets);
  });

  testWidgets('an already-Pro learner sees a manage panel, not the upsell',
      (WidgetTester tester) async {
    await openPaywall(tester, pro: true);
    expect(find.textContaining('You are on RATEL PRO'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('paywall-cta')), findsNothing);
  });
}

class _AlwaysProEntitlements implements Entitlements {
  const _AlwaysProEntitlements();
  @override
  bool get isPro => true;
}
