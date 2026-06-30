-- GENERATED CONTRACT (hand-authored migration). Stage-3 generic per-table isolation RLS [L5 / TS-2 / TS-3].
-- Apply to a DISPOSABLE pgserver DB only; the live Supabase project is never touched here.
--
-- Threat closed (TS-2 cross-user data access / TS-3 horizontal privilege escalation):
-- every learner-owned table is deny-by-default (ENABLE + FORCE ROW LEVEL SECURITY) and scoped to
-- the caller with USING/WITH CHECK (auth.uid() = user_id) — a logged-in user can read and write
-- ONLY their own rows and can never see or mutate another user's data.
--
-- Intentionally NOT here: `user` and `credit_ledger`. 0002 already locks them CLIENT-READ-ONLY;
-- re-granting them own-row writes would reopen the free-Pro / infinite-credit holes (P0-3). They are
-- still RLS-isolated (their 0002 SELECT-own policy) and the isolation test covers all 7 user tables.
--
-- review_log is append-only (R-M, kept forever): SELECT-own + INSERT-own only — never UPDATE/DELETE.
--
-- Deny-by-default by construction: a NEW learner table added without a policy below stays no-access
-- (FORCE RLS + no permissive policy => every client row is hidden), and the parameterized isolation
-- test (which derives the table list from the schema) fails until its RLS is declared here.

-- ---- user_course -----------------------------------------------------------------------------
ALTER TABLE "user_course" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "user_course" FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS user_course_own ON "user_course";
CREATE POLICY user_course_own ON "user_course"
  FOR ALL TO authenticated
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS user_course_service_all ON "user_course";
CREATE POLICY user_course_service_all ON "user_course"
  FOR ALL TO service_role USING (true) WITH CHECK (true);
REVOKE ALL ON "user_course" FROM authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "user_course" TO authenticated;
GRANT ALL ON "user_course" TO service_role;

-- ---- user_item_state -------------------------------------------------------------------------
ALTER TABLE "user_item_state" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "user_item_state" FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS user_item_state_own ON "user_item_state";
CREATE POLICY user_item_state_own ON "user_item_state"
  FOR ALL TO authenticated
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS user_item_state_service_all ON "user_item_state";
CREATE POLICY user_item_state_service_all ON "user_item_state"
  FOR ALL TO service_role USING (true) WITH CHECK (true);
REVOKE ALL ON "user_item_state" FROM authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "user_item_state" TO authenticated;
GRANT ALL ON "user_item_state" TO service_role;

-- ---- user_phoneme_state ----------------------------------------------------------------------
ALTER TABLE "user_phoneme_state" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "user_phoneme_state" FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS user_phoneme_state_own ON "user_phoneme_state";
CREATE POLICY user_phoneme_state_own ON "user_phoneme_state"
  FOR ALL TO authenticated
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS user_phoneme_state_service_all ON "user_phoneme_state";
CREATE POLICY user_phoneme_state_service_all ON "user_phoneme_state"
  FOR ALL TO service_role USING (true) WITH CHECK (true);
REVOKE ALL ON "user_phoneme_state" FROM authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "user_phoneme_state" TO authenticated;
GRANT ALL ON "user_phoneme_state" TO service_role;

-- ---- placement_session -----------------------------------------------------------------------
ALTER TABLE "placement_session" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "placement_session" FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS placement_session_own ON "placement_session";
CREATE POLICY placement_session_own ON "placement_session"
  FOR ALL TO authenticated
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS placement_session_service_all ON "placement_session";
CREATE POLICY placement_session_service_all ON "placement_session"
  FOR ALL TO service_role USING (true) WITH CHECK (true);
REVOKE ALL ON "placement_session" FROM authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "placement_session" TO authenticated;
GRANT ALL ON "placement_session" TO service_role;

-- ---- review_log: append-only (SELECT-own + INSERT-own; never UPDATE/DELETE for a client) ------
ALTER TABLE "review_log" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "review_log" FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS review_log_select_own ON "review_log";
CREATE POLICY review_log_select_own ON "review_log"
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
DROP POLICY IF EXISTS review_log_insert_own ON "review_log";
CREATE POLICY review_log_insert_own ON "review_log"
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS review_log_service_all ON "review_log";
CREATE POLICY review_log_service_all ON "review_log"
  FOR ALL TO service_role USING (true) WITH CHECK (true);
REVOKE ALL ON "review_log" FROM authenticated;
GRANT SELECT, INSERT ON "review_log" TO authenticated;
GRANT ALL ON "review_log" TO service_role;

-- ---- friendship: own-row relationship set (R-I9/R-L8). The app deletes-own + inserts-own its
-- current relationship set; own-row FOR ALL mirrors user_course. -------------------------------
ALTER TABLE "friendship" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "friendship" FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS friendship_own ON "friendship";
CREATE POLICY friendship_own ON "friendship"
  FOR ALL TO authenticated
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS friendship_service_all ON "friendship";
CREATE POLICY friendship_service_all ON "friendship"
  FOR ALL TO service_role USING (true) WITH CHECK (true);
REVOKE ALL ON "friendship" FROM authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "friendship" TO authenticated;
GRANT ALL ON "friendship" TO service_role;

-- ---- friend_activity: SELECT-own only (R-I9/R-L8). The feed is produced server-side; a learner
-- reads but never forges it -> INSERT/UPDATE/DELETE are service_role only (review_log read pattern). 
ALTER TABLE "friend_activity" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "friend_activity" FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS friend_activity_select_own ON "friend_activity";
CREATE POLICY friend_activity_select_own ON "friend_activity"
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
DROP POLICY IF EXISTS friend_activity_service_all ON "friend_activity";
CREATE POLICY friend_activity_service_all ON "friend_activity"
  FOR ALL TO service_role USING (true) WITH CHECK (true);
REVOKE ALL ON "friend_activity" FROM authenticated;
GRANT SELECT ON "friend_activity" TO authenticated;
GRANT ALL ON "friend_activity" TO service_role;

-- ---- league_cohort: SHARED weekly grouping (R-I6), NO single owner -> NO authenticated policy
-- (deny-by-default): a client never directly SELECTs a cohort row. Reading a member's own cohort is
-- a server-side (SECURITY DEFINER) path in a later slice; service_role owns formation + the close job.
ALTER TABLE "league_cohort" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "league_cohort" FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS league_cohort_service_all ON "league_cohort";
CREATE POLICY league_cohort_service_all ON "league_cohort"
  FOR ALL TO service_role USING (true) WITH CHECK (true);
REVOKE ALL ON "league_cohort" FROM authenticated;
GRANT ALL ON "league_cohort" TO service_role;

-- ---- league_member: own-row weekly standing (R-I6). own-row FOR ALL mirrors user_course/friendship;
-- the cross-user leaderboard (co-members' XP) is a server-side read path in a later slice, never a
-- direct cross-row client SELECT. ------------------------------------------------------------------
ALTER TABLE "league_member" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "league_member" FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS league_member_own ON "league_member";
CREATE POLICY league_member_own ON "league_member"
  FOR ALL TO authenticated
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS league_member_service_all ON "league_member";
CREATE POLICY league_member_service_all ON "league_member"
  FOR ALL TO service_role USING (true) WITH CHECK (true);
REVOKE ALL ON "league_member" FROM authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "league_member" TO authenticated;
GRANT ALL ON "league_member" TO service_role;
