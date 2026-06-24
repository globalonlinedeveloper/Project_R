// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// CAPS-1 [R-M8 · R-H7] tests for the relay request-size hard cap. Proves a fail-closed,
// deterministic size ceiling rejects an over-size prompt UP FRONT — before moderation, the
// meter, or the paid model — so it costs nothing and is never silently truncated. Three
// layers: the pure [RequestSizeGuard], the [RequestSizeLimitedAiRelay] decorator in isolation,
// and the full buildModeratedBudgetedRelay stack (the size cap slots OUTERMOST). No network.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

/// Inner spy: counts how many times the wrapped stack (moderation+meter+model) is reached.
class _SpyModel implements AiRelay {
  _SpyModel({this.out = 'model reply'});
  final String out;
  int calls = 0;
  @override
  bool get isAvailable => true;
  @override
  Future<RelayText> complete(String prompt) async {
    calls++;
    return RelayText(out);
  }
}

/// Moderation provider that ALWAYS allows but counts classify calls, so a test can prove an
/// over-size prompt was rejected BEFORE moderation ran (call count stays 0).
class _CountingProvider implements ModerationProvider {
  int calls = 0;
  @override
  Future<ModerationVerdict> classify(String text) async {
    calls++;
    return ModerationVerdict.allowed;
  }
}

const _prompt = 'please summarize this paragraph'; // 31 chars; clean

