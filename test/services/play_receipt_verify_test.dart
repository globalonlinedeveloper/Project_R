// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// R-J7 (Play Billing / mobile IAP) tests for PlayReceiptVerifier against a FAKE transport:
// unconfigured / empty-token fail closed WITHOUT touching the transport; a 200
// SubscriptionPurchaseV2 parses to the shared PaymentEvent (ACTIVE/IN_GRACE/CANCELED ->
// grant w/ until from the latest lineItems expiry; ON_HOLD/PAUSED/EXPIRED -> lapse);
// PENDING/unknown and unattributable receipts verify with NO event; non-2xx / transport
// error / malformed body all return verified=false. No network, no key.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

class _FakeTransport {
  _FakeTransport(this._responder);
  final Future<HttpLikeResponse> Function(HttpLikeRequest) _responder;
  int calls = 0;
  HttpLikeRequest? last;
  Future<HttpLikeResponse> handle(HttpLikeRequest req) {
    calls++;
    last = req;
    return _responder(req);
  }
}

const _cfg = PlayConfig(
  baseUrl: 'https://androidpublisher.test',
  packageName: 'com.learnwithratel.ratel',
  accessToken: 'ya29.fake',
);

String subBody({
  required String state,
  String? order = 'GPA.test-order',
  String? user = '11111111-1111-1111-1111-111111111111',
  List<String> expiries = const ['2027-06-01T00:00:00Z'],
}) {
  final m = <String, dynamic>{'subscriptionState': state};
  if (order != null) m['latestOrderId'] = order;
  if (user != null) {
    m['externalAccountIdentifiers'] = {'obfuscatedExternalAccountId': user};
  }
  if (expiries.isNotEmpty) {
    m['lineItems'] = [
      for (final e in expiries) {'productId': 'pro_monthly', 'expiryTime': e},
    ];
  }
  return jsonEncode(m);
}

