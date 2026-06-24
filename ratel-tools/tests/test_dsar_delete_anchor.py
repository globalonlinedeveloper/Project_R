# BUILD-AHEAD — not deployed; pending human review + go-live wiring.
#
# DSAR-1 [R-K4] tests for schema/sql/0007 on a DISPOSABLE pgserver. 0001 declares no FK
# from public.user -> auth.users, so an account delete (auth.users row removed by Supabase)
# would orphan every public.* row. 0007 adds the ON DELETE CASCADE anchor. These prove:
# deleting auth.users cascades through public.user to ALL child tables (no orphans); a
# public.user with no matching auth.users row is rejected (the anchor is enforced); and the
# migration is idempotent. auth.users is mocked via the harness extra_preamble (Supabase
# provides the real one). The live Supabase project is never touched.
import pathlib
import sys
import tempfile
import uuid as uuidlib

import pytest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import rls_harness  # noqa: E402

# Minimal stand-in for the Supabase-managed auth.users (id is what public.user references).
MOCK_AUTH = """
CREATE TABLE IF NOT EXISTS auth.users (
  id    uuid PRIMARY KEY,
  email text
);
GRANT ALL ON auth.users TO service_role;
"""

_CHILD_TABLES = ("user", "user_course", "review_log", "credit_ledger")


@pytest.fixture()
def h():
    pgserver = rls_harness.require_pgserver()
    d = tempfile.mkdtemp(prefix="ratel_dsar_")
    harness = rls_harness.Harness(
        pgserver, d, ["0007_dsar_delete_anchor.sql"], extra_preamble=MOCK_AUTH)
    yield harness
    harness.cleanup()


def _uid():
    return str(uuidlib.uuid4())


def _seed_full_user(h, uid):
    """auth.users + public.user + one row in several ON DELETE CASCADE children."""
    with h.session() as cur:  # superuser seed (bypasses RLS)
        cur.execute(
            "INSERT INTO auth.users(id,email) VALUES (%s::uuid,'a@example.test')", (uid,))
        cur.execute(
            'INSERT INTO "user"(user_id,created_at,updated_at) '
            'VALUES (%s::uuid,now(),now())', (uid,))
        cur.execute(
            'INSERT INTO user_course(user_course_id,user_id,target_locale,created_at,updated_at) '
            'VALUES (%s::uuid,%s::uuid,%s,now(),now())', (_uid(), uid, 'es-ES'))
        cur.execute(
            'INSERT INTO review_log(review_log_id,user_id,item_id,reviewed_at,rating) '
            "VALUES (%s::uuid,%s::uuid,'it_1','2026-06-15T00:00:00Z',3)", (_uid(), uid))
        cur.execute(
            'INSERT INTO credit_ledger'
            '(credit_ledger_id,user_id,entry_type,amount,client_event_id,created_at) '
            "VALUES (%s::uuid,%s::uuid,'grant',10,%s::uuid,now())", (_uid(), uid, _uid()))


def _counts(h, uid):
    out = {}
    with h.session() as cur:
        for tbl in _CHILD_TABLES:
            cur.execute('SELECT count(*) FROM "%s" WHERE user_id=%%s::uuid' % tbl, (uid,))
            out[tbl] = cur.fetchone()[0]
    return out


def test_deleting_auth_user_cascades_no_orphans(h):
    uid = _uid()
    _seed_full_user(h, uid)
    assert _counts(h, uid) == {t: 1 for t in _CHILD_TABLES}  # seeded
    with h.session() as cur:  # the account deletion Supabase performs
        cur.execute("DELETE FROM auth.users WHERE id=%s::uuid", (uid,))
    assert _counts(h, uid) == {t: 0 for t in _CHILD_TABLES}  # NO orphans survive erasure


def test_user_without_auth_row_is_rejected(h):
    ghost = _uid()  # never inserted into auth.users
    with h.session() as cur:
        with pytest.raises(h.Error):
            cur.execute(
                'INSERT INTO "user"(user_id,created_at,updated_at) '
                'VALUES (%s::uuid,now(),now())', (ghost,))


def test_migration_is_idempotent(h):
    # Re-applying 0007 must not error (guarded ADD CONSTRAINT) and must keep the anchor.
    sql = (rls_harness.SQL / "0007_dsar_delete_anchor.sql").read_text(encoding="utf-8")
    with h.session() as cur:
        cur.execute(sql)
    ghost = _uid()
    with h.session() as cur:
        with pytest.raises(h.Error):
            cur.execute(
                'INSERT INTO "user"(user_id,created_at,updated_at) '
                'VALUES (%s::uuid,now(),now())', (ghost,))
