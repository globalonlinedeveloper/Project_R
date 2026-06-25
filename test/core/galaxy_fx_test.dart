import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/design_system/design_system.dart';

/// FX is a moving layer, so we test the DETERMINISTIC seeded model + the tier
/// gates (motion-as-policy), never pixels (the no-pixel-tests-on-moving-layers
/// policy). The widget tests assert structure + reduce-motion stillness only.
void main() {
  const size = Size(344, 716);

  group('GalaxyFx model (deterministic, tier-gated)', () {
    test('shooting stars spawn while moving; none + minimal clear the canvas',
        () {
      final fx = GalaxyFx(seed: 1);
      fx.update(dtMs: 1600, size: size, tier: MotionTier.full);
      expect(fx.shootCount, greaterThan(0));
      fx.update(dtMs: 16, size: size, tier: MotionTier.none);
      expect(fx.shootCount, 0);

      final fx2 = GalaxyFx(seed: 1);
      fx2.update(dtMs: 1600, size: size, tier: MotionTier.full);
      fx2.update(dtMs: 16, size: size, tier: MotionTier.minimal); // OS floor
      expect(fx2.shootCount, 0);
    });

    test('supernova flashes are HIGH-only', () {
      var sawHigh = false;
      final hi = GalaxyFx(seed: 3);
      for (var i = 0; i < 200; i++) {
        hi.update(dtMs: 100, size: size, tier: MotionTier.full);
        if (hi.novaCount > 0) sawHigh = true;
      }
      expect(sawHigh, isTrue);

      var sawReduced = false;
      final lo = GalaxyFx(seed: 3);
      for (var i = 0; i < 200; i++) {
        lo.update(dtMs: 100, size: size, tier: MotionTier.reduced);
        if (lo.novaCount > 0) sawReduced = true;
      }
      expect(sawReduced, isFalse);
    });

    test('pod auto-defense fires a capped 2-missile volley -> 18 sparkle dust',
        () {
      final fx = GalaxyFx(seed: 5);
      const pod = Offset(172, 400);
      var maxMissiles = 0, maxDust = 0;
      for (var i = 0; i < 6000; i++) {
        fx.update(dtMs: 16, size: size, pod: pod, tier: MotionTier.full);
        if (fx.missileCount > maxMissiles) maxMissiles = fx.missileCount;
        if (fx.dustCount > maxDust) maxDust = fx.dustCount;
      }
      expect(maxMissiles, 2); // exactly two homing missiles, never overlapping
      expect(maxDust, greaterThanOrEqualTo(18)); // burst of 18 mint sparkles
    });

    test('auto-defense never fires below HIGH (reduced)', () {
      final fx = GalaxyFx(seed: 5);
      const pod = Offset(172, 400);
      var fired = false;
      for (var i = 0; i < 6000; i++) {
        fx.update(dtMs: 16, size: size, pod: pod, tier: MotionTier.reduced);
        if (fx.missileCount > 0) fired = true;
      }
      expect(fired, isFalse);
    });

    test('pod off-screen never triggers a volley', () {
      final fx = GalaxyFx(seed: 5);
      const pod = Offset(172, 900); // below the viewport
      var fired = false;
      for (var i = 0; i < 6000; i++) {
        fx.update(dtMs: 16, size: size, pod: pod, tier: MotionTier.full);
        if (fx.missileCount > 0) fired = true;
      }
      expect(fired, isFalse);
    });
  });

  group('GalaxyFxLayer widget (structure + reduce-motion floor)', () {
    Widget host(MotionTier tier) => MaterialApp(
          home: Scaffold(
            body: GalaxyFxLayer(
              controller: ScrollController(),
              size: size,
              activePlanet: const Offset(100, 300),
              bands: const [GalaxyBand(0, 18, 'NEBULA REACH')],
              tier: tier,
            ),
          ),
        );

    testWidgets('renders a painter and ticks safely while moving',
        (tester) async {
      await tester.pumpWidget(host(MotionTier.full));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('is still + settles under reduce-motion (minimal/none floor)',
        (tester) async {
      await tester.pumpWidget(host(MotionTier.minimal));
      await tester.pumpAndSettle(); // no ticker -> settles cleanly, no hang
      expect(tester.takeException(), isNull);
    });
  });
}
