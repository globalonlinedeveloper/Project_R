import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'anonymous_claim.dart';

export 'anonymous_claim.dart';
export 'service_role_contract.dart';

/// Portability seam (R-K6): identity. `auth.uid()` is the ONLY user primary key —
/// no parallel user identifier is ever introduced. Stage 3 supplies a
/// Supabase-auth-backed implementation behind this interface.
abstract interface class Identity {
  /// The current user's stable id (`auth.uid()`), or null when guest/anonymous.
  String? get uid;
  bool get isAuthenticated;

  /// TS-11: claim/merge on-device anonymous state into the now-authenticated
  /// account. Authorized ONLY by a SERVER-issued [AnonymousClaimToken] — never a
  /// client-chosen anon id (the token type makes the unsafe call unrepresentable).
  Future<void> claimAnonymousState(AnonymousClaimToken token);

  /// TS-11: mint a SERVER-issued [AnonymousClaimToken] capturing the CURRENT
  /// anonymous session, so its on-device learner-state can be claimed into the
  /// account after sign-in. Returns null when there is nothing to claim (a guest
  /// with no server session, or no relay wired) — the caller then skips the claim.
  Future<AnonymousClaimToken?> mintClaimToken();
}

/// Default (local / Stage 1–2): no account yet — guest.
class AnonymousIdentity implements Identity {
  const AnonymousIdentity();
  @override
  String? get uid => null;
  @override
  bool get isAuthenticated => false;

  /// Fails closed: there is no server to issue a claim token in Stage 1–2, so no
  /// anonymous-state claim can be authorized locally (Stage 3 supplies the
  /// auth-backed impl). The [AnonymousClaimToken] argument already guarantees a
  /// raw client id can never be passed here.
  @override
  Future<void> claimAnonymousState(AnonymousClaimToken token) async =>
      throw UnsupportedError(
          'claimAnonymousState requires a Stage-3 server-issued token; '
          'no backend in Stage 1–2.');

  /// No backend in Stage 1–2: a local guest has no server session to mint a
  /// claim token from, so there is nothing to claim (returns null, never throws).
  @override
  Future<AnonymousClaimToken?> mintClaimToken() async => null;
}

/// Inject the identity seam. Stage 3 overrides this with a real auth-backed impl.
final identityProvider = Provider<Identity>((ref) => const AnonymousIdentity());
