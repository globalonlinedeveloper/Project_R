import 'dart:convert';
import 'dart:typed_data' show Uint8List;

import '../ai_relay/ai_relay.dart'
    show HttpTransport, HttpLikeRequest, HttpLikeResponse;
import 'tts_relay.dart';

/// R-H7-style client relay for TTS: POSTs `{text|ssml, voiceId, tier}` to the
/// SERVER-SIDE `tts-relay` edge function (which holds the GCP_TTS key) and reads
/// back `{audioBase64, mime}`. The key NEVER touches the client — this layer only
/// knows the relay [url]. Pure over an injected [HttpTransport] (REUSED from the
/// ai_relay seam — it is generic, not model-specific), so unit-testable with no
/// `package:http`.
///
/// Fails closed: an empty [url] is unconfigured (`isAvailable=false`,
/// [synthesize] throws [TtsUnavailable] and NEVER touches the transport); any
/// non-2xx / transport error -> [TtsUnavailable]; malformed body / missing audio
/// / disallowed [allowedMime] / over-[maxBytes] -> [TtsBadResponse]. Never a
/// partial result. Audio bytes are opaque (decoded by an audio player), so no
/// `RelayText` escaping box is needed — but the mime allowlist + size cap are
/// enforced as defense-in-depth before decoding.
class EdgeTtsRelay implements TtsRelay {
  EdgeTtsRelay({
    required this.transport,
    this.url = '',
    this.timeout = const Duration(seconds: 25),
    this.allowedMime = const <String>{'audio/mpeg', 'audio/ogg'},
    this.maxBytes = 5 * 1024 * 1024,
  });

  final HttpTransport transport;
  final String url;
  final Duration timeout;
  final Set<String> allowedMime;
  final int maxBytes;

  @override
  bool get isAvailable => url.isNotEmpty;

  @override
  Future<AudioBytes> synthesize(TtsRequest req) async {
    if (!isAvailable) {
      throw const TtsUnavailable('not configured (no url)');
    }
    final HttpLikeRequest request = buildRequest(req);
    HttpLikeResponse resp;
    try {
      resp = await transport(request).timeout(timeout);
    } catch (e) {
      throw TtsUnavailable('transport error: ${e.runtimeType}');
    }
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw TtsUnavailable('non-2xx status ${resp.statusCode}');
    }
    return _parse(resp.body);
  }

  /// Builds the POST body (visible for shape assertions). Sends `ssml` when
  /// present, else `text`; always includes `voiceId` + `tier`.
  HttpLikeRequest buildRequest(TtsRequest req) {
    final Map<String, String> payload = <String, String>{
      if (req.ssml.isNotEmpty) 'ssml': req.ssml else 'text': req.text,
      'voiceId': req.voiceId,
      'tier': req.tier,
    };
    return HttpLikeRequest(
      method: 'POST',
      url: url,
      headers: const <String, String>{'content-type': 'application/json'},
      body: jsonEncode(payload),
    );
  }

  AudioBytes _parse(String body) {
    Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw const TtsBadResponse('malformed JSON');
    }
    if (decoded is! Map) {
      throw const TtsBadResponse('response is not a JSON object');
    }
    final Object? b64 = decoded['audioBase64'];
    final Object? mime = decoded['mime'];
    if (b64 is! String || b64.isEmpty) {
      throw const TtsBadResponse('no audio');
    }
    if (mime is! String || !allowedMime.contains(mime)) {
      throw const TtsBadResponse('disallowed or missing mime');
    }
    final Uint8List bytes;
    try {
      bytes = base64Decode(b64);
    } on FormatException {
      throw const TtsBadResponse('audio not valid base64');
    }
    if (bytes.isEmpty || bytes.length > maxBytes) {
      throw const TtsBadResponse('audio size out of bounds');
    }
    return AudioBytes(bytes, mime);
  }
}