void main() {
  group('verifySubscription (orchestrator + fake transport)', () {
    test('unconfigured -> verified=false, transport untouched', () async {
      final t = _FakeTransport(
          (r) async => const HttpLikeResponse(statusCode: 200, body: '{}'));
      final v = PlayReceiptVerifier(transport: t.handle); // default empty config
      final r = await v.verifySubscription(purchaseToken: 'tok');
      expect(r.verified, isFalse);
      expect(r.event, isNull);
      expect(t.calls, 0);
    });

    test('empty token -> verified=false, transport untouched', () async {
      final t = _FakeTransport(
          (r) async => const HttpLikeResponse(statusCode: 200, body: '{}'));
      final v = PlayReceiptVerifier(transport: t.handle, config: _cfg);
      final r = await v.verifySubscription(purchaseToken: '');
      expect(r.verified, isFalse);
      expect(t.calls, 0);
    });

    test('ACTIVE 200 -> verified grant; request shape asserted', () async {
      final t = _FakeTransport((r) async => HttpLikeResponse(
          statusCode: 200, body: subBody(state: 'SUBSCRIPTION_STATE_ACTIVE')));
      final v = PlayReceiptVerifier(transport: t.handle, config: _cfg);
      final r = await v.verifySubscription(purchaseToken: 'tok_abc');
      expect(r.verified, isTrue);
      expect(r.event, isNotNull);
      expect(r.event!.kind, PaymentEventKind.grant);
      expect(r.event!.userId, '11111111-1111-1111-1111-111111111111');
      expect(r.event!.eventId, 'GPA.test-order');
      expect(r.event!.until, DateTime.utc(2027, 6, 1));
      expect(t.calls, 1);
      expect(t.last!.method, 'GET');
      expect(t.last!.url, contains('/purchases/subscriptionsv2/tokens/tok_abc'));
      expect(t.last!.url, contains('com.learnwithratel.ratel'));
      expect(t.last!.headers['authorization'], 'Bearer ya29.fake');
    });

    test('transport throws -> verified=false (fail closed)', () async {
      final t = _FakeTransport((r) async => throw StateError('boom'));
      final v = PlayReceiptVerifier(transport: t.handle, config: _cfg);
      final r = await v.verifySubscription(purchaseToken: 'tok');
      expect(r.verified, isFalse);
      expect(r.event, isNull);
    });

    test('non-2xx -> verified=false', () async {
      final t = _FakeTransport(
          (r) async => const HttpLikeResponse(statusCode: 404, body: '{}'));
      final v = PlayReceiptVerifier(transport: t.handle, config: _cfg);
      expect((await v.verifySubscription(purchaseToken: 'tok')).verified, isFalse);
    });

    test('200 malformed body -> verified=false', () async {
      final t = _FakeTransport((r) async =>
          const HttpLikeResponse(statusCode: 200, body: 'not json {'));
      final v = PlayReceiptVerifier(transport: t.handle, config: _cfg);
      expect((await v.verifySubscription(purchaseToken: 'tok')).verified, isFalse);
    });
  });

  group('parseSubscription (pure)', () {
    test('grant states -> grant with until from expiry', () {
      for (final s in const [
        'SUBSCRIPTION_STATE_ACTIVE',
        'SUBSCRIPTION_STATE_IN_GRACE_PERIOD',
        'SUBSCRIPTION_STATE_CANCELED',
      ]) {
        final r = PlayReceiptVerifier.parseSubscription(subBody(state: s));
        expect(r.verified, isTrue, reason: s);
        expect(r.event?.kind, PaymentEventKind.grant, reason: s);
        expect(r.event?.until, DateTime.utc(2027, 6, 1), reason: s);
      }
    });

    test('lapse states -> lapse with no until', () {
      for (final s in const [
        'SUBSCRIPTION_STATE_ON_HOLD',
        'SUBSCRIPTION_STATE_PAUSED',
        'SUBSCRIPTION_STATE_EXPIRED',
      ]) {
        final r = PlayReceiptVerifier.parseSubscription(subBody(state: s));
        expect(r.event?.kind, PaymentEventKind.lapse, reason: s);
        expect(r.event?.until, isNull, reason: s);
      }
    });

    test('pending / unknown -> verified, no event', () {
      final p = PlayReceiptVerifier.parseSubscription(
          subBody(state: 'SUBSCRIPTION_STATE_PENDING'));
      expect(p.verified, isTrue);
      expect(p.event, isNull);
      expect(
          PlayReceiptVerifier.parseSubscription(subBody(state: 'WHATEVER')).event,
          isNull);
    });

    test('grant without expiry -> verified, no event (cannot satisfy until)', () {
      final r = PlayReceiptVerifier.parseSubscription(
          subBody(state: 'SUBSCRIPTION_STATE_ACTIVE', expiries: const []));
      expect(r.verified, isTrue);
      expect(r.event, isNull);
    });

    test('missing obfuscated account id -> verified, no event', () {
      final r = PlayReceiptVerifier.parseSubscription(
          subBody(state: 'SUBSCRIPTION_STATE_ACTIVE', user: null));
      expect(r.verified, isTrue);
      expect(r.event, isNull);
    });

    test('passed-in eventId wins over latestOrderId', () {
      final r = PlayReceiptVerifier.parseSubscription(
          subBody(state: 'SUBSCRIPTION_STATE_ACTIVE'),
          eventId: 'evt_hdr');
      expect(r.event?.eventId, 'evt_hdr');
    });

    test('latest of multiple line-item expiries is chosen', () {
      final r = PlayReceiptVerifier.parseSubscription(subBody(
          state: 'SUBSCRIPTION_STATE_ACTIVE',
          expiries: const [
            '2027-06-01T00:00:00Z',
            '2027-09-01T00:00:00Z',
            '2027-03-01T00:00:00Z',
          ]));
      expect(r.event?.until, DateTime.utc(2027, 9, 1));
    });

    test('non-object / missing state / non-JSON -> verified=false', () {
      expect(PlayReceiptVerifier.parseSubscription('[1,2,3]').verified, isFalse);
      expect(PlayReceiptVerifier.parseSubscription('{"foo":1}').verified, isFalse);
      expect(PlayReceiptVerifier.parseSubscription('not json {').verified, isFalse);
    });
  });
}
