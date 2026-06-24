// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// TELEMETRY-ID [R-M5] — fail-closed crash / error-telemetry identity seam: a
// known minor emits NO persistent identifier into the crash pipeline. This is
// the crash/telemetry sibling of the analytics-identity seam
// (lib/services/analytics/analytics_identity.dart) — the SAME fail-closed,
// injected-audience shape, applied to the Observability crash reporter instead
// of the analytics / ad SDK.
//
// GO-LIVE STOP: this is the CONTRACT a real crash reporter adapter (Firebase
// Crashlytics, or the held-in-reserve GlitchTip OSS escape hatch) must honor at
// go-live — it is NOT a live sink: it touches no network, attaches no real
// identifier, ships no breadcrumb, and reads no age signal on its own. Before
// go-live a concrete CrashTelemetrySink adapter is written behind this SAME
// seam, the TelemetryAudience is sourced from the VERIFIED age gate (never a
// caller-supplied value or a report payload), and the human dual senior-
// architect sign-off wires it in.
//
// R-M5 known-minors rule (Observability): crash/error telemetry carries NO
// persistent analytics/crash identifier (session-scoped or none) and no
// profiling breadcrumbs for a known minor; the authenticated auth.uid() account
// id is never attached to crash telemetry, and minors are excluded from replay.
// A minor IS still counted toward the crash-free-users signal — the error is
// still recorded — it just carries no stable identifier and no profiling
// breadcrumb. This seam makes that suppression STRUCTURAL and INJECTED (driven
// by the audience, not a buried constant), so a future real adapter physically
// cannot leak a minor's stable identifier into the crash pipeline.

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The crash/error-telemetry boundary a real reporter adapter implements at
/// go-live (Firebase Crashlytics, or GlitchTip as the OSS escape hatch). The
/// local default is a no-op. Distinct from the durable audit sink (the AUDIT-2
/// `record_audit_event` adapter): this is the device-side crash reporter that
/// keys a session's reports on a stable user identifier — exactly the
/// identifier a known minor must never carry.
abstract interface class CrashTelemetrySink {
  /// Associate subsequent crash reports with a stable, pseudonymous user
  /// identifier. For an adult this is the scrubbed pseudonymous user id — never
  /// `auth.uid()`.
  void setUser(String userId);

  /// Drop any stable user association so subsequent reports are unattributable.
  void clearUser();

  /// Record a non-fatal or fatal error for the crash-free-users signal.
  void recordError(Object error, {StackTrace? stackTrace});

  /// Leave a profiling breadcrumb on the report trail.
  void leaveBreadcrumb(String message);
}

/// Default (local / Stage 1–2): reports nothing, attaches nothing, calls out
/// nowhere. The concrete vendor adapter replaces this delegate at Stage 3 —
/// still behind [MinorSafeCrashTelemetry].
class NoopCrashTelemetrySink implements CrashTelemetrySink {
  const NoopCrashTelemetrySink();
  @override
  void setUser(String userId) {}
  @override
  void clearUser() {}
  @override
  void recordError(Object error, {StackTrace? stackTrace}) {}
  @override
  void leaveBreadcrumb(String message) {}
}

/// Whether the current user is a known minor. SUPPLIED by the verified age gate
/// at go-live — never trusted from the client or a report payload. Modeled as an
/// explicit value (not a bare bool) so the suppression decision is visible at
/// every call site. [unknown] fails CLOSED (treated as a minor) so an
/// un-gated / pre-age-gate session never carries a stable identifier.
enum TelemetryAudience { adult, minor, unknown }

/// Fail-closed crash-telemetry identity wrapper (R-M5). Wraps a concrete
/// [CrashTelemetrySink] and gates every stable-identity / profiling signal by
/// the INJECTED [TelemetryAudience]:
///   • adult            → setUser + breadcrumbs forward to the delegate;
///   • minor / unknown  → NO stable identifier EVER reaches the delegate (the
///     assignment is dropped and the delegate is explicitly cleared — active,
///     not passive, suppression), and profiling breadcrumbs are dropped.
/// [recordError] ALWAYS forwards: a known minor is still counted toward the
/// crash-free-users signal, but because [setUser] never reaches the delegate the
/// report carries no stable identifier. [clearUser] always forwards.
class MinorSafeCrashTelemetry implements CrashTelemetrySink {
  const MinorSafeCrashTelemetry(this._delegate, this._audience);

  final CrashTelemetrySink _delegate;
  final TelemetryAudience _audience;

  /// Only a CONFIRMED adult may carry a stable crash identifier or profiling
  /// breadcrumbs. Both `minor` and `unknown` suppress — the default is
  /// conservative.
  bool get _identifiable => _audience == TelemetryAudience.adult;

  @override
  void setUser(String userId) {
    if (!_identifiable) {
      _delegate.clearUser(); // fail closed — never attach a minor's id
      return;
    }
    _delegate.setUser(userId);
  }

  @override
  void clearUser() => _delegate.clearUser();

  @override
  void recordError(Object error, {StackTrace? stackTrace}) =>
      _delegate.recordError(error, stackTrace: stackTrace);

  @override
  void leaveBreadcrumb(String message) {
    if (!_identifiable) return; // no profiling breadcrumbs for a known minor
    _delegate.leaveBreadcrumb(message);
  }
}

/// The seam ships SUPPRESSING from day one: until the verified age gate injects
/// a real audience at go-live, the audience is [TelemetryAudience.unknown], so
/// the provider hands back a wrapper that attaches NO stable identifier. Mirrors
/// how `analyticsIdentityProvider` ships suppressing from day one.
final crashTelemetryProvider = Provider<CrashTelemetrySink>(
    (ref) => const MinorSafeCrashTelemetry(
        NoopCrashTelemetrySink(), TelemetryAudience.unknown));
