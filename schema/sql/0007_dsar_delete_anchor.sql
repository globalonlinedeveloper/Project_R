-- BUILD-AHEAD — not deployed; pending human review + go-live wiring.
--
-- DSAR-1 [R-K4 · R-K3] — account-delete anchor (the S26 P0 privacy gap).
--
-- public.user.user_id IS the auth.users.id (R-K6; auth.uid() = user_id throughout the RLS),
-- but 0001 declares NO foreign key from public.user -> auth.users. So when a user deletes
-- their account and Supabase removes the auth.users row, every public.* row (the user plus
-- all FSRS / credit / review children) is ORPHANED and survives erasure — a GDPR / DPDP /
-- CCPA right-to-erasure violation (R-K4). This adds the missing anchor: an ON DELETE CASCADE
-- FK so deleting auth.users(id) removes public.user, which (via the child FKs ALREADY
-- declared ON DELETE CASCADE in 0001) removes user_course / user_item_state /
-- user_phoneme_state / placement_session / review_log / credit_ledger. One delete, no orphans.
--
-- Idempotent (guarded ADD CONSTRAINT) so re-running is safe. On a GREENFIELD DB (S28) there
-- are no rows, so the constraint validates immediately. On an EXISTING DB with possible
-- pre-anchor orphans, add it NOT VALID, reconcile the orphans, then VALIDATE CONSTRAINT.
--
-- Apply to a DISPOSABLE pgserver DB only; the live Supabase project is never touched here.
-- auth.users is provided by Supabase in production; the disposable test mocks a minimal one.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
     WHERE conname = 'user_auth_users_fk'
       AND conrelid = '"user"'::regclass
  ) THEN
    ALTER TABLE "user"
      ADD CONSTRAINT user_auth_users_fk
      FOREIGN KEY (user_id) REFERENCES auth.users (id) ON DELETE CASCADE;
  END IF;
END $$;
