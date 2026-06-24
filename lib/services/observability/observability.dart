/// Observability seam (R-M5) — durable audit sink adapters that back the M2 / M8 audit
/// seams with a write to the AUDIT-1 store (schema/sql/0008), plus the fail-closed
/// crash/error-telemetry identity seam (a known minor emits no persistent crash identifier).
/// Local defaults are unconfigured / suppressing; the real transport + service-role key +
/// verified age-gate audience are injected server-side at go-live.
library;

export 'audit_sink.dart';
export 'crash_telemetry.dart';
