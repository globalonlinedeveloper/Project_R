"""L4 [P0-3 / TS-8] entitlement + credit ledger are CLIENT-READ-ONLY. Negative proofs on a
disposable pgserver DB: a logged-in `authenticated` user CANNOT grant themselves Pro
(write user.pro_until) nor mint credits (insert a credit_ledger grant) — the "free Pro /
infinite credits" holes — while `service_role` can. Skips where pgserver is absent."""
import pathlib
import sys
import tempfile

import pytest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import rls_harness  # noqa: E402

USERA = "11111111-1111-1111-1111-111111111111"
USERB = "22222222-2222-2222-2222-222222222222"


@pytest.fixture(scope="module")
def h():
    pgserver = rls_harness.require_pgserver()
    d = tempfile.mkdtemp(prefix="ratel_rls_ent_")
    harness = rls_harness.Harness(pgserver, d, ["0002_rls_entitlement.sql"])
    with harness.session() as cur:  # superuser seed (bypasses RLS)
        cur.execute(f"INSERT INTO \"user\"(user_id,created_at,updated_at) VALUES "
                    f"('{USERA}',now(),now()),('{USERB}',now(),now())")
        cur.execute("INSERT INTO \"credit_ledger\"(credit_ledger_id,user_id,entry_type,amount,client_event_id,created_at) "
                    f"VALUES (gen_random_uuid(),'{USERA}','grant',5,gen_random_uuid(),now())")
    yield harness
    harness.cleanup()


def _is_denial(exc) -> bool:
    m = str(exc).lower()
    return "permission denied" in m or "row-level security" in m or "violates row-level" in m


def test_authenticated_cannot_grant_self_pro(h):
    with h.session("authenticated", USERA) as cur:
        with pytest.raises(h.Error) as e:
            cur.execute(f"UPDATE \"user\" SET pro_until=now()+interval '999 days' WHERE user_id='{USERA}'")
        assert _is_denial(e.value), f"free-Pro hole OPEN: {e.value}"
    with h.session("service_role", "") as cur:  # confirm nothing was written
        cur.execute(f"SELECT pro_until FROM \"user\" WHERE user_id='{USERA}'")
        assert cur.fetchone()[0] is None, "pro_until was mutated by a client!"


def test_authenticated_cannot_mint_credits(h):
    with h.session("authenticated", USERA) as cur:
        with pytest.raises(h.Error) as e:
            cur.execute("INSERT INTO \"credit_ledger\"(credit_ledger_id,user_id,entry_type,amount,client_event_id,created_at) "
                        f"VALUES (gen_random_uuid(),'{USERA}','grant',9999,gen_random_uuid(),now())")
        assert _is_denial(e.value), f"infinite-credits hole OPEN: {e.value}"
    with h.session("service_role", "") as cur:
        cur.execute(f"SELECT coalesce(sum(amount),0) FROM \"credit_ledger\" WHERE user_id='{USERA}'")
        assert cur.fetchone()[0] == 5, "credit balance changed by a client!"


def test_authenticated_reads_only_own_rows(h):
    with h.session("authenticated", USERA) as cur:
        cur.execute(f"SELECT count(*) FROM \"user\" WHERE user_id='{USERA}'")
        assert cur.fetchone()[0] == 1
        cur.execute(f"SELECT count(*) FROM \"user\" WHERE user_id='{USERB}'")
        assert cur.fetchone()[0] == 0, "cross-user entitlement read leaked!"
        cur.execute("SELECT count(*) FROM \"credit_ledger\"")
        assert cur.fetchone()[0] == 1, "ledger read not scoped to the caller!"


def test_service_role_can_write_entitlement_and_credits(h):
    with h.session("service_role", "") as cur:
        cur.execute(f"UPDATE \"user\" SET pro_until=now() WHERE user_id='{USERB}'")
        cur.execute(f"SELECT pro_until FROM \"user\" WHERE user_id='{USERB}'")
        assert cur.fetchone()[0] is not None
        cur.execute("INSERT INTO \"credit_ledger\"(credit_ledger_id,user_id,entry_type,amount,client_event_id,created_at) "
                    f"VALUES (gen_random_uuid(),'{USERB}','grant',10,gen_random_uuid(),now())")
        cur.execute(f"SELECT count(*) FROM \"credit_ledger\" WHERE user_id='{USERB}'")
        assert cur.fetchone()[0] == 1


if __name__ == "__main__":
    import subprocess
    raise SystemExit(subprocess.call([sys.executable, "-m", "pytest", __file__, "-q"]))
