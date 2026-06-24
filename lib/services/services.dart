/// Portability seams (SPEC §3 / R-O1) — the vendor & runtime boundaries built so
/// Stage 3 can plug concrete implementations behind them without touching feature
/// code. Each is a thin interface with a safe LOCAL default (no backend, no
/// network, no schema): AI relay (R-H7), analytics (R-M1), billing/entitlement
/// (R-J7a), data-access (R-M3), and the `auth.uid()` identity contract (R-K6).
library;

export 'ai_relay/ai_relay.dart';
export 'analytics/analytics.dart';
export 'billing/billing.dart';
export 'data_access/data_access.dart';
export 'identity/identity.dart';
export 'observability/observability.dart';
export 'learning/learning.dart';
