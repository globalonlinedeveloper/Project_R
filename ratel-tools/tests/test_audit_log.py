# BUILD-AHEAD — not deployed; pending human review + go-live wiring.
#
# AUDIT-1 [R-M5 · R-M8 · R-K6] tests for the durable, append-only audit_log + record_audit_event
# on a DISPOSABLE pgserver. Proves the durable store R-M5 needs for security/abuse forensics:
#
#   * service_role CAN append (via record_audit_event) and read back the row it wrote — and the
#     fn records EXACTLY the category/action/user_id/detail passed (incl. the moderation shape:
#     user_id NULL, since ModerationAuditSink.record() carries no userId);
#   * authenticated AND anon can do NEITHER — they cannot EXECUTE the fn, nor SELECT/INSERT the
#     table directly (re-asserts the 0002/0005 server-only floor for a new table · R-K6);
#   * APPEND-ONLY: not even service_role may UPDATE or DELETE a row (only SELECT+INSERT granted),
#     so the audit trail is tamper-evident-by-design;
#   * the fn FAILS CLOSED on a malformed event (blank category/action, non-object detail) and
#     writes NO row when it rejects.
#
# The live Supabase project is never touched (local unix socket only).
import json
import pathlib
import sys
import tempfile
import uuid as uuidlib

import pytest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import rls_harness  # noqa: E402


@pytest.fixture(scope="module")
def h():
    pgserver = rls_harness.require_pgserver()
    d = tempfile.mkdtemp(prefix="ratel_audit_")
    # audit_log is self-contained: 0001 (applied by the harness) + the role/auth preamble + 0008.
    harness = rls_harness.Harness(pgserver, d, ["0008_audit_log.sql"])
    yield harness
    harness.cleanup()


def _uid():
    return str(uuidlib.uuid4())


def _is_denial(exc) -> bool:
    m = str(exc).lower()
    return (
        "permission denied" in m
        or "row-level security" in m
        or "violates row-level" in m
    )


def _record(h, category, action, user_id=None, detail=None, *, role="service_role", sub=""):
    """Call record_audit_event; return the resulting row as a dict (detail normalized)."""
    with h.session(role, sub) as cur:
        cur.execute(
            "SELECT audit_id, occurred_at, user_id, category, action, detail "
            "FROM record_audit_event(%s,%s,%s::uuid,%s::jsonb)",
            (category, action, user_id, None if detail is None else json.dumps(detail)),
        )
        r = cur.fetchone()
    d = r[5]
    if isinstance(d, str):
        d = json.loads(d)
    return {"audit_id": r[0], "occurred_at": r[1], "user_id": r[2],
            "category": r[3], "action": r[4], "detail": d}


def _count(h):
    with h.session("service_role", "") as cur:
        cur.execute("SELECT count(*) FROM audit_log")
        return cur.fetchone()[0]


def _select_by_id(h, audit_id, role="service_role", sub=""):
    with h.session(role, sub) as cur:
        cur.execute(
            "SELECT category, action, user_id, detail FROM audit_log WHERE audit_id=%s::uuid",
            (str(audit_id),),
        )
        return cur.fetchone()


# ── service_role can append + read; the fn records the expected row ───────────────────────────
def test_service_role_records_grant_denial(h):
    u = _uid()
    out = _record(h, "grant", "denyVelocity", u, {"source": "referral", "deviceId": "dev-1"})
    assert out["audit_id"] is not None
    assert out["category"] == "grant"
    assert out["action"] == "denyVelocity"
    assert str(out["user_id"]) == u
    assert out["detail"] == {"source": "referral", "deviceId": "dev-1"}
    # durably readable by the service role
    row = _select_by_id(h, out["audit_id"])
    assert row is not None
    assert row[0] == "grant" and row[1] == "denyVelocity"


def test_service_role_records_moderation_verdict_null_user(h):
    # ModerationAuditSink.record() has NO userId -> user_id NULL (no persistent id leaks).
    out = _record(h, "moderation", "blocked", None, {"stage": "output"})
    assert out["user_id"] is None
    assert out["category"] == "moderation"
    assert out["action"] == "blocked"
    assert out["detail"] == {"stage": "output"}


