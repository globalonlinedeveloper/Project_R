-- [R-I9 · R-L8 · R-K6 · R-M3] Friend Quest — co-op "finish N lessons together" shared state + SECURITY DEFINER RPCs.
-- R-I9 (Social: friends/feed) + R-L8 (Gamification & social screens); R-K6 (RLS/authz); R-M3 (server-derived, anti-inflation).
-- Applied to a DISPOSABLE pgserver only (the live Supabase project is migrated separately, owner-gated apply — like 0011/0012).
-- SHARED-ROW model (NOT own-row like friendship): BOTH creator_id and partner_id may SELECT the row; ALL writes go through
-- the definer RPCs below — a client can never INSERT/UPDATE/DELETE a quest or forge progress. Progress is SERVER-DERIVED from
-- each member's durable user_course.lessons_completed (baseline-diff at create/accept) so neither client can inflate it.

ALTER TABLE "friend_quest" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "friend_quest" FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS friend_quest_member_read ON "friend_quest";
CREATE POLICY friend_quest_member_read ON "friend_quest"
  FOR SELECT TO authenticated
  USING (auth.uid() = creator_id OR auth.uid() = partner_id);
DROP POLICY IF EXISTS friend_quest_service_all ON "friend_quest";
CREATE POLICY friend_quest_service_all ON "friend_quest"
  FOR ALL TO service_role USING (true) WITH CHECK (true);
REVOKE ALL ON "friend_quest" FROM authenticated;
GRANT SELECT ON "friend_quest" TO authenticated;
GRANT ALL ON "friend_quest" TO service_role;

-- durable, server-authoritative lessons counter for a user (summed across courses)
CREATE OR REPLACE FUNCTION public._fq_lessons(p_uid uuid)
RETURNS integer LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $fn$
  SELECT COALESCE(SUM(lessons_completed), 0)::integer FROM public.user_course WHERE user_id = p_uid;
$fn$;

-- client-facing json for a quest row incl. LIVE server-derived progress
CREATE OR REPLACE FUNCTION public._fq_json(q public.friend_quest)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $fn$
DECLARE
  v_cp integer := GREATEST(public._fq_lessons(q.creator_id) - q.creator_baseline, 0);
  v_pp integer := CASE WHEN q.partner_baseline IS NULL THEN 0
                       ELSE GREATEST(public._fq_lessons(q.partner_id) - q.partner_baseline, 0) END;
  v_combined integer := v_cp + v_pp;
BEGIN
  RETURN jsonb_build_object(
    'friend_quest_id', q.friend_quest_id, 'creator_id', q.creator_id, 'partner_id', q.partner_id,
    'goal_lessons', q.goal_lessons, 'status', q.status,
    'creator_progress', v_cp, 'partner_progress', v_pp,
    'combined_progress', LEAST(v_combined, q.goal_lessons), 'done', (v_combined >= q.goal_lessons),
    'created_at', q.created_at, 'completed_at', q.completed_at);
END; $fn$;

-- CREATE: caller invites @partner_handle to a co-op quest (status='pending'); baseline snapshot = caller's lessons now.
CREATE OR REPLACE FUNCTION public.create_friend_quest(partner_handle text, p_goal integer DEFAULT 12)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $fn$
DECLARE
  v_caller uuid := auth.uid();
  v_partner uuid;
  v_goal integer := COALESCE(p_goal, 12);
  q public.friend_quest;
BEGIN
  IF v_caller IS NULL THEN RAISE EXCEPTION 'not authenticated' USING errcode='28000'; END IF;
  IF v_goal < 1 THEN RAISE EXCEPTION 'goal must be >= 1' USING errcode='22023'; END IF;
  SELECT id INTO v_partner FROM public.profiles WHERE handle = lower(partner_handle);
  IF v_partner IS NULL THEN RAISE EXCEPTION 'no such handle' USING errcode='P0002'; END IF;
  IF v_partner = v_caller THEN RAISE EXCEPTION 'cannot quest with yourself' USING errcode='22023'; END IF;
  IF EXISTS (SELECT 1 FROM public.friend_quest WHERE status IN ('pending','active')
               AND ((creator_id=v_caller AND partner_id=v_partner)
                 OR (creator_id=v_partner AND partner_id=v_caller))) THEN
    RAISE EXCEPTION 'a quest with this friend is already active' USING errcode='23505';
  END IF;
  INSERT INTO public.friend_quest(friend_quest_id, creator_id, partner_id, goal_lessons,
      creator_baseline, partner_baseline, status, created_at, updated_at)
    VALUES (gen_random_uuid(), v_caller, v_partner, v_goal, public._fq_lessons(v_caller), NULL, 'pending', now(), now())
    RETURNING * INTO q;
  RETURN public._fq_json(q);
