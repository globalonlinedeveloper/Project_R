import 'package:ratel/features/auth/auth_service.dart';

/// Shared in-memory [AuthService] for the auth screen tests — exercises the
/// screens with no live client (mirrors the SupabaseIdentity unit-test seam).
/// One fake keeps in lockstep with the interface as it grows across increments.
class FakeAuth implements AuthService {
  FakeAuth({this.outcome = AuthOutcome.emailSent, this.error});

  /// Outcome returned by sign-up / sign-in (magic link + reset have fixed results).
  final AuthOutcome outcome;

  /// When set, every call throws this instead of returning.
  final Object? error;

  int signUpCalls = 0;
  int signInCalls = 0;
  int magicCalls = 0;
  int resetCalls = 0;
  int signOutCalls = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<AuthOutcome> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    signUpCalls++;
    lastEmail = email;
    lastPassword = password;
    if (error != null) throw error!;
    return outcome;
  }

  @override
  Future<AuthOutcome> signInWithPassword({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    lastEmail = email;
    lastPassword = password;
    if (error != null) throw error!;
    return outcome;
  }

  @override
  Future<AuthOutcome> sendMagicLink({required String email}) async {
    magicCalls++;
    lastEmail = email;
    if (error != null) throw error!;
    return AuthOutcome.emailSent;
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    resetCalls++;
    lastEmail = email;
    if (error != null) throw error!;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (error != null) throw error!;
  }
}
