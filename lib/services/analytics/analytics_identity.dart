// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// GO-LIVE STOP: this is the CONTRACT a real analytics / ad SDK adapter
// (Firebase / GA4 / AdMob) must honor at go-live — it is NOT a live sink and it
// touches no network, sets no real device / advertising ID, and reads no age
// signal on its own. Before go-live a concrete AnalyticsIdentitySink adapter is
// written behind this same seam, the AnalyticsAudience is sourced from the
// VERIFIED age gate (never a caller-supplied value or an event payload), and the
// human dual senior-architect sign-off wires it in.
//
// R-M1 / R-K1 (two-ID model · P0-13): a known minor carries NO persistent
// analytics / tracking / ad identifier — no analytics user_id, no device-id
// linkage, no ad ID. This is DISTINCT from the authenticated account id
// (auth.uid()), which is server-side only and is never the thing assigned here.
// This seam makes that suppression STRUCTURAL and INJECTED (driven by the
// audience, not a buried constant), so a future real adapter physically cannot
// leak a minor's stable identifier into the analytics / ad pipeline.

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The analytics-identity boundary a real SDK adapter implements at go-live.
/// Distinct from event logging (`Analytics.logEvent`, which carries aggregate
/// props): this assigns the STABLE per-user / per-device identifier an analytics
/// or ad SDK keys all of a user's events on. The local default is a no-op.
abstract interface class AnalyticsIdentitySink {
  /// Associate subsequent analytics events with a stable user identifier.
  void setUserId(String userId);

  /// Associate / link a stable device or advertising identifier.
  void setDeviceId(String deviceId);

  /// Drop any stable identifier so events become unlinkable (anonymous).
  void clearIdentity();
}

/// Default (local / Stage 1–2): assigns nothing, links nothing, calls out
/// nowhere. The concrete vendor adapter replaces this delegate at Stage 3 —
/// still behind [MinorSafeAnalyticsIdentity].
class NoopAnalyticsIdentitySink implements AnalyticsIdentitySink {
  const NoopAnalyticsIdentitySink();
  @override
  void setUserId(String userId) {}
  @override
  void setDeviceId(String deviceId) {}
  @override
  void clearIdentity() {}
}

/// Whether the current user is a known minor. SUPPLIED by the verified age gate
/// at go-live — never trusted from the client or an event payload. Modeled as an
/// explicit value (not a bare bool) so the suppression decision is visible at
/// every call site. [unknown] fails CLOSED (treated as a minor) so an
/// un-gated / pre-age-gate session never carries a stable identifier.
enum AnalyticsAudience { adult, minor, unknown }

/// Fail-closed analytics-identity assigner (R-M1 / R-K1). Wraps a concrete
/// [AnalyticsIdentitySink] and gates every stable-identifier assignment by the
/// INJECTED [AnalyticsAudience]:
///   • adult            → assignments forward to the delegate normally;
///   • minor / unknown  → NO stable identifier EVER reaches the delegate; the
///     assignment is dropped and the delegate is explicitly cleared (active,
///     not passive, suppression — fail closed).
/// The minor path may still emit AGGREGATE, non-identifying events through the
/// separate `Analytics` seam; this governs only the stable IDENTIFIER, which is
/// exactly what R-M1 / R-K1 forbid for minors.
class MinorSafeAnalyticsIdentity implements AnalyticsIdentitySink {
  const MinorSafeAnalyticsIdentity(this._delegate, this._audience);

  final AnalyticsIdentitySink _delegate;
  final AnalyticsAudience _audience;

  /// Only a CONFIRMED adult may carry a stable analytics identifier. Both
  /// `minor` and `unknown` suppress — the default is conservative.
  bool get _identifiable => _audience == AnalyticsAudience.adult;

  @override
  void setUserId(String userId) {
    if (!_identifiable) {
      _delegate.clearIdentity(); // fail closed — never link a minor
      return;
    }
    _delegate.setUserId(userId);
  }

  @override
  void setDeviceId(String deviceId) {
    if (!_identifiable) {
      _delegate.clearIdentity();
      return;
    }
    _delegate.setDeviceId(deviceId);
  }

  @override
  void clearIdentity() => _delegate.clearIdentity();
}

/// The seam ships SUPPRESSING from day one: until the verified age gate injects
/// a real audience at go-live, the audience is [AnalyticsAudience.unknown], so
/// the provider hands back a wrapper that assigns NO stable identifier. Mirrors
/// how `analyticsProvider` ships allow-list-wrapped from day one.
final analyticsIdentityProvider = Provider<AnalyticsIdentitySink>(
    (ref) => const MinorSafeAnalyticsIdentity(
        NoopAnalyticsIdentitySink(), AnalyticsAudience.unknown));
