# [R-I9 · R-L8 · R-K6 · R-M3] Provenance + behaviour tests for schema/sql/0013_friend_quest.sql —
# the co-op "finish N lessons together" friend-quest: a SHARED (both-member-readable) friend_quest
# row + SECURITY DEFINER RPCs (create/respond/refresh/list). Runs on a DISPOSABLE pgserver; the live
# Supabase project is NEVER touched. auth.uid() is shimmed by the harness (request.jwt.claim.sub GUC).
#
# 0001 is STRUCTURE-ONLY (no column defaults); the RPCs supply gen_random_uuid()/now() explicitly, so
# only user_course needs a few defaults re-declared (below). `profiles` (handle->id) is auth-linked and
# absent from 0001 -> a minimal shim. friend_quest.creator_id/partner_id REFERENCE "user"(user_id), so
# every seeded person needs both a "user" row and a matching-id "profiles" row (see _person). Progress is
# SERVER-DERIVED from user_course.lessons_completed (durable counter) so neither client can inflate it.
import json
import pathlib
import sys
import tempfile
import uuid as uuidlib

import pytest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import rls_harness  # noqa: E402

FQ_PREAMBLE = """
CREATE TABLE IF NOT EXISTS public.profiles (
  id           uuid PRIMARY KEY,
  handle       text,
  display_name text,
  is_pro       boolean NOT NULL DEFAULT false,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS profiles_handle_lower_key
  ON public.profiles (lower(handle));
ALTER TABLE public.user_course ALTER COLUMN user_course_id SET DEFAULT gen_random_uuid();
ALTER TABLE public.user_course ALTER COLUMN created_at     SET DEFAULT now();
ALTER TABLE public.user_course ALTER COLUMN updated_at     SET DEFAULT now();
GRANT USAGE ON SCHEMA public TO authenticated, anon;
"""


@pytest.fixture()
def h():
    pgserver = rls_harness.require_pgserver()
    d = tempfile.mkdtemp(prefix="ratel_fq_")
    harness = rls_harness.Harness(
        pgserver, d, ["0013_friend_quest.sql"], extra_preamble=FQ_PREAMBLE)
    yield harness
    harness.cleanup()


def _uid():
    return str(uuidlib.uuid4())


def _j(v):
    return v if isinstance(v, (dict, list)) else json.loads(v)


def _person(cur, uid, handle, name=None):
    cur.execute('INSERT INTO "user"(user_id,created_at,updated_at) '
                'VALUES (%s::uuid,now(),now())', (uid,))
    cur.execute('INSERT INTO public.profiles(id,handle,display_name) '
                'VALUES (%s::uuid,%s,%s)', (uid, handle, name))


def _course(cur, uid, lessons, loc='es'):
    cur.execute('INSERT INTO user_course(user_id,target_locale,lessons_completed) '
                'VALUES (%s::uuid,%s,%s)', (uid, loc, lessons))


def _bump(cur, uid, lessons, loc='es'):
    cur.execute('UPDATE user_course SET lessons_completed=%s '
                'WHERE user_id=%s::uuid AND target_locale=%s', (lessons, uid, loc))


def _mk_pair(h, creator_lessons=0, partner_lessons=0):
    a = _uid(); b = _uid()
    with h.session() as cur:
        _person(cur, a, 'alice', 'Alice'); _person(cur, b, 'bob', 'Bob')
        _course(cur, a, creator_lessons); _course(cur, b, partner_lessons)
    return a, b


# ---- create -----------------------------------------------------------------

def test_create_is_pending_with_zero_progress(h):
    a, b = _mk_pair(h, creator_lessons=5)          # 5 prior lessons => baseline 5
    with h.session(role='authenticated', sub=a) as cur:
        cur.execute("SELECT create_friend_quest('bob', 12)")
        q = _j(cur.fetchone()[0])
    assert q['status'] == 'pending'
    assert q['goal_lessons'] == 12
    assert q['creator_progress'] == 0 and q['partner_progress'] == 0   # prior lessons don't count
    assert q['done'] is False
    assert str(q['creator_id']) == a and str(q['partner_id']) == b


