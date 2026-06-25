import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Outcome of an account-entry attempt, surfaced to the UI WITHOUT leaking any
/// GoTrue / Supabase types into the widget layer (portability seam, R-K6).
enum AuthOutcome {
  /// A session is live immediately (e.g. password sign-up when email
  /// confirmation is off, or a confirmed returning user).
  session,

  /// No session yet — an email was dispatched (a confirmation link for a
  /// password sign-up, or a magic link). The UI shows a "check your inbox" state.
  emailSent,
}

/// A user-presentable auth error. The Supabase impl translates GoTrue's
/// `AuthException` into this so screens never import backend types (R-K6).
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
  @override
  String toString() => 'AuthFailure: $message';
}

/// Account entry/exit seam (R-L1). Stage-3 supplies a Supabase-backed impl
/// ([SupabaseAuthService]); screens depend only on this interface and tests
/// inject a fake. Grows across the auth increments: sign-up + magic link (#3),
/// then sign-in + password reset (#4), then sign-out (#5).
abstract interface class AuthService {
  /// Create an account with email + password. Resolves to [AuthOutcome.session]
  /// when a session is established, or [AuthOutcome.emailSent] when a
  /// confirmation email was dispatched. Throws [AuthFailure] when rejected.
  Future<AuthOutcome> signUpWithPassword({
    required String email,
    required String password,
  });

  /// Email a passwordless magic link (creates the account if absent). Resolves
  /// to [AuthOutcome.emailSent] on success; throws [AuthFailure] otherwise.
  Future<AuthOutcome> sendMagicLink({required String email});
}

/// Injection point for the [AuthService]. Deliberately unimplemented by default:
/// `main()` overrides it with a [SupabaseAuthService] once `authEnabled` is on,
/// and tests override it with a fake. Reading it without an override is a wiring
/// bug (the auth screens are unreachable while the flag is off), so it fails
/// loudly rather than silently no-opping.
final authServiceProvider = Provider<AuthService>((ref) {
  throw StateError(
    'authServiceProvider must be overridden (main wires SupabaseAuthService '
    'behind authEnabled; tests inject a fake).',
  );
});
