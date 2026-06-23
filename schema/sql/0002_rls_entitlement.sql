-- GENERATED CONTRACT (hand-authored migration). Stage-3 entitlement/credit RLS [P0-3].
-- Apply to a DISPOSABLE pgserver DB only; the live Supabase project is never touched here.
--
-- Threat closed (TS-8 / P0-3): a logged-in user must NEVER be able to grant themselves Pro
-- (write user.pro_until) or mint credits (insert a credit_ledger grant). Entitlement + ledger
-- are CLIENT-READ-ONLY: `authenticated` may SELECT only its own rows; ALL writes are `service_role`.
-- In Supabase the roles `authenticated`/`service_role` and `auth.uid()` already exist (platform-provided);
-- the local test harness creates equivalents before applying this file.

-- ---- user: entitlement-bearing (pro_until). Client read-only. -------------------------------
ALTER TABLE "user" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "user" FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS user_select_own ON "user";
CREATE POLICY user_select_own ON "user"
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

-- No INSERT/UPDATE/DELETE policy for `authenticated` => every client write is denied.
DROP POLICY IF EXISTS user_service_all ON "user";
CREATE POLICY user_service_all ON "user"
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);

-- Privilege floor (defence in depth): clients get SELECT only; service_role gets everything.
REVOKE ALL ON "user" FROM authenticated;
GRANT SELECT ON "user" TO authenticated;
GRANT ALL ON "user" TO service_role;

-- ---- credit_ledger: minting is server-only. Client read-only. -------------------------------
ALTER TABLE "credit_ledger" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "credit_ledger" FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS credit_select_own ON "credit_ledger";
CREATE POLICY credit_select_own ON "credit_ledger"
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS credit_service_all ON "credit_ledger";
CREATE POLICY credit_service_all ON "credit_ledger"
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);

REVOKE ALL ON "credit_ledger" FROM authenticated;
GRANT SELECT ON "credit_ledger" TO authenticated;
GRANT ALL ON "credit_ledger" TO service_role;
