-- BACKFILL — provenance for the TWELVE live `public` tables that were applied
-- direct-to-live (Supabase migration history) and were NOT yet snapshotted in
-- this repo. This file makes schema/sql/ a faithful record of live (S166):
-- every table, constraint, RLS policy, grant and trigger below was captured via
-- READ-ONLY introspection of the live project (fkbmodjtxatrqcghhfba) on
-- 2026-07-18 and reproduces it verbatim-for-semantics. It is NOT a new change to
-- live — the objects already exist there.
--
-- WHY THIS IS A RAW-SQL PROVENANCE FILE (not schema/tables/*.schema.json):
--   * The pg_dump-parity gate (test_pg_dump_parity.py) round-trips ONLY the
--     generated schema/sql/0001_schema.sql (codegen_ddl.py <- schema/tables/*).
--     Raw-SQL files 0002..0012 are OUTSIDE that parity set — like 0009/0010
--     (leagues) and 0011 (friends), this file adds ZERO pg_dump-parity or Dart
--     model-drift surface (no codegen_dart change; no Flutter needed).
--   * These tables are auth-linked (FK -> auth.users) and/or live-runtime sync
--     state; `profiles` is DELIBERATELY excluded from schema/tables/ (auth.users
--     FK, handled as a shim in the friends tests). Modelling them in the JSON SoT
--     would force Dart models the client reaches by other code paths and push 12
--     tables through pg_dump round-trip at once. Raw-SQL provenance is the right
--     seam; test_sync_tables.py applies this file to a DISPOSABLE pgserver.
--
-- Live provenance (supabase_migrations.schema_migrations):
--   20260624190305 auth_profiles_and_handle_new_user  -> profiles (+ is_pro guard)
--   20260710023552 profiles_self_read_grant           -> profiles SELECT-own grant
--   20260625080618 claim_tokens_and_merge_learner_state-> claim_tokens, learner_theta
--   20260709235352 live_ai_entitlement_usage          -> ai_usage
--   20260709235958 live_ai_service_role_grants         -> ai_usage grants
--   20260709220249 user_state_sync_schema             -> saved_words,
--       user_adventure_progress, user_earned_stamps, user_outfits,
--       user_progress_daily, user_settings, user_study_stats
--   20260709232940 user_state_sync_grants_fix          -> the 7 sync-table grants
--   (item_bank = L5 IRT calibration bank, seeded via the RATEL_L5_* migrations)
--
-- Requirements evidenced: [R-M3] backend infra (Supabase Postgres/RLS) ·
--   [R-K6] security (RLS, PII, server-only tokens, is_pro guard) ·
--   [R-B8] IRT item bank + learner theta · [R-I2] daily-XP/streak source ·
--   [R-I9] social profiles (handle/display_name) · [R-L6] profile & settings hub.
--
-- RLS shape per table (faithful to live): own-row (auth.uid()=user_id) for the
-- learner-owned tables; SELECT-own for ai_usage; read-all for item_bank; SELECT-
-- own for profiles (+ insert/update-own, is_pro server-managed); and claim_tokens
-- is RLS-ON with NO policy => deny-all to clients (guest-claim is service-role /
-- definer only). Live ENABLEs RLS without FORCE, reproduced here.

-- ========================================================================== --
-- item_bank — IRT calibration bank (content; read-all) [R-B8 · R-M3]
-- ========================================================================== --
CREATE TABLE public.item_bank (
    target_locale text NOT NULL,
    item_id       text NOT NULL,
    exercise_type text NOT NULL DEFAULT 'mcq',
    irt_a         double precision NOT NULL DEFAULT 1.0,
    irt_b         double precision NOT NULL DEFAULT 0.0,
    irt_c         double precision NOT NULL DEFAULT 0.0,
    calib_rung    text,
    calib_n       integer NOT NULL DEFAULT 0,
    calibrated_at timestamptz,
    updated_at    timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (target_locale, item_id)
);
ALTER TABLE public.item_bank ENABLE ROW LEVEL SECURITY;
CREATE POLICY item_bank_read ON public.item_bank
    FOR SELECT TO authenticated USING (true);
GRANT SELECT ON public.item_bank TO authenticated;
GRANT DELETE, INSERT, SELECT, UPDATE ON public.item_bank TO service_role;

-- ========================================================================== --
-- learner_theta — per-course ability estimate (own-row) [R-B8 · R-K6 · R-M3]
-- ========================================================================== --
CREATE TABLE public.learner_theta (
    user_id        uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    target_locale  text NOT NULL,
    theta          double precision NOT NULL,
    theta_sd       double precision NOT NULL,
    response_count integer NOT NULL DEFAULT 0,
    updated_at     timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, target_locale)
);
ALTER TABLE public.learner_theta ENABLE ROW LEVEL SECURITY;
CREATE POLICY learner_theta_own ON public.learner_theta
    FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
GRANT DELETE, INSERT, SELECT, UPDATE ON public.learner_theta TO authenticated;
GRANT DELETE, INSERT, SELECT, UPDATE ON public.learner_theta TO service_role;

-- ========================================================================== --
-- ai_usage — per-day AI meter (voice secs / chat msgs); SELECT-own, server-write
-- [R-K6 · R-M3]
-- ========================================================================== --
CREATE TABLE public.ai_usage (
    user_id       uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    day           date NOT NULL,
    voice_seconds integer NOT NULL DEFAULT 0 CONSTRAINT ai_usage_voice_seconds_check CHECK (voice_seconds >= 0),
    chat_msgs     integer NOT NULL DEFAULT 0 CONSTRAINT ai_usage_chat_msgs_check CHECK (chat_msgs >= 0),
    updated_at    timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, day)
);
ALTER TABLE public.ai_usage ENABLE ROW LEVEL SECURITY;
CREATE POLICY ai_usage_select_own ON public.ai_usage
    FOR SELECT TO authenticated USING (auth.uid() = user_id);
GRANT SELECT ON public.ai_usage TO authenticated;
GRANT INSERT, SELECT, UPDATE ON public.ai_usage TO service_role;

-- ========================================================================== --
-- claim_tokens — guest->account claim tokens; RLS-ON, NO policy => server-only
-- [R-K6 · R-M3]
-- ========================================================================== --
CREATE TABLE public.claim_tokens (
    token_hash  text NOT NULL,
    source_uid  uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at  timestamptz NOT NULL DEFAULT now(),
    expires_at  timestamptz NOT NULL,
    consumed_at timestamptz,
    PRIMARY KEY (token_hash)
);
ALTER TABLE public.claim_tokens ENABLE ROW LEVEL SECURITY;
-- (intentionally NO policy: deny-all to authenticated/anon; only service_role /
--  the guest-claim edge function reads or writes this table.)
GRANT DELETE, INSERT, SELECT, UPDATE ON public.claim_tokens TO service_role;

-- ========================================================================== --
-- profiles — auth-linked public identity (handle/display_name/is_pro) [R-I9 · R-K6 · R-L6 · R-M3]
-- ========================================================================== --
CREATE TABLE public.profiles (
    id           uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name text,
    created_at   timestamptz NOT NULL DEFAULT now(),
    updated_at   timestamptz NOT NULL DEFAULT now(),
    handle       text,
    is_pro       boolean NOT NULL DEFAULT false,
    PRIMARY KEY (id),
    CONSTRAINT profiles_handle_format CHECK ((handle IS NULL) OR (handle ~ '^[a-z0-9_]{2,20}$'))
);
CREATE UNIQUE INDEX profiles_handle_lower_key ON public.profiles (lower(handle));
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY profiles_select_own ON public.profiles
    FOR SELECT TO authenticated USING ((SELECT auth.uid()) = id);
CREATE POLICY profiles_insert_own ON public.profiles
    FOR INSERT TO authenticated WITH CHECK ((SELECT auth.uid()) = id);
CREATE POLICY profiles_update_own ON public.profiles
    FOR UPDATE TO authenticated USING ((SELECT auth.uid()) = id) WITH CHECK ((SELECT auth.uid()) = id);
GRANT SELECT ON public.profiles TO authenticated;
GRANT SELECT ON public.profiles TO service_role;

-- is_pro is server-managed: block a logged-in user from self-promoting to Pro.
CREATE OR REPLACE FUNCTION public.prevent_is_pro_self_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if new.is_pro is distinct from old.is_pro
     and current_setting('request.jwt.claims', true) is not null
     and coalesce((current_setting('request.jwt.claims', true)::jsonb)->>'role','') = 'authenticated'
  then
    raise exception 'is_pro is managed server-side';
  end if;
  return new;
end $function$;
CREATE TRIGGER profiles_is_pro_guard BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION prevent_is_pro_self_change();

-- ========================================================================== --
-- saved_words — tap-to-define saved vocab (own-row) [R-L6 · R-K6 · R-M3]
-- ========================================================================== --
CREATE TABLE public.saved_words (
    user_id          uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    course_id        text NOT NULL,
    normalized_lemma text NOT NULL,
    raw_word         text NOT NULL DEFAULT '',
    added_at         timestamptz NOT NULL DEFAULT now(),
    admitted_on      date,
    PRIMARY KEY (user_id, course_id, normalized_lemma)
);
ALTER TABLE public.saved_words ENABLE ROW LEVEL SECURITY;
CREATE POLICY saved_words_own ON public.saved_words
    FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
GRANT DELETE, INSERT, SELECT, UPDATE ON public.saved_words TO authenticated;

-- ========================================================================== --
-- user_adventure_progress — explored scenarios (own-row) [R-L6 · R-K6 · R-M3]
-- ========================================================================== --
CREATE TABLE public.user_adventure_progress (
    user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    scenario_id text NOT NULL,
    explored_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, scenario_id)
);
ALTER TABLE public.user_adventure_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_adventure_progress_own ON public.user_adventure_progress
    FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
GRANT DELETE, INSERT, SELECT, UPDATE ON public.user_adventure_progress TO authenticated;
GRANT ALL ON public.user_adventure_progress TO service_role;

-- ========================================================================== --
-- user_earned_stamps — earned notification/achievement stamps (own-row) [R-I2 · R-K6 · R-M3]
-- ========================================================================== --
CREATE TABLE public.user_earned_stamps (
    user_id         uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    notification_id text NOT NULL,
    earned_at       timestamptz NOT NULL,
    updated_at      timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, notification_id)
);
ALTER TABLE public.user_earned_stamps ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_earned_stamps_own ON public.user_earned_stamps
    FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
GRANT DELETE, INSERT, SELECT, UPDATE ON public.user_earned_stamps TO authenticated;
GRANT ALL ON public.user_earned_stamps TO service_role;

-- ========================================================================== --
-- user_outfits — mascot cosmetics owned/selected (own-row) [R-L6 · R-K6 · R-M3]
-- ========================================================================== --
CREATE TABLE public.user_outfits (
    user_id    uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    owned      text[] NOT NULL DEFAULT '{}'::text[],
    selected   text NOT NULL DEFAULT 'classic',
    updated_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id)
);
ALTER TABLE public.user_outfits ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_outfits_own ON public.user_outfits
    FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
GRANT DELETE, INSERT, SELECT, UPDATE ON public.user_outfits TO authenticated;

-- ========================================================================== --
-- user_progress_daily — per-day XP (streak source) (own-row) [R-I2 · R-K6 · R-M3]
-- ========================================================================== --
CREATE TABLE public.user_progress_daily (
    user_id    uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    day        date NOT NULL,
    xp         integer NOT NULL DEFAULT 0 CONSTRAINT user_progress_daily_xp_check CHECK (xp >= 0),
    updated_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, day)
);
ALTER TABLE public.user_progress_daily ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_progress_daily_own ON public.user_progress_daily
    FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
GRANT DELETE, INSERT, SELECT, UPDATE ON public.user_progress_daily TO authenticated;

-- ========================================================================== --
-- user_settings — per-user app settings (own-row) [R-L6 · R-K6 · R-M3]
-- ========================================================================== --
CREATE TABLE public.user_settings (
    user_id             uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    high_contrast       boolean NOT NULL DEFAULT false,
    sound               boolean NOT NULL DEFAULT true,
    haptics             boolean NOT NULL DEFAULT true,
    daily_goal          integer NOT NULL DEFAULT 20 CONSTRAINT user_settings_daily_goal_check CHECK (daily_goal >= 0),
    theme_mode          text NOT NULL DEFAULT 'system',
    reduce_motion       boolean NOT NULL DEFAULT false,
    display_name        text NOT NULL DEFAULT '',
    world_theme         text NOT NULL DEFAULT 'classic',
    read_notifications  text[] NOT NULL DEFAULT '{}'::text[],
    muted_notifications text[] NOT NULL DEFAULT '{}'::text[],
    recent_searches     text[] NOT NULL DEFAULT '{}'::text[],
    updated_at          timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id)
);
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_settings_own ON public.user_settings
    FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
GRANT DELETE, INSERT, SELECT, UPDATE ON public.user_settings TO authenticated;

-- ========================================================================== --
-- user_study_stats — lifetime accuracy/time (own-row) [R-I2 · R-K6 · R-M3]
-- ========================================================================== --
CREATE TABLE public.user_study_stats (
    user_id       uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    correct       integer NOT NULL DEFAULT 0 CONSTRAINT user_study_stats_correct_check CHECK (correct >= 0),
    total         integer NOT NULL DEFAULT 0,
    study_seconds integer NOT NULL DEFAULT 0 CONSTRAINT user_study_stats_study_seconds_check CHECK (study_seconds >= 0),
    updated_at    timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id),
    CONSTRAINT user_study_stats_check CHECK ((total >= 0) AND (total >= correct))
);
ALTER TABLE public.user_study_stats ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_study_stats_own ON public.user_study_stats
    FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
GRANT DELETE, INSERT, SELECT, UPDATE ON public.user_study_stats TO authenticated;
