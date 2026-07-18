-- BACKFILL — provenance for the FRIENDS social RPC surface, ALL FIVE functions
-- ALREADY APPLIED to live (Supabase migration history). This file makes
-- schema/sql/ a faithful snapshot of live (S165): every function below is
-- byte-for-semantics identical to the live definition captured via read-only
-- introspection (pg_get_functiondef). It is NOT a new change to live —
-- re-applying it (CREATE OR REPLACE) is idempotent and safe.
--
-- Live provenance (supabase_migrations.schema_migrations):
--   20260630143806 friend_delivery_handle_and_rpcs  -> send_friend_request
--                                                       + respond_to_friend_request
--   20260630154621 remove_friend_rpc                -> remove_friend
--   20260630165645 emit_friend_activity_producer    -> emit_friend_activity
--   20260630175721 publish_weekly_xp_producer       -> publish_weekly_xp
--
-- WHY SECURITY DEFINER [R-I9 / R-L8 / R-M3 / R-K6]: own-row RLS on `friendship`
-- and `friend_activity` (deny cross-user writes) is correct, so writing the
-- COUNTERPARTY's half of a friendship / another user's activity feed requires a
-- postgres-owned definer that resolves @handle -> uid via `profiles` (the same
-- pattern as the project's `handle_new_user`). These are the ONLY privilege
-- surface for friends; every other friends read/write stays own-row RLS.
-- Contract mirrors the Dart client SupabaseFriendsService (send/respond/remove
-- return {status,handle} jsonb; emit/publish return an integer inserted-row
-- count). `profiles` is the auth-linked table (id -> auth.users) owned by the
-- `auth_profiles_and_handle_new_user` migration; it is deliberately NOT part of
-- schema/tables/*.schema.json (no app-data SoT), so it is not in 0001 — the DB
-- provenance test re-creates a minimal `profiles` shim in its preamble.
--
-- Grants captured from live (proacl = postgres=X | authenticated=X; PUBLIC
-- revoked): EXECUTE is granted to `authenticated` only — a signed-in caller's
-- auth.uid() authorizes every mutation; anon/public cannot execute.

-- ===========================================================================
-- 1) send_friend_request(target_handle) -> jsonb {status, handle}
--    Resolves @handle -> uid, writes BOTH sides. Mutual-pending auto-accepts
--    (their prior requestOutgoing + my new send => friends). Idempotent on the
--    (user_id, friend_id) unique key; honest errors for missing-own-handle,
--    unknown target, self, and blocked.
-- ===========================================================================
CREATE OR REPLACE FUNCTION public.send_friend_request(target_handle text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_caller      uuid := auth.uid();
  v_norm        text := lower(regexp_replace(coalesce(target_handle, ''), '^@+', ''));
  v_my_handle   text;
  v_my_name     text;
  v_target_id   uuid;
  v_target_name text;
  v_mine        text;
  v_theirs      text;
begin
  if v_caller is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;
  if v_norm !~ '^[a-z0-9_]{2,20}$' then
    raise exception 'invalid handle' using errcode = '22023';
  end if;

  select handle, display_name into v_my_handle, v_my_name
    from public.profiles where id = v_caller;
  if v_my_handle is null then
    raise exception 'set your own @handle first' using errcode = 'P0001';
  end if;

  select id, display_name into v_target_id, v_target_name
    from public.profiles where lower(handle) = v_norm;
  if v_target_id is null then
    raise exception 'no user with that handle' using errcode = 'P0002';
  end if;
  if v_target_id = v_caller then
    raise exception 'cannot add yourself' using errcode = 'P0003';
  end if;

  select status into v_mine
    from public.friendship where user_id = v_caller and friend_id = v_norm;
  select status into v_theirs
    from public.friendship where user_id = v_target_id and friend_id = v_my_handle;

  if v_mine = 'blocked' then
    raise exception 'unblock first' using errcode = 'P0004';
  end if;
  if v_mine = 'friends' then
    return jsonb_build_object('status', 'friends', 'handle', v_norm);
  end if;

  if v_theirs = 'requestOutgoing' then
    insert into public.friendship (user_id, friend_id, handle, display_name, status)
      values (v_caller, v_norm, v_norm, coalesce(v_target_name, '@' || v_norm), 'friends')
      on conflict (user_id, friend_id)
        do update set status = 'friends',
                      display_name = coalesce(v_target_name, '@' || v_norm),
                      updated_at = now();
    update public.friendship set status = 'friends', updated_at = now()
      where user_id = v_target_id and friend_id = v_my_handle;
    return jsonb_build_object('status', 'friends', 'handle', v_norm);
  end if;

  insert into public.friendship (user_id, friend_id, handle, display_name, status)
    values (v_caller, v_norm, v_norm, '@' || v_norm, 'requestOutgoing')
    on conflict (user_id, friend_id)
      do update set status = 'requestOutgoing', updated_at = now();

  if v_theirs is distinct from 'blocked' then
    insert into public.friendship (user_id, friend_id, handle, display_name, status)
      values (v_target_id, v_my_handle, v_my_handle,
              coalesce(v_my_name, '@' || v_my_handle), 'requestIncoming')
      on conflict (user_id, friend_id) do nothing;
  end if;

  return jsonb_build_object('status', 'requestOutgoing', 'handle', v_norm);
end;
$function$;

REVOKE ALL ON FUNCTION public.send_friend_request(text) FROM public;
GRANT EXECUTE ON FUNCTION public.send_friend_request(text) TO authenticated;

-- ===========================================================================
-- 2) respond_to_friend_request(requester_handle, accept) -> jsonb {status,handle}
--    Only a genuine 'requestIncoming' can be answered. Accept => both sides
--    'friends'; decline => both sides cleared.
-- ===========================================================================
CREATE OR REPLACE FUNCTION public.respond_to_friend_request(requester_handle text, accept boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_caller    uuid := auth.uid();
  v_norm      text := lower(regexp_replace(coalesce(requester_handle, ''), '^@+', ''));
  v_my_handle text;
  v_my_name   text;
  v_req_id    uuid;
  v_mine      text;
begin
  if v_caller is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;
  if v_norm !~ '^[a-z0-9_]{2,20}$' then
    raise exception 'invalid handle' using errcode = '22023';
  end if;

  select handle, display_name into v_my_handle, v_my_name
    from public.profiles where id = v_caller;
  if v_my_handle is null then
    raise exception 'set your own @handle first' using errcode = 'P0001';
  end if;

  select status into v_mine
    from public.friendship where user_id = v_caller and friend_id = v_norm;
  if v_mine is distinct from 'requestIncoming' then
    raise exception 'no pending request from that handle' using errcode = 'P0002';
  end if;

  select id into v_req_id from public.profiles where lower(handle) = v_norm;

  if accept then
    update public.friendship set status = 'friends', updated_at = now()
      where user_id = v_caller and friend_id = v_norm;
    if v_req_id is not null then
      update public.friendship
        set status = 'friends',
            display_name = coalesce(v_my_name, '@' || v_my_handle),
            updated_at = now()
        where user_id = v_req_id and friend_id = v_my_handle;
    end if;
    return jsonb_build_object('status', 'friends', 'handle', v_norm);
  else
    delete from public.friendship where user_id = v_caller and friend_id = v_norm;
    if v_req_id is not null then
      delete from public.friendship where user_id = v_req_id and friend_id = v_my_handle;
    end if;
    return jsonb_build_object('status', 'none', 'handle', v_norm);
  end if;
end;
$function$;

REVOKE ALL ON FUNCTION public.respond_to_friend_request(text, boolean) FROM public;
GRANT EXECUTE ON FUNCTION public.respond_to_friend_request(text, boolean) TO authenticated;

-- ===========================================================================
-- 3) remove_friend(other_handle, block) -> jsonb {status, handle}
--    Two-sided delete of the friendship. When block=true, additionally leaves
--    the caller's own 'blocked' bookkeeping row (counterparty row still cleared).
-- ===========================================================================
CREATE OR REPLACE FUNCTION public.remove_friend(other_handle text, block boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_caller    uuid := auth.uid();
  v_norm      text := lower(regexp_replace(coalesce(other_handle, ''), '^@+', ''));
  v_my_handle text;
  v_other_id  uuid;
begin
  if v_caller is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;
  if v_norm !~ '^[a-z0-9_]{2,20}$' then
    raise exception 'invalid handle' using errcode = '22023';
  end if;

  select handle into v_my_handle
    from public.profiles where id = v_caller;
  if v_my_handle is null then
    raise exception 'set your own @handle first' using errcode = 'P0001';
  end if;

  select id into v_other_id from public.profiles where lower(handle) = v_norm;
  if v_other_id = v_caller then
    raise exception 'cannot remove yourself' using errcode = 'P0003';
  end if;

  delete from public.friendship where user_id = v_caller and friend_id = v_norm;
  if v_other_id is not null then
    delete from public.friendship where user_id = v_other_id and friend_id = v_my_handle;
  end if;

  if block then
    insert into public.friendship (user_id, friend_id, handle, display_name, status)
      values (v_caller, v_norm, v_norm, '@' || v_norm, 'blocked')
      on conflict (user_id, friend_id)
        do update set status = 'blocked', updated_at = now();
    return jsonb_build_object('status', 'blocked', 'handle', v_norm);
  end if;

  return jsonb_build_object('status', 'none', 'handle', v_norm);
end;
$function$;

REVOKE ALL ON FUNCTION public.remove_friend(text, boolean) FROM public;
GRANT EXECUTE ON FUNCTION public.remove_friend(text, boolean) TO authenticated;

-- ===========================================================================
-- 4) emit_friend_activity(activity_type, summary, targets) -> integer rows
--    Inserts one activity-feed row into each 'friends' counterparty's feed
--    (optionally filtered to `targets`). Validates the activity type, requires
--    the caller to have a handle, and dedups the same (actor,type,summary)
--    within a 12h window. Returns the number of rows inserted (0 is honest).
-- ===========================================================================
CREATE OR REPLACE FUNCTION public.emit_friend_activity(activity_type text, summary text DEFAULT ''::text, targets text[] DEFAULT NULL::text[])
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_caller    uuid := auth.uid();
  v_my_handle text;
  v_my_name   text;
  v_summary   text := left(coalesce(summary, ''), 280);
  v_targets   text[];
  v_count     integer;
begin
  if v_caller is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;

  if activity_type not in
       ('joined','lessonsCompleted','leveledUp','streak','passedYouInLeague') then
    raise exception 'invalid activity type' using errcode = '22023';
  end if;

  select handle, display_name into v_my_handle, v_my_name
    from public.profiles where id = v_caller;

  if v_my_handle is null then
    return 0;
  end if;

  if targets is not null then
    select array_agg(distinct n) into v_targets
      from (
        select lower(regexp_replace(t, '^@+', '')) as n
          from unnest(targets) as t
         where t is not null
      ) s
     where n ~ '^[a-z0-9_]{2,20}$';
    if v_targets is null then
      return 0;
    end if;
  end if;

  insert into public.friend_activity
    (user_id, actor_id, actor_handle, actor_name, type, summary, at)
  select p.id,
         v_my_handle,
         v_my_handle,
         coalesce(v_my_name, '@' || v_my_handle),
         activity_type,
         v_summary,
         now()
    from public.friendship f
    join public.profiles  p on lower(p.handle) = f.friend_id
   where f.user_id = v_caller
     and f.status  = 'friends'
     and (v_targets is null or f.friend_id = any (v_targets))
     and not exists (
       select 1 from public.friend_activity fa
        where fa.user_id    = p.id
          and fa.actor_id   = v_my_handle
          and fa.type       = activity_type
          and fa.summary    is not distinct from v_summary
          and fa.created_at > now() - interval '12 hours'
     );

  get diagnostics v_count = row_count;
  return v_count;
end;
$function$;

REVOKE ALL ON FUNCTION public.emit_friend_activity(text, text, text[]) FROM public;
GRANT EXECUTE ON FUNCTION public.emit_friend_activity(text, text, text[]) TO authenticated;

-- ===========================================================================
-- 5) publish_weekly_xp(p_weekly_xp) -> integer rows
--    Mirrors the caller's weekly league XP into friends' own-row
--    friendship.weekly_xp, and emits a 'passedYouInLeague' activity to any
--    friend the caller just overtook (old <= their_xp < new). XP clamped to
--    [0, 1_000_000]; dedup 12h. Returns the passed-you rows inserted.
-- ===========================================================================
CREATE OR REPLACE FUNCTION public.publish_weekly_xp(p_weekly_xp integer)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_caller    uuid    := auth.uid();
  v_my_handle text;
  v_my_name   text;
  v_new       integer := greatest(0, least(coalesce(p_weekly_xp, 0), 1000000));
  v_old       integer;
  v_count     integer := 0;
begin
  if v_caller is null then
    raise exception 'not authenticated' using errcode = '28000';
  end if;

  select handle, display_name into v_my_handle, v_my_name
    from public.profiles where id = v_caller;

  if v_my_handle is null then
    return 0;
  end if;

  select coalesce(max(weekly_xp), 0) into v_old
    from public.friendship
   where friend_id = v_my_handle and status = 'friends';

  if v_new > v_old then
    insert into public.friend_activity
      (user_id, actor_id, actor_handle, actor_name, type, summary, at)
    select p.id,
           v_my_handle,
           v_my_handle,
           coalesce(v_my_name, '@' || v_my_handle),
           'passedYouInLeague',
           'passed you this week',
           now()
      from public.friendship f
      join public.profiles  p on lower(p.handle) = f.friend_id
     where f.user_id   = v_caller
       and f.status    = 'friends'
       and f.weekly_xp >= v_old
       and f.weekly_xp <  v_new
       and f.weekly_xp >  0
       and not exists (
         select 1 from public.friend_activity fa
          where fa.user_id   = p.id
            and fa.actor_id   = v_my_handle
            and fa.type       = 'passedYouInLeague'
            and fa.created_at > now() - interval '12 hours'
       );
    get diagnostics v_count = row_count;
  end if;

  update public.friendship
     set weekly_xp = v_new, updated_at = now()
   where friend_id = v_my_handle and status = 'friends';

  return v_count;
end;
$function$;

REVOKE ALL ON FUNCTION public.publish_weekly_xp(integer) FROM public;
GRANT EXECUTE ON FUNCTION public.publish_weekly_xp(integer) TO authenticated;
