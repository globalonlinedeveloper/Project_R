# BACKFILL — provenance tests for schema/sql/0009 (read_league_cohort) + 0010
# (close_league_week). Both functions are ALREADY LIVE (S164, applied direct to
# Supabase); these tests pin their behaviour on a DISPOSABLE pgserver so the repo
# snapshot is verifiable and regression-guarded. The live Supabase project is
# NEVER touched. auth.uid() is shimmed by the harness (request.jwt.claim.sub GUC).
#
# 0001 is STRUCTURE-ONLY (no column defaults); the live league tables carry
# gen_random_uuid()/now()/0 defaults that the functions depend on, so we
# re-declare them via extra_preamble to match live behaviour. league_member.user_id
# REFERENCES "user"(user_id), so every seeded member needs a parent "user" row
# (0001 declares NO auth.users FK — 0007, not applied here, would add it).
import json
import pathlib
import sys
import tempfile
import uuid as uuidlib

import pytest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import rls_harness  # noqa: E402

LEAGUE_PREAMBLE = """
ALTER TABLE public.league_cohort ALTER COLUMN league_cohort_id SET DEFAULT gen_random_uuid();
ALTER TABLE public.league_cohort ALTER COLUMN created_at       SET DEFAULT now();
ALTER TABLE public.league_member ALTER COLUMN league_member_id SET DEFAULT gen_random_uuid();
ALTER TABLE public.league_member ALTER COLUMN weekly_xp        SET DEFAULT 0;
ALTER TABLE public.league_member ALTER COLUMN created_at       SET DEFAULT now();
ALTER TABLE public.league_member ALTER COLUMN updated_at       SET DEFAULT now();
"""

OUT_COLS = {"member_id", "display_name", "avatar_emoji", "weekly_xp",
            "tier", "week_start", "is_you"}


@pytest.fixture()
def h():
    pgserver = rls_harness.require_pgserver()
    d = tempfile.mkdtemp(prefix="ratel_league_")
    harness = rls_harness.Harness(
        pgserver, d,
        ["0009_read_league_cohort_fn.sql", "0010_league_close_fn.sql"],
        extra_preamble=LEAGUE_PREAMBLE)
    yield harness
    harness.cleanup()


def _uid():
    return str(uuidlib.uuid4())


def _seed_user(cur, uid):
    cur.execute('INSERT INTO "user"(user_id,created_at,updated_at) '
                'VALUES (%s::uuid,now(),now())', (uid,))


def _seed_member(cur, uid, week, tier, xp, cohort=None, name=None, avatar=None):
    cur.execute(
        'INSERT INTO league_member'
        '(user_id,cohort_id,week_start,tier,weekly_xp,display_name,avatar_emoji) '
        'VALUES (%s::uuid,%s,%s::date,%s,%s,%s,%s)',
        (uid, cohort, week, tier, xp, name, avatar))


def _names(rows, idx=0):
    return [r[idx] for r in rows]


def test_read_lazy_assigns_a_solo_caller(h):
    a = _uid(); wk = "2026-07-13"
    with h.session() as cur:
        _seed_user(cur, a)
        _seed_member(cur, a, wk, "bronze", 50, name="A", avatar="🦊")
        cur.execute("SELECT cohort_id FROM league_member WHERE user_id=%s::uuid", (a,))
        assert cur.fetchone()[0] is None            # NULL cohort before any read
    with h.session(role="authenticated", sub=a) as cur:
        cur.execute("SELECT member_id, weekly_xp, is_you FROM read_league_cohort()")
        rows = cur.fetchall()
    assert len(rows) == 1
    assert rows[0][1] == 50 and rows[0][2] is True   # own row, own real weekly_xp
    with h.session() as cur:                          # caller is now assigned
        cur.execute("SELECT cohort_id FROM league_member WHERE user_id=%s::uuid", (a,))
        assert cur.fetchone()[0] is not None


