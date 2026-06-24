// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// R-J7 (Play Billing / mobile IAP) — server-to-server receipt validation, the mobile
// counterpart to the Razorpay/Stripe web webhook verifier (payments_verify.dart, R-J7a).
//
// Unlike the HMAC webhook path, a Google Play purchase is validated by CALLING the Google
// Play Developer API (purchases.subscriptionsv2.get) with the app's service-account
// credentials and the client-supplied purchaseToken; Google's response is authoritative.
// We model that call behind the SAME injected [HttpTransport] seam used by the AI relay:
// the production transport adds the OAuth bearer + does the real network; tests inject a
// fake returning canned Google JSON. A verified, ACTIVE subscription is normalised to the
// shared [PaymentEvent] and handed to schema/sql/0005 apply_entitlement_event (one
// pro_until transition, exactly once) — the same server-side entitlement path as the web
// verifier, so Pro follows the user across platforms.
//
// Fail closed: unconfigured / empty token / transport error / non-2xx / malformed body all
// return verified=false with NO event — a caller must NEVER grant Pro on an unverified
// receipt. A valid response that implies no transition (PENDING/unspecified, or an
// unattributable purchase) returns verified=true with event=null.
//
// GO-LIVE (owner/money-gated): mint the service-account OAuth access token server-side
// (Google service account → JWT → bearer), inject the real package:http transport + the
// app packageName, and confirm the exact subscriptionsv2 field paths against REAL receipts.
// Consumable AI-credit top-ups (purchases.products.get) are a SEPARATE path that feeds the
// credit ledger (schema/sql/0004, R-J3), not this pro_until entitlement verifier.

import 'dart:convert';

import '../ai_relay/gemini_relay.dart' show HttpLikeRequest, HttpLikeResponse, HttpTransport;
import 'payments_verify.dart';

/// Connection config for the Play Developer API. Empty baseUrl / packageName / accessToken
/// => unconfigured (fail closed). Real values are injected server-side at go-live; the
/// short-lived OAuth access token is minted from the service account, NEVER hard-coded.
class PlayConfig {
  const PlayConfig({
    this.baseUrl = '',
    this.packageName = '',
    this.accessToken = '',
  });

  final String baseUrl;
  final String packageName;
  final String accessToken;

  bool get isConfigured =>
      baseUrl.isNotEmpty && packageName.isNotEmpty && accessToken.isNotEmpty;
}

/// Result of a Play receipt validation. [verified] = Google's API confirmed the token;
/// [event] = the normalised entitlement transition for apply_entitlement_event (null when
/// the receipt is valid but implies no transition). On ANY failure: verified=false,
/// event=null, [error] a short reason (the upstream body is never surfaced).
class PlayReceipt {
  const PlayReceipt({required this.verified, this.event, this.error});

  factory PlayReceipt.fail(String error) =>
      PlayReceipt(verified: false, error: error);

  final bool verified;
  final PaymentEvent? event;
  final String? error;

  @override
  String toString() => 'PlayReceipt(verified=$verified, event=$event, error=$error)';
}

/// Validates Google Play purchase tokens behind an injected [HttpTransport]. Stateless apart
/// from the injected transport/config, so it is exhaustively unit-testable with no network.
class PlayReceiptVerifier {
  PlayReceiptVerifier({
    required this.transport,
    this.config = const PlayConfig(),
    this.timeout = const Duration(seconds: 20),
  });

  final HttpTransport transport;
  final PlayConfig config;
  final Duration timeout;

  /// subscriptionState -> normalised [PaymentEventKind]. ACTIVE / IN_GRACE_PERIOD / CANCELED
  /// (canceled = auto-renew off but still entitled until expiry) => grant; ON_HOLD / PAUSED
  /// / EXPIRED => lapse. PENDING / UNSPECIFIED / any unknown state => null (no transition).
  static const Map<String, PaymentEventKind> _subStateMap = <String, PaymentEventKind>{
    'SUBSCRIPTION_STATE_ACTIVE': PaymentEventKind.grant,
    'SUBSCRIPTION_STATE_IN_GRACE_PERIOD': PaymentEventKind.grant,
    'SUBSCRIPTION_STATE_CANCELED': PaymentEventKind.grant,
    'SUBSCRIPTION_STATE_ON_HOLD': PaymentEventKind.lapse,
    'SUBSCRIPTION_STATE_PAUSED': PaymentEventKind.lapse,
    'SUBSCRIPTION_STATE_EXPIRED': PaymentEventKind.lapse,
  };

