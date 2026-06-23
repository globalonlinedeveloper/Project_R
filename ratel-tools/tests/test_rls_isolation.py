"""L5 [TS-2 / TS-3] generic deny-by-default RLS + cross-user isolation for every learner-owned
table, proven on a disposable pgserver DB. The user-table list is DERIVED from schema/tables/*.json
(every table carrying a user_id), so a new user table added without an RLS policy fails this test
BY CONSTRUCTION. The live Supabase project is NEVER touched. Skips where pgserver is absent."""
import json
import pathlib
import sys
import tempfile

import pytest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import rls_harness  # noqa: E402

REPO = pathlib.Path(__file__).resolve().parents[2]
TABLES_DIR = REPO / "schema" / "tables"

USERA = "11111111-1111-1111-1111-111111111111"
USERB = "22222222-2222-2222-2222-222222222222"


def _user_tables():
    """Every table in the source-of-truth carrying a user_id => a learner-owned table that MUST be
    RLS-isolated. Derived from the schema so a new user table cannot silently skip isolation."""
    out = []
    for f in sorted(TABLES_DIR.glob("*.schema.json")):
        props = json.loads(f.read_text(encoding="utf-8")).get("properties", {})
        if "user_id" in props:
            out.append(f.stem.replace(".schema", ""))
    return out


USER_TABLES = _user_tables()
EXPECTED = {"user", "user_course", "user_item_state", "user_phoneme_state",
            "placement_session", "review_log", "credit_ledger"}

# Minimal valid INSERT (column list, VALUES body with {uid} = the owner literal) per user table.
_SEED = {
    "user": ("user_id,created_at,updated_at",
             "{uid},now(),now()"),
    "user_course": ("user_course_id,user_id,target_locale,created_at,updated_at",
                    "gen_random_uuid(),{uid},'es',now(),now()"),
    "user_item_state": ("user_item_state_id,user_id,item_id,due,state,created_at,updated_at",
                        "gen_random_uuid(),{uid},'it1',now(),'new',now(),now()"),
    "user_phoneme_state": ("user_phoneme_state_id,user_id,phoneme_id,created_at,updated_at",
                           "gen_random_uuid(),{uid},'p1',now(),now()"),
    "placement_session": ("placement_session_id,user_id,target_locale,started_at",
                          "gen_random_uuid(),{uid},'es',now()"),
    "review_log": ("review_log_id,user_id,item_id,reviewed_at,rating",
                   "gen_random_uuid(),{uid},'it1',now(),3"),
    "credit_ledger": ("credit_ledger_id,user_id,entry_type,amount,client_event_id,created_at",
                      "gen_random_uuid(),{uid},'grant',5,gen_random_uuid(),now()"),
}


def _denied(exc) -> bool:
    m = str(exc).lower()
    return ("permission denied" in m or "row-level security" in m or "violates row-level" in m)


def _insert(cur, table, uid):
    cols, vals = _SEED[table]
    cur.execute(f'INSERT INTO "{table}"({cols}) VALUES ({vals.format(uid=chr(39) + uid + chr(39))})')


@pytest.fixture(scope="module")
def h():
    pgserver = rls_harness.require_pgserver()
    d = tempfile.mkdtemp(prefix="ratel_rls_iso_")
    harness = rls_harness.Harness(pgserver, d, ["0002_rls_entitlement.sql", "0003_rls_all_tables.sql"])
    with harness.session() as cur:  # bootstrap superuser seed (bypasses RLS even under FORCE)
        _insert(cur, "user", USERA)
        _insert(cur, "user", USERB)
        for t in USER_TABLES:
            if t == "user":
                continue
            _insert(cur, t, USERA)
            _insert(cur, t, USERB)
    yield harness
    harness.cleanup()


def test_user_table_list_is_complete():
    """Tripwire: the discovered learner-table set must match the 7 known user tables. A new user
    table (or a removed one) trips this until RLS + this list are reconciled — isolation by design."""
    assert set(USER_TABLES) == EXPECTED, f"user-table set drifted: {sorted(USER_TABLES)}"


