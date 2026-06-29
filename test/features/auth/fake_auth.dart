import 'package:ratel/services/auth/auth.dart';

/// Shared in-memory [AuthService] for the auth-screen tests — exercises the
/// screens with no live client (mirrors the SupabaseIdentity unit-test seam).
class FakeAuth implements AuthService {
  FakeAuth({
    this.outcome = AuthOutcome.session,
    this.error,
    this.available = true,
  });

  /// Outcome returned by sign-up / sign-in (magic link + reset have fixed results).
  final AuthOutcome outcome;

  /// When set, every account action throws this instead of returning.
  final Object? error;

  /// Backs [isAvailable] — set false to exercise the honest unavailable state.
  final bool available;

  int signUpCalls = 0;
  int signInCalls = 0;
  int magicCalls = 0;
  int resetCalls = 0;
  int signOutCalls = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  bool get isAvailable => available;

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
