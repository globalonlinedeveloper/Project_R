-- BACKFILL — provenance for a function + cron job ALREADY APPLIED to live
-- (Supabase migration history + pg_cron). This file makes schema/sql/ a faithful
-- snapshot of live (S164); the function below is byte-for-semantics identical to
-- the live definition captured via read-only introspection. Re-applying it
-- (CREATE OR REPLACE) is idempotent; it is NOT a new change to live.
--
-- close_league_week(p_new_week date) [R-I6] — the Monday weekly ROLLOVER that
-- advances tiers using the same rules as the Dart pure engine
-- (lib/services/leagues/leagues.dart LeagueRules.standard: promoteTop 7 /
-- demoteBottom 5 / cohortTarget 30; 10-tier ladder bronze..diamond, clamped).
-- For each cohort of the CLOSED week it ranks members by weekly_xp desc
-- (ties by league_member_id), computes promote/hold/demote, and upserts each
-- member's NEXT-week row (weekly_xp reset to 0, cohort_id NULL) — then forms the
-- new week's cohorts of <= 30 per tier. Idempotent per (user_id, week_start)
-- via ON CONFLICT; advisory-locked per new-week so concurrent runs can't double.
-- SECURITY DEFINER + service-role only (no authenticated grant): clients never
-- close a week; only the scheduled job (below) or an owner-run call does.
CREATE OR REPLACE FUNCTION public.close_league_week(p_new_week date DEFAULT NULL::date)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_ladder   text[] := array['bronze','silver','gold','sapphire','ruby',
                             'emerald','amethyst','pearl','obsidian','diamond'];
  v_promote  int  := 7;   -- LeagueRules.standard.promoteTop
  v_demote   int  := 5;   -- LeagueRules.standard.demoteBottom
  v_cap      int  := 30;  -- LeagueRules.standard.cohortTarget
  v_new_week date := coalesce(p_new_week, date_trunc('week', current_date)::date);
  v_closed   date := v_new_week - 7;
  v_rows     int  := 0;
  v_cohorts  int  := 0;
  v_tier     text;
  v_cohort   uuid;
begin
  perform pg_advisory_xact_lock(hashtextextended('league_close|' || v_new_week::text, 0));

  insert into public.league_member
        (user_id, week_start, tier, weekly_xp, display_name, avatar_emoji, cohort_id)
  select c.user_id,
         v_new_week,
         v_ladder[ case
                     when c.rnk <= v_promote       then least(c.idx + 1, array_length(v_ladder, 1))
                     when c.rnk >  c.sz - v_demote then greatest(c.idx - 1, 1)
                     else c.idx
                   end ],
         0,
         c.display_name,
         c.avatar_emoji,
         null
    from (
      select m.user_id, m.display_name, m.avatar_emoji,
             coalesce(array_position(v_ladder, m.tier), 1) as idx,
             row_number() over (
               partition by coalesce(m.cohort_id::text, m.league_member_id::text)
               order by m.weekly_xp desc, m.league_member_id asc) as rnk,
             count(*) over (
               partition by coalesce(m.cohort_id::text, m.league_member_id::text)) as sz
        from public.league_member m
       where m.week_start = v_closed
    ) c
  on conflict (user_id, week_start) do update
        set tier = excluded.tier, updated_at = now();
  get diagnostics v_rows = row_count;

  for v_tier in
      select distinct tier
        from public.league_member
       where week_start = v_new_week and cohort_id is null
  loop
    loop
      insert into public.league_cohort (tier, week_start)
        values (v_tier, v_new_week)
        returning league_cohort_id into v_cohort;
      v_cohorts := v_cohorts + 1;
      update public.league_member
         set cohort_id = v_cohort, updated_at = now()
       where league_member_id in (
             select league_member_id
               from public.league_member
              where week_start = v_new_week and cohort_id is null and tier = v_tier
              order by league_member_id
              limit v_cap);
      exit when not exists (
        select 1 from public.league_member
         where week_start = v_new_week and cohort_id is null and tier = v_tier);
    end loop;
  end loop;

  return jsonb_build_object(
    'new_week',         v_new_week,
    'closed_week',      v_closed,
    'members_advanced', v_rows,
    'cohorts_formed',   v_cohorts);
end;
$function$;

REVOKE ALL ON FUNCTION public.close_league_week(date) FROM public;

-- SCHEDULER (pg_cron) — live provenance, applied out-of-band (pg_cron is a
-- Supabase extension, not present on the disposable CI pgserver, so this is
-- documented rather than executed here). The live job:
--   jobid 8  name 'ratel-league-weekly-close'  schedule '0 0 * * 1' (Mon 00:00 UTC)
--   command: select public.close_league_week();
-- Equivalent registration (run once, service-role / dashboard):
--   select cron.schedule('ratel-league-weekly-close', '0 0 * * 1',
--                         $$select public.close_league_week();$$);
