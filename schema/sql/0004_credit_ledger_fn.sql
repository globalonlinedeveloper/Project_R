-- BUILD-AHEAD — not deployed; pending human review + go-live wiring.
--
-- M4 [P0-7a · TS-9] — credit double-entry ledger posting function.
-- The ONLY credit-mint/spend surface: a service_role-only SECURITY DEFINER fn that
-- atomically (1) short-circuits idempotently on a replayed client_event_id, (2) locks
-- the user row so concurrent posts serialize, (3) recomputes the authoritative balance
-- as the signed sum of prior entries, (4) refuses any spend that would drop below zero
-- (never clamps), and (5) validates refunds against the referenced spend. Clients stay
-- read-only (0002 / P0-3): EXECUTE is granted to service_role ONLY.
--
-- Apply to a DISPOSABLE pgserver DB only; the live Supabase project is never touched here.
-- GO-LIVE STOP: callers (the Deno grant Edge fn) add device attestation + Turnstile
-- (M8) before invoking this; those need real accounts/keys/devices.

CREATE OR REPLACE FUNCTION post_credit_entry(
  p_user_id          uuid,
  p_entry_type       ledger_entry_type,
  p_amount           integer,
  p_client_event_id  uuid,
  p_grant_source     grant_source DEFAULT NULL,
  p_related_ledger_id uuid       DEFAULT NULL,
  p_reason           text         DEFAULT NULL
) RETURNS credit_ledger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $fn$
DECLARE
  v_existing  credit_ledger;
  v_prev      integer;
  v_delta     integer;
  v_balance   integer;
  v_spent     integer;
  v_refunded  integer;
  v_row       credit_ledger;
BEGIN
  IF p_amount IS NULL OR p_amount < 1 THEN
    RAISE EXCEPTION 'amount must be >= 1 (got %)', p_amount USING ERRCODE = 'check_violation';
  END IF;

  -- (1) Idempotency: a replayed client_event_id returns the original row, no re-post.
  SELECT * INTO v_existing FROM credit_ledger WHERE client_event_id = p_client_event_id;
  IF FOUND THEN
    RETURN v_existing;
  END IF;

  -- (2) Per-user serialization: concurrent posts can't both read a stale balance
  --     and both pass the zero floor (TS-9). Lock anchor = the user row.
  PERFORM 1 FROM "user" WHERE user_id = p_user_id FOR UPDATE;

  -- (3) Authoritative balance = signed sum of prior entries (order-independent).
  SELECT COALESCE(SUM(CASE entry_type
             WHEN 'grant'  THEN amount
             WHEN 'refund' THEN amount
             WHEN 'spend'  THEN -amount
           END), 0)
    INTO v_prev
    FROM credit_ledger
    WHERE user_id = p_user_id;

  IF p_entry_type = 'grant' THEN
    v_delta := p_amount;
  ELSIF p_entry_type = 'spend' THEN
    v_delta := -p_amount;
  ELSIF p_entry_type = 'refund' THEN
    IF p_related_ledger_id IS NULL THEN
      RAISE EXCEPTION 'refund requires related_ledger_id (the spend being refunded)'
        USING ERRCODE = 'check_violation';
    END IF;
    SELECT amount INTO v_spent FROM credit_ledger
      WHERE credit_ledger_id = p_related_ledger_id
        AND user_id = p_user_id
        AND entry_type = 'spend';
    IF NOT FOUND THEN
      RAISE EXCEPTION 'refund must reference an existing spend of this user'
        USING ERRCODE = 'check_violation';
    END IF;
    SELECT COALESCE(SUM(amount), 0) INTO v_refunded FROM credit_ledger
      WHERE related_ledger_id = p_related_ledger_id AND entry_type = 'refund';
    IF p_amount > v_spent - v_refunded THEN
      RAISE EXCEPTION 'refund % exceeds remaining refundable % on spend %',
        p_amount, v_spent - v_refunded, p_related_ledger_id
        USING ERRCODE = 'check_violation';
    END IF;
    v_delta := p_amount;
  ELSE
    RAISE EXCEPTION 'unsupported entry_type %', p_entry_type USING ERRCODE = 'check_violation';
  END IF;

  -- (4) Fail closed at zero — never clamp a spend into a negative balance.
  v_balance := v_prev + v_delta;
  IF v_balance < 0 THEN
    RAISE EXCEPTION 'insufficient credits: balance % cannot cover spend % (would be %)',
      v_prev, p_amount, v_balance USING ERRCODE = 'check_violation';
  END IF;

  INSERT INTO credit_ledger(
      credit_ledger_id, user_id, entry_type, amount, balance_after,
      grant_source, client_event_id, related_ledger_id, reason, created_at)
  VALUES (
      gen_random_uuid(), p_user_id, p_entry_type, p_amount, v_balance,
      p_grant_source, p_client_event_id, p_related_ledger_id, p_reason, now())
  ON CONFLICT (client_event_id) DO NOTHING
  RETURNING * INTO v_row;

  IF v_row.credit_ledger_id IS NULL THEN
    -- Lost an idempotency race between the SELECT above and the INSERT; return the winner.
    SELECT * INTO v_row FROM credit_ledger WHERE client_event_id = p_client_event_id;
  END IF;

  RETURN v_row;
END;
$fn$;

-- Least privilege: clients never mint/spend; service_role is the ONLY EXECUTE surface.
REVOKE ALL ON FUNCTION post_credit_entry(uuid, ledger_entry_type, integer, uuid, grant_source, uuid, text) FROM PUBLIC;
REVOKE ALL ON FUNCTION post_credit_entry(uuid, ledger_entry_type, integer, uuid, grant_source, uuid, text) FROM authenticated, anon;
GRANT EXECUTE ON FUNCTION post_credit_entry(uuid, ledger_entry_type, integer, uuid, grant_source, uuid, text) TO service_role;
