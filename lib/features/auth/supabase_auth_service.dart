import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';

/// Stage-3 [AuthService] backed by Supabase GoTrue. Thin by design: it adapts
/// `auth.signUp` / `auth.signInWithPassword` / `auth.signInWithOtp` /
/// `auth.resetPasswordForEmail` to [AuthOutcome] and converts GoTrue's
/// `AuthException` into our portable [AuthFailure], so the widget layer never
/// imports backend types (R-K6). Wired in `main` via [fromClient] once
/// `authEnabled` flips on (auth increment #5).
class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._auth, {this.emailRedirectTo});

  /// Build from a live Supabase client (the GoTrue session powers auth.uid()).
  factory SupabaseAuthService.fromClient(
    SupabaseClient client, {
    String? emailRedirectTo,
  }) =>
      SupabaseAuthService(client.auth, emailRedirectTo: emailRedirectTo);

  final GoTrueClient _auth;

  /// Deep link the confirmation / magic-link / reset email returns to (set when
  /// the live client is wired).
  final String? emailRedirectTo;

  @override
  Future<AuthOutcome> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: emailRedirectTo,
      );
      return res.session != null ? AuthOutcome.session : AuthOutcome.emailSent;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<AuthOutcome> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final res =
          await _auth.signInWithPassword(email: email, password: password);
      return res.session != null ? AuthOutcome.session : AuthOutcome.emailSent;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<AuthOutcome> sendMagicLink({required String email}) async {
    try {
      await _auth.signInWithOtp(email: email, emailRedirectTo: emailRedirectTo);
      return AuthOutcome.emailSent;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _auth.resetPasswordForEmail(email, redirectTo: emailRedirectTo);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }
}
