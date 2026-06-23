import 'package:flutter_riverpod/flutter_riverpod.dart';

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
