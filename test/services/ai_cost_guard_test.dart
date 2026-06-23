// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// M1 [R-H7 / R-M8 · TS-4] tests: deterministic cost estimate, fail-closed
// budget gate, and the BudgetedAiRelay decorator (inner NEVER called on deny).
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

/// Spy inner relay: counts delegations so "inner NEVER called on deny" is provable.
class _SpyRelay implements AiRelay {
  int calls = 0;
  @override
  bool get isAvailable => true;
  @override
  Future<RelayText> complete(String prompt) async {
    calls++;
    return RelayText('ok:$prompt');
  }
}

void main() {
  group('M1 CostGuard.estimateCost', () {
    test('is >= floor and monotonic non-decreasing in prompt length', () {
      const g = CostGuard(
          CostConfig(unitFloor: 1, charsPerUnit: 10, unitPrice: 2));
      var prev = -1;
      for (final n in [0, 1, 9, 10, 11, 100, 1000]) {
        final c = g.estimateCost('x' * n);
        expect(c, greaterThanOrEqualTo(1), reason: 'len=$n below floor');
        expect(c, greaterThanOrEqualTo(prev), reason: 'len=$n not monotonic');
        prev = c;
      }
    });
    test('is deterministic for the same prompt', () {
      const g = CostGuard();
      expect(g.estimateCost('hello world'), g.estimateCost('hello world'));
    });
  });

  group('M1 CostGuard.check (fail-closed)', () {
    const g = CostGuard(
        CostConfig(perUserDailyCap: 50, globalDailyCeiling: 1000));
    test('under both caps -> allow', () {
      expect(
          g.check(userSpentToday: 0, globalSpentToday: 0, estimate: 10).isAllow,
          isTrue);
    });
    test('at or over per-user cap -> denyPerUserCap', () {
      expect(g.check(userSpentToday: 50, globalSpentToday: 0, estimate: 1),
          CostDecision.denyPerUserCap);
      expect(g.check(userSpentToday: 45, globalSpentToday: 0, estimate: 10),
          CostDecision.denyPerUserCap);
    });
    test('over global ceiling denies even when the user is under cap', () {
      expect(g.check(userSpentToday: 0, globalSpentToday: 1000, estimate: 1),
          CostDecision.denyGlobalCeiling);
    });
    test('null inputs -> denyInvalid', () {
      expect(g.check(userSpentToday: null, globalSpentToday: 0, estimate: 1),
          CostDecision.denyInvalid);
      expect(g.check(userSpentToday: 0, globalSpentToday: null, estimate: 1),
          CostDecision.denyInvalid);
      expect(g.check(userSpentToday: 0, globalSpentToday: 0, estimate: null),
          CostDecision.denyInvalid);
    });
    test('negative inputs -> denyInvalid', () {
      expect(g.check(userSpentToday: -1, globalSpentToday: 0, estimate: 1),
          CostDecision.denyInvalid);
      expect(g.check(userSpentToday: 0, globalSpentToday: -5, estimate: 1),
          CostDecision.denyInvalid);
      expect(g.check(userSpentToday: 0, globalSpentToday: 0, estimate: -1),
          CostDecision.denyInvalid);
    });
  });

  group('M1 BudgetedAiRelay', () {
    test('under cap -> inner called once, spend recorded once', () async {
      final spy = _SpyRelay();
      var recorded = 0;
      final relay = BudgetedAiRelay(
        spy,
        userSpentToday: () async => 0,
        globalSpentToday: () async => 0,
        recordSpend: (c) async => recorded += c,
        guard: const CostGuard(CostConfig(
            perUserDailyCap: 1000, globalDailyCeiling: 100000)),
      );
      final r = await relay.complete('hello');
      expect(spy.calls, 1);
      expect(recorded, greaterThan(0));
      expect(r, isA<RelayText>());
    });

    test('at/over per-user cap -> deny, inner NEVER called, no spend', () async {
      final spy = _SpyRelay();
      var recorded = 0;
      final relay = BudgetedAiRelay(
        spy,
        userSpentToday: () async => 50,
        globalSpentToday: () async => 0,
        recordSpend: (c) async => recorded += c,
        guard: const CostGuard(CostConfig(
            perUserDailyCap: 50, globalDailyCeiling: 100000)),
      );
      await expectLater(
          relay.complete('hello'), throwsA(isA<RelayBudgetExceeded>()));
      expect(spy.calls, 0);
      expect(recorded, 0);
    });

    test('over global ceiling -> deny even if user under cap, inner not called',
        () async {
      final spy = _SpyRelay();
      final relay = BudgetedAiRelay(
        spy,
        userSpentToday: () async => 0,
        globalSpentToday: () async => 100000,
        recordSpend: (c) async {},
        guard: const CostGuard(CostConfig(
            perUserDailyCap: 1000, globalDailyCeiling: 100000)),
      );
      try {
        await relay.complete('hello');
        fail('expected RelayBudgetExceeded');
      } on RelayBudgetExceeded catch (e) {
        expect(e.decision, CostDecision.denyGlobalCeiling);
      }
      expect(spy.calls, 0);
    });

    test('spend provider that throws -> fail closed, inner NEVER called',
        () async {
      final spy = _SpyRelay();
      final relay = BudgetedAiRelay(
        spy,
        userSpentToday: () async => throw StateError('ledger down'),
        globalSpentToday: () async => 0,
        recordSpend: (c) async {},
      );
      await expectLater(
          relay.complete('hi'), throwsA(isA<RelayBudgetExceeded>()));
      expect(spy.calls, 0);
    });

    test('burst crossing the cap delegates only the in-budget calls', () async {
      final spy = _SpyRelay();
      var userSpent = 0;
      final relay = BudgetedAiRelay(
        spy,
        userSpentToday: () async => userSpent,
        globalSpentToday: () async => 0,
        recordSpend: (c) async => userSpent += c,
        guard: const CostGuard(CostConfig(
            perUserDailyCap: 20,
            globalDailyCeiling: 100000,
            unitFloor: 5,
            charsPerUnit: 1000,
            unitPrice: 5)), // each short prompt costs exactly 5 credits
      );
      var allowed = 0;
      var denied = 0;
      for (var i = 0; i < 10; i++) {
        try {
          await relay.complete('hi');
          allowed++;
        } on RelayBudgetExceeded {
          denied++;
        }
      }
      expect(allowed, 4); // 20 cap / 5 per call
      expect(denied, 6);
      expect(spy.calls, 4);
      expect(userSpent, 20);
    });

    test('isAvailable delegates to the inner relay', () {
      final relay = BudgetedAiRelay(
        _SpyRelay(),
        userSpentToday: () async => 0,
        globalSpentToday: () async => 0,
        recordSpend: (c) async {},
      );
      expect(relay.isAvailable, isTrue);
    });
  });
}