void main() {
  group('RequestSizeGuard (pure check)', () {
    test('under / at the char limit passes; one over denies (chars)', () {
      const guard = RequestSizeGuard(RequestSizeLimits(maxChars: 10));
      expect(guard.check('').isAllow, isTrue, reason: 'empty is not too large');
      expect(guard.check('a' * 9).isAllow, isTrue);
      expect(guard.check('a' * 10).isAllow, isTrue, reason: 'AT the limit passes');
      expect(guard.check('a' * 11), RequestSizeDecision.denyChars,
          reason: 'one over the limit denies');
    });

    test('token axis is OFF by default (maxTokens null)', () {
      const guard = RequestSizeGuard(RequestSizeLimits(maxChars: 100000));
      // 400 chars would be ~100 tokens, but with no token cap it still passes.
      expect(guard.check('a' * 400).isAllow, isTrue);
    });

    test('estimateTokens is deterministic ceil(chars / charsPerToken) — heuristic injected', () {
      // charsPerToken: 5 is non-default (default is 4), proving the ratio is injected.
      const guard = RequestSizeGuard(RequestSizeLimits(charsPerToken: 5));
      expect(guard.estimateTokens(''), 0);
      expect(guard.estimateTokens('a' * 10), 2);
      expect(guard.estimateTokens('a' * 11), 3, reason: 'ceil, not floor');
    });

    test('optional token ceiling denies when chars pass but tokens exceed', () {
      const guard = RequestSizeGuard(
          RequestSizeLimits(maxChars: 100000, maxTokens: 4, charsPerToken: 2));
      expect(guard.check('a' * 8).isAllow, isTrue, reason: '4 tokens == cap');
      expect(guard.check('a' * 9), RequestSizeDecision.denyTokens,
          reason: '5 tokens > cap (chars still well under maxChars)');
    });

    test('char ceiling is checked before the token ceiling', () {
      const guard = RequestSizeGuard(
          RequestSizeLimits(maxChars: 5, maxTokens: 1, charsPerToken: 2));
      // 8 chars exceeds BOTH; the char axis reports first.
      expect(guard.check('a' * 8), RequestSizeDecision.denyChars);
    });
  });

  group('RequestSizeLimitedAiRelay (decorator in isolation)', () {
    test('over-size prompt is REJECTED before the inner relay (calls==0)', () async {
      final inner = _SpyModel();
      final r = RequestSizeLimitedAiRelay(inner,
          guard: const RequestSizeGuard(RequestSizeLimits(maxChars: 10)));
      await expectLater(r.complete('a' * 11), throwsA(isA<RequestTooLarge>()));
      expect(inner.calls, 0, reason: 'inner relay never reached on an over-size prompt');
    });

    test('at/under the limit passes through and returns the inner output', () async {
      final inner = _SpyModel(out: 'ok');
      final r = RequestSizeLimitedAiRelay(inner,
          guard: const RequestSizeGuard(RequestSizeLimits(maxChars: 10)));
      final out = await r.complete('a' * 10);
      expect(out.plain, 'ok');
      expect(inner.calls, 1);
    });

    test('empty prompt passes through', () async {
      final inner = _SpyModel();
      final r = RequestSizeLimitedAiRelay(inner,
          guard: const RequestSizeGuard(RequestSizeLimits(maxChars: 10)));
      await r.complete('');
      expect(inner.calls, 1);
    });

    test('the limit is INJECTED — a stricter guard rejects what a looser one allows', () async {
      final inner = _SpyModel();
      final strict = RequestSizeLimitedAiRelay(inner,
          guard: const RequestSizeGuard(RequestSizeLimits(maxChars: 5)));
      await expectLater(strict.complete(_prompt), throwsA(isA<RequestTooLarge>()));
      expect(inner.calls, 0);

      final loose = RequestSizeLimitedAiRelay(inner,
          guard: const RequestSizeGuard(RequestSizeLimits(maxChars: 1000)));
      await loose.complete(_prompt);
      expect(inner.calls, 1, reason: 'same prompt, looser limit -> passes');
    });

    test('RequestTooLarge carries the decision, actual chars, and breached limit', () async {
      final inner = _SpyModel();
      final r = RequestSizeLimitedAiRelay(inner,
          guard: const RequestSizeGuard(RequestSizeLimits(maxChars: 5)));
      try {
        await r.complete('a' * 9);
        fail('expected RequestTooLarge');
      } on RequestTooLarge catch (e) {
        expect(e.decision, RequestSizeDecision.denyChars);
        expect(e.chars, 9);
        expect(e.limit, 5);
      }
    });
  });

  group('buildModeratedBudgetedRelay (CAPS-1 slots OUTERMOST)', () {
    test('over-size prompt rejected BEFORE moderation, meter, and model', () async {
      final model = _SpyModel();
      final provider = _CountingProvider();
      var recorded = 0;
      final relay = buildModeratedBudgetedRelay(
        model: model,
        moderationProvider: provider,
        userSpentToday: () async => 0,
        globalSpentToday: () async => 0,
        recordSpend: (c) async => recorded += c,
        sizeGuard: const RequestSizeGuard(RequestSizeLimits(maxChars: 5)),
      );
      await expectLater(relay.complete(_prompt), throwsA(isA<RequestTooLarge>()));
      expect(model.calls, 0, reason: 'model never called');
      expect(provider.calls, 0, reason: 'moderation never called (cap is outermost)');
      expect(recorded, 0, reason: 'nothing charged');
    });

    test('in-size prompt flows through the full stack and charges exactly once', () async {
      final model = _SpyModel(out: 'clean answer');
      final provider = _CountingProvider();
      var recorded = 0;
      var charges = 0;
      const guard = CostGuard();
      final relay = buildModeratedBudgetedRelay(
        model: model,
        moderationProvider: provider,
        userSpentToday: () async => 0,
        globalSpentToday: () async => 0,
        recordSpend: (c) async {
          recorded += c;
          charges += 1;
        },
        guard: guard,
        // default sizeGuard (maxChars 8000) comfortably allows the short prompt.
      );
      final out = await relay.complete(_prompt);
      expect(out.plain, 'clean answer');
      expect(model.calls, 1);
      expect(provider.calls, 2, reason: 'input + output moderation both ran');
      expect(charges, 1, reason: 'no double-charge');
      expect(recorded, guard.estimateCost(_prompt));
    });
  });
}
