import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/backend_wiring.dart' show aiRelayUrl;
import 'package:ratel/services/ai_relay/ai_relay.dart';

// INC4 client seam: EdgeAiRelay POSTs { prompt } to the SERVER-SIDE relay (which
// holds the model key) and reads { text } back. The model key never touches the
// client. Pure over an injected transport; fails closed on every error path.
// [R-H7]

void main() {
  HttpTransport ok(String body, {int status = 200}) =>
      (HttpLikeRequest _) async =>
          HttpLikeResponse(statusCode: status, body: body);

  group('EdgeAiRelay', () {
    test('unconfigured (empty url) fails closed; transport untouched', () async {
      final EdgeAiRelay relay = EdgeAiRelay(
        transport: (HttpLikeRequest _) async => fail('must not call transport'),
      );
      expect(relay.isAvailable, isFalse);
      await expectLater(
          relay.complete('hi'), throwsA(isA<RelayUnavailable>()));
    });

    test('buildRequest POSTs {prompt} to the url', () {
      final EdgeAiRelay relay = EdgeAiRelay(
          transport: ok('{}'), url: 'https://x/functions/v1/ai-relay');
      final HttpLikeRequest req = relay.buildRequest('hola');
      expect(req.method, 'POST');
      expect(req.url, 'https://x/functions/v1/ai-relay');
      expect(req.body, '{"prompt":"hola"}');
    });

    test('2xx {text} -> RelayText', () async {
      final EdgeAiRelay relay =
          EdgeAiRelay(transport: ok('{"text":"buenos dias"}'), url: 'https://x');
      final RelayText out = await relay.complete('hola');
      expect(out.plain, 'buenos dias');
    });

    test('non-2xx fails closed (RelayUnavailable)', () async {
      final EdgeAiRelay relay = EdgeAiRelay(
          transport: ok('{"error":"relay_unconfigured"}', status: 503),
          url: 'https://x');
      await expectLater(
          relay.complete('hi'), throwsA(isA<RelayUnavailable>()));
    });

    test('malformed JSON -> RelayBadResponse', () async {
      final EdgeAiRelay relay =
          EdgeAiRelay(transport: ok('not json'), url: 'https://x');
      await expectLater(
          relay.complete('hi'), throwsA(isA<RelayBadResponse>()));
    });

    test('missing/empty text -> RelayBadResponse', () async {
      final EdgeAiRelay relay =
          EdgeAiRelay(transport: ok('{"error":"empty"}'), url: 'https://x');
      await expectLater(
          relay.complete('hi'), throwsA(isA<RelayBadResponse>()));
    });

    test('transport throw -> RelayUnavailable', () async {
      final EdgeAiRelay relay = EdgeAiRelay(
        transport: (HttpLikeRequest _) async => throw Exception('boom'),
        url: 'https://x',
      );
      await expectLater(
          relay.complete('hi'), throwsA(isA<RelayUnavailable>()));
    });
  });

  test('aiRelayUrl derives the functions endpoint', () {
    expect(aiRelayUrl('https://abc.supabase.co'),
        'https://abc.supabase.co/functions/v1/ai-relay');
  });
}
