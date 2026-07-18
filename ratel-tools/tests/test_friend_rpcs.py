# BACKFILL — provenance tests for schema/sql/0011_friend_rpcs.sql (the five
# friends social RPCs: send_friend_request, respond_to_friend_request,
# remove_friend, emit_friend_activity, publish_weekly_xp). All five are ALREADY
# LIVE (S165, applied direct to Supabase across four migrations); these tests
# pin their behaviour on a DISPOSABLE pgserver so the repo snapshot is
# verifiable + regression-guarded. The live Supabase project is NEVER touched.
# auth.uid() is shimmed by the harness (request.jwt.claim.sub GUC).
#
# 0001 is STRUCTURE-ONLY (no column defaults); the live friendship/friend_activity
# tables carry gen_random_uuid()/now()/0 defaults the RPCs depend on, re-declared
# via extra_preamble. `profiles` is the auth-linked handle table (id -> auth.users),
# deliberately NOT in schema/tables/*.schema.json, so it is absent from 0001 — the
# preamble creates a minimal shim (no auth.users FK; the pgserver has no auth
# tables). friendship/friend_activity.user_id REFERENCE "user"(user_id), and the
# RPCs also insert on the COUNTERPARTY's behalf, so every seeded person needs both
# a "user" row and a matching-id "profiles" row.
import json
import pathlib
import sys
import tempfile
import uuid as uuidlib

import pytest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import rls_harness  # noqa: E402

FRIENDS_PREAMBLE = """
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
ALTER TABLE public.friendship      ALTER COLUMN friendship_id      SET DEFAULT gen_random_uuid();
ALTER TABLE public.friendship      ALTER COLUMN weekly_xp          SET DEFAULT 0;
ALTER TABLE public.friendship      ALTER COLUMN created_at         SET DEFAULT now();
ALTER TABLE public.friendship      ALTER COLUMN updated_at         SET DEFAULT now();
ALTER TABLE public.friend_activity ALTER COLUMN friend_activity_id SET DEFAULT gen_random_uuid();
ALTER TABLE public.friend_activity ALTER COLUMN created_at         SET DEFAULT now();
GRANT USAGE ON SCHEMA public TO authenticated, anon;
"""


@pytest.fixture()
def h():
    pgserver = rls_harness.require_pgserver()
    d = tempfile.mkdtemp(prefix="ratel_friends_")
    harness = rls_harness.Harness(
        pgserver, d, ["0011_friend_rpcs.sql"], extra_preamble=FRIENDS_PREAMBLE)
    yield harness
    harness.cleanup()


def _uid():
    return str(uuidlib.uuid4())


def _j(v):
    return v if isinstance(v, dict) else json.loads(v)


def _person(cur, uid, handle, name=None):
    cur.execute('INSERT INTO "user"(user_id,created_at,updated_at) '
                'VALUES (%s::uuid,now(),now())', (uid,))
    cur.execute('INSERT INTO public.profiles(id,handle,display_name) '
                'VALUES (%s::uuid,%s,%s)', (uid, handle, name))


def _no_handle_user(cur, uid):
    cur.execute('INSERT INTO "user"(user_id,created_at,updated_at) '
                'VALUES (%s::uuid,now(),now())', (uid,))
    cur.execute('INSERT INTO public.profiles(id,handle) VALUES (%s::uuid,NULL)', (uid,))


def _friendship(cur, user_id, friend_id, status, weekly_xp=0, name=None):
    cur.execute(
        'INSERT INTO friendship(user_id,friend_id,handle,display_name,status,weekly_xp) '
        'VALUES (%s::uuid,%s,%s,%s,%s,%s)',
        (user_id, friend_id, friend_id, name, status, weekly_xp))


def _status(cur, user_id, friend_id):
    cur.execute('SELECT status FROM friendship WHERE user_id=%s::uuid AND friend_id=%s',
                (user_id, friend_id))
    r = cur.fetchone()
    return r[0] if r else None


# ---- send_friend_request ----------------------------------------------------

def test_send_creates_two_sided_pending(h):
    a = _uid(); b = _uid()
    with h.session() as cur:
        _person(cur, a, 'alice', 'Alice'); _person(cur, b, 'bob', 'Bob')
    with h.session(role='authenticated', sub=a) as cur:
        cur.execute("SELECT send_friend_request('bob')")
        res = _j(cur.fetchone()[0])
    assert res['status'] == 'requestOutgoing' and res['handle'] == 'bob'
    with h.session() as cur:                     # the definer wrote BOTH sides
        assert _status(cur, a, 'bob') == 'requestOutgoing'
        assert _status(cur, b, 'alice') == 'requestIncoming'


