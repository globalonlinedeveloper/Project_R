import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/identity/supabase_identity.dart';

void main() {
  test('guest when there is no session (uid null, not authenticated)', () {
    final Identity id = SupabaseIdentity(currentUserId: () => null);
    expect(id.uid, isNull);
    expect(id.isAuthenticated, isFalse);
  });

  test('authenticated when a uid is present', () {
    final Identity id = SupabaseIdentity(currentUserId: () => 'uid-123');
    expect(id.uid, 'uid-123');
    expect(id.isAuthenticated, isTrue);
  });

  test('claimAnonymousState fails closed until the relay is wired', () async {
    final id = SupabaseIdentity(currentUserId: () => 'uid-123');
    final token = AnonymousClaimToken.fromServer('srv_test_token');
    await expectLater(
      id.claimAnonymousState(token),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('claimAnonymousState delegates to the wired relay', () async {
    AnonymousClaimToken? seen;
    final id = SupabaseIdentity(
      currentUserId: () => 'uid-123',
      onClaim: (t) async => seen = t,
    );
    final token = AnonymousClaimToken.fromServer('srv_abc123');
    await id.claimAnonymousState(token);
    expect(seen, isNotNull);
  });

  test('mintClaimToken returns null when no mint relay is wired', () async {
    final id = SupabaseIdentity(currentUserId: () => null);
    expect(await id.mintClaimToken(), isNull);
  });

  test('mintClaimToken wraps the relay token as a server claim token', () async {
    final id = SupabaseIdentity(
      currentUserId: () => null,
      onMint: () async => 'srv_minted_abc',
    );
    final token = await id.mintClaimToken();
    expect(token, isNotNull);
    expect(token!.value, 'srv_minted_abc');
  });

  test('mintClaimToken returns null when the relay yields null or empty',
      () async {
    final idNull =
        SupabaseIdentity(currentUserId: () => null, onMint: () async => null);
    expect(await idNull.mintClaimToken(), isNull);
    final idEmpty =
        SupabaseIdentity(currentUserId: () => null, onMint: () async => '');
    expect(await idEmpty.mintClaimToken(), isNull);
  });

  test('mintClaimToken is best-effort: a throwing relay yields null', () async {
    final id = SupabaseIdentity(
      currentUserId: () => null,
      onMint: () async => throw StateError('mint network error'),
    );
    expect(await id.mintClaimToken(), isNull);
  });
}
