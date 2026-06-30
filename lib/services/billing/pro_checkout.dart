// R-J7 / R-J7a · Pro purchase launcher — portability seam.
//
// Pure seam. The v1 default ([UnavailableProCheckout]) REFUSES honestly — no store /
// web-checkout is wired, so the paywall (R-J6) shows real prices but cannot charge and
// the client never flips the free entitlement. Go-live injects the real StoreKit 2 /
// Play Billing / web-checkout (Stripe / MoR) adapter behind this same interface.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pricing.dart';

/// Outcome of attempting to start checkout.
enum CheckoutStatus {
  /// No billing is wired yet (v1 default) — nothing was charged.
  unavailable,

  /// A real store / web checkout flow was launched (go-live only).
  started,
}

/// Result of [ProCheckout.start] — a status plus an honest user-facing message.
class CheckoutResult {
  const CheckoutResult(this.status, this.message);

  final CheckoutStatus status;
  final String message;

  /// Whether a real checkout flow actually started.
  bool get isAvailable => status != CheckoutStatus.unavailable;
}

/// Portability seam (R-J7 / R-J7a): the Pro purchase launcher. One interface over
/// StoreKit 2 (iOS), Play Billing (Android) and the web checkout (Stripe / MoR) — the
/// vendor is swappable without touching feature code; the server writes `pro_until`.
abstract interface class ProCheckout {
  Future<CheckoutResult> start({required ProPlan plan, required ProBand band});
}

/// Default (local / Stage 1-2): checkout is not live. Returns
/// [CheckoutStatus.unavailable] with an honest message and charges nothing — Pro stays
/// whatever the server-side entitlement says (free by default).
class UnavailableProCheckout implements ProCheckout {
  const UnavailableProCheckout();

  @override
  Future<CheckoutResult> start({
    required ProPlan plan,
    required ProBand band,
  }) async =>
      const CheckoutResult(
        CheckoutStatus.unavailable,
        "Checkout opens at launch — store billing isn't live in this build yet.",
      );
}

/// The active checkout launcher. The local default refuses honestly; go-live overrides
/// this provider with the real adapter.
final proCheckoutProvider =
    Provider<ProCheckout>((ref) => const UnavailableProCheckout());
