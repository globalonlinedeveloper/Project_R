import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/design_system/world/galaxy_model.dart';

void main() {
  group('mulberry32 is bit-exact vs the approved prototype', () {
    test('seed 1000 reproduces the JS stream', () {
      final r = Mulberry32(1000);
      const expected = <double>[
        0.7951949068810791,
        0.8276879135519266,
        0.6915161057841033,
        0.8805752142798156,
      ];
      for (final e in expected) {
        expect(r.next(), closeTo(e, 1e-12));
      }
    });

    test('deterministic: same seed → same sequence; output in [0,1)', () {
      final a = Mulberry32(42);
      final b = Mulberry32(42);
      for (var i = 0; i < 50; i++) {
        final v = a.next();
        expect(v, b.next());
        expect(v, inInclusiveRange(0.0, 1.0));
        expect(v, lessThan(1.0));
      }
    });
  });

  test('golden-angle section hues match the prototype', () {
    expect(goldenHue(0), closeTo(208, 1e-9));
    expect(goldenHue(1), closeTo(345.508, 1e-9));
    expect(goldenHue(2), closeTo(123.016, 1e-9));
  });

  group('generateGalaxy reproduces the golden layout (35 planets)', () {
    final g = generateGalaxy();

    test('counts + total height', () {
      expect(g.count, 35);
      expect(g.units.length, 9);
      expect(g.total, 3714);
      expect(g.bands.map((b) => b.y).toList(), <double>[18, 1188, 2280]);
    });

    test('first planet matches golden', () {
      final p = g.planets.first;
      expect(p.x, closeTo(99.278, 1e-3));
      expect(p.y, 180);
      expect(p.hue, 6);
      expect(p.arch, PlanetArch.icy);
      expect(p.ring, isFalse);
      expect(p.moon, isTrue);
      expect(p.isCheckpoint, isFalse);
      expect(p.lessonNo, 1);
      expect(p.lessons, 5);
      expect(p.unitTitle, 'Greetings');
    });

    test('planet 5 (next unit) matches golden', () {
      final p = g.planets[5];
      expect(p.x, closeTo(103.861, 1e-3));
      expect(p.y, 652);
      expect(p.ui, 1);
      expect(p.hue, 255);
      expect(p.arch, PlanetArch.icy);
    });

    test('last planet is a checkpoint matching golden', () {
      final p = g.planets.last;
      expect(p.x, closeTo(270.723, 1e-3));
      expect(p.y, 3620);
      expect(p.section, 2);
      expect(p.isCheckpoint, isTrue);
      expect(p.hue, 220);
      expect(p.arch, PlanetArch.banded);
    });

    test('checkpoints are exactly the last lesson of each unit', () {
      for (final p in g.planets) {
        expect(p.isCheckpoint, p.lessonNo == p.lessons);
      }
      expect(g.planets.where((p) => p.isCheckpoint).length, g.units.length);
    });
  });
}
// Traceability: R-WT4
