// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// M3 [R-H7] — Gemini adapter behind the `ai_relay` seam, fully unit-tested
// against a FAKED HTTP transport. No real network, no real key is ever read
// here. Go-live = inject the real base URL + key (server-side) and override
// `aiRelayProvider`; the thin Deno host function is a separate wiring task.
//
// Request/parse/error-map/isAvailable are all pure given the injected
// [HttpTransport]. The default [GeminiConfig] has no key => `isAvailable=false`
// and `complete()` fails closed (parity with `UnconfiguredAiRelay`), so an
// un-wired build can never silently call out.
import 'dart:convert';

import 'ai_relay.dart';

/// Minimal HTTP shape so this layer needs no `package:http` dependency; the real
/// client is injected at go-live behind [HttpTransport].
class HttpLikeRequest {
  const HttpLikeRequest({
    required this.method,
    required this.url,
    required this.headers,
    required this.body,
  });
  final String method;
  final String url;
  final Map<String, String> headers;
  final String body;
}

class HttpLikeResponse {
  const HttpLikeResponse({required this.statusCode, required this.body});
  final int statusCode;
  final String body;
}

/// The seam where the real Gemini/HTTP client is injected at go-live.
typedef HttpTransport = Future<HttpLikeResponse> Function(HttpLikeRequest request);

/// Connection config. Empty key/baseUrl => unconfigured (fail closed). The real
/// values are injected server-side at go-live; NEVER hard-coded here.
class GeminiConfig {
  const GeminiConfig({
    this.baseUrl = '',
    this.model = 'gemini-1.5-flash',
    this.apiKey = '',
  });
  final String baseUrl;
  final String model;
  final String apiKey;

  bool get isConfigured => baseUrl.isNotEmpty && apiKey.isNotEmpty;
}

/// Relay call could not be completed (unconfigured / non-2xx / transport error
/// or timeout). Carries only a short reason — never the upstream body.
class RelayUnavailable implements Exception {
  const RelayUnavailable(this.reason);
  final String reason;
  @override
  String toString() => 'RelayUnavailable: $reason';
}

/// Upstream returned 2xx but the payload was malformed / had no usable candidate.
class RelayBadResponse implements Exception {
  const RelayBadResponse(this.reason);
  final String reason;
  @override
  String toString() => 'RelayBadResponse: $reason';
}

/// Gemini implementation of the [AiRelay] seam over an injected [HttpTransport].
class GeminiAiRelay implements AiRelay {
  GeminiAiRelay({
    required this.transport,
    this.config = const GeminiConfig(),
    this.timeout = const Duration(seconds: 20),
  });

  final HttpTransport transport;
  final GeminiConfig config;
  final Duration timeout;

  @override
  bool get isAvailable => config.isConfigured;

  @override
  Future<RelayText> complete(String prompt) async {
    if (!isAvailable) {
      // Fail closed; the transport is NEVER touched when unconfigured.
      throw const RelayUnavailable('not configured (no baseUrl/key)');
    }

    final request = buildRequest(prompt);
    HttpLikeResponse resp;
    try {
      resp = await transport(request).timeout(timeout);
    } catch (e) {
      // Transport error or timeout => fail closed; no partial result.
      throw RelayUnavailable('transport error: ${e.runtimeType}');
    }

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      // Do NOT include the body (avoid leaking upstream error detail).
      throw RelayUnavailable('non-2xx status ${resp.statusCode}');
    }

    return _parse(resp.body);
  }

  /// Builds the `generateContent` request (visible for shape assertions).
  HttpLikeRequest buildRequest(String prompt) {
    final url =
        '${config.baseUrl}/v1beta/models/${config.model}:generateContent';
    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
    });
    return HttpLikeRequest(
      method: 'POST',
      url: url,
      headers: {
        'content-type': 'application/json',
        'x-goog-api-key': config.apiKey,
      },
      body: body,
    );
  }

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
    final candidates = decoded['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const RelayBadResponse('no candidates');
    }
    final first = candidates.first;
    if (first is! Map) throw const RelayBadResponse('candidate not an object');
    final content = first['content'];
    if (content is! Map) throw const RelayBadResponse('no content');
    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) {
      throw const RelayBadResponse('no parts');
    }
    final buf = StringBuffer();
    for (final p in parts) {
      if (p is Map && p['text'] is String) buf.write(p['text'] as String);
    }
    final text = buf.toString();
    if (text.isEmpty) throw const RelayBadResponse('empty text');
    // TS-13: relay output is untrusted -> boxed in RelayText.
    return RelayText(text);
  }
}

// ── GO-LIVE WIRING (example only; NOT active on main) ────────────────────────
// Wiring is owner/money-gated: a real key (server-side), base URL, and a
// provider override. Sketch of the final composition once those exist:
//
//   final relay = BudgetedAiRelay(
//     ModeratedAiRelay(
//       GeminiAiRelay(
//         transport: realHttpTransport,                 // package:http etc.
//         config: GeminiConfig(baseUrl: env.baseUrl,    // injected server-side
//                              apiKey: env.geminiKey),   // NEVER in client code
//       ),
//       provider: realModerationProvider,
//     ),
//     userSpentToday: () => ledger.userSpentToday(uid),
//     globalSpentToday: () => ledger.globalSpentToday(),
//     recordSpend: (c) => ledger.postSpend(uid, c),
//   );
//   // override: aiRelayProvider = Provider<AiRelay>((ref) => relay);
