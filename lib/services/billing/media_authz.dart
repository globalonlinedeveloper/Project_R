// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// M6 [P1-6 · TS-12] — media access authorization + signed-URL policy.
//
// Pure Dart, ZERO network, NO credential embedded. Decides (a) WHETHER a user may
// receive a media URL for an asset (authorization, not obscurity) and (b) the exact
// TTL/scope/method that URL must carry. The real Cloudflare R2 presigner is the
// injected [UrlSigner] seam; the local fake just records what it was asked to sign.
//
// Two layers, both fail-closed:
//   * [MediaAccessPolicy.authorize] — entitlement gate. `proAudio` assets require Pro;
//     a non-Pro user is DENIED outright (the URL is never minted), not merely hidden.
//     Entitlement is resolved SERVER-SIDE ([MediaEntitlement.isProAt] / the Part-1
//     `Entitlements.isPro` contract), never asserted by the client.
//   * [SignedUrlPolicy.buildRequest] — the ONLY sanctioned way to mint a
//     [SignedUrlRequest]. It refuses prefixes/wildcards, non-GET methods, and TTLs
//     beyond a short ceiling, so an over-broad signing request is unconstructable.
//
// GO-LIVE STOP: real Cloudflare R2 bucket + presign credentials, Turnstile keys, and KV
// — all owner-gated. Only the [UrlSigner] implementation is swapped in; this logic stays.

/// Sensitivity tier of a media asset. `proAudio` requires a Pro entitlement; `free`
/// media is available to every user (still short-TTL, single-object, GET-only).
enum MediaAssetTier { free, proAudio }

/// Why a media URL was denied. Callers branch on this — never a bare bool/null.
enum MediaDenyReason {
  /// The asset is Pro-gated and the user is not (currently) Pro.
  notEntitled,

  /// The requested asset key is not a single concrete object (prefix/wildcard/empty).
  invalidAsset,
}

/// Time-aware Pro entitlement, evaluated SERVER-SIDE. Mirrors the Part-1
/// `Entitlements.isPro` contract but adds the `pro_until` instant so an expired
/// subscription resolves to non-Pro at the relevant [now]. A client never supplies this.
class MediaEntitlement {
  /// Pro is active strictly before this instant; `null` means never Pro (free tier).
  final DateTime? proUntil;

  const MediaEntitlement({this.proUntil});

  /// Whether Pro is active at [now]. Free (null) or lapsed (`now >= proUntil`) ⇒ false.
  bool isProAt(DateTime now) => proUntil != null && now.isBefore(proUntil!);
}

/// Thrown when a signing request would violate the signed-URL policy (prefix/wildcard
/// scope, non-GET method, or a non-positive / over-ceiling TTL). Fail-closed: the policy
/// REFUSES rather than silently narrowing, so an over-broad URL can never be issued.
class SignedUrlPolicyViolation implements Exception {
  final String message;
  const SignedUrlPolicyViolation(this.message);
  @override
  String toString() => 'SignedUrlPolicyViolation: $message';
}

/// A fully-validated request to presign exactly ONE object, GET-only, for a short TTL.
/// It is unconstructable in an over-broad form: [SignedUrlPolicy.buildRequest] is the
/// only sanctioned builder, and it enforces every invariant before this exists.
class SignedUrlRequest {
  /// Exact object key (never a prefix or wildcard).
  final String objectKey;

  /// Time-to-live of the signed URL — short, within the policy ceiling.
  final Duration ttl;

  /// HTTP method the signed URL permits — always `GET`.
  final String method;

  const SignedUrlRequest._(this.objectKey, this.ttl, this.method);

  @override
  String toString() =>
      'SignedUrlRequest($objectKey, ttl=${ttl.inSeconds}s, $method)';
}

/// The invariants every signed media URL must satisfy: a single exact object, GET-only,
/// and a TTL within a short ceiling. [buildRequest] is the ONLY way to mint a
/// [SignedUrlRequest]; it throws [SignedUrlPolicyViolation] on any over-broad input.
class SignedUrlPolicy {
  /// Hard ceiling on signed-URL lifetime. Requests longer than this are refused.
  final Duration maxTtl;

  const SignedUrlPolicy({this.maxTtl = const Duration(minutes: 15)});

  /// Validate and mint a [SignedUrlRequest]. Refuses (throws) on: a non-GET method, a
  /// non-single-object key (empty/prefix/wildcard/traversal), a non-positive TTL, or a
  /// TTL beyond [maxTtl]. Never silently clamps — refusing is the fail-closed choice.
  SignedUrlRequest buildRequest({
    required String objectKey,
    required Duration ttl,
    String method = 'GET',
  }) {
    if (method != 'GET') {
      throw SignedUrlPolicyViolation('only GET is permitted, got "$method"');
    }
    if (!isSingleObjectKey(objectKey)) {
      throw SignedUrlPolicyViolation(
          'scope must be a single object key, not a prefix: "$objectKey"');
    }
    if (ttl <= Duration.zero) {
      throw const SignedUrlPolicyViolation('ttl must be positive');
    }
    if (ttl > maxTtl) {
      throw SignedUrlPolicyViolation('ttl $ttl exceeds ceiling $maxTtl');
    }
    return SignedUrlRequest._(objectKey, ttl, method);
  }

