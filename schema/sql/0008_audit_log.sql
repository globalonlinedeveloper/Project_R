-- BUILD-AHEAD — not deployed; pending human review + go-live wiring.
--
-- AUDIT-1 [R-M5 · R-M8 · R-K6] — durable, append-only audit store for security-relevant events.
--
-- The M2 ModerationAuditSink (lib/services/ai_relay/moderation.dart) and the M8 GrantAuditSink
-- (lib/services/billing/grant_guard.dart) define audit SEAMS that are NO-OP locally, so grant /
-- anti-abuse DENIALS and moderation verdicts currently EVAPORATE — there is no durable store for
-- incident response / abuse forensics. R-M5 requires security-relevant signals (auth failures,
-- relay/abuse signals, M8 spend-ceiling events) to land in a DURABLE store with security
-- retention; R-M8 wants the per-account/per-device abuse velocity + anomaly trail observable.
-- This adds that store, mirroring 0005's server-only pattern:
--
--   * audit_log — append-only. Clients get NEITHER read NOR write (service_role-only, exactly
--     like 0005's processed_payment_event). No client UPDATE/DELETE path exists, and even
--     service_role is granted only SELECT+INSERT (NO UPDATE/DELETE), so the log is
--     tamper-evident-by-design: rows can be added and read, never silently altered or removed.
--   * record_audit_event(...) — SECURITY DEFINER, EXECUTE = service_role ONLY. The Deno relay /
--     grant host calls it under the service role after a denial / moderation verdict.
--   * detail jsonb is PII-MINIMAL / ALLOW-LISTED (R-M5 + the R-M1 analytics discipline): the
--     caller passes only low-cardinality enum-ish fields (decision, source, stage, reason) —
--     NEVER raw user content, prompts, transcripts, or moderated text. The fn enforces the
--     SHAPE (a json object, not a scalar/array blob); allow-list CONTENT stays the caller's
--     duty (the seams already refuse to echo offending text). user_id is the pseudonymous
--     account id and is NULLABLE: moderation events and pre-auth/minor events carry NULL — no
--     persistent identifier leaks through the audit pipeline (inherits the R-M1-5 minor mode).
--
-- Append-only ⇒ there is no UPDATE/DELETE grant to anyone; retention/erasure is an out-of-band
-- owner job (the R-M5 ~90-day security window; any R-K3 data-min purge), never a client capability.
-- GO-LIVE DECISION (owner · R-K4 / R-K3): whether an account-delete erases / anonymizes this user's
-- audit rows or retains them (user_id is pseudonymous + nullable) under the R-M5 security-forensics
-- basis. This migration deliberately adds NO account-delete cascade here — the erase-vs-retain call
-- is the owner's, exactly like the DSAR-2 anonymize-vs-delete decision. Flag, don't bake.
--
-- Apply to a DISPOSABLE pgserver DB only; the live Supabase project is never touched here.
-- GO-LIVE STOP: the real service-role key, the Deno host wiring, and the daily-export → durable
-- 90-day-retention job (R-M5) need owner accounts/keys.

-- ── Append-only audit store (server-only) ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS audit_log (
  audit_id    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  occurred_at timestamptz NOT NULL DEFAULT now(),
  user_id     uuid,                                  -- pseudonymous account id; NULL for moderation / pre-auth / minor (no persistent id)
  category    text        NOT NULL,                  -- coarse bucket: 'grant' | 'moderation' | ...
  action      text        NOT NULL,                  -- enum-ish outcome: 'denyVelocity' | 'blocked' | ...
  detail      jsonb       NOT NULL DEFAULT '{}'::jsonb  -- PII-MINIMAL allow-listed fields ONLY (no raw content)
);

-- Forensics access paths: by time window, and by event type within a window.
CREATE INDEX IF NOT EXISTS audit_log_occurred_at_idx ON audit_log (occurred_at DESC);
CREATE INDEX IF NOT EXISTS audit_log_category_action_idx ON audit_log (category, action, occurred_at DESC);

ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log FORCE ROW LEVEL SECURITY;
-- No policy for authenticated/anon => every client read/write is denied (server-only table).
DROP POLICY IF EXISTS audit_log_service_all ON audit_log;
CREATE POLICY audit_log_service_all ON audit_log
  FOR ALL TO service_role USING (true) WITH CHECK (true);
-- Least privilege + APPEND-ONLY: clients get nothing; service_role may read + append, never
-- UPDATE/DELETE (so even a compromised service path cannot rewrite or erase history).
REVOKE ALL ON audit_log FROM PUBLIC, authenticated, anon;
GRANT SELECT, INSERT ON audit_log TO service_role;

-- ── Append fn (service_role-only, SECURITY DEFINER) ──────────────────────────────────────────
CREATE OR REPLACE FUNCTION record_audit_event(
  p_category text,
  p_action   text,
  p_user_id  uuid  DEFAULT NULL,
  p_detail   jsonb DEFAULT '{}'::jsonb
) RETURNS audit_log
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $fn$
DECLARE
  v_row audit_log;
BEGIN
  -- Fail closed on a malformed event (never write a junk audit row).
  IF p_category IS NULL OR length(btrim(p_category)) = 0 THEN
    RAISE EXCEPTION 'category required' USING ERRCODE = 'check_violation';
  END IF;
  IF p_action IS NULL OR length(btrim(p_action)) = 0 THEN
    RAISE EXCEPTION 'action required' USING ERRCODE = 'check_violation';
  END IF;
  -- detail must be a JSON OBJECT (an allow-listed key/value map), never a scalar/array that
  -- could smuggle a raw blob. This is a SHAPE guard; the caller still owns PII-free CONTENT.
  IF p_detail IS NOT NULL AND jsonb_typeof(p_detail) <> 'object' THEN
    RAISE EXCEPTION 'detail must be a json object' USING ERRCODE = 'check_violation';
  END IF;

  INSERT INTO audit_log(user_id, category, action, detail)
    VALUES (p_user_id, btrim(p_category), btrim(p_action), COALESCE(p_detail, '{}'::jsonb))
    RETURNING * INTO v_row;
  RETURN v_row;
END;
$fn$;

-- Least privilege: clients never write audit rows; service_role is the ONLY EXECUTE surface.
REVOKE ALL ON FUNCTION record_audit_event(text, text, uuid, jsonb) FROM PUBLIC;
REVOKE ALL ON FUNCTION record_audit_event(text, text, uuid, jsonb) FROM authenticated, anon;
GRANT EXECUTE ON FUNCTION record_audit_event(text, text, uuid, jsonb) TO service_role;
