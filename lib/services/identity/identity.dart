import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'anonymous_claim.dart';

export 'anonymous_claim.dart';

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
}

/// Inject the identity seam. Stage 3 overrides this with a real auth-backed impl.
final identityProvider = Provider<Identity>((ref) => const AnonymousIdentity());
