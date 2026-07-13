import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Outcome of an account-entry attempt, surfaced to the UI WITHOUT leaking any
/// GoTrue / Supabase types into the widget layer (portability seam, R-K6).
enum AuthOutcome {
  /// A session is live immediately (e.g. password sign-in/up with a confirmed
  /// account).
  session,

  /// No session yet — an email was dispatched (a confirmation link, a magic
  /// link, or a password-reset link). The UI shows a "check your inbox" state.
  emailSent,
}

/// Stable, backend-agnostic code for the hard-coded unconfigured-build auth
/// failure (i18n I4); null for dynamic backend (GoTrue) messages.
enum AuthFailureCode { accountsUnavailable }

/// A user-presentable auth error. The Supabase impl translates GoTrue's
/// `AuthException` into this so screens never import backend types (R-K6).
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code});
  final String message;

  /// Non-null for the hard-coded unconfigured-build failure (mapped to a
  /// localized ARB string at the render site); null for backend messages.
  final AuthFailureCode? code;
  @override
  String toString() => 'AuthFailure: $message';
}

/// Account entry/exit seam (R-L1). Stage-3 supplies a Supabase-backed impl
/// ([SupabaseAuthService]); screens depend only on this interface and tests
/// inject a fake. [isAvailable] lets a screen show an honest "accounts are not
/// available in this build" state instead of a form that silently fails — the
/// same fail-closed honesty the AI relay uses (`UnconfiguredAiRelay`).
abstract interface class AuthService {
  /// False when no real auth backend is wired (the default local build): the
  /// screens render but every action fail-closes — nothing is ever faked.
  bool get isAvailable;

  /// Create an account with email + password. Resolves to [AuthOutcome.session]
  /// when a session is established, or [AuthOutcome.emailSent] when a
  /// confirmation email was dispatched. Throws [AuthFailure] when rejected.
  Future<AuthOutcome> signUpWithPassword({
    required String email,
    required String password,
  });

  /// Sign in with email + password. Resolves to [AuthOutcome.session] on
  /// success; throws [AuthFailure] on bad credentials / unconfirmed account.
  Future<AuthOutcome> signInWithPassword({
    required String email,
    required String password,
  });

  /// Email a passwordless magic link (creates the account if absent). Resolves
  /// to [AuthOutcome.emailSent] on success; throws [AuthFailure] otherwise.
  Future<AuthOutcome> sendMagicLink({required String email});

  /// Email a password-reset link. Resolves once the request is accepted; throws
  /// [AuthFailure] otherwise.
  Future<void> sendPasswordReset({required String email});

  /// Sign out the current session (returns to guest). Throws [AuthFailure] if
  /// the sign-out call itself fails.
  Future<void> signOut();
}

/// Default (local / Stage 1–2): no auth backend configured — fails closed.
/// Mirrors [UnconfiguredAiRelay]: the screens stay reachable and render, but
/// every account action throws an honest [AuthFailure] (never a fake session),
/// so a guest is never misled into thinking they have an account.
class UnconfiguredAuthService implements AuthService {
  const UnconfiguredAuthService();

  static const String _msg =
      'Accounts are not available in this build yet — keep learning as a guest.';

  @override
  bool get isAvailable => false;

  @override
  Future<AuthOutcome> signUpWithPassword({
    required String email,
    required String password,
  }) async =>
      throw const AuthFailure(_msg, code: AuthFailureCode.accountsUnavailable);

  @override
  Future<AuthOutcome> signInWithPassword({
    required String email,
    required String password,
  }) async =>
      throw const AuthFailure(_msg, code: AuthFailureCode.accountsUnavailable);

  @override
  Future<AuthOutcome> sendMagicLink({required String email}) async =>
      throw const AuthFailure(_msg, code: AuthFailureCode.accountsUnavailable);

  @override
  Future<void> sendPasswordReset({required String email}) async =>
      throw const AuthFailure(_msg, code: AuthFailureCode.accountsUnavailable);

  @override
  Future<void> signOut() async {
    // No session to end in the unconfigured build — a no-op (never throws), so
    // a "sign out" gesture from a guest is harmless.
  }
}

/// Injection point for the [AuthService]. Defaults to the honest fail-closed
/// [UnconfiguredAuthService]; `backend_wiring` overrides it with a real
/// [SupabaseAuthService] when the build carries the Supabase config, and tests
/// inject a fake.
final authServiceProvider = Provider<AuthService>(
  (ref) => const UnconfiguredAuthService(),
);
