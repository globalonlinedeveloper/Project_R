-- BACKFILL — provenance for a function ALREADY APPLIED to live (Supabase
-- migration history). This file makes schema/sql/ a faithful snapshot of the
-- live project (S164): the function below is byte-for-semantics identical to the
-- live definition captured via read-only introspection. It is NOT a new change
-- to live — re-applying it (CREATE OR REPLACE) is idempotent and safe.
--
-- read_league_cohort() [R-I6 · R-M3] — the ONLY sanctioned cross-user read for
-- the Leagues leaderboard. Own-row RLS on league_member + deny-all on
-- league_cohort correctly forbid a client from SELECTing peers, so this
-- SECURITY DEFINER is the honest peer-read path. It:
--   (a) derives the caller from auth.uid() (never trusts a client-supplied id),
--   (b) finds the caller's most-recent (week_start, tier, cohort_id),
--   (c) LAZILY self-assigns a NULL-cohort caller into an open (<30) cohort for
--       that (tier, week_start) — creating the league_cohort row if none has
--       room — under an advisory lock so concurrent first-reads don't race,
--   (d) returns the cohort's members ranked by weekly_xp desc,
--       exposing the OPAQUE league_member_id as member_id + an is_you flag,
--       but NEVER a co-member's auth.uid()/user_id.
-- A caller with no membership row returns an empty set (honest solo baseline).
-- Contract mirrors the Dart mapping in leagues_controller._memberFrom /
-- SupabaseLeaguesStore.cohortRowsFrom (member_id, display_name, avatar_emoji,
-- weekly_xp, tier, week_start, is_you).
CREATE OR REPLACE FUNCTION public.read_league_cohort()
 RETURNS TABLE(member_id uuid, display_name text, avatar_emoji text, weekly_xp integer, tier text, week_start date, is_you boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_caller uuid := auth.uid();
  v_week   date;
  v_tier   text;
  v_cohort uuid;
begin
  if v_caller is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;

  select lm.week_start, lm.tier, lm.cohort_id
    into v_week, v_tier, v_cohort
    from public.league_member lm
   where lm.user_id = v_caller
   order by lm.week_start desc
   limit 1;

  if v_week is null then
    return;
  end if;

  if v_cohort is null then
    perform pg_advisory_xact_lock(hashtextextended(v_tier || '|' || v_week::text, 0));
    select lm.cohort_id into v_cohort
      from public.league_member lm
     where lm.user_id = v_caller and lm.week_start = v_week;
    if v_cohort is null then
      select c.league_cohort_id into v_cohort
        from public.league_cohort c
       where c.tier = v_tier and c.week_start = v_week
         and (select count(*) from public.league_member m
               where m.cohort_id = c.league_cohort_id) < 30
       order by c.created_at asc
       limit 1;
      if v_cohort is null then
        insert into public.league_cohort (tier, week_start)
          values (v_tier, v_week)
          returning league_cohort_id into v_cohort;
      end if;
      update public.league_member lm
         set cohort_id = v_cohort, updated_at = now()
       where lm.user_id = v_caller and lm.week_start = v_week;
    end if;
  end if;

  return query
    select m.league_member_id,
           m.display_name,
           m.avatar_emoji,
           m.weekly_xp,
           m.tier,
           m.week_start,
           (m.user_id = v_caller) as is_you
      from public.league_member m
     where m.cohort_id = v_cohort
     order by m.weekly_xp desc, m.league_member_id asc;
end;
$function$;

REVOKE ALL ON FUNCTION public.read_league_cohort() FROM public;
GRANT EXECUTE ON FUNCTION public.read_league_cohort() TO authenticated;