def test_create_unauth_self_unknown_and_duplicate(h):
    a, b = _mk_pair(h)
    # unauthenticated
    with h.session() as cur:
        with pytest.raises(h.Error) as ei:
            cur.execute("SELECT create_friend_quest('bob', 12)")
    assert 'not authenticated' in str(ei.value).lower()
    # self
    with h.session(role='authenticated', sub=a) as cur:
        with pytest.raises(h.Error) as ei:
            cur.execute("SELECT create_friend_quest('alice', 12)")
    assert 'yourself' in str(ei.value).lower()
    # unknown handle
    with h.session(role='authenticated', sub=a) as cur:
        with pytest.raises(h.Error) as ei:
            cur.execute("SELECT create_friend_quest('ghost', 12)")
    assert 'no such handle' in str(ei.value).lower()
    # duplicate active/pending
    with h.session(role='authenticated', sub=a) as cur:
        cur.execute("SELECT create_friend_quest('bob', 12)")
    with h.session(role='authenticated', sub=a) as cur:
        with pytest.raises(h.Error) as ei:
            cur.execute("SELECT create_friend_quest('bob', 12)")
    assert 'already active' in str(ei.value).lower()


# ---- respond ----------------------------------------------------------------

def _create(h, a):
    with h.session(role='authenticated', sub=a) as cur:
        cur.execute("SELECT create_friend_quest('bob', 12)")
        return _j(cur.fetchone()[0])['friend_quest_id']


def test_accept_activates_and_snapshots_partner_baseline(h):
    a, b = _mk_pair(h, partner_lessons=2)          # partner has 2 prior lessons
    qid = _create(h, a)
    with h.session(role='authenticated', sub=b) as cur:
        cur.execute("SELECT respond_friend_quest(%s::uuid, true)", (qid,))
        q = _j(cur.fetchone()[0])
    assert q['status'] == 'active' and q['partner_progress'] == 0   # baseline 2 => 0 counted so far


def test_decline_sets_declined(h):
    a, b = _mk_pair(h)
    qid = _create(h, a)
    with h.session(role='authenticated', sub=b) as cur:
        cur.execute("SELECT respond_friend_quest(%s::uuid, false)", (qid,))
        q = _j(cur.fetchone()[0])
    assert q['status'] == 'declined'


def test_respond_non_partner_and_non_pending_raise(h):
    a, b = _mk_pair(h)
    c = _uid()
    with h.session() as cur:
        _person(cur, c, 'carol', 'Carol'); _course(cur, c, 0)
    qid = _create(h, a)
    # a stranger cannot respond
    with h.session(role='authenticated', sub=c) as cur:
        with pytest.raises(h.Error) as ei:
            cur.execute("SELECT respond_friend_quest(%s::uuid, true)", (qid,))
    assert 'not the invited partner' in str(ei.value).lower()
    # once accepted, cannot respond again
    with h.session(role='authenticated', sub=b) as cur:
        cur.execute("SELECT respond_friend_quest(%s::uuid, true)", (qid,))
    with h.session(role='authenticated', sub=b) as cur:
        with pytest.raises(h.Error) as ei:
            cur.execute("SELECT respond_friend_quest(%s::uuid, true)", (qid,))
    assert 'not pending' in str(ei.value).lower()


# ---- progress derivation + completion --------------------------------------

