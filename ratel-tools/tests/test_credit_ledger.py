# BUILD-AHEAD — not deployed; pending human review + go-live wiring.
#
# M4 [P0-7a · TS-9] tests for post_credit_entry on a DISPOSABLE pgserver:
# idempotent grant/spend/refund, balance tracking + reconciliation, fail-closed
# at zero (never negative), refund validation, service_role-only EXECUTE (re-asserts
# 0002 / P0-3), and a true concurrency proof that interleaved spends can't both
# pass the zero floor. The live Supabase project is never touched.
import pathlib
import sys
import tempfile
import threading
import uuid as uuidlib

import pytest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import rls_harness  # noqa: E402


@pytest.fixture(scope="module")
def h():
    pgserver = rls_harness.require_pgserver()
    d = tempfile.mkdtemp(prefix="ratel_ledger_")
    harness = rls_harness.Harness(
        pgserver, d, ["0002_rls_entitlement.sql", "0004_credit_ledger_fn.sql"]
    )
    yield harness
    harness.cleanup()


def _uid():
    return str(uuidlib.uuid4())


def _new_user(h):
    u = _uid()
    with h.session() as cur:  # superuser seed
        cur.execute(
            'INSERT INTO "user"(user_id,created_at,updated_at) '
            f"VALUES ('{u}',now(),now())"
        )
    return u


def _post(h, user, etype, amount, *, src=None, related=None, reason=None,
          eid=None, role="service_role", sub=""):
    """Call post_credit_entry; returns (credit_ledger_id, entry_type, amount, balance_after)."""
    eid = eid or _uid()
    with h.session(role, sub) as cur:
        cur.execute(
            "SELECT credit_ledger_id, entry_type, amount, balance_after "
            "FROM post_credit_entry("
            "%s::uuid,%s::ledger_entry_type,%s,%s::uuid,%s::grant_source,%s::uuid,%s)",
            (user, etype, amount, eid, src, related, reason),
        )
        return cur.fetchone()


def _balance(h, user):
    with h.session("service_role", "") as cur:
        cur.execute(
            "SELECT COALESCE(SUM(CASE entry_type WHEN 'spend' THEN -amount ELSE amount END),0) "
            "FROM credit_ledger WHERE user_id=%s::uuid",
            (user,),
        )
        return cur.fetchone()[0]


def _count_eid(h, eid):
    with h.session("service_role", "") as cur:
        cur.execute("SELECT count(*) FROM credit_ledger WHERE client_event_id=%s::uuid", (eid,))
        return cur.fetchone()[0]


def _is_denial(exc) -> bool:
    m = str(exc).lower()
    return "permission denied" in m or "row-level security" in m or "violates row-level" in m


# ── happy path + reconciliation ──────────────────────────────────────────────
def test_grant_then_spend_tracks_balance(h):
    u = _new_user(h)
    assert _post(h, u, "grant", 100, src="purchase")[3] == 100
    assert _post(h, u, "spend", 30)[3] == 70
    assert _balance(h, u) == 70  # independent reconciliation


# ── idempotency ──────────────────────────────────────────────────────────────
def test_replayed_grant_does_not_double(h):
    u = _new_user(h)
    eid = _uid()
    r1 = _post(h, u, "grant", 50, src="promo", eid=eid)
    r2 = _post(h, u, "grant", 50, src="promo", eid=eid)
    assert str(r1[0]) == str(r2[0])      # same row returned
    assert _count_eid(h, eid) == 1       # exactly one posted row
    assert _balance(h, u) == 50          # not 100


def test_replayed_spend_charged_once(h):
    u = _new_user(h)
    _post(h, u, "grant", 100, src="purchase")
    eid = _uid()
    _post(h, u, "spend", 40, eid=eid)
    _post(h, u, "spend", 40, eid=eid)    # replay
    assert _count_eid(h, eid) == 1
    assert _balance(h, u) == 60          # charged once, not 20


# ── fail closed at zero ──────────────────────────────────────────────────────
def test_spend_over_balance_raises_and_rolls_back(h):
    u = _new_user(h)
    _post(h, u, "grant", 20, src="purchase")
    with pytest.raises(h.Error):
        _post(h, u, "spend", 50)
    assert _balance(h, u) == 20          # unchanged, never negative
    with h.session("service_role", "") as cur:
        cur.execute("SELECT count(*) FROM credit_ledger WHERE user_id=%s::uuid AND entry_type='spend'", (u,))
        assert cur.fetchone()[0] == 0    # no spend row left behind


