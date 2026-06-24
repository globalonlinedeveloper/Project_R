# BUILD-AHEAD — not deployed; pending human review + go-live wiring.
#
# PARTMAN-1 [Door #4 · R-M3] tests for ensure_review_log_partitions on a DISPOSABLE pgserver.
# 0001 ships review_log with only static 2026_06/2026_07 partitions and NO default, so an
# insert past that window hard-fails ("no partition found"); the maintenance fn rolls the
# window forward so the insert succeeds, is idempotent, coexists with the static partitions,
# prunes only when explicitly asked (opt-in retention), and is service_role-only (clients
# never run DDL — re-asserts 0002/0003). The live Supabase project is never touched.
import datetime as dt
import pathlib
import sys
import tempfile
import uuid as uuidlib

import pytest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import rls_harness  # noqa: E402


@pytest.fixture()
def h():
    """Function-scoped: each test gets a FRESH disposable DB (partition DDL is global state)."""
    pgserver = rls_harness.require_pgserver()
    d = tempfile.mkdtemp(prefix="ratel_partman_")
    harness = rls_harness.Harness(pgserver, d, ["0006_review_log_partitions.sql"])
    yield harness
    harness.cleanup()


def _utc_month_start():
    return dt.datetime.now(dt.timezone.utc).date().replace(day=1)


def _add_months(d, n):
    m = d.month - 1 + n
    return dt.date(d.year + m // 12, m % 12 + 1, 1)


def _partitions(h):
    with h.session("service_role", "") as cur:
        cur.execute(
            "SELECT c.relname FROM pg_inherits inh "
            "JOIN pg_class c ON c.oid=inh.inhrelid "
            "JOIN pg_class p ON p.oid=inh.inhparent "
            "WHERE p.relname='review_log' ORDER BY c.relname")
        return [r[0] for r in cur.fetchall()]


def _ensure(h, months_ahead=6, drop_before=None, role="service_role", sub=""):
    with h.session(role, sub) as cur:
        cur.execute(
            "SELECT op, part_name FROM ensure_review_log_partitions(%s, %s::date)",
            (months_ahead, drop_before))
        return cur.fetchall()


def _seed_user(h):
    u = str(uuidlib.uuid4())
    with h.session() as cur:  # superuser seed (bypasses RLS)
        cur.execute(
            'INSERT INTO "user"(user_id,created_at,updated_at) VALUES (%s::uuid, now(), now())',
            (u,))
    return u


def _insert_review(h, user, reviewed_at_iso):
    with h.session() as cur:  # superuser seed
        cur.execute(
            'INSERT INTO "review_log"(review_log_id,user_id,item_id,reviewed_at,rating) '
            "VALUES (%s::uuid, %s::uuid, 'it_x', %s::timestamptz, 3)",
            (str(uuidlib.uuid4()), user, reviewed_at_iso))


def _is_denial(exc) -> bool:
    m = str(exc).lower()
    return "permission denied" in m or "must be owner" in m


# ── headline: the cliff is fixed (future insert fails -> ensure -> succeeds) ───
def test_rolls_window_forward_and_fixes_cliff(h):
    assert set(_partitions(h)) == {"review_log_2026_06", "review_log_2026_07"}
    target = _add_months(_utc_month_start(), 13)            # well past the static window
    tname = "review_log_%04d_%02d" % (target.year, target.month)
    at = target.replace(day=15).isoformat()
    u = _seed_user(h)

    # before maintenance: no partition for that month -> insert fails closed
    with pytest.raises(h.Error):
        _insert_review(h, u, at)

    rows = _ensure(h, months_ahead=13)
    assert tname in [r[1] for r in rows]
    assert tname in _partitions(h)

    # after maintenance: the same insert now lands in its partition
    _insert_review(h, u, at)

    # coexists with the static partitions (no overlap error on 2026_06/2026_07)
    assert {"review_log_2026_06", "review_log_2026_07"}.issubset(set(_partitions(h)))

    # idempotent: a 2nd run neither errors nor changes the partition set
    before = set(_partitions(h))
    _ensure(h, months_ahead=13)
    assert set(_partitions(h)) == before


# ── retention is opt-in and drops only whole, fully-old months ────────────────
def test_retention_is_opt_in(h):
    # default (drop_before NULL) never drops: 2026_06 survives
    _ensure(h, months_ahead=0)
    assert "review_log_2026_06" in _partitions(h)

    # explicit cutoff drops the month whose range ends on/before it, keeps the rest
    dropped = _ensure(h, months_ahead=0, drop_before="2026-07-01")
    assert "review_log_2026_06" in [r[1] for r in dropped if r[0] == "dropped"]
    parts = _partitions(h)
    assert "review_log_2026_06" not in parts          # upper 2026-07-01 <= cutoff -> dropped
    assert "review_log_2026_07" in parts              # upper 2026-08-01 >  cutoff -> kept


# ── only the server may run maintenance (clients never run DDL) ───────────────
def test_only_service_role_can_run(h):
    u = _seed_user(h)
    with h.session("authenticated", u) as cur:
        with pytest.raises(h.Error) as e:
            cur.execute("SELECT ensure_review_log_partitions(1)")
        assert _is_denial(e.value), f"client could run partition maintenance: {e.value}"
    with h.session("anon") as cur:
        with pytest.raises(h.Error):
            cur.execute("SELECT ensure_review_log_partitions(1)")


# ── adversarial input fails closed ────────────────────────────────────────────
def test_negative_months_ahead_rejected(h):
    with pytest.raises(h.Error):
        _ensure(h, months_ahead=-1)
