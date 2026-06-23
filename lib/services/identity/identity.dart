import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Portability seam (R-K6): identity. `auth.uid()` is the ONLY user primary key —
/// no parallel user identifier is ever introduced. Stage 3 supplies a
/// Supabase-auth-backed implementation behind this interface.
abstract interface class Identity {
  /// The current user's stable id (`auth.uid()`), or null when guest/anonymous.
  String? get uid;
  bool get isAuthenticated;
}

/// Default (local / Stage 1–2): no account yet — guest.
class AnonymousIdentity implements Identity {
  const AnonymousIdentity();
  @override
  String? get uid => null;
  @override
  bool get isAuthenticated => false;
}

/// Inject the identity seam. Stage 3 overrides this with a real auth-backed impl.
final identityProvider = Provider<Identity>((ref) => const AnonymousIdentity());
