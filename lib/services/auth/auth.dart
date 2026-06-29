/// Account entry/exit seam (R-L1). The widget layer reads [authServiceProvider];
/// the Supabase-backed implementation plugs in behind it via `backend_wiring`.
library;

export 'auth_service.dart';
export 'supabase_auth_service.dart';
