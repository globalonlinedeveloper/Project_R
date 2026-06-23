# BUILD-AHEAD — not deployed; pending human review + go-live wiring.
#
# M5 [P1-1 · TS-6] tests for apply_entitlement_event on a DISPOSABLE pgserver:
# first grant sets pro_until; replayed provider event_id transitions exactly once
# (no double-grant); refund/chargeback/lapse claw back; out-of-order grants are
# deterministic (GREATEST, never shortens); the lapse->grant lifecycle restores Pro;
# unknown kind / grant-without-until / unknown user fail closed; and `authenticated`
# can neither EXECUTE the fn nor write user.pro_until (re-asserts 0002 / P0-3).
# The live Supabase project is never touched.
import pathlib
import sys
import tempfile
import uuid as uuidlib

import pytest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import rls_harness  # noqa: E402

# Fixed expiries so GREATEST/extend assertions are exact. EARLY < LATE.
EARLY = "2027-01-01T00:00:00+00:00"
LATE = "2027-06-01T00:00:00+00:00"


@pytest.fixture(scope="module")
def h():
    pgserver = rls_harness.require_pgserver()
    d = tempfile.mkdtemp(prefix="ratel_entitlement_")
    harness = rls_harness.Harness(
        pgserver, d, ["0002_rls_entitlement.sql", "0005_entitlement_fn.sql"]
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


def _apply(h, event_id, user, kind, until=None, *, role="service_role", sub=""):
    """Call apply_entitlement_event; returns the resulting pro_until (datetime or None)."""
    with h.session(role, sub) as cur:
        cur.execute(
            "SELECT pro_until FROM apply_entitlement_event(%s,%s::uuid,%s,%s::timestamptz)",
            (event_id, user, kind, until),
        )
        return cur.fetchone()[0]


def _pro_until(h, user):
    with h.session("service_role", "") as cur:
        cur.execute('SELECT pro_until FROM "user" WHERE user_id=%s::uuid', (user,))
        return cur.fetchone()[0]


def _ppe_count(h, event_id):
    with h.session("service_role", "") as cur:
        cur.execute("SELECT count(*) FROM processed_payment_event WHERE event_id=%s", (event_id,))
        return cur.fetchone()[0]


def _is_denial(exc) -> bool:
    m = str(exc).lower()
    return "permission denied" in m or "row-level security" in m or "violates row-level" in m


# ── grant sets entitlement ───────────────────────────────────────────────────
def test_first_grant_sets_pro_until(h):
    u = _new_user(h)
    assert _pro_until(h, u) is None              # free to start
    out = _apply(h, "evt_" + _uid(), u, "grant", LATE)
    assert out is not None
    assert _pro_until(h, u) == out               # persisted


# ── idempotency: a replayed webhook transitions exactly once ─────────────────
def test_replayed_event_id_no_double_grant(h):
    u = _new_user(h)
    eid = "evt_" + _uid()
    first = _apply(h, eid, u, "grant", EARLY)
    # A second grant with the SAME event_id but a LATER until must NOT extend
    # (the event was already processed; the body is never re-run).
    again = _apply(h, eid, u, "grant", LATE)
    assert again == first                        # unchanged
    assert _pro_until(h, u) == first             # still the EARLY expiry
    assert _ppe_count(h, eid) == 1               # exactly one processed row


# ── clawbacks ────────────────────────────────────────────────────────────────
@pytest.mark.parametrize("kind", ["refund", "chargeback", "lapse"])
def test_clawback_revokes_pro(h, kind):
    u = _new_user(h)
    _apply(h, "evt_" + _uid(), u, "grant", LATE)
    assert _pro_until(h, u) is not None
    out = _apply(h, "evt_" + _uid(), u, kind)    # until omitted -> NULL
    assert out is None
    assert _pro_until(h, u) is None              # entitlement cleared


def test_replayed_clawback_is_idempotent(h):
    u = _new_user(h)
    _apply(h, "evt_" + _uid(), u, "grant", LATE)
    eid = "evt_" + _uid()
    _apply(h, eid, u, "lapse")
    _apply(h, eid, u, "lapse")                   # replay
    assert _ppe_count(h, eid) == 1
    assert _pro_until(h, u) is None


# ── out-of-order grants are deterministic (extend, never shorten) ────────────
def test_out_of_order_grants_deterministic(h):
    ua = _new_user(h)
    ub = _new_user(h)
    # user A: LATE then EARLY ; user B: EARLY then LATE — same final state.
    _apply(h, "evt_" + _uid(), ua, "grant", LATE)
    _apply(h, "evt_" + _uid(), ua, "grant", EARLY)
    _apply(h, "evt_" + _uid(), ub, "grant", EARLY)
    _apply(h, "evt_" + _uid(), ub, "grant", LATE)
    assert _pro_until(h, ua) == _pro_until(h, ub)        # order-independent
    assert _pro_until(h, ua) is not None
    # and both equal the LATER expiry (a stale older grant never shortens)
    probe = _new_user(h)
    late_only = _apply(h, "evt_" + _uid(), probe, "grant", LATE)
    assert _pro_until(h, ua) == late_only


# ── full lifecycle: grant -> clawback -> re-grant ────────────────────────────
def test_lapse_then_grant_lifecycle(h):
    u = _new_user(h)
    _apply(h, "evt_" + _uid(), u, "grant", EARLY)
    _apply(h, "evt_" + _uid(), u, "lapse")
    assert _pro_until(h, u) is None              # lapsed
    out = _apply(h, "evt_" + _uid(), u, "grant", LATE)   # renewed
    assert out is not None
    assert _pro_until(h, u) == out               # Pro again


# ── adversarial: fail closed, never mark a bad event processed ───────────────
def test_unknown_kind_rejected(h):
    u = _new_user(h)
    eid = "evt_" + _uid()
    with pytest.raises(h.Error):
        _apply(h, eid, u, "upgrade", LATE)       # not in the allowed set
    assert _ppe_count(h, eid) == 0               # rolled back; not recorded
    assert _pro_until(h, u) is None


def test_grant_without_until_rejected(h):
    u = _new_user(h)
    eid = "evt_" + _uid()
    with pytest.raises(h.Error):
        _apply(h, eid, u, "grant")               # missing until
    assert _ppe_count(h, eid) == 0
    assert _pro_until(h, u) is None


def test_unknown_user_rejected_and_not_recorded(h):
    eid = "evt_" + _uid()
    ghost = _uid()                               # never inserted into "user"
    with pytest.raises(h.Error):
        _apply(h, eid, ghost, "grant", LATE)
    assert _ppe_count(h, eid) == 0               # the dedupe insert rolled back too


# ── client cannot transition entitlement (re-asserts 0002 / P0-3) ────────────
def test_authenticated_cannot_execute_fn_or_write_pro_until(h):
    u = _new_user(h)
    with h.session("authenticated", u) as cur:
        with pytest.raises(h.Error) as e1:
            cur.execute(
                "SELECT * FROM apply_entitlement_event(%s,%s::uuid,'grant',%s::timestamptz)",
                ("evt_" + _uid(), u, LATE),
            )
        assert _is_denial(e1.value), f"client could EXECUTE the entitlement fn: {e1.value}"
    with h.session("authenticated", u) as cur:
        with pytest.raises(h.Error) as e2:
            cur.execute('UPDATE "user" SET pro_until=%s::timestamptz WHERE user_id=%s::uuid', (LATE, u))
        assert _is_denial(e2.value), f"client could self-grant Pro: {e2.value}"
    assert _pro_until(h, u) is None              # still free
