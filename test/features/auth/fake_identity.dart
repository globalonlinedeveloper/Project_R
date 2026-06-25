import 'package:ratel/services/identity/identity.dart';

/// In-memory [Identity] for the auth-screen tests: records the TS-11 mint/claim
/// calls so a test can assert the guest→account merge fired (or was skipped).
/// Mirrors the live SupabaseIdentity seam without a backend.
class FakeIdentity implements Identity {
  FakeIdentity({this.mintToken, this.claimThrows = false});

  /// Raw `srv_` token returned by [mintClaimToken]; null = nothing to claim.
  final String? mintToken;

  /// When true, [claimAnonymousState] throws (proves a failed merge is non-fatal).
  final bool claimThrows;

  int mintCalls = 0;
  AnonymousClaimToken? claimed;

  @override
  String? get uid => 'uid-test';

  @override
  bool get isAuthenticated => true;

  @override
  Future<AnonymousClaimToken?> mintClaimToken() async {
    mintCalls++;
    final token = mintToken;
    return token == null ? null : AnonymousClaimToken.fromServer(token);
  }

  @override
  Future<void> claimAnonymousState(AnonymousClaimToken token) async {
    if (claimThrows) throw StateError('merge failed');
    claimed = token;
  }
}