  /// True iff [key] names exactly one object: non-empty, no trailing `/` (prefix),
  /// no `*` (wildcard), no `..` (traversal), no leading `/` (absolute/odd).
  static bool isSingleObjectKey(String key) {
    if (key.isEmpty) return false;
    if (key.endsWith('/')) return false;
    if (key.contains('*')) return false;
    if (key.contains('..')) return false;
    if (key.startsWith('/')) return false;
    return true;
  }
}

/// Grant TTLs per tier. Short by default; both must stay within the [SignedUrlPolicy]
/// ceiling (the policy refuses anything longer regardless).
class MediaAuthzConfig {
  final Duration freeTtl;
  final Duration proAudioTtl;

  const MediaAuthzConfig({
    this.freeTtl = const Duration(minutes: 5),
    this.proAudioTtl = const Duration(minutes: 5),
  });
}

/// Outcome of a media access check: [MediaAccessGrant] or [MediaAccessDeny].
sealed class MediaAuthzDecision {
  const MediaAuthzDecision();
}

/// Access granted: the caller may presign [scopePath] for [ttl] (expiring at [expiresAt]).
class MediaAccessGrant extends MediaAuthzDecision {
  /// Exact object key the grant is scoped to.
  final String scopePath;

  /// Short TTL the eventual signed URL must carry.
  final Duration ttl;

  /// Absolute expiry instant (`now + ttl`).
  final DateTime expiresAt;

  const MediaAccessGrant({
    required this.scopePath,
    required this.ttl,
    required this.expiresAt,
  });
}

/// Access denied — no URL is minted. [reason] explains why.
class MediaAccessDeny extends MediaAuthzDecision {
  final MediaDenyReason reason;
  const MediaAccessDeny(this.reason);
}

/// Pure authorization core. Decides whether a user may receive a media URL and, if so,
/// the TTL/scope it must carry. Entitlement is read SERVER-SIDE ([isPro] resolved by the
/// caller from [MediaEntitlement.isProAt]); a client never asserts its own tier.
class MediaAccessPolicy {
  final MediaAuthzConfig config;

  const MediaAccessPolicy({this.config = const MediaAuthzConfig()});

  /// Authorize access to [assetKey] of [assetTier] for a user whose Pro status (resolved
  /// server-side at [now]) is [isPro]. `proAudio` + non-Pro ⇒ [MediaAccessDeny]
  /// (authorization, not obscurity). An invalid asset key ⇒ deny. Otherwise ⇒ grant
  /// with the tier's short TTL, scoped to the exact key, expiring at `now + ttl`.
  MediaAuthzDecision authorize({
    required MediaAssetTier assetTier,
    required String assetKey,
    required bool isPro,
    required DateTime now,
  }) {
    if (!SignedUrlPolicy.isSingleObjectKey(assetKey)) {
      return const MediaAccessDeny(MediaDenyReason.invalidAsset);
    }
    if (assetTier == MediaAssetTier.proAudio && !isPro) {
      return const MediaAccessDeny(MediaDenyReason.notEntitled);
    }
    final ttl = assetTier == MediaAssetTier.proAudio
        ? config.proAudioTtl
        : config.freeTtl;
    return MediaAccessGrant(
      scopePath: assetKey,
      ttl: ttl,
      expiresAt: now.add(ttl),
    );
  }
}

/// Presign seam (R-J7a / TS-12). The real Cloudflare R2 presigner plugs in here at
/// go-live; the local fake just records `(objectKey, ttl, method)`. Only ever handed a
/// policy-validated [SignedUrlRequest], so an implementation cannot widen the scope.
abstract interface class UrlSigner {
  Future<String> sign(SignedUrlRequest request);
}

/// Result of issuing a media URL: [MediaUrlIssued] or [MediaUrlDenied].
sealed class MediaUrlResult {
  const MediaUrlResult();
}

/// A signed, short-lived, single-object, GET-only URL was issued.
class MediaUrlIssued extends MediaUrlResult {
  final String url;
  final SignedUrlRequest request;
  final DateTime expiresAt;
  const MediaUrlIssued({
    required this.url,
    required this.request,
    required this.expiresAt,
  });
}

/// No URL was issued; [reason] explains why. The signer was NOT invoked.
class MediaUrlDenied extends MediaUrlResult {
  final MediaDenyReason reason;
  const MediaUrlDenied(this.reason);
}

/// Orchestrates authorization → policy-validated request → signer. On a Deny the signer
/// is NEVER invoked (no URL is minted for an unauthorized or invalid asset).
class MediaUrlService {
  final MediaAccessPolicy accessPolicy;
  final SignedUrlPolicy urlPolicy;
  final UrlSigner signer;

  const MediaUrlService({
    required this.accessPolicy,
    required this.urlPolicy,
    required this.signer,
  });

  /// Authorize then (on grant) build a policy-validated request and ask the [signer] for
  /// a URL. Returns [MediaUrlDenied] without touching the signer on any deny.
  Future<MediaUrlResult> issue({
    required MediaAssetTier assetTier,
    required String assetKey,
    required bool isPro,
    required DateTime now,
  }) async {
    final decision = accessPolicy.authorize(
      assetTier: assetTier,
      assetKey: assetKey,
      isPro: isPro,
      now: now,
    );
    switch (decision) {
      case MediaAccessDeny(:final reason):
        return MediaUrlDenied(reason);
      case MediaAccessGrant(:final scopePath, :final ttl, :final expiresAt):
        final request = urlPolicy.buildRequest(objectKey: scopePath, ttl: ttl);
        final url = await signer.sign(request);
        return MediaUrlIssued(url: url, request: request, expiresAt: expiresAt);
    }
  }
}