def test_send_mutual_pending_auto_accepts(h):
    a = _uid(); b = _uid()
    with h.session() as cur:
        _person(cur, a, 'alice', 'Alice'); _person(cur, b, 'bob', 'Bob')
    with h.session(role='authenticated', sub=a) as cur:
        cur.execute("SELECT send_friend_request('bob')")      # a -> b (pending)
    with h.session(role='authenticated', sub=b) as cur:
        cur.execute("SELECT send_friend_request('alice')")    # b -> a completes
        res = _j(cur.fetchone()[0])
    assert res['status'] == 'friends'
    with h.session() as cur:
        assert _status(cur, a, 'bob') == 'friends'
        assert _status(cur, b, 'alice') == 'friends'


def test_send_requires_own_handle(h):
    a = _uid(); b = _uid()
    with h.session() as cur:
        _no_handle_user(cur, a); _person(cur, b, 'bob', 'Bob')
    with h.session(role='authenticated', sub=a) as cur:
        with pytest.raises(h.Error) as ei:
            cur.execute("SELECT send_friend_request('bob')")
    assert 'set your own' in str(ei.value).lower()


def test_send_unknown_target_not_found(h):
    a = _uid()
    with h.session() as cur:
        _person(cur, a, 'alice', 'Alice')
    with h.session(role='authenticated', sub=a) as cur:
        with pytest.raises(h.Error) as ei:
            cur.execute("SELECT send_friend_request('ghost')")
    assert 'no user with that handle' in str(ei.value).lower()


def test_send_cannot_add_yourself(h):
    a = _uid()
    with h.session() as cur:
        _person(cur, a, 'alice', 'Alice')
    with h.session(role='authenticated', sub=a) as cur:
        with pytest.raises(h.Error) as ei:
            cur.execute("SELECT send_friend_request('alice')")
    assert 'cannot add yourself' in str(ei.value).lower()


# ---- respond_to_friend_request ---------------------------------------------

def test_respond_accept_makes_both_friends(h):
    a = _uid(); b = _uid()
    with h.session() as cur:
        _person(cur, a, 'alice', 'Alice'); _person(cur, b, 'bob', 'Bob')
    with h.session(role='authenticated', sub=a) as cur:
        cur.execute("SELECT send_friend_request('bob')")      # b now has requestIncoming
    with h.session(role='authenticated', sub=b) as cur:
        cur.execute("SELECT respond_to_friend_request('alice', true)")
        res = _j(cur.fetchone()[0])
    assert res['status'] == 'friends'
    with h.session() as cur:
        assert _status(cur, b, 'alice') == 'friends'
        assert _status(cur, a, 'bob') == 'friends'


def test_respond_decline_clears_both(h):
    a = _uid(); b = _uid()
    with h.session() as cur:
        _person(cur, a, 'alice', 'Alice'); _person(cur, b, 'bob', 'Bob')
    with h.session(role='authenticated', sub=a) as cur:
        cur.execute("SELECT send_friend_request('bob')")
    with h.session(role='authenticated', sub=b) as cur:
        cur.execute("SELECT respond_to_friend_request('alice', false)")
        res = _j(cur.fetchone()[0])
    assert res['status'] == 'none'
    with h.session() as cur:
        assert _status(cur, b, 'alice') is None
        assert _status(cur, a, 'bob') is None


def test_respond_no_pending_raises(h):
    a = _uid(); b = _uid()
    with h.session() as cur:
        _person(cur, a, 'alice', 'Alice'); _person(cur, b, 'bob', 'Bob')
    with h.session(role='authenticated', sub=b) as cur:
        with pytest.raises(h.Error) as ei:
            cur.execute("SELECT respond_to_friend_request('alice', true)")
    assert 'no pending request' in str(ei.value).lower()


# ---- remove_friend ----------------------------------------------------------

def test_remove_is_two_sided(h):
    a = _uid(); b = _uid()
    with h.session() as cur:
        _person(cur, a, 'alice', 'Alice'); _person(cur, b, 'bob', 'Bob')
        _friendship(cur, a, 'bob', 'friends'); _friendship(cur, b, 'alice', 'friends')
    with h.session(role='authenticated', sub=a) as cur:
        cur.execute("SELECT remove_friend('bob', false)")
        res = _j(cur.fetchone()[0])
    assert res['status'] == 'none'
    with h.session() as cur:
        assert _status(cur, a, 'bob') is None
        assert _status(cur, b, 'alice') is None


