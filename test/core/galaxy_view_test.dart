import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/design_system/design_system.dart';

Widget _harness(
  GalaxyLayout layout, {
  required int activeIdx,
  required MotionTier tier,
  required void Function(GalaxyPlanet, int) onTap,
}) =>
    MaterialApp(
      home: Scaffold(
        body: GalaxyView(
          layout: layout,
          activeIdx: activeIdx,
          tier: tier,
          onPlanetTap: onTap,
        ),
      ),
    );

void main() {
  testWidgets('renders the pod and is scrollable; no overflow', (tester) async {
    final layout = generateGalaxy();
    await tester.pumpWidget(_harness(layout,
        activeIdx: 0, tier: MotionTier.full, onTap: (_, _) {}));
    await tester.pump();
    expect(find.byType(RatelPod), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a planet reports the tapped index', (tester) async {
    final layout = generateGalaxy();
    int? tappedIndex;
    await tester.pumpWidget(_harness(layout,
        activeIdx: 0,
        tier: MotionTier.full,
        onTap: (_, i) => tappedIndex = i));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('galaxy-planet-0')));
    expect(tappedIndex, 0);
  });

  testWidgets('reduce-motion (none tier) stays static — no settle hang',
      (tester) async {
    final layout = generateGalaxy();
    await tester.pumpWidget(_harness(layout,
        activeIdx: 5, tier: MotionTier.none, onTap: (_, _) {}));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(GalaxyView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
// Traceability: R-WT4