def test_detail_defaults_to_empty_object_when_omitted(h):
    out = _record(h, "grant", "allow", _uid(), None)
    assert out["detail"] == {}


def test_each_call_is_a_distinct_append(h):
    before = _count(h)
    a = _record(h, "grant", "denyAttestation", _uid(), {"source": "adReward"})
    b = _record(h, "grant", "denyAttestation", _uid(), {"source": "adReward"})
    assert a["audit_id"] != b["audit_id"]
    assert _count(h) == before + 2


# ── clients (authenticated / anon) can do NEITHER (re-asserts the server-only floor · R-K6) ───
@pytest.mark.parametrize("role", ["authenticated", "anon"])
def test_client_cannot_execute_fn(h, role):
    before = _count(h)
    with h.session(role, "") as cur:
        with pytest.raises(h.Error) as e:
            cur.execute(
                "SELECT record_audit_event(%s,%s,%s::uuid,%s::jsonb)",
                ("grant", "denyVelocity", _uid(), json.dumps({"source": "promo"})),
            )
        assert _is_denial(e.value), f"{role} could EXECUTE record_audit_event: {e.value}"
    assert _count(h) == before  # nothing written


@pytest.mark.parametrize("role", ["authenticated", "anon"])
def test_client_cannot_select(h, role):
    # seed a row as service_role first so a leak would be observable
    _record(h, "grant", "denyTurnstile", _uid(), {"source": "referral"})
    with h.session(role, "") as cur:
        with pytest.raises(h.Error) as e:
            cur.execute("SELECT category, action FROM audit_log")
        assert _is_denial(e.value), f"{role} could read audit_log: {e.value}"


@pytest.mark.parametrize("role", ["authenticated", "anon"])
def test_client_cannot_insert_directly(h, role):
    before = _count(h)
    with h.session(role, "") as cur:
        with pytest.raises(h.Error) as e:
            cur.execute(
                "INSERT INTO audit_log(category, action) VALUES ('grant','spoofed')"
            )
        assert _is_denial(e.value), f"{role} could INSERT into audit_log: {e.value}"
    assert _count(h) == before


# ── APPEND-ONLY: not even service_role may UPDATE or DELETE ───────────────────────────────────
def test_service_role_cannot_update(h):
    out = _record(h, "grant", "denyVelocity", _uid(), {"source": "promo"})
    with h.session("service_role", "") as cur:
        with pytest.raises(h.Error) as e:
            cur.execute("UPDATE audit_log SET action='tampered' WHERE audit_id=%s::uuid",
                        (str(out["audit_id"]),))
        assert _is_denial(e.value), f"audit_log was UPDATE-able: {e.value}"
    # value is unchanged
    assert _select_by_id(h, out["audit_id"])[1] == "denyVelocity"


def test_service_role_cannot_delete(h):
    out = _record(h, "grant", "denyVelocity", _uid(), {"source": "promo"})
    with h.session("service_role", "") as cur:
        with pytest.raises(h.Error) as e:
            cur.execute("DELETE FROM audit_log WHERE audit_id=%s::uuid", (str(out["audit_id"]),))
        assert _is_denial(e.value), f"audit_log row was DELETE-able: {e.value}"
    assert _select_by_id(h, out["audit_id"]) is not None  # still there


# ── fail closed on a malformed event; write NO row ───────────────────────────────────────────
@pytest.mark.parametrize("category,action", [("", "blocked"), ("   ", "blocked"),
                                             ("moderation", ""), ("moderation", "  ")])
def test_blank_category_or_action_rejected(h, category, action):
    before = _count(h)
    with pytest.raises(h.Error):
        _record(h, category, action, None, {"stage": "input"})
    assert _count(h) == before  # nothing written


@pytest.mark.parametrize("bad", ['"a string"', "42", "[1,2,3]", "true"])
def test_non_object_detail_rejected(h, bad):
    before = _count(h)
    with h.session("service_role", "") as cur:
        with pytest.raises(h.Error):
            cur.execute(
                "SELECT record_audit_event(%s,%s,NULL,%s::jsonb)",
                ("moderation", "blocked", bad),
            )
    assert _count(h) == before  # nothing written
