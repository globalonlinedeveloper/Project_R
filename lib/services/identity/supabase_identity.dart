import 'package:supabase_flutter/supabase_flutter.dart';

import 'identity.dart';

/// Stage-3 [Identity] backed by Supabase auth — `auth.uid()` is the only user
/// primary key (R-G1 / R-K6). The current uid is read through an injected
/// source so the core is unit-testable without a live client;
/// [SupabaseIdentity.fromClient] wires the real GoTrue session.
class SupabaseIdentity implements Identity {
  SupabaseIdentity({
    required this.currentUserId,
    this.onClaim,
  });

  /// Wire to a live Supabase client: the uid is the GoTrue session user id.
  factory SupabaseIdentity.fromClient(
    SupabaseClient client, {
    Future<void> Function(AnonymousClaimToken token)? onClaim,
  }) {
    return SupabaseIdentity(
      currentUserId: () => client.auth.currentUser?.id,
      onClaim: onClaim,
    );
  }

  /// Source of the current `auth.uid()` (null when guest / anonymous).
  final String? Function() currentUserId;

  /// Stage-3 relay performing the server-authorised anonymous-state claim.
  final Future<void> Function(AnonymousClaimToken token)? onClaim;

  @override
  String? get uid => currentUserId();

  @override
  bool get isAuthenticated => uid != null;

  @override
  Future<void> claimAnonymousState(AnonymousClaimToken token) async {
    final claim = onClaim;
    if (claim == null) {
      // Fail-closed until the Stage-3 relay claim is wired (auth increment 1b/1c).
      throw UnsupportedError(
        'claimAnonymousState relay is not wired yet (auth increment 1b).',
      );
    }
    await claim(token);
  }
}
