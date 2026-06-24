// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// COLDSTART-1 [R-G7] tests for the pure cold-start CEFR-anchor prior mapping.
// Golden values were computed from the P0-8 logit-scale anchor table
// (A1 −2.5 … C2 +2.5, even 1.0-logit spacing) plus the ≤0.5 offset clamp, and
// cross-checked in python. Properties proven: each band maps to its exact
// anchor; an offset within the bound passes through; an offset beyond the bound
// is clamped; a clamped prior never crosses into a neighbour band (each band
// owns a 1.0-logit slice); priorThetaForBand returns the band anchor θ; bandFor
// inverts a prior to its owning band; the anchor table + offset bound are
// injected (not hard-coded); the mapping is fully deterministic. No clock, no
// I/O.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel;
import 'package:ratel/services/services.dart';

void main() {
  const ColdStartModel model = ColdStartModel();

  group('anchor table on the logit scale', () {
    test('each band maps to its exact anchor', () {
      expect(model.irtBForItem(CefrLevel.a1), closeTo(-2.5, 1e-12));
      expect(model.irtBForItem(CefrLevel.a2), closeTo(-1.5, 1e-12));
      expect(model.irtBForItem(CefrLevel.b1), closeTo(-0.5, 1e-12));
      expect(model.irtBForItem(CefrLevel.b2), closeTo(0.5, 1e-12));
      expect(model.irtBForItem(CefrLevel.c1), closeTo(1.5, 1e-12));
      expect(model.irtBForItem(CefrLevel.c2), closeTo(2.5, 1e-12));
    });

    test('anchors ascend in even 1.0-logit steps', () {
      expect(model.irtBForItem(CefrLevel.a2) - model.irtBForItem(CefrLevel.a1),
          closeTo(1.0, 1e-12));
      expect(model.irtBForItem(CefrLevel.b1) - model.irtBForItem(CefrLevel.a2),
          closeTo(1.0, 1e-12));
      expect(model.irtBForItem(CefrLevel.b2) - model.irtBForItem(CefrLevel.b1),
          closeTo(1.0, 1e-12));
      expect(model.irtBForItem(CefrLevel.c1) - model.irtBForItem(CefrLevel.b2),
          closeTo(1.0, 1e-12));
      expect(model.irtBForItem(CefrLevel.c2) - model.irtBForItem(CefrLevel.c1),
          closeTo(1.0, 1e-12));
    });
  });

  group('cold-start irt_b = anchor + clamped offset', () {
    test('an offset within the bound passes through', () {
      expect(model.irtBForItem(CefrLevel.b1, 0.3), closeTo(-0.2, 1e-9));
      expect(model.irtBForItem(CefrLevel.c1, -0.4), closeTo(1.1, 1e-9));
    });

    test('an offset beyond +bound clamps to +bound', () {
      expect(model.irtBForItem(CefrLevel.b1, 1.0), closeTo(0.0, 1e-12));
      expect(model.irtBForItem(CefrLevel.a1, 5.0), closeTo(-2.0, 1e-12));
    });

    test('an offset beyond -bound clamps to -bound', () {
      expect(model.irtBForItem(CefrLevel.b1, -1.0), closeTo(-1.0, 1e-12));
      expect(model.irtBForItem(CefrLevel.c2, -5.0), closeTo(2.0, 1e-12));
    });

    test('at exactly the bound the offset is unchanged', () {
      expect(model.irtBForItem(CefrLevel.b1, 0.5), closeTo(0.0, 1e-12));
      expect(model.irtBForItem(CefrLevel.b1, -0.5), closeTo(-1.0, 1e-12));
    });
  });

  group('a clamped prior never crosses into a neighbour band', () {
    test('every band and any offset stays within its 1.0-logit slice', () {
      const List<double> offsets = <double>[
        -10.0, -0.6, -0.5, 0.0, 0.3, 0.5, 0.6, 10.0,
      ];
      for (final CefrLevel band in CefrLevel.values) {
        final double anchor = CefrAnchors.defaults.anchorFor(band);
        for (final double offset in offsets) {
          final double b = model.irtBForItem(band, offset);
          expect(b, greaterThanOrEqualTo(anchor - 0.5 - 1e-9));
          expect(b, lessThanOrEqualTo(anchor + 0.5 + 1e-9));
          expect((b - anchor).abs(), lessThanOrEqualTo(0.5 + 1e-9));
        }
      }
    });

    test('B1 cold-start priors stay within [-1.0, 0.0]', () {
      const List<double> offsets = <double>[-9.0, -0.5, 0.0, 0.5, 9.0];
      for (final double offset in offsets) {
        final double b = model.irtBForItem(CefrLevel.b1, offset);
        expect(b, greaterThanOrEqualTo(-1.0 - 1e-9));
        expect(b, lessThanOrEqualTo(0.0 + 1e-9));
      }
    });
  });

  group('learner ability prior', () {
    test('priorThetaForBand returns the band anchor theta', () {
      expect(model.priorThetaForBand(CefrLevel.a1), closeTo(-2.5, 1e-12));
      expect(model.priorThetaForBand(CefrLevel.b1), closeTo(-0.5, 1e-12));
      expect(model.priorThetaForBand(CefrLevel.c2), closeTo(2.5, 1e-12));
      // The prior θ for a band equals that band's irt_b anchor (same scale).
      for (final CefrLevel band in CefrLevel.values) {
        expect(model.priorThetaForBand(band), model.irtBForItem(band));
      }
    });
  });

  group('bandFor maps a prior back to its owning band', () {
    test('an anchor maps back to its own band', () {
      for (final CefrLevel band in CefrLevel.values) {
        expect(model.bandFor(model.irtBForItem(band)), band);
      }
    });

    test('an interior prior maps to its band', () {
      expect(model.bandFor(-0.2), CefrLevel.b1);
      expect(model.bandFor(1.1), CefrLevel.c1);
    });

    test('a shared boundary resolves to the lower band', () {
      expect(model.bandFor(0.0), CefrLevel.b1);
      expect(model.bandFor(-1.0), CefrLevel.a2);
    });

    test('a value outside every slice is null', () {
      expect(model.bandFor(5.0), isNull);
      expect(model.bandFor(-4.0), isNull);
      expect(model.bandFor(3.6), isNull);
    });

    test('the scale edges are still in range', () {
      expect(model.bandFor(-3.0), CefrLevel.a1);
      expect(model.bandFor(3.0), CefrLevel.c2);
    });
  });

  group('params are injected, not hard-coded', () {
    test('a wider injected offset bound lets a larger guess through', () {
      const ColdStartModel wide =
          ColdStartModel(CefrAnchors(offsetBound: 1.0));
      // Under the wide bound the +0.8 guess passes through unclamped...
      expect(wide.irtBForItem(CefrLevel.b1, 0.8), closeTo(0.3, 1e-9));
      // ...while the default ±0.5 bound clamps the same guess back to the edge.
      expect(model.irtBForItem(CefrLevel.b1, 0.8), closeTo(0.0, 1e-12));
    });

    test('a custom injected anchor is honored', () {
      const ColdStartModel custom = ColdStartModel(CefrAnchors(b1: 0.0));
      expect(custom.irtBForItem(CefrLevel.b1), closeTo(0.0, 1e-12));
      expect(custom.priorThetaForBand(CefrLevel.b1), closeTo(0.0, 1e-12));
      // Other bands keep their defaults.
      expect(custom.irtBForItem(CefrLevel.c1), closeTo(1.5, 1e-12));
    });
  });

  group('determinism', () {
    test('same band + offset => identical irt_b and theta', () {
      expect(model.irtBForItem(CefrLevel.b2, 0.25),
          model.irtBForItem(CefrLevel.b2, 0.25));
      expect(model.priorThetaForBand(CefrLevel.b2),
          model.priorThetaForBand(CefrLevel.b2));
    });
  });
}
