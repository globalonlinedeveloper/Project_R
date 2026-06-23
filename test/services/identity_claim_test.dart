import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

void main() {
  group('AnonymousClaimToken (TS-11 — anon->auth claim needs a SERVER token)',
      () {
    test('mints from a server-issued opaque token', () {
      final t = AnonymousClaimToken.fromServer('srv_9f8c7b6a5d4e');
      expect(t.value, 'srv_9f8c7b6a5d4e');
    });

    test('rejects a bare UUID — the client anon id / auth.uid() shape', () {
      expect(
        () => AnonymousClaimToken.fromServer(
            '11111111-2222-3333-4444-555555555555'),
        throwsArgumentError,
      );
    });

    test('rejects a token without the server scheme (a raw client id)', () {
      expect(() => AnonymousClaimToken.fromServer('device-anon-42'),
          throwsArgumentError);
    });

    test('rejects empty / blank tokens', () {
      expect(() => AnonymousClaimToken.fromServer(''), throwsArgumentError);
      expect(() => AnonymousClaimToken.fromServer('   '), throwsArgumentError);
    });

    test('trims surrounding whitespace on a valid server token', () {
      expect(AnonymousClaimToken.fromServer('  srv_abc  ').value, 'srv_abc');
    });

    test('toString does not leak the token value', () {
      final t = AnonymousClaimToken.fromServer('srv_secret123');
      expect(t.toString().contains('secret123'), isFalse);
    });

    test('value equality', () {
      expect(AnonymousClaimToken.fromServer('srv_a'),
          AnonymousClaimToken.fromServer('srv_a'));
    });
  });

  group('Identity.claimAnonymousState (TS-11 guard)', () {
    test('local guest fails closed even with a well-formed server token', () {
      // The signature accepts only AnonymousClaimToken (no public ctor from a
      // raw client id), so passing a client anon id does not compile. The local
      // default additionally fails closed because there is no Stage-1/2 backend.
      final token = AnonymousClaimToken.fromServer('srv_ok');
      expect(() => const AnonymousIdentity().claimAnonymousState(token),
          throwsUnsupportedError);
    });

    test('guest identity stays anonymous (no client-side claim path)', () {
      const id = AnonymousIdentity();
      expect(id.uid, isNull);
      expect(id.isAuthenticated, isFalse);
    });
  });
}