  /// S2S validate a subscription purchase token via purchases.subscriptionsv2.get, then
  /// normalise the result to a [PaymentEvent]. [eventId] (the provider-opaque id used for
  /// 0005 dedupe) defaults to the response's `latestOrderId`, which CHANGES per renewal so
  /// each renewal is a distinct entitlement event — the purchaseToken is stable across
  /// renewals and would wrongly dedupe them.
  Future<PlayReceipt> verifySubscription({
    required String purchaseToken,
    String? eventId,
  }) async {
    if (!config.isConfigured) return PlayReceipt.fail('not configured');
    if (purchaseToken.isEmpty) return PlayReceipt.fail('missing purchaseToken');

    final request = buildSubscriptionRequest(purchaseToken);
    HttpLikeResponse resp;
    try {
      resp = await transport(request).timeout(timeout);
    } catch (e) {
      // Transport error or timeout => fail closed; no partial result.
      return PlayReceipt.fail('transport error: ${e.runtimeType}');
    }
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      // Never include the body (avoid leaking upstream error detail).
      return PlayReceipt.fail('non-2xx status ${resp.statusCode}');
    }
    return parseSubscription(resp.body, eventId: eventId);
  }

  /// Builds the subscriptionsv2 GET request (visible for shape assertions).
  HttpLikeRequest buildSubscriptionRequest(String purchaseToken) {
    final url = '${config.baseUrl}/androidpublisher/v3/applications/'
        '${config.packageName}/purchases/subscriptionsv2/tokens/$purchaseToken';
    return HttpLikeRequest(
      method: 'GET',
      url: url,
      headers: <String, String>{
        'authorization': 'Bearer ${config.accessToken}',
        'accept': 'application/json',
      },
      body: '',
    );
  }

  /// Pure parser of a SubscriptionPurchaseV2 body. Never throws: a non-JSON / non-object /
  /// stateless body returns verified=false; a well-formed body returns verified=true with
  /// the normalised [PaymentEvent] (or null when there is no actionable / attributable
  /// transition).
  static PlayReceipt parseSubscription(String body, {String? eventId}) {
    Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      return PlayReceipt.fail('malformed JSON');
    }
    if (decoded is! Map) return PlayReceipt.fail('not a JSON object');

    final state = decoded['subscriptionState'];
    if (state is! String) return PlayReceipt.fail('missing subscriptionState');

    final kind = _subStateMap[state];
    if (kind == null) {
      // Valid response, no actionable transition (pending / unspecified).
      return const PlayReceipt(verified: true);
    }

    final userId = _obfuscatedAccountId(decoded);
    final order = decoded['latestOrderId'];
    final id = (eventId != null && eventId.isNotEmpty)
        ? eventId
        : (order is String && order.isNotEmpty ? order : null);
    // Verified but unattributable (no id / no user) -> emit no event (never grant blind).
    if (id == null || userId == null) return const PlayReceipt(verified: true);

    DateTime? until;
    if (kind == PaymentEventKind.grant) {
      until = _latestExpiry(decoded);
      // apply_entitlement_event requires an expiry for a grant; without one we can verify
      // the receipt but cannot form a grant event.
      if (until == null) return const PlayReceipt(verified: true);
    }
    return PlayReceipt(
      verified: true,
      event: PaymentEvent(eventId: id, kind: kind, userId: userId, until: until),
    );
  }

  /// `externalAccountIdentifiers.obfuscatedExternalAccountId` — the id we set at purchase to
  /// link a Play purchase back to our user, or null.
  static String? _obfuscatedAccountId(Map m) {
    final ext = m['externalAccountIdentifiers'];
    if (ext is Map) {
      final id = ext['obfuscatedExternalAccountId'];
      if (id is String && id.isNotEmpty) return id;
    }
    return null;
  }

  /// The LATEST `lineItems[].expiryTime` (RFC3339) as UTC, or null if none parse.
  static DateTime? _latestExpiry(Map m) {
    final items = m['lineItems'];
    if (items is! List) return null;
    DateTime? best;
    for (final it in items) {
      if (it is Map && it['expiryTime'] is String) {
        final t = DateTime.tryParse(it['expiryTime'] as String)?.toUtc();
        if (t != null && (best == null || t.isAfter(best))) best = t;
      }
    }
    return best;
  }
}
