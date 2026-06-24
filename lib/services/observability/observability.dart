/// Observability seam (R-M5) — durable audit sink adapters that back the M2 / M8 audit
/// seams with a write to the AUDIT-1 store (schema/sql/0008). Local default is unconfigured
/// (no-op); the real transport + service-role key are injected server-side at go-live.
library;

export 'audit_sink.dart';
