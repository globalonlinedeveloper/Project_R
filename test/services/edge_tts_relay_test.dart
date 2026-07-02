import 'dart:convert';
import 'dart:typed_data' show Uint8List;

import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/backend_wiring.dart' show ttsRelayUrl;
import 'package:ratel/services/ai_relay/ai_relay.dart'
    show HttpTransport, HttpLikeRequest, HttpLikeResponse;
import 'package:ratel/services/tts_relay/tts_relay.dart';

// tts-relay client seam (mirrors edge_relay_test.dart): EdgeTtsRelay POSTs
// {text|ssml, voiceId, tier} to the SERVER-SIDE relay (which holds GCP_TTS) and
// reads {audioBase64, mime}. The key never touches the client. Pure over an
// injected transport; fails closed on every error path. [R-H7]

void main() {
  HttpTransport ok(String body, {int status = 200}) =>
      (HttpLikeRequest _) async =>
          HttpLikeResponse(statusCode: status, body: body);

  String audioBody({String? b64, String mime = 'audio/mpeg'}) => jsonEncode(
        <String, String>{
          'audioBase64': b64 ?? base64Encode(<int>[1, 2, 3, 4]),
          'mime': mime,
        },
      );

  group('EdgeTtsRelay', () {
    test('unconfigured (empty url) fails closed; transport untouched', () async {
      final EdgeTtsRelay relay = EdgeTtsRelay(
        transport: (HttpLikeRequest _) async => fail('must not call transport'),
      );
      expect(relay.isAvailable, isFalse);
      await expectLater(relay.synthesize(const TtsRequest(text: 'hola')),
          throwsA(isA<TtsUnavailable>()));
    });

    test('buildRequest POSTs {text,voiceId,tier} to the url', () {
      final EdgeTtsRelay relay = EdgeTtsRelay(
          transport: ok('{}'), url: 'https://x/functions/v1/tts-relay');
      final HttpLikeRequest req = relay.buildRequest(
          const TtsRequest(text: 'hola', voiceId: 'es-1', tier: 'hd'));
      expect(req.method, 'POST');
      expect(req.url, 'https://x/functions/v1/tts-relay');
      final Map<String, dynamic> body =
          jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['text'], 'hola');
      expect(body['voiceId'], 'es-1');
      expect(body['tier'], 'hd');
      expect(body.containsKey('ssml'), isFalse);
    });

    test('buildRequest prefers ssml when present', () {
      final EdgeTtsRelay relay = EdgeTtsRelay(transport: ok('{}'), url: 'https://x');
      final HttpLikeRequest req = relay.buildRequest(
          const TtsRequest(ssml: '<speak>hi</speak>', text: 'ignored'));
      final Map<String, dynamic> body =
          jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['ssml'], '<speak>hi</speak>');
      expect(body.containsKey('text'), isFalse);
    });

    test('2xx {audioBase64,mime} -> AudioBytes', () async {
      final EdgeTtsRelay relay = EdgeTtsRelay(transport: ok(audioBody()), url: 'https://x');
      final AudioBytes out = await relay.synthesize(const TtsRequest(text: 'hola'));
      expect(out.bytes, <int>[1, 2, 3, 4]);
      expect(out.mime, 'audio/mpeg');
      expect(out.length, 4);
    });

    test('non-2xx fails closed (TtsUnavailable)', () async {
      final EdgeTtsRelay relay =
          EdgeTtsRelay(transport: ok(audioBody(), status: 503), url: 'https://x');
      await expectLater(relay.synthesize(const TtsRequest(text: 'hi')),
          throwsA(isA<TtsUnavailable>()));
    });

    test('malformed JSON -> TtsBadResponse', () async {
      final EdgeTtsRelay relay =
          EdgeTtsRelay(transport: ok('not json'), url: 'https://x');
      await expectLater(relay.synthesize(const TtsRequest(text: 'hi')),
          throwsA(isA<TtsBadResponse>()));
    });

    test('missing audio -> TtsBadResponse', () async {
      final EdgeTtsRelay relay = EdgeTtsRelay(
          transport: ok(jsonEncode(<String, String>{'mime': 'audio/mpeg'})),
          url: 'https://x');
      await expectLater(relay.synthesize(const TtsRequest(text: 'hi')),
          throwsA(isA<TtsBadResponse>()));
    });

    test('disallowed mime -> TtsBadResponse', () async {
      final EdgeTtsRelay relay = EdgeTtsRelay(
          transport: ok(audioBody(mime: 'audio/x-evil')), url: 'https://x');
      await expectLater(relay.synthesize(const TtsRequest(text: 'hi')),
          throwsA(isA<TtsBadResponse>()));
    });

    test('transport throw -> TtsUnavailable', () async {
      final EdgeTtsRelay relay = EdgeTtsRelay(
        transport: (HttpLikeRequest _) async => throw Exception('boom'),
        url: 'https://x',
      );
      await expectLater(relay.synthesize(const TtsRequest(text: 'hi')),
          throwsA(isA<TtsUnavailable>()));
    });
  });

  test('UnconfiguredTtsRelay default fails closed', () async {
    const TtsRelay relay = UnconfiguredTtsRelay();
    expect(relay.isAvailable, isFalse);
    await expectLater(relay.synthesize(const TtsRequest(text: 'x')),
        throwsA(isA<TtsUnavailable>()));
  });

  group('TtsSizeLimitedTtsRelay (build-ahead CAPS-2)', () {
    test('rejects an oversize payload BEFORE the inner relay', () async {
      final _RecordingRelay inner = _RecordingRelay();
      final TtsSizeLimitedTtsRelay guarded = TtsSizeLimitedTtsRelay(inner,
          guard: const TtsSizeGuard(TtsSizeLimits(maxChars: 5)));
      await expectLater(
          guarded.synthesize(const TtsRequest(text: 'way too long')),
          throwsA(isA<TtsRequestTooLarge>()));
      expect(inner.calls, 0);
    });

    test('passes an in-cap payload through to the inner relay', () async {
      final _RecordingRelay inner = _RecordingRelay();
      final TtsSizeLimitedTtsRelay guarded = TtsSizeLimitedTtsRelay(inner);
      await guarded.synthesize(const TtsRequest(text: 'ok'));
      expect(inner.calls, 1);
    });
  });

  test('ttsRelayUrl derives the functions endpoint', () {
    expect(ttsRelayUrl('https://abc.supabase.co'),
        'https://abc.supabase.co/functions/v1/tts-relay');
  });
}

class _RecordingRelay implements TtsRelay {
  int calls = 0;
  @override
  bool get isAvailable => true;
  @override
  Future<AudioBytes> synthesize(TtsRequest req) async {
    calls++;
    return AudioBytes(Uint8List.fromList(const <int>[1]), 'audio/mpeg');
  }
}
