// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// M5 [P1-1 · TS-6] — payment-webhook signature verification + event normalisation.
//
// Pure Dart, ZERO network, NO SDK key embedded. The real signing secret and provider
// endpoint are the injected seam: [PaymentsVerifier.verifyWebhook] takes `secret`, so
// the go-live Deno Edge webhook wires the live Stripe/Play secret in at deploy time.
// A verified+normalised [PaymentEvent] is then handed to schema/sql/0005's
// `apply_entitlement_event`, which applies it to `user.pro_until` exactly once.
//
// HMAC-SHA256 is implemented inline (dart:typed_data only) rather than via the `crypto`
// package, which is a TRANSITIVE dependency here — importing it from lib/ would trip the
// `depend_on_referenced_packages` lint and fail the analyze gate. The implementation is
// cross-checked against Python's hmac/hashlib in the build-ahead verification.
//
// GO-LIVE STOP: real Stripe/Play signing secrets, receipts, the live webhook URL, and
// store server-to-server receipt validation — all owner-gated.

import 'dart:convert';
import 'dart:typed_data';

/// Why a webhook signature was (not) accepted. Callers branch on this — never a bare bool.
enum WebhookVerdict {
  verified,
  missingSecret,
  missingSignature,
  malformedSignature,
  staleTimestamp,
  signatureMismatch,
}

/// Normalised entitlement transition — mirrors the `kind` set of schema/sql/0005's
/// `apply_entitlement_event`. [grant] carries an [PaymentEvent.until]; clawbacks do not.
enum PaymentEventKind { grant, refund, chargeback, lapse }

/// A provider-agnostic, already-verified payment event ready for the server-side
/// entitlement transition. Construction is intentionally cheap and immutable.
class PaymentEvent {
  final String eventId;
  final PaymentEventKind kind;
  final String userId;
  final DateTime? until;

  const PaymentEvent({
    required this.eventId,
    required this.kind,
    required this.userId,
    this.until,
  });

  @override
  String toString() =>
      'PaymentEvent($eventId, $kind, $userId, until=$until)';
}

/// Stateless verifier + normaliser for payment webhooks. All inputs are injected so it
/// is exhaustively unit-testable with no network, clock, or key.
class PaymentsVerifier {
  const PaymentsVerifier();

  /// Provider `type` → normalised [PaymentEventKind]. A type absent from this map is
  /// deliberately IGNORED (returns null from [parseEvent]) — never guessed.
  static const Map<String, PaymentEventKind> _typeMap = <String, PaymentEventKind>{
    'grant': PaymentEventKind.grant,
    'checkout.session.completed': PaymentEventKind.grant,
    'invoice.paid': PaymentEventKind.grant,
    'customer.subscription.created': PaymentEventKind.grant,
    'customer.subscription.updated': PaymentEventKind.grant,
    'refund': PaymentEventKind.refund,
    'charge.refunded': PaymentEventKind.refund,
    'chargeback': PaymentEventKind.chargeback,
    'charge.dispute.created': PaymentEventKind.chargeback,
    'lapse': PaymentEventKind.lapse,
    'customer.subscription.deleted': PaymentEventKind.lapse,
  };

  /// Verify a Stripe-style signature header `t=<unixSeconds>,v1=<hexHmacSha256>` over the
  /// EXACT raw request body. `signedPayload = "<t>.<rawBody>"`,
  /// `expected = hex(HMAC_SHA256(secret, signedPayload))`. Comparison is constant-time;
  /// an event older/newer than [tolerance] is rejected (replay window). [now] is injectable.
  static WebhookVerdict verifyWebhook({
    required String rawBody,
    required String signatureHeader,
    required String secret,
    Duration tolerance = const Duration(minutes: 5),
    DateTime? now,
  }) {
    if (secret.isEmpty) return WebhookVerdict.missingSecret;
    if (signatureHeader.trim().isEmpty) return WebhookVerdict.missingSignature;

    String? t;
    String? v1;
    for (final part in signatureHeader.split(',')) {
      final eq = part.indexOf('=');
      if (eq <= 0) continue;
      final key = part.substring(0, eq).trim();
      final value = part.substring(eq + 1).trim();
      if (key == 't') {
        t = value;
      } else if (key == 'v1') {
        v1 = value; // first v1 scheme wins
      }
    }
    if (t == null || v1 == null || t.isEmpty || v1.isEmpty) {
      return WebhookVerdict.malformedSignature;
    }

    final tsSeconds = int.tryParse(t);
    if (tsSeconds == null) return WebhookVerdict.malformedSignature;

    final clock = now ?? DateTime.now().toUtc();
    final eventTime =
        DateTime.fromMillisecondsSinceEpoch(tsSeconds * 1000, isUtc: true);
    if (clock.difference(eventTime).abs() > tolerance) {
      return WebhookVerdict.staleTimestamp;
    }

    final expected = _hex(_hmacSha256(
      utf8.encode(secret),
      utf8.encode('$t.$rawBody'),
    ));
    // Constant-time compare over the hex strings (lowercased) — no early return.
    if (!_constantTimeEquals(expected, v1.toLowerCase())) {
      return WebhookVerdict.signatureMismatch;
    }
    return WebhookVerdict.verified;
  }

