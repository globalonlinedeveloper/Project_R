"""L3 [Part D] pg_dump diff = 0 — the generated Stage-3 DDL round-trips through a REAL
PostgreSQL with ZERO schema drift, on a DISPOSABLE local DB (the live Supabase project is
NEVER touched). Proof: apply schema/sql/0001_schema.sql to DB-A, `pg_dump --schema-only`;
apply that dump verbatim to a fresh DB-B, dump again; the normalized dumps are identical.
The pgserver-backed test skips cleanly where pgserver is unavailable (e.g. CI) so the gate
stays green; the cheap artifact-drift guard runs everywhere."""
import pathlib
import subprocess
import sys
import tempfile

import pytest

REPO = pathlib.Path(__file__).resolve().parents[2]
DDL = REPO / "schema" / "sql" / "0001_schema.sql"
USER_TABLES = ("user", "user_course", "user_item_state", "user_phoneme_state",
               "placement_session", "review_log", "credit_ledger")


def _regen_ddl() -> str:
    sys.path.insert(0, str(REPO / "ratel-tools"))
    import codegen_ddl  # noqa: E402
    return codegen_ddl.generate()


def _norm(dump: str) -> list[str]:
    return [s.strip() for s in dump.splitlines()
            if s.strip() and not s.strip().startswith("--")]


def test_generated_ddl_matches_committed_artifact():
    """SoT drift guard (no DB needed): the committed .sql == the generator output."""
    assert DDL.read_text(encoding="utf-8") == _regen_ddl(), (
        "schema/sql/0001_schema.sql is stale — re-run python3 ratel-tools/codegen_ddl.py")


def _bin(pgserver, name: str) -> str:
    return str(pathlib.Path(pgserver.__file__).resolve().parent / "pginstall" / "bin" / name)


def _apply(pgserver, uri: str, sql_path: pathlib.Path):
    subprocess.run([_bin(pgserver, "psql"), uri, "-v", "ON_ERROR_STOP=1", "-q", "-f", str(sql_path)],
                   check=True, capture_output=True, text=True)


def _dump(pgserver, uri: str) -> str:
    r = subprocess.run([_bin(pgserver, "pg_dump"), uri, "--schema-only", "--no-owner", "--no-privileges"],
                       check=True, capture_output=True, text=True)
    return r.stdout


def test_pg_dump_diff_is_zero():
    pgserver = pytest.importorskip("pgserver")
    a_dir = tempfile.mkdtemp(prefix="ratel_pgA_")
    b_dir = tempfile.mkdtemp(prefix="ratel_pgB_")
    srv_a = pgserver.get_server(a_dir)
    srv_b = pgserver.get_server(b_dir)
    try:
        # DB-A: apply the generated DDL, dump the schema
        _apply(pgserver, srv_a.get_uri(), DDL)
        dump_a = _dump(pgserver, srv_a.get_uri())
        # DB-B: apply DB-A's dump verbatim, dump again
        with tempfile.NamedTemporaryFile("w", suffix=".sql", delete=False) as f:
            f.write(dump_a)
            dump_a_path = pathlib.Path(f.name)
        _apply(pgserver, srv_b.get_uri(), dump_a_path)
        dump_b = _dump(pgserver, srv_b.get_uri())
        # diff = 0
        na, nb = _norm(dump_a), _norm(dump_b)
        drift = [f"A:{a!r} != B:{b!r}" for a, b in zip(na, nb) if a != b]
        assert na == nb and len(na) == len(nb), "pg_dump round-trip drift:\n" + "\n".join(drift)[:2000]
        # sanity: every user table + the 4 enum types really landed
        for t in USER_TABLES:
            assert f'public."{t}"' in dump_a or f"public.{t} " in dump_a, f"{t} missing from dump"
        for ty in ("cefr_level", "fsrs_state", "grant_source", "ledger_entry_type"):
            assert f"CREATE TYPE public.{ty}" in dump_a, f"enum {ty} missing from dump"
    finally:
        srv_a.cleanup()
        srv_b.cleanup()


if __name__ == "__main__":
    test_generated_ddl_matches_committed_artifact()
    print("PASS  generated DDL matches committed artifact")
    test_pg_dump_diff_is_zero()
    print("PASS  pg_dump diff = 0")