def test_progress_is_server_derived_baseline_diff(h):
    a, b = _mk_pair(h, creator_lessons=5, partner_lessons=2)
    qid = _create(h, a)
    with h.session(role='authenticated', sub=b) as cur:
        cur.execute("SELECT respond_friend_quest(%s::uuid, true)", (qid,))
    with h.session() as cur:                         # each does more real lessons
        _bump(cur, a, 8)                             # +3 since baseline 5
        _bump(cur, b, 6)                             # +4 since baseline 2
    with h.session(role='authenticated', sub=a) as cur:
        cur.execute("SELECT refresh_friend_quest(%s::uuid)", (qid,))
        q = _j(cur.fetchone()[0])
    assert q['creator_progress'] == 3 and q['partner_progress'] == 4


def test_completes_when_combined_reaches_goal(h):
    a, b = _mk_pair(h, creator_lessons=0, partner_lessons=0)
    with h.session(role='authenticated', sub=a) as cur:
        cur.execute("SELECT create_friend_quest('bob', 5)")     # small goal
        qid = _j(cur.fetchone()[0])['friend_quest_id']
    with h.session(role='authenticated', sub=b) as cur:
        cur.execute("SELECT respond_friend_quest(%s::uuid, true)", (qid,))
    with h.session() as cur:
        _bump(cur, a, 3); _bump(cur, b, 4)          # combined 7 >= 5
    with h.session(role='authenticated', sub=b) as cur:
        cur.execute("SELECT refresh_friend_quest(%s::uuid)", (qid,))
        q = _j(cur.fetchone()[0])
    assert q['status'] == 'completed' and q['done'] is True
    assert q['completed_at'] is not None
    assert q['combined_progress'] == 5              # clamped to goal


def test_refresh_non_member_raises(h):
    a, b = _mk_pair(h)
    c = _uid()
    with h.session() as cur:
        _person(cur, c, 'carol', 'Carol'); _course(cur, c, 0)
    qid = _create(h, a)
    with h.session(role='authenticated', sub=c) as cur:
        with pytest.raises(h.Error) as ei:
            cur.execute("SELECT refresh_friend_quest(%s::uuid)", (qid,))
    assert 'not a quest member' in str(ei.value).lower()


# ---- RLS: shared-row read for members only ---------------------------------

def test_rls_both_members_read_stranger_denied(h):
    a, b = _mk_pair(h)
    c = _uid()
    with h.session() as cur:
        _person(cur, c, 'carol', 'Carol'); _course(cur, c, 0)
    _create(h, a)
    for who in (a, b):
        with h.session(role='authenticated', sub=who) as cur:
            cur.execute("SELECT count(*) FROM friend_quest")
            assert cur.fetchone()[0] == 1           # creator + partner both see it
    with h.session(role='authenticated', sub=c) as cur:
        cur.execute("SELECT count(*) FROM friend_quest")
        assert cur.fetchone()[0] == 0               # stranger sees nothing (RLS)


def test_client_cannot_write_directly(h):
    a, b = _mk_pair(h)
    with h.session(role='authenticated', sub=a) as cur:
        with pytest.raises(h.Error) as ei:
            cur.execute("INSERT INTO friend_quest(friend_quest_id,creator_id,partner_id,"
                        "goal_lessons,creator_baseline,status,created_at,updated_at) "
                        "VALUES (gen_random_uuid(),%s::uuid,%s::uuid,12,0,'active',now(),now())",
                        (a, b))
    assert 'permission denied' in str(ei.value).lower()   # only SELECT granted; writes via RPC


def test_list_returns_callers_quests(h):
    a, b = _mk_pair(h)
    _create(h, a)
    with h.session(role='authenticated', sub=b) as cur:
        cur.execute("SELECT list_friend_quests()")
        arr = _j(cur.fetchone()[0])
    assert isinstance(arr, list) and len(arr) == 1 and arr[0]['status'] == 'pending'


# ---- grants -----------------------------------------------------------------

def test_grants_authenticated_only_anon_denied(h):
    _mk_pair(h)
    with h.session(role='anon') as cur:
        with pytest.raises(h.Error) as ei:
            cur.execute("SELECT create_friend_quest('bob', 12)")
    assert 'permission denied' in str(ei.value).lower()
