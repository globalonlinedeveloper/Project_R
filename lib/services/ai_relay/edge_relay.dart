import 'dart:convert';

import 'ai_relay.dart';

/// R-H7 client relay: POSTs `{ "prompt": ... }` to the SERVER-SIDE edge relay
/// (which holds the model key) and reads back `{ "text": ... }`.
///
/// The model key NEVER touches the client — this layer only knows the relay
/// [url]. Like [GeminiAiRelay] it takes an injected [HttpTransport] so it is
/// pure + unit-testable with no `package:http` dependency; the real transport
/// (Supabase Functions client) is wired at go-live in `backend_wiring`.
///
/// Fails closed: an empty [url] is unconfigured (`isAvailable=false`,
/// [complete] throws [RelayUnavailable] and NEVER touches the transport); any
/// non-2xx / transport error / malformed body throws, never a partial result.
/// TS-13: the returned text is UNTRUSTED — boxed in [RelayText].
class EdgeAiRelay implements AiRelay {
  EdgeAiRelay({
    required this.transport,
    this.url = '',
    this.timeout = const Duration(seconds: 25),
  });

  final HttpTransport transport;
  final String url;
  final Duration timeout;

  @override
  bool get isAvailable => url.isNotEmpty;

  @override
  Future<RelayText> complete(String prompt) async {
    if (!isAvailable) {
      throw const RelayUnavailable('not configured (no url)');
    }
    final HttpLikeRequest request = buildRequest(prompt);
    HttpLikeResponse resp;
    try {
      resp = await transport(request).timeout(timeout);
    } catch (e) {
      throw RelayUnavailable('transport error: ${e.runtimeType}');
    }
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw RelayUnavailable('non-2xx status ${resp.statusCode}');
    }
    return _parse(resp.body);
  }

  /// Builds the `{prompt}` POST to [url] (visible for shape assertions).
  HttpLikeRequest buildRequest(String prompt) => HttpLikeRequest(
        method: 'POST',
        url: url,
        headers: const <String, String>{'content-type': 'application/json'},
        body: jsonEncode(<String, String>{'prompt': prompt}),
      );

  RelayText _parse(String body) {
    Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw const RelayBadResponse('malformed JSON');
    }
    if (decoded is! Map) {
      throw const RelayBadResponse('response is not a JSON object');
    }
    final Object? text = decoded['text'];
    if (text is! String || text.isEmpty) {
      throw const RelayBadResponse('no text');
    }
    return RelayText(text);
  }
}
