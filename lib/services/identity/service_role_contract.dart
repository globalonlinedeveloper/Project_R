// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// M7 [P0-6 · TS-5] — service-role key handling contract (read-from-env only).
//
// There is NO key here and there never will be one in client code. The Supabase
// service-role key is read ONLY server-side, at request time, from the runtime secret
// store (Deno.env / Supabase function secrets), and is injected at deploy time. It must
// never appear in client bundles, logs, analytics, or the repository — the M7 secret-scan
// (ratel-tools/tests/test_secret_scan.py) enforces the "never in the repo" half in CI.
//
// Least privilege: the ONLY database surfaces that require `service_role` EXECUTE are the
// SECURITY DEFINER functions post_credit_entry (schema/sql/0004 — M4) and
// apply_entitlement_event (schema/sql/0005 — M5). A logged-in client (anon/authenticated)
// can neither EXECUTE them nor write entitlement/credit rows directly (0002 / P0-3).
//
// GO-LIVE STOP: actual key rotation against the real project + injecting the real key into
// the server runtime secret store — owner-gated.

/// Compile-time, reviewable contract for how the Supabase service-role key is handled.
/// This client-side declaration never reads, stores, or transmits the key; it exists so
/// the invariant is version-controlled and the rotation runbook lives next to the code.
abstract final class ServiceRoleKeyContract {
  /// Where the key is read from — the server runtime secret store, at request time only.
  static const String secretSource =
      'server runtime secret store (Deno.env / Supabase function secrets)';

  /// The key is NEVER permitted in client code, bundles, logs, analytics, or the repo.
  static const bool allowedInClientCode = false;

  /// The only database surfaces that require `service_role` EXECUTE (least privilege).
  static const List<String> serviceRoleExecuteSurfaces = <String>[
    'post_credit_entry (schema/sql/0004 — M4)',
    'apply_entitlement_event (schema/sql/0005 — M5)',
  ];

  /// Go-live rotation runbook: revoke → reissue → redeploy → invalidate.
  static const List<String> rotationRunbook = <String>[
    'Revoke the old/compromised service-role key in the Supabase dashboard.',
    'Reissue a new service-role key and any dependent function secrets.',
    'Redeploy the Edge functions/server with the new key injected from the secret store.',
    'Invalidate cached sessions/tokens; verify no old key remains in logs, configs, or CI.',
  ];
}
