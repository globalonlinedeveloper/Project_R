// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// CAT-1 [R-G4] tests for the pure placement-test selection + estimation core.
// Golden values were computed from the 3PL information / EAP formulas and
// cross-checked in python. Properties proven: 3PL item information reduces to
// a²·P·Q for 1PL (peaking at θ=b), a>1 raises the peak ∝ a², and a guessing
// floor shifts the peak above b; Maximum Fisher Information selection picks the
// most informative unseen item with a deterministic id tie-break; the EAP
// estimate returns the prior with no responses, rises with more-correct answers,
// and its SE shrinks as items accumulate; the variable-length stop rule honours
// the min/max envelope and the injected SE threshold; the grid/prior/threshold/
// length are injected, not hard-coded; everything is deterministic. No clock,
// no I/O, no randomness.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

void main() {
  const CatModel model = CatModel();

  group('3PL item information I(θ)', () {
    test('1PL information peaks at θ=b and equals a²·P·Q', () {
      const IrtItem item = IrtItem(b: 0.0);
      expect(model.information(0.0, item), closeTo(0.25, 1e-9));
      expect(model.information(0.0, item),
          greaterThan(model.information(0.3, item)));
      expect(model.information(0.0, item),
          greaterThan(model.information(-0.3, item)));
    });

    test('golden 1PL information value at θ−b=1', () {
      const IrtItem item = IrtItem(b: 0.0);
      expect(model.information(1.0, item), closeTo(0.19661193324148185, 1e-9));
    });

    test('1PL information is symmetric around b', () {
      const IrtItem item = IrtItem(b: 0.0);
      expect(model.information(0.5, item),
          closeTo(model.information(-0.5, item), 1e-12));
    });

    test('a>1 raises the information peak ∝ a²', () {
      const IrtItem oneP = IrtItem(b: 0.0);
      const IrtItem twoP = IrtItem(b: 0.0, a: 2.0);
      expect(model.information(0.0, twoP), closeTo(1.0, 1e-9));
      expect(model.information(0.0, twoP),
          greaterThan(model.information(0.0, oneP)));
    });

    test('a guessing floor shifts the information peak above b and lowers it',
        () {
      const IrtItem item = IrtItem(b: 0.0, c: 0.2);
      expect(model.information(0.0, item), closeTo(0.16666666666666666, 1e-9));
      expect(model.information(0.3, item),
          greaterThan(model.information(0.0, item)));
    });

    test('information vanishes far from b and is never negative', () {
      const IrtItem item = IrtItem(b: 0.0);
      expect(model.information(-6.0, item), closeTo(0.0, 0.01));
      expect(model.information(-6.0, item), greaterThanOrEqualTo(0.0));
    });
  });

  group('Maximum Fisher Information selection', () {
    const List<CatItem> bank = <CatItem>[
      CatItem(id: 'b_neg2', params: IrtItem(b: -2.0)),
      CatItem(id: 'b_neg05', params: IrtItem(b: -0.5)),
      CatItem(id: 'b_03', params: IrtItem(b: 0.3)),
      CatItem(id: 'b_15', params: IrtItem(b: 1.5)),
    ];

    test('picks the item whose b is nearest θ among equal-a items', () {
      expect(model.selectNext(bank, 0.0, const <String>{})?.id, 'b_03');
    });

    test('skips already-seen items', () {
      expect(
          model.selectNext(bank, 0.0, const <String>{'b_03'})?.id, 'b_neg05');
    });

    test('returns null when every item has been seen', () {
      const Set<String> all = <String>{'b_neg2', 'b_neg05', 'b_03', 'b_15'};
      expect(model.selectNext(bank, 0.0, all), isNull);
    });

    test('a high-discrimination item can beat a nearer low-a item', () {
      const CatItem near = CatItem(id: 'near', params: IrtItem(b: 0.0, a: 0.3));
      const CatItem sharp =
          CatItem(id: 'sharp', params: IrtItem(b: 0.8, a: 2.0));
      expect(
          model.selectNext(const <CatItem>[near, sharp], 0.0, const <String>{})
              ?.id,
          'sharp');
    });

    test('ties break deterministically on the smaller id', () {
      const CatItem x = CatItem(id: 'aaa', params: IrtItem(b: 0.0));
      const CatItem y = CatItem(id: 'bbb', params: IrtItem(b: 0.0));
      expect(
          model.selectNext(const <CatItem>[x, y], 0.0, const <String>{})?.id,
          'aaa');
      expect(
          model.selectNext(const <CatItem>[y, x], 0.0, const <String>{})?.id,
          'aaa');
    });
  });

  group('EAP θ estimate', () {
    const List<CatItem> items = <CatItem>[
      CatItem(id: 'i_neg1', params: IrtItem(b: -1.0)),
      CatItem(id: 'i_neg05', params: IrtItem(b: -0.5)),
      CatItem(id: 'i_0', params: IrtItem(b: 0.0)),
      CatItem(id: 'i_05', params: IrtItem(b: 0.5)),
      CatItem(id: 'i_1', params: IrtItem(b: 1.0)),
    ];

    List<CatResponse> pattern(List<bool> correct) => <CatResponse>[
          for (int i = 0; i < correct.length; i++)
            CatResponse(item: items[i], correct: correct[i]),
        ];

    test('no responses returns the prior (θ≈0, SE≈1)', () {
      final EapEstimate e = model.eap(const <CatResponse>[]);
      expect(e.theta, closeTo(0.0, 1e-9));
      expect(e.se, closeTo(1.0, 0.01));
    });

    test('θ rises as more answers are correct', () {
      final EapEstimate two =
          model.eap(pattern(const <bool>[true, true, false, false, false]));
      final EapEstimate three =
          model.eap(pattern(const <bool>[true, true, true, false, false]));
      expect(three.theta, greaterThan(two.theta));
    });

    test('all-correct places θ high, all-wrong places θ low', () {
      final EapEstimate hi =
          model.eap(pattern(const <bool>[true, true, true, true, true]));
      final EapEstimate lo =
          model.eap(pattern(const <bool>[false, false, false, false, false]));
      expect(hi.theta, greaterThan(1.0));
      expect(lo.theta, lessThan(-1.0));
    });

    test('the standard error shrinks as items accumulate', () {
      const CatItem at0 = CatItem(id: 'a0', params: IrtItem(b: 0.0));
      List<CatResponse> alt(int n) => <CatResponse>[
            for (int i = 0; i < n; i++)
              CatResponse(item: at0, correct: i.isEven),
          ];
      final double se2 = model.eap(alt(2)).se;
      final double se6 = model.eap(alt(6)).se;
      final double se12 = model.eap(alt(12)).se;
      expect(se6, lessThan(se2));
      expect(se12, lessThan(se6));
    });

    test('golden EAP θ and SE for a fixed answer pattern', () {
      final EapEstimate e =
          model.eap(pattern(const <bool>[true, true, true, false, false]));
      expect(e.theta, closeTo(0.2470770829597662, 1e-6));
      expect(e.se, closeTo(0.7041310887462325, 1e-6));
    });
  });

  group('variable-length stop rule', () {
    test('never stops before the minimum length', () {
      expect(model.shouldStop(7, 0.0), isFalse);
      expect(model.shouldStop(0, 0.01), isFalse);
    });

    test('always stops at the maximum length regardless of SE', () {
      expect(model.shouldStop(25, 1.0), isTrue);
      expect(model.shouldStop(30, 5.0), isTrue);
    });

    test('between min and max, stops once SE is strictly below the threshold',
        () {
      expect(model.shouldStop(8, 0.29), isTrue);
      expect(model.shouldStop(8, 0.31), isFalse);
      expect(model.shouldStop(8, 0.30), isFalse);
    });
  });

  group('configuration is injected, not hard-coded', () {
    test('the prior mean is honoured with no responses', () {
      const CatModel shifted = CatModel(CatConfig(priorMean: 1.0));
      expect(shifted.eap(const <CatResponse>[]).theta, closeTo(1.0, 0.01));
    });

    test('the SE threshold is injected', () {
      const CatModel loose = CatModel(CatConfig(seThreshold: 0.5));
      expect(loose.shouldStop(8, 0.4), isTrue);
      expect(model.shouldStop(8, 0.4), isFalse);
    });

    test('the length envelope is injected', () {
      const CatModel shortCat = CatModel(CatConfig(minLength: 4, maxLength: 10));
      expect(shortCat.shouldStop(4, 0.1), isTrue);
      expect(shortCat.shouldStop(10, 9.9), isTrue);
      expect(shortCat.shouldStop(3, 0.0), isFalse);
    });

    test('a coarser grid yields essentially the same estimate', () {
      const List<CatResponse> p = <CatResponse>[
        CatResponse(
            item: CatItem(id: 'x', params: IrtItem(b: 0.0)), correct: true),
        CatResponse(
            item: CatItem(id: 'y', params: IrtItem(b: 0.5)), correct: false),
      ];
      const CatModel coarse = CatModel(CatConfig(gridStep: 0.5));
      expect(coarse.eap(p).theta, closeTo(model.eap(p).theta, 0.05));
    });

    test('selection and estimation are deterministic', () {
      const IrtItem item = IrtItem(b: 0.2, a: 1.3, c: 0.1);
      expect(model.information(0.4, item), model.information(0.4, item));
      const List<CatResponse> p = <CatResponse>[
        CatResponse(
            item: CatItem(id: 'x', params: IrtItem(b: 0.0)), correct: true),
      ];
      expect(model.eap(p).theta, model.eap(p).theta);
      expect(model.eap(p).se, model.eap(p).se);
    });
  });
}
