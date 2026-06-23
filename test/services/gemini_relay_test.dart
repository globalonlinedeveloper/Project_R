// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// M3 [R-H7] tests: Gemini adapter against a FAKE transport. Unconfigured fails
// closed (transport untouched); 200 parses to RelayText with the right request
// shape; non-2xx/transport-error/timeout => RelayUnavailable (no body leak);
// malformed/empty payload => RelayBadResponse; output stays RelayText; and the
// M1+M2+M3 composition works end-to-end with fakes.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

class _CapturingTransport {
  _CapturingTransport(this._responder);
  final Future<HttpLikeResponse> Function(HttpLikeRequest req) _responder;
  int calls = 0;
  HttpLikeRequest? last;
  Future<HttpLikeResponse> handle(HttpLikeRequest req) {
    calls++;
    last = req;
    return _responder(req);
  }
}

String _okBody(String text) => jsonEncode({
      'candidates': [
        {
          'content': {
            'role': 'model',
            'parts': [
              {'text': text},
            ],
          },
        },
      ],
    });

const _cfg = GeminiConfig(baseUrl: 'https://gemini.test', apiKey: 'K');

void main() {
  test('unconfigured: isAvailable false, complete throws, transport untouched',
      () async {
    final t = _CapturingTransport(
        (r) async => const HttpLikeResponse(statusCode: 200, body: '{}'));
    final relay = GeminiAiRelay(transport: t.handle); // default empty config
    expect(relay.isAvailable, isFalse);
    await expectLater(relay.complete('hi'), throwsA(isA<RelayUnavailable>()));
    expect(t.calls, 0);
  });

  test('configured 200 -> RelayText parsed; request shape asserted', () async {
    final t = _CapturingTransport((r) async =>
        HttpLikeResponse(statusCode: 200, body: _okBody('hello from gemini')));
    final relay = GeminiAiRelay(
      transport: t.handle,
      config: const GeminiConfig(
          baseUrl: 'https://gemini.test', model: 'gemini-x', apiKey: 'FAKEKEY'),
    );
    expect(relay.isAvailable, isTrue);
    final r = await relay.complete('say hi');
    expect(r, isA<RelayText>());
    expect(r.plain, 'hello from gemini');
    expect(t.calls, 1);
    expect(t.last!.method, 'POST');
    expect(t.last!.url, contains('gemini-x:generateContent'));
    expect(t.last!.headers['x-goog-api-key'], 'FAKEKEY');
    expect(t.last!.body, contains('say hi'));
  });

  test('non-2xx -> RelayUnavailable, upstream body not leaked', () async {
    final t = _CapturingTransport((r) async =>
        const HttpLikeResponse(statusCode: 503, body: 'UPSTREAM-SECRET-ERR'));
    final relay = GeminiAiRelay(transport: t.handle, config: _cfg);
    try {
      await relay.complete('hi');
      fail('expected RelayUnavailable');
    } on RelayUnavailable catch (e) {
      expect(e.toString(), isNot(contains('UPSTREAM-SECRET-ERR')));
      expect(e.toString(), contains('503'));
    }
  });

  test('malformed JSON -> RelayBadResponse (no crash)', () async {
    final t = _CapturingTransport(
        (r) async => const HttpLikeResponse(statusCode: 200, body: 'not json{'));
    final relay = GeminiAiRelay(transport: t.handle, config: _cfg);
    await expectLater(relay.complete('hi'), throwsA(isA<RelayBadResponse>()));
  });

  test('empty candidates -> RelayBadResponse', () async {
    final t = _CapturingTransport((r) async =>
        const HttpLikeResponse(statusCode: 200, body: '{"candidates":[]}'));
    final relay = GeminiAiRelay(transport: t.handle, config: _cfg);
    await expectLater(relay.complete('hi'), throwsA(isA<RelayBadResponse>()));
  });

  test('transport throws -> RelayUnavailable', () async {
    final t = _CapturingTransport((r) async => throw StateError('socket'));
    final relay = GeminiAiRelay(transport: t.handle, config: _cfg);
    await expectLater(relay.complete('hi'), throwsA(isA<RelayUnavailable>()));
  });

  test('transport timeout -> RelayUnavailable', () async {
    final t = _CapturingTransport((r) => Future.delayed(
        const Duration(milliseconds: 500),
        () => const HttpLikeResponse(statusCode: 200, body: '{}')));
    final relay = GeminiAiRelay(
        transport: t.handle,
        config: _cfg,
        timeout: const Duration(milliseconds: 20));
    await expectLater(relay.complete('hi'), throwsA(isA<RelayUnavailable>()));
  });

  test('result is RelayText; toString does not leak raw text', () async {
    const raw = 'TOP-SECRET-OUTPUT';
    final t = _CapturingTransport(
        (r) async => HttpLikeResponse(statusCode: 200, body: _okBody(raw)));
    final relay = GeminiAiRelay(transport: t.handle, config: _cfg);
    final r = await relay.complete('hi');
    expect(r.toString(), isNot(contains(raw)));
    expect(r.plain, raw);
  });

  test('compose M1+M2+M3 happy path (budget+moderation+gemini)', () async {
    final t = _CapturingTransport((r) async =>
        HttpLikeResponse(statusCode: 200, body: _okBody('composed-ok')));
    final gemini = GeminiAiRelay(transport: t.handle, config: _cfg);
    final moderated = ModeratedAiRelay(
      gemini,
      provider: const KeywordModerationProvider({}), // empty blocklist => allow
    );
    var recorded = 0;
    final budgeted = BudgetedAiRelay(
      moderated,
      userSpentToday: () async => 0,
      globalSpentToday: () async => 0,
      recordSpend: (c) async => recorded += c,
      guard: const CostGuard(
          CostConfig(perUserDailyCap: 1000, globalDailyCeiling: 100000)),
    );
    final r = await budgeted.complete('hello');
    expect(r.plain, 'composed-ok');
    expect(t.calls, 1);
    expect(recorded, greaterThan(0));
  });
}
