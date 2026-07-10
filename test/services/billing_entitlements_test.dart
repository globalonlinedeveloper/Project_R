import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/backend_wiring.dart';
import 'package:ratel/services/billing/billing.dart';

/// L-5b (S114): PRO entitlements follow `profiles.is_pro` through the
/// reactive [proStatusProvider]. Defaults stay free-tier byte-identical.
void main() {
  test('default entitlements stay free tier (keyless guard)', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(entitlementsProvider).isPro, isFalse);
    expect(container.read(isProProvider), isFalse);
    expect(container.read(proStatusProvider), isFalse);
  });

  test('StaticEntitlements carries the given flag', () {
    expect(const StaticEntitlements(isPro: true).isPro, isTrue);
    expect(const StaticEntitlements(isPro: false).isPro, isFalse);
  });

  test('wired override: isPro follows the reactive proStatusProvider', () {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        entitlementsProvider.overrideWith(
            (ref) => StaticEntitlements(isPro: ref.watch(proStatusProvider))),
      ],
    );
    addTearDown(container.dispose);
    expect(container.read(isProProvider), isFalse,
        reason: 'seed default false => free');
    container.read(proStatusProvider.notifier).state = true;
    expect(container.read(isProProvider), isTrue,
        reason: 'pro flag flips the UI gate without a reboot');
    container.read(proStatusProvider.notifier).state = false;
    expect(container.read(isProProvider), isFalse,
        reason: 'revocation drops PRO immediately');
  });

  test('default refresher is an inert no-op', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(proStatusRefresherProvider)();
    expect(container.read(proStatusProvider), isFalse);
  });

  test('fetchIsPro: signed-out client => false, no network needed', () async {
    final SupabaseClient client =
        SupabaseClient('http://127.0.0.1:9', 'test-key');
    expect(await fetchIsPro(client), isFalse);
  });
}
