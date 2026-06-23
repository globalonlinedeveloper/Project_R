import 'package:flutter/foundation.dart' show immutable;

/// TS-11 (Stage-4 threat model): the anonymous→authenticated migration. When a
/// guest signs in, their on-device anonymous learner-state is merged into the
/// real `auth.uid()` account (door #17 — `auth.uid()` is the only user PK). The
/// merge MUST be authorized by a token the SERVER minted for THIS sign-in —
/// never by a client-chosen anonymous id, or a malicious client could claim
/// another user's anonymous state.
///
/// This wrapper is the ONLY argument [Identity.claimAnonymousState] accepts, and
/// it can be built only via [AnonymousClaimToken.fromServer]; there is
/// deliberately NO constructor that takes a raw client id / uuid, so the unsafe
/// call is unrepresentable at the type level and rejected fail-closed at runtime.
@immutable
class AnonymousClaimToken {
  const AnonymousClaimToken._(this.value);

  /// The opaque server-issued claim token (handed to the Stage-3 relay call).
  final String value;

  /// The scheme every server-minted claim token carries. A client cannot forge a
  /// claim by passing its own anon id: anything without this prefix — or anything
  /// shaped like a bare UUID / `auth.uid()` — is rejected.
  static const String serverPrefix = 'srv_';

  /// Mint from a SERVER-issued token. Fail-closed guard (TS-11):
  ///  - rejects empty / blank tokens;
  ///  - rejects a bare UUID — the canonical client anon id / `auth.uid()` shape,
  ///    which must NEVER authorize a claim;
  ///  - requires the [serverPrefix] opaque-token scheme.
  factory AnonymousClaimToken.fromServer(String serverToken) {
    final token = serverToken.trim();
    if (token.isEmpty) {
      throw ArgumentError.value(serverToken, 'serverToken', 'empty claim token');
    }
    if (_uuidShape.hasMatch(token)) {
      throw ArgumentError.value(
        serverToken,
        'serverToken',
        'looks like a client-supplied id/uuid — claimAnonymousState requires a '
            'SERVER-issued token, never a client anon id (TS-11)',
      );
    }
    if (!token.startsWith(serverPrefix)) {
      throw ArgumentError.value(
        serverToken,
        'serverToken',
        'not a server-issued token (missing "$serverPrefix" scheme) (TS-11)',
      );
    }
    return AnonymousClaimToken._(token);
  }

  static final RegExp _uuidShape = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// Does not leak the token value (it is a capability that may reach logs).
  @override
  String toString() => 'AnonymousClaimToken(server-issued)';

  @override
  bool operator ==(Object other) =>
      other is AnonymousClaimToken && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
