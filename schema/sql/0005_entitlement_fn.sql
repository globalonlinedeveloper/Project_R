-- BUILD-AHEAD — not deployed; pending human review + go-live wiring.
--
-- M5 [P1-1 · TS-6] — payments entitlement-transition function + webhook-event dedupe.
-- The server-side surface that turns a VERIFIED payment webhook event (Stripe/Play) into
-- a `user.pro_until` transition, exactly once. Pairs with the pure-Dart signature verify
-- (lib/services/billing/payments_verify.dart): the Deno Edge webhook verifies the HMAC,
-- normalises the event, then calls this fn under the service_role.
--
--   * Idempotent on the provider event id via processed_payment_event(event_id PK):
--     a replayed webhook (Stripe retries aggressively) transitions entitlement ONCE.
--   * grant            -> EXTEND pro_until (GREATEST, never shortens) => order-independent
--                         across grants (TS-6 out-of-order safety).
--   * refund/chargeback/lapse -> CLAWBACK (pro_until := NULL).
--   * Per-user row lock serialises concurrent transitions; unknown kind / grant-without-until
--     / unknown user all RAISE (and roll back, so the event is NOT marked processed).
--   * Clients stay read-only (re-asserts 0002 / P0-3): EXECUTE + the dedupe table are
--     service_role ONLY; `authenticated` can neither call the fn nor write pro_until.
--
-- Apply to a DISPOSABLE pgserver DB only; the live Supabase project is never touched here.
-- GO-LIVE STOP: real Stripe/Play signing secrets, receipts, the live webhook URL, and
-- store server-to-server receipt validation — all need owner accounts/keys.

-- ── Webhook-event dedupe ledger (server-only) ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS processed_payment_event (
  event_id    text PRIMARY KEY,                 -- provider-opaque id (Stripe evt_…, Play purchaseToken)
  user_id     uuid NOT NULL,
  kind        text NOT NULL,
  until       timestamptz,                       -- the grant expiry the provider computed (null for clawbacks)
  applied_at  timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE processed_payment_event ENABLE ROW LEVEL SECURITY;
ALTER TABLE processed_payment_event FORCE ROW LEVEL SECURITY;
-- No policy for authenticated/anon => every client read/write is denied (server-only table).
DROP POLICY IF EXISTS ppe_service_all ON processed_payment_event;
CREATE POLICY ppe_service_all ON processed_payment_event
  FOR ALL TO service_role USING (true) WITH CHECK (true);
REVOKE ALL ON processed_payment_event FROM PUBLIC, authenticated, anon;
GRANT ALL ON processed_payment_event TO service_role;

-- ── Entitlement transition (service_role-only, idempotent) ──────────────────────────────────
CREATE OR REPLACE FUNCTION apply_entitlement_event(
  p_event_id  text,
  p_user_id   uuid,
  p_kind      text,
  p_until     timestamptz DEFAULT NULL
) RETURNS "user"
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $fn$
DECLARE
  v_user     "user";
  v_new_pro  timestamptz;
BEGIN
  -- Validate the normalized event up front (fail closed on anything unexpected).
  IF p_event_id IS NULL OR length(btrim(p_event_id)) = 0 THEN
    RAISE EXCEPTION 'event_id required' USING ERRCODE = 'check_violation';
  END IF;
  IF p_kind NOT IN ('grant', 'refund', 'chargeback', 'lapse') THEN
    RAISE EXCEPTION 'unknown entitlement kind %', p_kind USING ERRCODE = 'check_violation';
  END IF;
  IF p_kind = 'grant' AND p_until IS NULL THEN
    RAISE EXCEPTION 'grant requires until' USING ERRCODE = 'check_violation';
  END IF;

  -- (1) Idempotency: the FIRST writer of this event_id records it; a replay no-ops.
  INSERT INTO processed_payment_event(event_id, user_id, kind, until)
    VALUES (p_event_id, p_user_id, p_kind, p_until)
    ON CONFLICT (event_id) DO NOTHING;
  IF NOT FOUND THEN
    -- Already processed -> return current entitlement unchanged (no double transition).
    SELECT * INTO v_user FROM "user" WHERE user_id = p_user_id;
    RETURN v_user;
  END IF;

  -- (2) Serialise concurrent transitions for this user on the user row.
  SELECT * INTO v_user FROM "user" WHERE user_id = p_user_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'no such user %', p_user_id USING ERRCODE = 'foreign_key_violation';
  END IF;

  -- (3) Apply the transition.
  IF p_kind = 'grant' THEN
    -- Extend, never shorten: a late/out-of-order older grant cannot reduce entitlement.
    v_new_pro := GREATEST(COALESCE(v_user.pro_until, p_until), p_until);
  ELSE
    -- refund / chargeback / lapse -> immediate clawback.
    v_new_pro := NULL;
  END IF;

  UPDATE "user" SET pro_until = v_new_pro, updated_at = now()
    WHERE user_id = p_user_id
    RETURNING * INTO v_user;
  RETURN v_user;
END;
$fn$;

-- Least privilege: clients never transition entitlement; service_role is the ONLY EXECUTE surface.
REVOKE ALL ON FUNCTION apply_entitlement_event(text, uuid, text, timestamptz) FROM PUBLIC;
REVOKE ALL ON FUNCTION apply_entitlement_event(text, uuid, text, timestamptz) FROM authenticated, anon;
GRANT EXECUTE ON FUNCTION apply_entitlement_event(text, uuid, text, timestamptz) TO service_role;
