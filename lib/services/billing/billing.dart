import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'payments_verify.dart';
export 'media_authz.dart';
export 'grant_guard.dart';
export 'play_receipt_verify.dart';
export 'pricing.dart';
export 'pro_checkout.dart';
export 'manage_subscription.dart';

/// Portability seam (R-J7a): payments / entitlement. IAP + web checkout sit behind
/// one adapter; entitlement is computed server-side at Stage 3, never
/// client-asserted. This local default is read-only and always free tier.
abstract interface class Entitlements {
  /// Whether the user currently has Pro. Default tier is free.
  bool get isPro;
}

/// Default (local / Stage 1–2): everyone is free tier.
class FreeTierEntitlements implements Entitlements {
  const FreeTierEntitlements();
  @override
  bool get isPro => false;
}

final entitlementsProvider =
    Provider<Entitlements>((ref) => const FreeTierEntitlements());

/// L-5b (S114): a fixed entitlements snapshot. The wired override in
/// `backend_wiring.dart` rebuilds one from the reactive [proStatusProvider]
/// (seeded at boot from the own `profiles.is_pro` row, refreshed on session
/// entry). Real spend stays fail-closed SERVER-side at the `live-token` mint.
class StaticEntitlements implements Entitlements {
  const StaticEntitlements({required this.isPro});
  @override
  final bool isPro;
}

/// Reactive pro flag behind the wired [entitlementsProvider]. Default false =>
/// free tier; keyless/guest builds never touch it (byte-identical defaults).
final proStatusProvider = StateProvider<bool>((_) => false);

/// Re-reads the pro flag from the backend — fired on session entry (login /
/// signup) so PRO unlocks without a reboot. No-op by default.
final proStatusRefresherProvider =
    Provider<Future<void> Function()>((_) => () async {});