  /// Normalise an already-VERIFIED webhook body into a [PaymentEvent], or null if the
  /// body is not JSON, is missing `id`/`user_id`, or carries an unknown event type.
  /// Never throws — a malformed/unknown payload is ignored, not crashed on.
  static PaymentEvent? parseEvent(String rawBody) {
    Object? decoded;
    try {
      decoded = jsonDecode(rawBody);
    } on FormatException {
      return null;
    }
    if (decoded is! Map) return null;
    final map = decoded;

    final id = map['id'];
    final userId = map['user_id'] ?? map['client_reference_id'];
    if (id is! String || id.isEmpty) return null;
    if (userId is! String || userId.isEmpty) return null;

    final rawType = (map['kind'] ?? map['type']);
    if (rawType is! String) return null;
    final kind = _typeMap[rawType];
    if (kind == null) return null; // unknown type -> ignored, no crash

    DateTime? until;
    if (kind == PaymentEventKind.grant) {
      until = _parseUntil(map['until'] ?? map['current_period_end']);
    }
    return PaymentEvent(eventId: id, kind: kind, userId: userId, until: until);
  }

  static DateTime? _parseUntil(Object? v) {
    if (v == null) return null;
    if (v is int) {
      return DateTime.fromMillisecondsSinceEpoch(v * 1000, isUtc: true);
    }
    if (v is String) {
      final asInt = int.tryParse(v);
      if (asInt != null) {
        return DateTime.fromMillisecondsSinceEpoch(asInt * 1000, isUtc: true);
      }
      return DateTime.tryParse(v)?.toUtc();
    }
    return null;
  }

  // ── constant-time compare ──────────────────────────────────────────────────
  static bool _constantTimeEquals(String a, String b) {
    final ab = utf8.encode(a);
    final bb = utf8.encode(b);
    // Fold length difference into the accumulator; iterate the longer side fully so
    // there is no input-dependent early return.
    var diff = ab.length ^ bb.length;
    final n = ab.length > bb.length ? ab.length : bb.length;
    for (var i = 0; i < n; i++) {
      final x = i < ab.length ? ab[i] : 0;
      final y = i < bb.length ? bb[i] : 0;
      diff |= x ^ y;
    }
    return diff == 0;
  }

  // ── HMAC-SHA256 (inline; cross-checked vs Python) ──────────────────────────
  static Uint8List _hmacSha256(List<int> key, List<int> message) {
    const blockSize = 64;
    var k = Uint8List.fromList(key);
    if (k.length > blockSize) k = _sha256(k);
    final block = Uint8List(blockSize)..setRange(0, k.length, k);
    final ipad = Uint8List(blockSize);
    final opad = Uint8List(blockSize);
    for (var i = 0; i < blockSize; i++) {
      ipad[i] = block[i] ^ 0x36;
      opad[i] = block[i] ^ 0x5c;
    }
    final inner = _sha256(Uint8List.fromList(<int>[...ipad, ...message]));
    return _sha256(Uint8List.fromList(<int>[...opad, ...inner]));
  }

  static String _hex(Uint8List bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }

  static const List<int> _k = <int>[
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
    0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
    0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
    0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
    0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
    0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
  ];

  static const int _mask = 0xFFFFFFFF;

  static int _rotr(int x, int n) =>
      ((x >> n) | (x << (32 - n))) & _mask;

  static Uint8List _sha256(Uint8List msg) {
    var h0 = 0x6a09e667,
        h1 = 0xbb67ae85,
        h2 = 0x3c6ef372,
        h3 = 0xa54ff53a,
        h4 = 0x510e527f,
        h5 = 0x9b05688c,
        h6 = 0x1f83d9ab,
        h7 = 0x5be0cd19;

    final bitLen = msg.length * 8;
    final padded = <int>[...msg, 0x80];
    while (padded.length % 64 != 56) {
      padded.add(0);
    }
    for (var i = 7; i >= 0; i--) {
      padded.add((bitLen >> (i * 8)) & 0xff);
    }

    final w = List<int>.filled(64, 0);
    for (var chunk = 0; chunk < padded.length; chunk += 64) {
      for (var i = 0; i < 16; i++) {
        final j = chunk + i * 4;
        w[i] = ((padded[j] << 24) |
                (padded[j + 1] << 16) |
                (padded[j + 2] << 8) |
                padded[j + 3]) &
            _mask;
      }
      for (var i = 16; i < 64; i++) {
        final s0 = _rotr(w[i - 15], 7) ^ _rotr(w[i - 15], 18) ^ (w[i - 15] >> 3);
        final s1 = _rotr(w[i - 2], 17) ^ _rotr(w[i - 2], 19) ^ (w[i - 2] >> 10);
        w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & _mask;
      }

      var a = h0, b = h1, c = h2, d = h3, e = h4, f = h5, g = h6, h = h7;
      for (var i = 0; i < 64; i++) {
        final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
        final ch = (e & f) ^ ((~e & _mask) & g);
        final temp1 = (h + s1 + ch + _k[i] + w[i]) & _mask;
        final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final temp2 = (s0 + maj) & _mask;
        h = g;
        g = f;
        f = e;
        e = (d + temp1) & _mask;
        d = c;
        c = b;
        b = a;
        a = (temp1 + temp2) & _mask;
      }

      h0 = (h0 + a) & _mask;
      h1 = (h1 + b) & _mask;
      h2 = (h2 + c) & _mask;
      h3 = (h3 + d) & _mask;
      h4 = (h4 + e) & _mask;
      h5 = (h5 + f) & _mask;
      h6 = (h6 + g) & _mask;
      h7 = (h7 + h) & _mask;
    }

    final out = Uint8List(32);
    final hs = <int>[h0, h1, h2, h3, h4, h5, h6, h7];
    for (var i = 0; i < 8; i++) {
      out[i * 4] = (hs[i] >> 24) & 0xff;
      out[i * 4 + 1] = (hs[i] >> 16) & 0xff;
      out[i * 4 + 2] = (hs[i] >> 8) & 0xff;
      out[i * 4 + 3] = hs[i] & 0xff;
    }
    return out;
  }
}
