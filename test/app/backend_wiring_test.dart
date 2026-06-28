import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/backend_wiring.dart';

void main() {
  group('supabaseConfigured gate (R-M3 / R-K6 seam wiring)', () {
    test('requires BOTH the url and the publishable key', () {
      expect(supabaseConfigured(url: '', publishableKey: ''), isFalse);
      expect(
          supabaseConfigured(url: 'https://x.supabase.co', publishableKey: ''),
          isFalse);
      expect(supabaseConfigured(url: '', publishableKey: 'pk'), isFalse);
      expect(
          supabaseConfigured(
              url: 'https://x.supabase.co', publishableKey: 'pk'),
          isTrue);
    });

    test('an un-configured build (no --dart-define) stays LOCAL', () {
      // The test runner passes no dart-define ⇒ both compile-time consts are
      // empty ⇒ the Supabase seams are NEVER selected ⇒ local defaults hold.
      expect(supabaseConfigured(), isFalse);
    });
  });
}
