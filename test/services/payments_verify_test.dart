// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// M5 [P1-1 · TS-6] tests for PaymentsVerifier (flutter-gate): HMAC-SHA256 webhook
// signature verify (constant-time, timestamp tolerance) + event normalisation. The
// expected signature constant below is computed independently by Python's
// hmac/hashlib over `"<t>.<body>"` — so this test pins the inline Dart HMAC to a
// reference implementation. No network, no key, no clock dependence (now is injected).
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

// Fixed reference vector. `_kSig` = python:
//   hmac.new(b"<secret>", b"<t>.<body>", sha256).hexdigest()
const String _kSecret = 'whsec_test_build_ahead_key';
const String _kT = '1750000000';
const String _kBody =
    '{"id":"evt_abc123","type":"checkout.session.completed",'
    '"user_id":"11111111-1111-1111-1111-111111111111",'
    '"current_period_end":1781536000}';
const String _kSig =
    '3bbec7aa10687d6a27d5887f549a70fc91f3181f4c4f02ce7e0d95f9992373d5';

DateTime get _eventTime =>
    DateTime.fromMillisecondsSinceEpoch(int.parse(_kT) * 1000, isUtc: true);
String get _header => 't=$_kT,v1=$_kSig';

void main() {
  group('verifyWebhook', () {
    test('valid signature verifies (inline HMAC == python reference)', () {
      expect(
        PaymentsVerifier.verifyWebhook(
          rawBody: _kBody,
          signatureHeader: _header,
          secret: _kSecret,
          now: _eventTime,
        ),
        WebhookVerdict.verified,
      );
    });

    test('tampered body is rejected', () {
      expect(
        PaymentsVerifier.verifyWebhook(
          rawBody: '$_kBody ', // one extra byte
          signatureHeader: _header,
          secret: _kSecret,
          now: _eventTime,
        ),
        WebhookVerdict.signatureMismatch,
      );
    });

    test('wrong secret is rejected', () {
      expect(
        PaymentsVerifier.verifyWebhook(
          rawBody: _kBody,
          signatureHeader: _header,
          secret: 'whsec_wrong',
          now: _eventTime,
        ),
        WebhookVerdict.signatureMismatch,
      );
    });

    test('empty secret -> missingSecret (never silently passes)', () {
      expect(
        PaymentsVerifier.verifyWebhook(
          rawBody: _kBody,
          signatureHeader: _header,
          secret: '',
          now: _eventTime,
        ),
        WebhookVerdict.missingSecret,
      );
    });

    test('empty/whitespace header -> missingSignature', () {
      expect(
        PaymentsVerifier.verifyWebhook(
          rawBody: _kBody,
          signatureHeader: '   ',
          secret: _kSecret,
          now: _eventTime,
        ),
        WebhookVerdict.missingSignature,
      );
    });

    test('header without v1 -> malformedSignature', () {
      expect(
        PaymentsVerifier.verifyWebhook(
          rawBody: _kBody,
          signatureHeader: 't=$_kT',
          secret: _kSecret,
          now: _eventTime,
        ),
        WebhookVerdict.malformedSignature,
      );
    });

    test('non-numeric timestamp -> malformedSignature', () {
      expect(
        PaymentsVerifier.verifyWebhook(
          rawBody: _kBody,
          signatureHeader: 't=notanumber,v1=$_kSig',
          secret: _kSecret,
          now: _eventTime,
        ),
        WebhookVerdict.malformedSignature,
      );
    });

    test('stale timestamp beyond tolerance -> staleTimestamp', () {
      expect(
        PaymentsVerifier.verifyWebhook(
          rawBody: _kBody,
          signatureHeader: _header,
          secret: _kSecret,
          now: _eventTime.add(const Duration(minutes: 6)),
        ),
        WebhookVerdict.staleTimestamp,
      );
    });

    test('future clock skew beyond tolerance -> staleTimestamp', () {
      expect(
        PaymentsVerifier.verifyWebhook(
          rawBody: _kBody,
          signatureHeader: _header,
          secret: _kSecret,
          now: _eventTime.subtract(const Duration(minutes: 6)),
        ),
        WebhookVerdict.staleTimestamp,
      );
    });

    test('exactly at tolerance boundary still verifies', () {
      expect(
        PaymentsVerifier.verifyWebhook(
          rawBody: _kBody,
          signatureHeader: _header,
          secret: _kSecret,
          now: _eventTime.add(const Duration(minutes: 5)),
        ),
        WebhookVerdict.verified,
      );
    });

    test('constant-time compare: mismatch at first OR last hex char both fail '
        '(no input-dependent early return)', () {
      final firstFlipped = 't=$_kT,v1=f${_kSig.substring(1)}';
      final lastFlipped =
          't=$_kT,v1=${_kSig.substring(0, _kSig.length - 1)}f';
      expect(
        PaymentsVerifier.verifyWebhook(
          rawBody: _kBody,
          signatureHeader: firstFlipped,
          secret: _kSecret,
          now: _eventTime,
        ),
        WebhookVerdict.signatureMismatch,
      );
      expect(
        PaymentsVerifier.verifyWebhook(
          rawBody: _kBody,
          signatureHeader: lastFlipped,
          secret: _kSecret,
          now: _eventTime,
        ),
        WebhookVerdict.signatureMismatch,
      );
    });
  });

  group('parseEvent', () {
    test('grant: kind/id/user/until normalised', () {
      final e = PaymentsVerifier.parseEvent(_kBody);
      expect(e, isNotNull);
      expect(e!.kind, PaymentEventKind.grant);
      expect(e.eventId, 'evt_abc123');
      expect(e.userId, '11111111-1111-1111-1111-111111111111');
      expect(
        e.until,
        DateTime.fromMillisecondsSinceEpoch(1781536000 * 1000, isUtc: true),
      );
    });

    test('refund / chargeback / lapse map to clawback kinds with no until', () {
      const refund = '{"id":"e","user_id":"u","type":"charge.refunded"}';
      const chargeback =
          '{"id":"e","user_id":"u","type":"charge.dispute.created"}';
      const lapse =
          '{"id":"e","user_id":"u","type":"customer.subscription.deleted"}';
      expect(PaymentsVerifier.parseEvent(refund)?.kind, PaymentEventKind.refund);
      expect(PaymentsVerifier.parseEvent(chargeback)?.kind,
          PaymentEventKind.chargeback);
      expect(PaymentsVerifier.parseEvent(lapse)?.kind, PaymentEventKind.lapse);
      expect(PaymentsVerifier.parseEvent(refund)?.until, isNull);
    });

    test('unknown event type is ignored (null), never crashes', () {
      expect(
        PaymentsVerifier.parseEvent(
            '{"id":"e","user_id":"u","type":"invoice.voided"}'),
        isNull,
      );
    });

    test('missing id or user_id -> null', () {
      expect(
        PaymentsVerifier.parseEvent('{"user_id":"u","type":"charge.refunded"}'),
        isNull,
      );
      expect(
        PaymentsVerifier.parseEvent('{"id":"e","type":"charge.refunded"}'),
        isNull,
      );
    });

    test('non-JSON / non-object payloads -> null (no throw)', () {
      expect(PaymentsVerifier.parseEvent('not json {'), isNull);
      expect(PaymentsVerifier.parseEvent('[1,2,3]'), isNull);
      expect(PaymentsVerifier.parseEvent('42'), isNull);
    });

    test('direct kind + client_reference_id fallback + ISO until', () {
      final e = PaymentsVerifier.parseEvent(
          '{"id":"e","client_reference_id":"u","kind":"grant",'
          '"until":"2027-06-01T00:00:00Z"}');
      expect(e, isNotNull);
      expect(e!.kind, PaymentEventKind.grant);
      expect(e.userId, 'u');
      expect(e.until, DateTime.utc(2027, 6, 1));
    });
  });

  group('razorpay (R-J7a web-checkout verifier)', () {
    // Reference vector: rzpSig = python
    //   hmac.new(b"<secret>", b"<rzpBody>", sha256).hexdigest()   (body-only, NO timestamp)
    const rzpSecret = 'rzp_test_whsec_build_ahead';
    const rzpBody =
        '{"entity":"event","event":"subscription.charged",'
        '"contains":["subscription","payment"],'
        '"payload":{"subscription":{"entity":{"id":"sub_PAY1build",'
        '"current_end":1781536000,'
        '"notes":{"user_id":"11111111-1111-1111-1111-111111111111"}}},'
        '"payment":{"entity":{"id":"pay_PAY1build"}}}}';
    const rzpSig =
        'f323a8e9f1d0e67703763155e70622a112eb9ac3d88240816dda770bec20f0cb';

    // payload helper: wrap an entity under payload.<key>.entity for an event.
    String body(String event, String key, String entityJson) =>
        '{"event":"$event","payload":{"$key":{"entity":$entityJson}}}';

    test('valid signature verifies (inline HMAC == python ref, no timestamp)', () {
      expect(
        PaymentsVerifier.verifyRazorpayWebhook(
            rawBody: rzpBody, signature: rzpSig, secret: rzpSecret),
        WebhookVerdict.verified,
      );
    });

    test('uppercased signature still verifies (compared lowercased)', () {
      expect(
        PaymentsVerifier.verifyRazorpayWebhook(
            rawBody: rzpBody, signature: rzpSig.toUpperCase(), secret: rzpSecret),
        WebhookVerdict.verified,
      );
    });

    test('tampered body -> signatureMismatch', () {
      expect(
        PaymentsVerifier.verifyRazorpayWebhook(
            rawBody: '$rzpBody ', signature: rzpSig, secret: rzpSecret),
        WebhookVerdict.signatureMismatch,
      );
    });

    test('wrong secret -> signatureMismatch', () {
      expect(
        PaymentsVerifier.verifyRazorpayWebhook(
            rawBody: rzpBody, signature: rzpSig, secret: 'rzp_wrong'),
        WebhookVerdict.signatureMismatch,
      );
    });

    test('empty secret -> missingSecret', () {
      expect(
        PaymentsVerifier.verifyRazorpayWebhook(
            rawBody: rzpBody, signature: rzpSig, secret: ''),
        WebhookVerdict.missingSecret,
      );
    });

    test('blank signature -> missingSignature', () {
      expect(
        PaymentsVerifier.verifyRazorpayWebhook(
            rawBody: rzpBody, signature: '   ', secret: rzpSecret),
        WebhookVerdict.missingSignature,
      );
    });

    test('subscription.charged -> grant w/ user + until from current_end', () {
      final e = PaymentsVerifier.parseRazorpayEvent(rzpBody);
      expect(e, isNotNull);
      expect(e!.kind, PaymentEventKind.grant);
      expect(e.eventId, 'sub_PAY1build');
      expect(e.userId, '11111111-1111-1111-1111-111111111111');
      expect(e.until,
          DateTime.fromMillisecondsSinceEpoch(1781536000 * 1000, isUtc: true));
    });

    test('passed-in X-Razorpay-Event-Id wins over entity id', () {
      final e =
          PaymentsVerifier.parseRazorpayEvent(rzpBody, eventId: 'evt_hdr_1');
      expect(e!.eventId, 'evt_hdr_1');
    });

    test('every mapped event name -> correct kind', () {
      const n = '"notes":{"user_id":"u1"}';
      PaymentEventKind? k(String ev, String key, String id) =>
          PaymentsVerifier.parseRazorpayEvent(body(ev, key, '{"id":"$id",$n}'))
              ?.kind;
      expect(k('order.paid', 'order', 'o1'), PaymentEventKind.grant);
      expect(k('payment.captured', 'payment', 'p1'), PaymentEventKind.grant);
      expect(k('subscription.activated', 'subscription', 's1'),
          PaymentEventKind.grant);
      expect(k('refund.created', 'refund', 'r1'), PaymentEventKind.refund);
      expect(k('refund.processed', 'refund', 'r2'), PaymentEventKind.refund);
      expect(k('payment.dispute.created', 'payment', 'p2'),
          PaymentEventKind.chargeback);
      expect(k('subscription.cancelled', 'subscription', 's2'),
          PaymentEventKind.lapse);
      expect(k('subscription.halted', 'subscription', 's3'),
          PaymentEventKind.lapse);
      expect(k('subscription.completed', 'subscription', 's4'),
          PaymentEventKind.lapse);
    });

    test('unknown event -> null (never throws)', () {
      expect(
        PaymentsVerifier.parseRazorpayEvent(body(
            'payment.failed', 'payment', '{"id":"p1","notes":{"user_id":"u1"}}')),
        isNull,
      );
    });

    test('clawback (refund) carries no until', () {
      final e = PaymentsVerifier.parseRazorpayEvent(body(
          'refund.created', 'refund', '{"id":"r1","notes":{"user_id":"u1"}}'));
      expect(e!.kind, PaymentEventKind.refund);
      expect(e.until, isNull);
    });

    test('grant via order.paid (one-time) has null until', () {
      final e = PaymentsVerifier.parseRazorpayEvent(body(
          'order.paid', 'order', '{"id":"o1","notes":{"user_id":"u1"}}'));
      expect(e!.kind, PaymentEventKind.grant);
      expect(e.until, isNull);
    });

    test('userId falls back to notes.client_reference_id', () {
      final e = PaymentsVerifier.parseRazorpayEvent(body('order.paid', 'order',
          '{"id":"o1","notes":{"client_reference_id":"u9"}}'));
      expect(e!.userId, 'u9');
    });

    test('missing notes user id -> null (cannot attribute entitlement)', () {
      expect(
        PaymentsVerifier.parseRazorpayEvent(
            body('order.paid', 'order', '{"id":"o1","notes":{"foo":"bar"}}')),
        isNull,
      );
    });

    test('non-JSON / non-object Razorpay body -> null', () {
      expect(PaymentsVerifier.parseRazorpayEvent('not json {'), isNull);
      expect(PaymentsVerifier.parseRazorpayEvent('[1,2,3]'), isNull);
    });
  });
}
