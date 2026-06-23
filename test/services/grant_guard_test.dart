// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// M8 [TS-9 · TS-7] tests (flutter-gate) for the anti-abuse grant gate. Pure: no network,
// fake verifiers + spy mint + recording audit. Proves: only Allow mints; self-referral,
// velocity, failed/unavailable attestation & Turnstile all deny (fail-closed); denials are
// audited and never reach the ledger; a burst never over-grants past the cap.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

class _Verifier implements AttestationVerifier, TurnstileVerifier {
  final VerifierVerdict verdict;
  int calls = 0;
  _Verifier(this.verdict);
  @override
  Future<VerifierVerdict> verify(String deviceId) async {
    calls++;
    return verdict;
  }
}

class _ThrowingVerifier implements AttestationVerifier, TurnstileVerifier {
  @override
  Future<VerifierVerdict> verify(String deviceId) async =>
      throw StateError('verifier down');
}

class _RecordingAudit implements GrantAuditSink {
  final List<GrantDecision> records = <GrantDecision>[];
  @override
  void record(GrantDecision decision,
          {required String userId,
          required String deviceId,
          required GrantSource source}) =>
      records.add(decision);
}

void main() {
  const guard = GrantGuard();
  const ok = VerifierVerdict.pass;

  group('GrantGuard.check (pure)', () {
    test('under caps + passing verifiers -> Allow', () {
      expect(
        guard.check(
          source: GrantSource.adReward,
          userId: 'u1',
          deviceId: 'd1',
          recentAccountGrants: 0,
          recentDeviceGrants: 0,
          attestation: ok,
          turnstile: ok,
        ),
        GrantDecision.allow,
      );
    });

    test('non-farmable source (purchase) needs no attestation -> Allow even if unavailable',
        () {
      expect(
        guard.check(
          source: GrantSource.purchase,
          userId: 'u1',
          deviceId: 'd1',
          recentAccountGrants: 0,
          recentDeviceGrants: 0,
          attestation: VerifierVerdict.unavailable,
          turnstile: VerifierVerdict.unavailable,
        ),
        GrantDecision.allow,
      );
    });

    test('self-referral by shared device -> DenySelfReferral', () {
      expect(
        guard.check(
          source: GrantSource.referral,
          userId: 'u1',
          deviceId: 'd1',
          referrerUserId: 'u2',
          referrerDeviceId: 'd1',
          recentAccountGrants: 0,
          recentDeviceGrants: 0,
          attestation: ok,
          turnstile: ok,
        ),
        GrantDecision.denySelfReferral,
      );
    });

    test('self-referral by shared account -> DenySelfReferral', () {
      expect(
        guard.check(
          source: GrantSource.referral,
          userId: 'u1',
          deviceId: 'd1',
          referrerUserId: 'u1',
          referrerDeviceId: 'd9',
          recentAccountGrants: 0,
          recentDeviceGrants: 0,
          attestation: ok,
          turnstile: ok,
        ),
        GrantDecision.denySelfReferral,
      );
    });

    test('over per-account velocity -> DenyVelocity', () {
      expect(
        guard.check(
          source: GrantSource.adReward,
          userId: 'u1',
          deviceId: 'd1',
          recentAccountGrants: 5,
          recentDeviceGrants: 0,
          attestation: ok,
          turnstile: ok,
        ),
        GrantDecision.denyVelocity,
      );
    });

    test('over per-device velocity -> DenyVelocity', () {
      expect(
        guard.check(
          source: GrantSource.adReward,
          userId: 'u1',
          deviceId: 'd1',
          recentAccountGrants: 0,
          recentDeviceGrants: 5,
          attestation: ok,
          turnstile: ok,
        ),
        GrantDecision.denyVelocity,
      );
    });

    test('negative/unknown counts -> DenyVelocity (fail-closed)', () {
      expect(
        guard.check(
          source: GrantSource.purchase,
          userId: 'u1',
          deviceId: 'd1',
          recentAccountGrants: -1,
          recentDeviceGrants: 0,
          attestation: ok,
          turnstile: ok,
        ),
        GrantDecision.denyVelocity,
      );
    });

    test('farmable + failed attestation -> DenyAttestation', () {
      expect(
        guard.check(
          source: GrantSource.adReward,
          userId: 'u1',
          deviceId: 'd1',
          recentAccountGrants: 0,
          recentDeviceGrants: 0,
          attestation: VerifierVerdict.fail,
          turnstile: ok,
        ),
        GrantDecision.denyAttestation,
      );
    });

    test('farmable + unavailable attestation -> DenyAttestation (fail-closed)', () {
      expect(
        guard.check(
          source: GrantSource.promo,
          userId: 'u1',
          deviceId: 'd1',
          recentAccountGrants: 0,
          recentDeviceGrants: 0,
          attestation: VerifierVerdict.unavailable,
          turnstile: ok,
        ),
        GrantDecision.denyAttestation,
      );
    });

    test('farmable + passing attestation but failed Turnstile -> DenyTurnstile', () {
      expect(
        guard.check(
          source: GrantSource.adReward,
          userId: 'u1',
          deviceId: 'd1',
          recentAccountGrants: 0,
          recentDeviceGrants: 0,
          attestation: ok,
          turnstile: VerifierVerdict.fail,
        ),
        GrantDecision.denyTurnstile,
      );
    });

    test('farmable + unavailable Turnstile -> DenyTurnstile (fail-closed)', () {
      expect(
        guard.check(
          source: GrantSource.adReward,
          userId: 'u1',
          deviceId: 'd1',
          recentAccountGrants: 0,
          recentDeviceGrants: 0,
          attestation: ok,
          turnstile: VerifierVerdict.unavailable,
        ),
        GrantDecision.denyTurnstile,
      );
    });
  });

  group('GrantGuard.authorizeAndMint (orchestration)', () {
    test('Allow -> mint invoked exactly once', () async {
      final g = GrantGuard(
          attestationVerifier: _Verifier(ok), turnstileVerifier: _Verifier(ok));
      var minted = 0;
      final d = await g.authorizeAndMint(
        source: GrantSource.adReward,
        userId: 'u1',
        deviceId: 'd1',
        recentAccountGrants: 0,
        recentDeviceGrants: 0,
        mint: () async => minted++,
      );
      expect(d, GrantDecision.allow);
      expect(minted, 1);
    });

    test('Deny -> mint NEVER invoked, audit records the denial', () async {
      final audit = _RecordingAudit();
      final g = GrantGuard(
        audit: audit,
        attestationVerifier: _Verifier(VerifierVerdict.fail),
        turnstileVerifier: _Verifier(ok),
      );
      var minted = 0;
      final d = await g.authorizeAndMint(
        source: GrantSource.adReward,
        userId: 'u1',
        deviceId: 'd1',
        recentAccountGrants: 0,
        recentDeviceGrants: 0,
        mint: () async => minted++,
      );
      expect(d, GrantDecision.denyAttestation);
      expect(minted, 0);
      expect(audit.records, <GrantDecision>[GrantDecision.denyAttestation]);
    });

    test('farmable with NO verifier injected -> deny (fail-closed), no mint', () async {
      const g = GrantGuard(); // no verifiers
      var minted = 0;
      final d = await g.authorizeAndMint(
        source: GrantSource.adReward,
        userId: 'u1',
        deviceId: 'd1',
        recentAccountGrants: 0,
        recentDeviceGrants: 0,
        mint: () async => minted++,
      );
      expect(d, GrantDecision.denyAttestation);
      expect(minted, 0);
    });

    test('verifier that throws -> unavailable -> deny (fail-closed)', () async {
      final g = GrantGuard(
          attestationVerifier: _ThrowingVerifier(),
          turnstileVerifier: _Verifier(ok));
      var minted = 0;
      final d = await g.authorizeAndMint(
        source: GrantSource.referral,
        userId: 'u1',
        deviceId: 'd1',
        recentAccountGrants: 0,
        recentDeviceGrants: 0,
        mint: () async => minted++,
      );
      expect(d, GrantDecision.denyAttestation);
      expect(minted, 0);
    });

    test('replay burst is rate-limited by the cap — never over-grants', () async {
      final g = GrantGuard(
        caps: const VelocityCaps(maxPerAccount: 5, maxPerDevice: 100),
        attestationVerifier: _Verifier(ok),
        turnstileVerifier: _Verifier(ok),
      );
      var ledger = 0; // simulates the M4 ledger count growing on each successful mint
      var minted = 0;
      for (var i = 0; i < 10; i++) {
        await g.authorizeAndMint(
          source: GrantSource.adReward,
          userId: 'u1',
          deviceId: 'd1',
          recentAccountGrants: ledger,
          recentDeviceGrants: 0,
          mint: () async {
            minted++;
            ledger++;
          },
        );
      }
      expect(minted, 5); // exactly the cap; attempts 6..10 denied
    });
  });
}