def test_empty_to_zero_then_any_spend_denied(h):
    u = _new_user(h)
    with pytest.raises(h.Error):
        _post(h, u, "spend", 1)          # empty balance -> denied
    _post(h, u, "grant", 10, src="daily_free")
    assert _post(h, u, "spend", 10)[3] == 0   # exactly to zero is allowed
    assert _balance(h, u) == 0
    with pytest.raises(h.Error):
        _post(h, u, "spend", 1)          # any further spend denied


# ── refund rules ─────────────────────────────────────────────────────────────
def test_refund_without_related_id_rejected(h):
    u = _new_user(h)
    _post(h, u, "grant", 100, src="purchase")
    _post(h, u, "spend", 40)
    with pytest.raises(h.Error):
        _post(h, u, "refund", 10)        # no related_ledger_id
    assert _balance(h, u) == 60


def test_refund_over_spend_rejected(h):
    u = _new_user(h)
    _post(h, u, "grant", 100, src="purchase")
    sp = _post(h, u, "spend", 40)
    with pytest.raises(h.Error):
        _post(h, u, "refund", 50, related=str(sp[0]))   # > spent 40
    assert _balance(h, u) == 60


def test_refund_valid_then_idempotent_then_second_rejected(h):
    u = _new_user(h)
    _post(h, u, "grant", 100, src="purchase")
    sp = _post(h, u, "spend", 40)
    sid = str(sp[0])
    eid = _uid()
    r1 = _post(h, u, "refund", 40, related=sid, eid=eid)
    r2 = _post(h, u, "refund", 40, related=sid, eid=eid)  # replay -> idempotent
    assert str(r1[0]) == str(r2[0])
    assert _balance(h, u) == 100         # grant100 - spend40 + refund40
    # spend now fully refunded -> a distinct further refund is rejected
    with pytest.raises(h.Error):
        _post(h, u, "refund", 1, related=sid)


# ── client cannot mint (re-asserts 0002 / P0-3) ──────────────────────────────
def test_authenticated_cannot_execute_fn_or_insert(h):
    u = _new_user(h)
    with h.session("authenticated", u) as cur:
        with pytest.raises(h.Error) as e1:
            cur.execute(
                "SELECT * FROM post_credit_entry(%s::uuid,'grant',999,%s::uuid)",
                (u, _uid()),
            )
        assert _is_denial(e1.value), f"client could EXECUTE the mint fn: {e1.value}"
    with h.session("authenticated", u) as cur:
        with pytest.raises(h.Error) as e2:
            cur.execute(
                'INSERT INTO "credit_ledger"(credit_ledger_id,user_id,entry_type,amount,client_event_id,created_at) '
                f"VALUES (gen_random_uuid(),'{u}','grant',999,gen_random_uuid(),now())"
            )
        assert _is_denial(e2.value), f"client could INSERT directly: {e2.value}"
    assert _balance(h, u) == 0


# ── concurrency: interleaved spends can't both pass zero ─────────────────────
def test_concurrent_spends_cannot_both_pass_zero(h):
    u = _new_user(h)
    _post(h, u, "grant", 100, src="purchase")

    results = []
    barrier = threading.Barrier(2)
    lock = threading.Lock()

    def worker():
        conn = h._pg8000.connect(**h._conn_args)
        conn.autocommit = False
        cur = conn.cursor()
        try:
            cur.execute("set role service_role")
            barrier.wait(timeout=10)
            cur.execute(
                "SELECT balance_after FROM post_credit_entry(%s::uuid,'spend',100,%s::uuid)",
                (u, _uid()),
            )
            row = cur.fetchone()
            conn.commit()
            with lock:
                results.append(("ok", row[0]))
        except Exception as e:  # noqa: BLE001 — capturing the insufficient-credits raise
            conn.rollback()
            with lock:
                results.append(("err", str(e)))
        finally:
            conn.close()

    ts = [threading.Thread(target=worker) for _ in range(2)]
    for t in ts:
        t.start()
    for t in ts:
        t.join(timeout=20)

    oks = [r for r in results if r[0] == "ok"]
    errs = [r for r in results if r[0] == "err"]
    assert len(oks) == 1, f"exactly one spend must win, got {results}"
    assert len(errs) == 1, f"the loser must fail closed, got {results}"
    assert oks[0][1] == 0           # winner drove balance to exactly zero
    assert _balance(h, u) == 0      # never negative
