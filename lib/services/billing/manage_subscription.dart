// R-J6 · Manage / cancel-subscription launcher — portability seam (two-tap OS cancel).
//
// Pure seam, mirroring [ProCheckout]. The v1 default ([UnavailableManageSubscription])
// REFUSES honestly — no `url_launcher` / StoreKit 2 `showManageSubscriptions` / Play
// subscriptions deep-link is wired, so "Manage subscription" tells the user where to
// cancel instead of pretending to deep-link. Go-live injects the real adapter behind
// this same interface, so the R-J6 "two-tap OS cancel" path is RESERVED, not forgotten.
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Outcome of attempting to open the OS-level manage-subscription surface.
enum ManageStatus {
  /// No deep-link is wired yet (v1 default) — nothing was opened.
  unavailable,

  /// The OS / store manage-subscription surface was opened (go-live only).
  opened,
}

/// Result of [ManageSubscription.open] — a status plus an honest user-facing message.
class ManageResult {
  const ManageResult(this.status, this.message);

  final ManageStatus status;
  final String message;

  /// Whether a real manage/cancel surface actually opened.
  bool get isAvailable => status != ManageStatus.unavailable;
}

/// Portability seam (R-J6): the manage / cancel-subscription launcher. One interface
/// over StoreKit 2 `showManageSubscriptions` (iOS), the Play subscriptions deep-link
/// (Android) and the web billing portal — swappable without touching feature code.
abstract interface class ManageSubscription {
  Future<ManageResult> open();
}

/// Default (local / Stage 1–2): the deep-link is not wired. Returns
/// [ManageStatus.unavailable] with an honest message and opens nothing.
class UnavailableManageSubscription implements ManageSubscription {
  const UnavailableManageSubscription();

  @override
  Future<ManageResult> open() async => const ManageResult(
        ManageStatus.unavailable,
        "Manage or cancel in your device's Subscriptions settings — the in-app "
        "shortcut opens at launch.",
      );
}

/// The active manage-subscription launcher. The local default refuses honestly;
/// go-live overrides this provider with the real deep-link adapter.
final manageSubscriptionProvider =
    Provider<ManageSubscription>((ref) => const UnavailableManageSubscription());