def test_remove_block_leaves_caller_blocked_row(h):
    a = _uid(); b = _uid()
    with h.session() as cur:
        _person(cur, a, 'alice', 'Alice'); _person(cur, b, 'bob', 'Bob')
        _friendship(cur, a, 'bob', 'friends'); _friendship(cur, b, 'alice', 'friends')
    with h.session(role='authenticated', sub=a) as cur:
        cur.execute("SELECT remove_friend('bob', true)")
        res = _j(cur.fetchone()[0])
    assert res['status'] == 'blocked'
    with h.session() as cur:
        assert _status(cur, a, 'bob') == 'blocked'    # caller keeps a blocked row
        assert _status(cur, b, 'alice') is None       # counterparty cleared


# ---- emit_friend_activity ---------------------------------------------------

def test_emit_inserts_one_row_per_friend_and_dedups(h):
    a = _uid(); b = _uid(); c = _uid()
    with h.session() as cur:
        _person(cur, a, 'alice', 'Alice'); _person(cur, b, 'bob'); _person(cur, c, 'carol')
        _friendship(cur, a, 'bob', 'friends'); _friendship(cur, a, 'carol', 'friends')
    with h.session(role='authenticated', sub=a) as cur:
        cur.execute("SELECT emit_friend_activity('lessonsCompleted','did 5')")
        n1 = cur.fetchone()[0]
        cur.execute("SELECT emit_friend_activity('lessonsCompleted','did 5')")   # 12h dedup
        n2 = cur.fetchone()[0]
    assert n1 == 2 and n2 == 0
    with h.session() as cur:
        cur.execute("SELECT user_id, actor_id, type FROM friend_activity")
        rows = cur.fetchall()
    assert len(rows) == 2
    assert {str(r[0]) for r in rows} == {b, c}
    assert all(r[1] == 'alice' and r[2] == 'lessonsCompleted' for r in rows)


def test_emit_invalid_type_raises(h):
    a = _uid(); b = _uid()
    with h.session() as cur:
        _person(cur, a, 'alice', 'Alice'); _person(cur, b, 'bob')
        _friendship(cur, a, 'bob', 'friends')
    with h.session(role='authenticated', sub=a) as cur:
        with pytest.raises(h.Error) as ei:
            cur.execute("SELECT emit_friend_activity('spam','x')")
    assert 'invalid activity type' in str(ei.value).lower()


# ---- publish_weekly_xp ------------------------------------------------------

def test_publish_weekly_xp_mirrors_and_emits_passed(h):
    a = _uid(); b = _uid(); c = _uid()
    with h.session() as cur:
        _person(cur, a, 'alice', 'Alice'); _person(cur, b, 'bob'); _person(cur, c, 'carol')
        # A's own view of each friend's weekly_xp:
        _friendship(cur, a, 'bob', 'friends', weekly_xp=150)    # ahead of a's 130
        _friendship(cur, a, 'carol', 'friends', weekly_xp=120)  # in [old=100, new=130)
        # A's mirror in friends' accounts (friend_id='alice'), old = 100:
        _friendship(cur, b, 'alice', 'friends', weekly_xp=100)
        _friendship(cur, c, 'alice', 'friends', weekly_xp=100)
    with h.session(role='authenticated', sub=a) as cur:
        cur.execute("SELECT publish_weekly_xp(130)")
        n = cur.fetchone()[0]
    assert n == 1                                   # only carol overtaken
    with h.session() as cur:
        cur.execute("SELECT weekly_xp FROM friendship "
                    "WHERE friend_id='alice' AND status='friends'")
        assert sorted(r[0] for r in cur.fetchall()) == [130, 130]   # mirror updated
        cur.execute("SELECT user_id FROM friend_activity WHERE type='passedYouInLeague'")
        rows = cur.fetchall()
    assert len(rows) == 1 and str(rows[0][0]) == c   # landed only in carol's feed


def test_publish_without_handle_returns_zero(h):
    a = _uid()
    with h.session() as cur:
        _no_handle_user(cur, a)
    with h.session(role='authenticated', sub=a) as cur:
        cur.execute("SELECT publish_weekly_xp(500)")
        assert cur.fetchone()[0] == 0


# ---- grants (REVOKE public + GRANT authenticated) ---------------------------

def test_grants_authenticated_only_anon_denied(h):
    a = _uid()
    with h.session() as cur:
        _person(cur, a, 'alice', 'Alice')
    with h.session(role='anon') as cur:
        with pytest.raises(h.Error) as ei:
            cur.execute("SELECT send_friend_request('bob')")
    assert 'permission denied' in str(ei.value).lower()