@pytest.mark.parametrize("table", USER_TABLES)
def test_rls_enabled_and_forced(h, table):
    with h.session() as cur:  # superuser reads the catalog
        cur.execute("select relrowsecurity, relforcerowsecurity from pg_class where relname=%s", (table,))
        row = cur.fetchone()
        assert row is not None and list(row) == [True, True], \
            f"{table}: RLS not ENABLE+FORCE -> deny-by-default not guaranteed ({row})"


@pytest.mark.parametrize("table", USER_TABLES)
def test_cross_user_select_isolated(h, table):
    with h.session("authenticated", USERA) as cur:
        cur.execute(f'SELECT count(*) FROM "{table}" WHERE user_id = %s', (USERB,))
        assert cur.fetchone()[0] == 0, f"{table}: user A can SEE user B's rows (cross-user read leak)"
        cur.execute(f'SELECT count(*) FROM "{table}" WHERE user_id = %s', (USERA,))
        assert cur.fetchone()[0] >= 1, f"{table}: own-row SELECT blocked (policy too strict)"


@pytest.mark.parametrize("table", USER_TABLES)
def test_cross_user_write_blocked(h, table):
    """A may NEVER modify B's row: either RLS hides it (0 rows) or the privilege is denied."""
    with h.session("authenticated", USERA) as cur:
        try:
            cur.execute(f'UPDATE "{table}" SET user_id = user_id WHERE user_id = %s', (USERB,))
            assert cur.rowcount == 0, f"{table}: user A UPDATED user B's row! (rowcount={cur.rowcount})"
        except h.Error as e:
            assert _denied(e), f"{table}: unexpected error (not an isolation denial): {e}"
    with h.session() as cur:  # B's row is intact and still owned by B
        cur.execute(f'SELECT count(*) FROM "{table}" WHERE user_id = %s', (USERB,))
        assert cur.fetchone()[0] == 1, f"{table}: user B's row was lost/mutated"


def test_review_log_foreign_uid_insert_denied(h):
    """Append-only audit integrity: A cannot forge a review_log row for B (WITH CHECK = own only)."""
    with h.session("authenticated", USERA) as cur:
        with pytest.raises(h.Error) as e:
            cur.execute('INSERT INTO "review_log"(review_log_id,user_id,item_id,reviewed_at,rating) '
                        "VALUES (gen_random_uuid(),%s,'forge',now(),3)", (USERB,))
        assert _denied(e.value), f"review_log foreign-uid insert NOT denied: {e.value}"


def test_own_row_writes_allowed(h):
    """Positive: the policies permit legitimate own-row writes (not a blanket deny)."""
    with h.session("authenticated", USERA) as cur:
        cur.execute('INSERT INTO "user_item_state"(user_item_state_id,user_id,item_id,due,state,created_at,updated_at) '
                    "VALUES (gen_random_uuid(),%s,'own1',now(),'new',now(),now())", (USERA,))
        cur.execute('INSERT INTO "review_log"(review_log_id,user_id,item_id,reviewed_at,rating) '
                    "VALUES (gen_random_uuid(),%s,'mine',now(),4)", (USERA,))
    with h.session() as cur:
        cur.execute('SELECT count(*) FROM "user_item_state" WHERE user_id=%s', (USERA,))
        assert cur.fetchone()[0] >= 2
        cur.execute('SELECT count(*) FROM "review_log" WHERE user_id=%s AND item_id=%s', (USERA, "mine"))
        assert cur.fetchone()[0] == 1


def test_service_role_bypasses_isolation(h):
    """service_role (server) sees every user's rows — needed for FSRS scheduling / DSAR / admin."""
    with h.session("service_role", "") as cur:
        cur.execute('SELECT count(distinct user_id) FROM "user_item_state"')
        assert cur.fetchone()[0] >= 2, "service_role cannot see all users' rows"


if __name__ == "__main__":
    import subprocess
    raise SystemExit(subprocess.call([sys.executable, "-m", "pytest", __file__, "-q"]))
