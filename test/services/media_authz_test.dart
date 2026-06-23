// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// M6 [P1-6 · TS-12] tests (flutter-gate) for media access authorization + the
// signed-URL policy. Pure: no network, no credential, injected clock + fake signer.
// Proves: Pro-only audio is DENIED to non-Pro (signer never invoked); every granted URL
// is single-object + GET-only + short-TTL; over-broad signing requests are refused; an
// expired entitlement resolves to non-Pro at `now`.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

/// Records every signing request and returns a deterministic fake URL.
class _RecordingSigner implements UrlSigner {
  final List<SignedUrlRequest> calls = <SignedUrlRequest>[];
  int get count => calls.length;

  @override
  Future<String> sign(SignedUrlRequest request) async {
    calls.add(request);
    return 'https://r2.fake/${request.objectKey}'
        '?ttl=${request.ttl.inSeconds}&m=${request.method}';
  }
}

/// A signer that MUST never be called; throws if it is.
class _ExplodingSigner implements UrlSigner {
  int count = 0;
  @override
  Future<String> sign(SignedUrlRequest request) async {
    count++;
    throw StateError('signer must not be invoked on a deny');
  }
}

void main() {
  final now = DateTime.utc(2026, 6, 23, 12);
  const policy = MediaAccessPolicy();
  const urlPolicy = SignedUrlPolicy();
  const key = 'audio/lesson_42/clip_01.mp3';

  group('MediaAccessPolicy.authorize', () {
    test('free + non-Pro -> Grant with short TTL, exact scope, expiry = now+ttl', () {
      final d = policy.authorize(
          assetTier: MediaAssetTier.free, assetKey: key, isPro: false, now: now);
      expect(d, isA<MediaAccessGrant>());
      final g = d as MediaAccessGrant;
      expect(g.scopePath, key);
      expect(g.ttl, const Duration(minutes: 5));
      expect(g.ttl <= const Duration(minutes: 15), isTrue);
      expect(g.expiresAt, now.add(const Duration(minutes: 5)));
    });

    test('free + Pro -> Grant (Pro never restricts free assets)', () {
      final d = policy.authorize(
          assetTier: MediaAssetTier.free, assetKey: key, isPro: true, now: now);
      expect(d, isA<MediaAccessGrant>());
    });

    test('proAudio + non-Pro -> Deny(notEntitled) — authorization, not obscurity', () {
      final d = policy.authorize(
          assetTier: MediaAssetTier.proAudio,
          assetKey: key,
          isPro: false,
          now: now);
      expect(d, isA<MediaAccessDeny>());
      expect((d as MediaAccessDeny).reason, MediaDenyReason.notEntitled);
    });

    test('proAudio + Pro -> Grant with short TTL', () {
      final d = policy.authorize(
          assetTier: MediaAssetTier.proAudio,
          assetKey: key,
          isPro: true,
          now: now);
      expect(d, isA<MediaAccessGrant>());
      expect((d as MediaAccessGrant).ttl, const Duration(minutes: 5));
    });

    test('empty / prefix / wildcard / traversal keys -> Deny(invalidAsset)', () {
      for (final bad in <String>['', 'audio/lesson_42/', 'audio/*', '../secret', '/abs']) {
        final d = policy.authorize(
            assetTier: MediaAssetTier.free, assetKey: bad, isPro: true, now: now);
        expect(d, isA<MediaAccessDeny>(), reason: 'key="$bad"');
        expect((d as MediaAccessDeny).reason, MediaDenyReason.invalidAsset,
            reason: 'key="$bad"');
      }
    });
  });

  group('MediaEntitlement (server-side, time-aware)', () {
    test('expired pro_until -> not Pro at now', () {
      final ent = MediaEntitlement(proUntil: now.subtract(const Duration(days: 1)));
      expect(ent.isProAt(now), isFalse);
    });

    test('future pro_until -> Pro at now; null -> never Pro', () {
      final active = MediaEntitlement(proUntil: now.add(const Duration(days: 1)));
      expect(active.isProAt(now), isTrue);
      expect(const MediaEntitlement().isProAt(now), isFalse);
    });

    test('now past faked expiry -> non-Pro -> proAudio Deny', () {
      final ent = MediaEntitlement(proUntil: now.subtract(const Duration(seconds: 1)));
      final d = policy.authorize(
          assetTier: MediaAssetTier.proAudio,
          assetKey: key,
          isPro: ent.isProAt(now),
          now: now);
      expect(d, isA<MediaAccessDeny>());
      expect((d as MediaAccessDeny).reason, MediaDenyReason.notEntitled);
    });
  });

  group('SignedUrlPolicy.buildRequest (over-broad requests are unconstructable)', () {
    test('valid -> GET, single object, short TTL', () {
      final r = urlPolicy.buildRequest(
          objectKey: key, ttl: const Duration(minutes: 5));
      expect(r.objectKey, key);
      expect(r.method, 'GET');
      expect(r.ttl, const Duration(minutes: 5));
    });

    test('TTL beyond ceiling is refused (never silently clamped)', () {
      expect(
        () => urlPolicy.buildRequest(objectKey: key, ttl: const Duration(hours: 1)),
        throwsA(isA<SignedUrlPolicyViolation>()),
      );
    });

    test('zero / negative TTL is refused', () {
      expect(() => urlPolicy.buildRequest(objectKey: key, ttl: Duration.zero),
          throwsA(isA<SignedUrlPolicyViolation>()));
      expect(
          () => urlPolicy.buildRequest(
              objectKey: key, ttl: const Duration(seconds: -1)),
          throwsA(isA<SignedUrlPolicyViolation>()));
    });

    test('prefix / wildcard / traversal / empty scope is rejected', () {
      for (final bad in <String>['audio/', 'audio/*', '../x', '', '/abs']) {
        expect(
          () => urlPolicy.buildRequest(objectKey: bad, ttl: const Duration(minutes: 1)),
          throwsA(isA<SignedUrlPolicyViolation>()),
          reason: 'key="$bad"',
        );
      }
    });

    test('non-GET method is refused', () {
      for (final m in <String>['PUT', 'POST', 'DELETE', 'HEAD', 'get']) {
        expect(
          () => urlPolicy.buildRequest(
              objectKey: key, ttl: const Duration(minutes: 1), method: m),
          throwsA(isA<SignedUrlPolicyViolation>()),
          reason: 'method="$m"',
        );
      }
    });

    test('isSingleObjectKey classifies keys', () {
      expect(SignedUrlPolicy.isSingleObjectKey(key), isTrue);
      expect(SignedUrlPolicy.isSingleObjectKey('a/b/c.mp3'), isTrue);
      expect(SignedUrlPolicy.isSingleObjectKey(''), isFalse);
      expect(SignedUrlPolicy.isSingleObjectKey('a/'), isFalse);
      expect(SignedUrlPolicy.isSingleObjectKey('a/*'), isFalse);
      expect(SignedUrlPolicy.isSingleObjectKey('../a'), isFalse);
    });
  });

  group('MediaUrlService.issue (orchestration + signer discipline)', () {
    test('free + non-Pro -> Issued; signer asked exactly once, GET/single/short-TTL', () async {
      final signer = _RecordingSigner();
      final svc = MediaUrlService(
          accessPolicy: policy, urlPolicy: urlPolicy, signer: signer);
      final r = await svc.issue(
          assetTier: MediaAssetTier.free, assetKey: key, isPro: false, now: now);
      expect(r, isA<MediaUrlIssued>());
      final issued = r as MediaUrlIssued;
      expect(signer.count, 1);
      expect(signer.calls.single.method, 'GET');
      expect(signer.calls.single.objectKey, key);
      expect(signer.calls.single.ttl, const Duration(minutes: 5));
      expect(issued.request.method, 'GET');
      expect(issued.url, contains(key));
      expect(issued.expiresAt, now.add(const Duration(minutes: 5)));
    });

    test('proAudio + non-Pro -> Denied(notEntitled); signer NEVER invoked', () async {
      final signer = _ExplodingSigner();
      final svc = MediaUrlService(
          accessPolicy: policy, urlPolicy: urlPolicy, signer: signer);
      final r = await svc.issue(
          assetTier: MediaAssetTier.proAudio,
          assetKey: key,
          isPro: false,
          now: now);
      expect(r, isA<MediaUrlDenied>());
      expect((r as MediaUrlDenied).reason, MediaDenyReason.notEntitled);
      expect(signer.count, 0);
    });

    test('proAudio + Pro -> Issued; signer invoked once', () async {
      final signer = _RecordingSigner();
      final svc = MediaUrlService(
          accessPolicy: policy, urlPolicy: urlPolicy, signer: signer);
      final r = await svc.issue(
          assetTier: MediaAssetTier.proAudio,
          assetKey: key,
          isPro: true,
          now: now);
      expect(r, isA<MediaUrlIssued>());
      expect(signer.count, 1);
    });

    test('now past faked expiry -> non-Pro -> Denied; signer never invoked', () async {
      final signer = _ExplodingSigner();
      final svc = MediaUrlService(
          accessPolicy: policy, urlPolicy: urlPolicy, signer: signer);
      final ent = MediaEntitlement(proUntil: now.subtract(const Duration(minutes: 1)));
      final r = await svc.issue(
          assetTier: MediaAssetTier.proAudio,
          assetKey: key,
          isPro: ent.isProAt(now),
          now: now);
      expect(r, isA<MediaUrlDenied>());
      expect(signer.count, 0);
    });

    test('invalid asset key -> Denied(invalidAsset); signer never invoked', () async {
      final signer = _ExplodingSigner();
      final svc = MediaUrlService(
          accessPolicy: policy, urlPolicy: urlPolicy, signer: signer);
      final r = await svc.issue(
          assetTier: MediaAssetTier.free, assetKey: 'audio/', isPro: true, now: now);
      expect(r, isA<MediaUrlDenied>());
      expect((r as MediaUrlDenied).reason, MediaDenyReason.invalidAsset);
      expect(signer.count, 0);
    });
  });
}
