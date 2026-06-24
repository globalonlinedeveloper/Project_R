// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// AUDIT-2 [R-M5 · R-M8 · R-K6] tests for the Dart audit-sink adapters against a FAKE
// transport: the request shape matches the schema/sql/0008 record_audit_event RPC
// (POST /rest/v1/rpc/record_audit_event, p_category/p_action/p_user_id/p_detail); the M2
// moderation seam maps verdict->action with a NULL user + {stage} detail; the M8 grant seam
// maps decision->action with the pseudonymous userId + {source, deviceId} detail; an
// unconfigured sink is a NO-OP (transport untouched); and a non-2xx / throwing transport is
// fail-soft (verified via onError, never rethrown into the caller). No network, no key.
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

const _cfg = AuditConfig(
  baseUrl: 'https://ratel.supabase.test',
  serviceRoleKey: 'svc-test-key', // deliberately NOT a full-shape secret (scan-safe)
);

Future<HttpLikeResponse> _ok(HttpLikeRequest _) async =>
    const HttpLikeResponse(statusCode: 200, body: '');

Map<String, dynamic> _decodeBody(HttpLikeRequest req) =>
    jsonDecode(req.body) as Map<String, dynamic>;

void main() {
  group('buildRequest (shape mirrors the 0008 RPC)', () {
    test('POST to record_audit_event with the p_* body + auth headers', () {
      final w = AuditEventWriter(transport: _ok, config: _cfg);
      final req = w.buildRequest(
        category: 'grant',
        action: 'denyVelocity',
        userId: 'user-1',
        detail: <String, Object?>{'source': 'referral', 'deviceId': 'dev-1'},
      );
      expect(req.method, 'POST');
      expect(req.url, 'https://ratel.supabase.test/rest/v1/rpc/record_audit_event');
      expect(req.headers['authorization'], 'Bearer svc-test-key');
      expect(req.headers['apikey'], 'svc-test-key');
      expect(req.headers['content-type'], 'application/json');
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['p_category'], 'grant');
      expect(body['p_action'], 'denyVelocity');
      expect(body['p_user_id'], 'user-1');
      expect(body['p_detail'], <String, Object?>{'source': 'referral', 'deviceId': 'dev-1'});
    });

    test('null userId serialises p_user_id as null', () {
      final w = AuditEventWriter(transport: _ok, config: _cfg);
      final req = w.buildRequest(category: 'moderation', action: 'blocked');
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      expect(body.containsKey('p_user_id'), isTrue);
      expect(body['p_user_id'], isNull);
      expect(body['p_detail'], <String, Object?>{});
    });
  });

  group('recordEvent (awaitable core)', () {
    test('unconfigured -> false, transport untouched, onError=unconfigured', () async {
      final errs = <String>[];
      final t = _FakeTransport(_ok);
      final w = AuditEventWriter(transport: t.handle, onError: errs.add); // default empty config
      final ok = await w.recordEvent(category: 'grant', action: 'allow');
      expect(ok, isFalse);
      expect(t.calls, 0);
      expect(errs, <String>['unconfigured']);
    });

    test('2xx (200 and 204) -> true', () async {
      for (final code in <int>[200, 204]) {
        final t = _FakeTransport((_) async => HttpLikeResponse(statusCode: code, body: ''));
        final w = AuditEventWriter(transport: t.handle, config: _cfg);
        expect(await w.recordEvent(category: 'moderation', action: 'allowed'), isTrue);
        expect(t.calls, 1);
      }
    });

    test('non-2xx -> false + onError, body never surfaced', () async {
      final errs = <String>[];
      final t = _FakeTransport(
          (_) async => const HttpLikeResponse(statusCode: 500, body: 'upstream secret detail'));
      final w = AuditEventWriter(transport: t.handle, config: _cfg, onError: errs.add);
      final ok = await w.recordEvent(category: 'grant', action: 'denyVelocity');
      expect(ok, isFalse);
      expect(errs.single, 'non-2xx status 500');
      expect(errs.single, isNot(contains('upstream secret detail')));
    });

    test('transport throw -> false + onError, fail-soft (never rethrows)', () async {
      final errs = <String>[];
      final t = _FakeTransport((_) async => throw const FormatException('boom'));
      final w = AuditEventWriter(transport: t.handle, config: _cfg, onError: errs.add);
      final ok = await w.recordEvent(category: 'grant', action: 'denyTurnstile');
      expect(ok, isFalse);
      expect(errs.single, startsWith('audit write failed'));
    });
  });

  group('HttpModerationAuditSink (M2 seam adapter)', () {
    test('verdict -> moderation row, NULL user, {stage} detail', () async {
      final t = _FakeTransport(_ok);
      final sink = HttpModerationAuditSink(
          AuditEventWriter(transport: t.handle, config: _cfg));
      sink.record(stage: 'output', verdict: ModerationVerdict.blocked);
      expect(await sink.writer.lastWrite, isTrue);
      final body = _decodeBody(t.last!);
      expect(body['p_category'], 'moderation');
      expect(body['p_action'], 'blocked');
      expect(body['p_user_id'], isNull);
      expect(body['p_detail'], <String, Object?>{'stage': 'output'});
    });

    test('every verdict name is recorded as the action', () async {
      for (final v in ModerationVerdict.values) {
        final t = _FakeTransport(_ok);
        final sink = HttpModerationAuditSink(
            AuditEventWriter(transport: t.handle, config: _cfg));
        sink.record(stage: 'input', verdict: v);
        await sink.writer.lastWrite;
        expect(_decodeBody(t.last!)['p_action'], v.name);
      }
    });

    test('unconfigured moderation sink is a no-op (transport untouched)', () async {
      final t = _FakeTransport(_ok);
      final sink = HttpModerationAuditSink(AuditEventWriter(transport: t.handle));
      sink.record(stage: 'output', verdict: ModerationVerdict.unknown);
      expect(await sink.writer.lastWrite, isFalse);
      expect(t.calls, 0);
    });
  });

  group('HttpGrantAuditSink (M8 seam adapter)', () {
    test('decision -> grant row, userId, {source, deviceId} detail', () async {
      final t = _FakeTransport(_ok);
      final sink =
          HttpGrantAuditSink(AuditEventWriter(transport: t.handle, config: _cfg));
      sink.record(
        GrantDecision.denyVelocity,
        userId: 'u-42',
        deviceId: 'dev-9',
        source: GrantSource.referral,
      );
      expect(await sink.writer.lastWrite, isTrue);
      final body = _decodeBody(t.last!);
      expect(body['p_category'], 'grant');
      expect(body['p_action'], 'denyVelocity');
      expect(body['p_user_id'], 'u-42');
      expect(body['p_detail'], <String, Object?>{'source': 'referral', 'deviceId': 'dev-9'});
    });

    test('decision + source names round-trip across variants', () async {
      final cases = <(GrantDecision, GrantSource)>[
        (GrantDecision.allow, GrantSource.dailyFree),
        (GrantDecision.denySelfReferral, GrantSource.referral),
        (GrantDecision.denyAttestation, GrantSource.adReward),
        (GrantDecision.denyTurnstile, GrantSource.promo),
      ];
      for (final c in cases) {
        final t = _FakeTransport(_ok);
        final sink =
            HttpGrantAuditSink(AuditEventWriter(transport: t.handle, config: _cfg));
        sink.record(c.$1, userId: 'u', deviceId: 'd', source: c.$2);
        await sink.writer.lastWrite;
        final body = _decodeBody(t.last!);
        expect(body['p_action'], c.$1.name);
        expect((body['p_detail'] as Map)['source'], c.$2.name);
      }
    });

    test('grant record() on a throwing transport does not throw into the caller', () async {
      final t = _FakeTransport((_) async => throw StateError('down'));
      final sink =
          HttpGrantAuditSink(AuditEventWriter(transport: t.handle, config: _cfg));
      // The void seam call must return normally even though the write will fail.
      expect(
        () => sink.record(GrantDecision.denyVelocity,
            userId: 'u', deviceId: 'd', source: GrantSource.adReward),
        returnsNormally,
      );
      expect(await sink.writer.lastWrite, isFalse);
    });
  });

  group('AuditSinks bundle', () {
    test('one config + transport powers both seams', () async {
      final t = _FakeTransport(_ok);
      final sinks = AuditSinks(transport: t.handle, config: _cfg);
      sinks.moderation.record(stage: 'input', verdict: ModerationVerdict.allowed);
      await sinks.writer.lastWrite;
      sinks.grant.record(GrantDecision.allow,
          userId: 'u', deviceId: 'd', source: GrantSource.subscription);
      await sinks.writer.lastWrite;
      expect(t.calls, 2);
    });

    test('default AuditSinks() is unconfigured -> no-op', () async {
      final t = _FakeTransport(_ok);
      final sinks = AuditSinks(transport: t.handle);
      sinks.grant.record(GrantDecision.denyVelocity,
          userId: 'u', deviceId: 'd', source: GrantSource.promo);
      expect(await sinks.writer.lastWrite, isFalse);
      expect(t.calls, 0);
    });
  });
}