def test_read_joins_peers_incrementally_ranked_no_user_id_leak(h):
    a = _uid(); b = _uid(); wk = "2026-07-13"
    with h.session() as cur:
        _seed_user(cur, a); _seed_user(cur, b)
        _seed_member(cur, a, wk, "silver", 30, name="A", avatar="🦊")
        _seed_member(cur, b, wk, "silver", 80, name="B", avatar="🐼")
    # A reads first -> auto-joined ALONE (the definer assigns only the caller).
    with h.session(role="authenticated", sub=a) as cur:
        cur.execute("SELECT display_name FROM read_league_cohort()")
        assert _names(cur.fetchall()) == ["A"]
    # B reads -> joins A's open (<30) cohort -> ranked by weekly_xp desc.
    with h.session(role="authenticated", sub=b) as cur:
        cur.execute("SELECT display_name, is_you FROM read_league_cohort()")
        rb = cur.fetchall()
    assert _names(rb) == ["B", "A"] and [r[1] for r in rb] == [True, False]
    # A reads again -> now sees the full 2-member cohort, is_you only on A.
    with h.session(role="authenticated", sub=a) as cur:
        cur.execute("SELECT display_name, is_you, member_id FROM read_league_cohort()")
        ra = cur.fetchall()
        colnames = {d[0] for d in cur.description}
    assert _names(ra) == ["B", "A"] and [r[1] for r in ra] == [False, True]
    # The definer NEVER exposes a co-member's user_id — only the opaque member_id.
    assert "user_id" not in colnames


def test_read_full_out_columns_are_exactly_the_contract(h):
    a = _uid(); wk = "2026-07-13"
    with h.session() as cur:
        _seed_user(cur, a)
        _seed_member(cur, a, wk, "bronze", 10, name="A")
    with h.session(role="authenticated", sub=a) as cur:
        cur.execute("SELECT * FROM read_league_cohort()")
        cur.fetchall()
        assert {d[0] for d in cur.description} == OUT_COLS


def test_read_no_membership_is_empty_honest_solo(h):
    ghost = _uid()
    with h.session() as cur:
        _seed_user(cur, ghost)                        # user exists, no league row
    with h.session(role="authenticated", sub=ghost) as cur:
        cur.execute("SELECT * FROM read_league_cohort()")
        assert list(cur.fetchall()) == []            # zero rows (pg8000 -> empty seq)


def test_close_promotes_top7_demotes_bottom5_holds_middle_resets_xp(h):
    new_week = "2026-07-13"; closed = "2026-07-06"
    with h.session() as cur:
        cur.execute("INSERT INTO league_cohort(tier,week_start) "
                    "VALUES ('gold',%s::date) RETURNING league_cohort_id", (closed,))
        cid = cur.fetchone()[0]
        for k in range(1, 16):                        # rank k has weekly_xp 16-k
            u = _uid(); _seed_user(cur, u)
            _seed_member(cur, u, closed, "gold", 16 - k, cohort=cid, name=f"M{k}")
    with h.session() as cur:                          # service-role / cron would call this
        cur.execute("SELECT close_league_week(%s::date)", (new_week,))
        res = cur.fetchone()[0]
    res = res if isinstance(res, dict) else json.loads(res)
    with h.session() as cur:
        cur.execute("SELECT tier, count(*) FROM league_member "
                    "WHERE week_start=%s::date GROUP BY tier", (new_week,))
        dist = {t: n for t, n in cur.fetchall()}
        cur.execute("SELECT bool_and(weekly_xp=0), bool_and(cohort_id IS NOT NULL) "
                    "FROM league_member WHERE week_start=%s::date", (new_week,))
        all_zero, all_formed = cur.fetchone()
    assert dist == {"sapphire": 7, "gold": 3, "silver": 5}   # 7 up / 3 hold / 5 down
    assert all_zero is True                                   # next-week XP reset
    assert all_formed is True                                 # re-formed into cohorts
    assert res["members_advanced"] == 15 and res["cohorts_formed"] == 3


def test_close_is_idempotent_per_user_week(h):
    new_week = "2026-07-13"; closed = "2026-07-06"
    a = _uid()
    with h.session() as cur:
        _seed_user(cur, a)
        _seed_member(cur, a, closed, "silver", 100, name="A")
    with h.session() as cur:
        cur.execute("SELECT close_league_week(%s::date)", (new_week,))
        cur.execute("SELECT close_league_week(%s::date)", (new_week,))  # re-run: no dup row
        cur.execute("SELECT count(*) FROM league_member "
                    "WHERE user_id=%s::uuid AND week_start=%s::date", (a, new_week))
        assert cur.fetchone()[0] == 1                 # ON CONFLICT(user_id,week_start)
