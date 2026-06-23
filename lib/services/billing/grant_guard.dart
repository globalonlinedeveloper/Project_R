// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// M8 [TS-9 velocity · TS-7 audit] — anti-abuse gate that runs BEFORE the credit mint
// (schema/sql/0004 `post_credit_entry`, M4). Pure Dart, ZERO network. Decides whether a
// grant attempt may proceed to mint, based on per-account / per-device velocity, self-
// referral detection, and (for farmable sources) device attestation + a Turnstile human
// check. Fails closed everywhere: unknown counts or an unavailable verifier ⇒ deny.
//
// Seams (faked locally, real at go-live): [AttestationVerifier] (Play Integrity / App
// Attest), [TurnstileVerifier] (Cloudflare Turnstile), [GrantAuditSink] (TS-7 durable
// store). `recentGrants` counts come from the credit ledger (M4). Only [GrantDecision.allow]
// reaches the injected `mint` callback; every denial is recorded to the audit sink and
// never touches the ledger.
//
// GO-LIVE STOP: real Play Integrity / App Attest + Turnstile accounts/keys, a durable
// audit store, and the Deno grant Edge function chaining GrantGuard → post_credit_entry.

/// Verifier outcome. `unavailable` (verifier down/timeout/unconfigured) is treated as a
/// DENY for any source that requires verification — fail-closed, never fail-open.
enum VerifierVerdict { pass, fail, unavailable }

/// What triggered a credit grant. Mirrors the ledger `grant_source` enum (schema/0001)
/// plus a guard-only [referral] trigger for the abuse model; a referral grant maps to a
/// concrete ledger `grant_source` at mint time. [adReward], [promo] and [referral] are
/// "farmable" — they require device attestation AND a Turnstile check.
enum GrantSource {
  dailyFree,
  reviewFree,
  adReward,
  purchase,
  subscription,
  promo,
  refundReversal,
  referral,
}

/// Outcome of the anti-abuse gate. Only [allow] proceeds to the ledger mint.
enum GrantDecision {
  allow,
  denySelfReferral,
  denyVelocity,
  denyAttestation,
  denyTurnstile,
}

/// Per-window grant caps. A grant attempt is denied once the account or device has already
/// reached its cap in the window (the count is sourced from the ledger, M4).
class VelocityCaps {
  final int maxPerAccount;
  final int maxPerDevice;
  const VelocityCaps({this.maxPerAccount = 5, this.maxPerDevice = 5});
}

/// Durable audit seam (TS-7). The local default is a no-op; go-live writes to an append-
/// only store. Every DENY is recorded so abuse patterns are observable.
abstract interface class GrantAuditSink {
  void record(
    GrantDecision decision, {
    required String userId,
    required String deviceId,
    required GrantSource source,
  });
}

class _NoopGrantAuditSink implements GrantAuditSink {
  const _NoopGrantAuditSink();
  @override
  void record(
    GrantDecision decision, {
    required String userId,
    required String deviceId,
    required GrantSource source,
  }) {}
}

/// Device-integrity seam — Play Integrity (Android) / App Attest (iOS) at go-live.
abstract interface class AttestationVerifier {
  Future<VerifierVerdict> verify(String deviceId);
}

/// Human-challenge seam — Cloudflare Turnstile at go-live.
abstract interface class TurnstileVerifier {
  Future<VerifierVerdict> verify(String deviceId);
}

/// Anti-abuse gate. [check] is the pure decision; [authorizeAndMint] resolves the verifier
/// seams (fail-closed), applies [check], and mints only on [GrantDecision.allow].
class GrantGuard {
  final VelocityCaps caps;
  final GrantAuditSink audit;
  final AttestationVerifier? attestationVerifier;
  final TurnstileVerifier? turnstileVerifier;

  const GrantGuard({
    this.caps = const VelocityCaps(),
    this.audit = const _NoopGrantAuditSink(),
    this.attestationVerifier,
    this.turnstileVerifier,
  });

  /// Farmable sources require attestation + Turnstile.
  static bool requiresVerification(GrantSource source) =>
      source == GrantSource.adReward ||
      source == GrantSource.promo ||
      source == GrantSource.referral;

  /// Pure decision. Fail-closed: negative/unknown counts ⇒ [GrantDecision.denyVelocity];
  /// an unavailable/failed verifier on a farmable source ⇒ deny. A referral whose referrer
  /// shares the referee's account or device ⇒ [GrantDecision.denySelfReferral].
  GrantDecision check({
    required GrantSource source,
    required String userId,
    required String deviceId,
    required int recentAccountGrants,
    required int recentDeviceGrants,
    required VerifierVerdict attestation,
    required VerifierVerdict turnstile,
    String? referrerUserId,
    String? referrerDeviceId,
  }) {
    // Fail-closed on unknown/negative counts (the ledger lookup failed).
    if (recentAccountGrants < 0 || recentDeviceGrants < 0) {
      return GrantDecision.denyVelocity;
    }
    // Self-referral: a referral that points back to the same account or device.
    final isReferral =
        source == GrantSource.referral || referrerUserId != null || referrerDeviceId != null;
    if (isReferral &&
        ((referrerUserId != null && referrerUserId == userId) ||
            (referrerDeviceId != null && referrerDeviceId == deviceId))) {
      return GrantDecision.denySelfReferral;
    }
    // Velocity caps (at or over the cap denies the new attempt).
    if (recentAccountGrants >= caps.maxPerAccount ||
        recentDeviceGrants >= caps.maxPerDevice) {
      return GrantDecision.denyVelocity;
    }
    // Farmable sources must pass attestation AND Turnstile (unavailable ⇒ deny).
    if (requiresVerification(source) || isReferral) {
      if (attestation != VerifierVerdict.pass) return GrantDecision.denyAttestation;
      if (turnstile != VerifierVerdict.pass) return GrantDecision.denyTurnstile;
    }
    return GrantDecision.allow;
  }

  /// Resolve the verifier seams (fail-closed on null/throw), apply [check], and invoke
  /// [mint] ONLY on [GrantDecision.allow]. Every denial is recorded to the audit sink and
  /// never reaches [mint]. Returns the decision.
  Future<GrantDecision> authorizeAndMint({
    required GrantSource source,
    required String userId,
    required String deviceId,
    required int recentAccountGrants,
    required int recentDeviceGrants,
    required Future<void> Function() mint,
    String? referrerUserId,
    String? referrerDeviceId,
  }) async {
    final attestation = await _resolve(attestationVerifier, deviceId);
    final turnstile = await _resolve(turnstileVerifier, deviceId);
    final decision = check(
      source: source,
      userId: userId,
      deviceId: deviceId,
      recentAccountGrants: recentAccountGrants,
      recentDeviceGrants: recentDeviceGrants,
      attestation: attestation,
      turnstile: turnstile,
      referrerUserId: referrerUserId,
      referrerDeviceId: referrerDeviceId,
    );
    if (decision == GrantDecision.allow) {
      await mint();
    } else {
      audit.record(decision, userId: userId, deviceId: deviceId, source: source);
    }
    return decision;
  }

  /// A null verifier or any thrown error resolves to [VerifierVerdict.unavailable]
  /// (fail-closed).
  Future<VerifierVerdict> _resolve(Object? verifier, String deviceId) async {
    try {
      if (verifier is AttestationVerifier) return await verifier.verify(deviceId);
      if (verifier is TurnstileVerifier) return await verifier.verify(deviceId);
      return VerifierVerdict.unavailable;
    } on Object {
      return VerifierVerdict.unavailable;
    }
  }
}
