"""Shared pgserver + pg8000 harness for the Stage-3 RLS tests (L4/L5). Boots a DISPOSABLE
local PostgreSQL, installs Supabase-equivalent roles (authenticated/anon/service_role) + an
auth.uid() shim reading a JWT-sub GUC, applies the table DDL, then the requested RLS
migration(s). Bulk DDL is applied with the bundled psql (multi-statement); per-test queries
run through pg8000 so role/GUC switching and permission errors are caught precisely.
The live Supabase project is NEVER touched — only a local unix socket is opened."""
import os
import pathlib
import subprocess
import urllib.parse as up
from contextlib import contextmanager

import pytest

REPO = pathlib.Path(__file__).resolve().parents[2]
SQL = REPO / "schema" / "sql"

HARNESS_PREAMBLE = """
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='authenticated') THEN CREATE ROLE authenticated NOLOGIN; END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='anon') THEN CREATE ROLE anon NOLOGIN; END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname='service_role') THEN CREATE ROLE service_role NOLOGIN BYPASSRLS; END IF;
END $$;
CREATE SCHEMA IF NOT EXISTS auth;
CREATE OR REPLACE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $fn$
  SELECT NULLIF(current_setting('request.jwt.claim.sub', true), '')::uuid
$fn$;
GRANT USAGE ON SCHEMA auth TO authenticated, anon, service_role;
"""


def require_pgserver():
    return pytest.importorskip("pgserver")


def _bin(pgserver, name):
    return str(pathlib.Path(pgserver.__file__).resolve().parent / "pginstall" / "bin" / name)


class Harness:
    def __init__(self, pgserver, datadir, rls_files):
        import pg8000.dbapi as pg8000
        self._pg8000 = pg8000
        self.Error = pg8000.DatabaseError
        self.pgserver = pgserver
        self.server = pgserver.get_server(datadir)
        uri = up.urlparse(self.server.get_uri())
        host = up.parse_qs(uri.query)["host"][0]
        self._conn_args = dict(
            user=(uri.username or "postgres"),
            database=(uri.path or "/postgres").lstrip("/") or "postgres",
            unix_sock=os.path.join(host, f".s.PGSQL.{uri.port or 5432}"),
        )
        self._psql = _bin(pgserver, "psql")
        self._apply_sql((SQL / "0001_schema.sql").read_text(encoding="utf-8"))
        self._apply_sql(HARNESS_PREAMBLE)
        for f in rls_files:
            self._apply_sql((SQL / f).read_text(encoding="utf-8"))

    def _apply_sql(self, sql):
        r = subprocess.run([self._psql, self.server.get_uri(), "-v", "ON_ERROR_STOP=1", "-q", "-c", sql],
                           capture_output=True, text=True)
        if r.returncode:
            raise RuntimeError(f"psql apply failed: {r.stderr.strip()}")

    def _conn(self):
        c = self._pg8000.connect(**self._conn_args)
        c.autocommit = True
        return c

    @contextmanager
    def session(self, role=None, sub=None):
        """Yield a cursor; optionally auth.uid()=<sub> then SET ROLE <role>.
        role=None -> bootstrap superuser (bypasses RLS; use for seeding)."""
        c = self._conn()
        cur = c.cursor()
        try:
            if sub is not None:
                cur.execute("select set_config('request.jwt.claim.sub', %s, false)", (sub,))
            if role is not None:
                cur.execute(f"set role {role}")
            yield cur
        finally:
            c.close()

    def cleanup(self):
        self.server.cleanup()