END; $fn$;

-- RESPOND: the invited partner accepts (status='active', partner baseline snapshot) or declines.
CREATE OR REPLACE FUNCTION public.respond_friend_quest(p_quest_id uuid, p_accept boolean)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $fn$
DECLARE
  v_caller uuid := auth.uid();
  q public.friend_quest;
BEGIN
  IF v_caller IS NULL THEN RAISE EXCEPTION 'not authenticated' USING errcode='28000'; END IF;
  SELECT * INTO q FROM public.friend_quest WHERE friend_quest_id = p_quest_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'quest not found' USING errcode='P0002'; END IF;
  IF q.partner_id <> v_caller THEN RAISE EXCEPTION 'not the invited partner' USING errcode='42501'; END IF;
  IF q.status <> 'pending' THEN RAISE EXCEPTION 'quest not pending' USING errcode='22023'; END IF;
  IF p_accept THEN
    UPDATE public.friend_quest SET status='active', partner_baseline=public._fq_lessons(v_caller), updated_at=now()
      WHERE friend_quest_id=p_quest_id RETURNING * INTO q;
  ELSE
    UPDATE public.friend_quest SET status='declined', updated_at=now()
      WHERE friend_quest_id=p_quest_id RETURNING * INTO q;
  END IF;
  RETURN public._fq_json(q);
END; $fn$;

-- REFRESH: recompute live progress; flip to 'completed' when combined lessons since baseline reach the goal.
CREATE OR REPLACE FUNCTION public.refresh_friend_quest(p_quest_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $fn$
DECLARE
  v_caller uuid := auth.uid();
  q public.friend_quest;
  v_combined integer;
BEGIN
  IF v_caller IS NULL THEN RAISE EXCEPTION 'not authenticated' USING errcode='28000'; END IF;
  SELECT * INTO q FROM public.friend_quest WHERE friend_quest_id = p_quest_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'quest not found' USING errcode='P0002'; END IF;
  IF v_caller <> q.creator_id AND v_caller <> q.partner_id THEN RAISE EXCEPTION 'not a quest member' USING errcode='42501'; END IF;
  IF q.status = 'active' THEN
    v_combined := GREATEST(public._fq_lessons(q.creator_id)-q.creator_baseline,0)
                + GREATEST(public._fq_lessons(q.partner_id)-COALESCE(q.partner_baseline,0),0);
    IF v_combined >= q.goal_lessons THEN
      UPDATE public.friend_quest SET status='completed', completed_at=now(), updated_at=now()
        WHERE friend_quest_id=p_quest_id RETURNING * INTO q;
    END IF;
  END IF;
  RETURN public._fq_json(q);
END; $fn$;

-- LIST: the caller's quests (pending/active/completed) with live progress — the client read path.
CREATE OR REPLACE FUNCTION public.list_friend_quests()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $fn$
DECLARE
  v_caller uuid := auth.uid();
  v_arr jsonb := '[]'::jsonb;
  q public.friend_quest;
BEGIN
  IF v_caller IS NULL THEN RAISE EXCEPTION 'not authenticated' USING errcode='28000'; END IF;
  FOR q IN SELECT * FROM public.friend_quest
           WHERE (creator_id=v_caller OR partner_id=v_caller) AND status IN ('pending','active','completed')
           ORDER BY created_at DESC LOOP
    v_arr := v_arr || public._fq_json(q);
  END LOOP;
  RETURN v_arr;
END; $fn$;

REVOKE ALL ON FUNCTION public._fq_lessons(uuid) FROM public;
REVOKE ALL ON FUNCTION public._fq_json(public.friend_quest) FROM public;
REVOKE ALL ON FUNCTION public.create_friend_quest(text, integer) FROM public;
GRANT EXECUTE ON FUNCTION public.create_friend_quest(text, integer) TO authenticated;
REVOKE ALL ON FUNCTION public.respond_friend_quest(uuid, boolean) FROM public;
GRANT EXECUTE ON FUNCTION public.respond_friend_quest(uuid, boolean) TO authenticated;
REVOKE ALL ON FUNCTION public.refresh_friend_quest(uuid) FROM public;
GRANT EXECUTE ON FUNCTION public.refresh_friend_quest(uuid) TO authenticated;
REVOKE ALL ON FUNCTION public.list_friend_quests() FROM public;
GRANT EXECUTE ON FUNCTION public.list_friend_quests() TO authenticated;
