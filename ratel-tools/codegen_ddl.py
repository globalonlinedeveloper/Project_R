#!/usr/bin/env python3
"""L2 [Part D] DDL generator: schema/ (JSON-Schema SoT, P0-6) -> schema/sql/0001_schema.sql.

Emits PostgreSQL DDL for the Stage-3 user/runtime tables so a DISPOSABLE local
PostgreSQL (pgserver) can be created and pg_dump-round-tripped (L3 / checklist Part D).
Content tables are intentionally NOT emitted here — they remain bundled JSON assets
until a later content-in-DB migration; this file is the user-state schema (P0-2).

Design rules (per backlog L2):
  * JSON-Schema -> PG types; enums -> CREATE TYPE; open object/array -> jsonb.
  * review_log is PARTITION BY RANGE (reviewed_at), monthly (pg_partman in prod;
    declarative partitions emitted here so a vanilla PG round-trips deterministically).
  * user_item_state carries the (user_id, due) review-queue index.
  * credit_ledger.client_event_id is UNIQUE (idempotency).
  * child tables FK user_id -> "user"(user_id) ON DELETE CASCADE (DSAR cascade, P0-4).
  * fail-LOUD (SystemExit) on any unrepresentable construct; deterministic ordering.
"""
from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
SCHEMA = ROOT / "schema"
OUT = ROOT / "schema" / "sql" / "0001_schema.sql"

# Deterministic table order; "user" first so child FKs resolve.
USER_TABLES = ["user", "user_course", "user_item_state", "user_phoneme_state",
               "placement_session", "review_log", "credit_ledger",
               "friendship", "friend_activity", "league_cohort", "league_member"]

PK = {
    "user": ["user_id"],
    "user_course": ["user_course_id"],
    "user_item_state": ["user_item_state_id"],
    "user_phoneme_state": ["user_phoneme_state_id"],
    "placement_session": ["placement_session_id"],
    "review_log": ["review_log_id", "reviewed_at"],  # partition key MUST be in the PK
    "credit_ledger": ["credit_ledger_id"],
    "friendship": ["friendship_id"],
    "friend_activity": ["friend_activity_id"],
    "league_cohort": ["league_cohort_id"],
    "league_member": ["league_member_id"],
}
PARTITION_BY = {"review_log": "reviewed_at"}
PARTITIONS = {  # concrete monthly partitions (what pg_partman would automate)
    "review_log": [
        ("review_log_2026_06", "2026-06-01", "2026-07-01"),
        ("review_log_2026_07", "2026-07-01", "2026-08-01"),
    ],
}
UNIQUES = {
    "user_course": [["user_id", "target_locale"]],
    "user_item_state": [["user_id", "item_id"]],
    "credit_ledger": [["client_event_id"]],
    "friendship": [["user_id", "friend_id"]],
    "league_member": [["user_id", "week_start"]],
}
INDEXES = {
    "user_item_state": [["user_id", "due"]],
    "review_log": [["user_id", "reviewed_at"]],
    "friend_activity": [["user_id", "at"]],
    "league_member": [["cohort_id", "week_start"]],
}
FK_USER = ["user_course", "user_item_state", "user_phoneme_state",
           "placement_session", "review_log", "credit_ledger",
           "friendship", "friend_activity", "league_member"]

# Non-user foreign keys: {table: [(column, ref_table, ref_column, on_delete), ...]}.
# league_member.cohort_id -> league_cohort(league_cohort_id): cohort FORMATION assigns
# it (NULL until then, so the FK is on a NULLABLE column). league_cohort is emitted
# before league_member (USER_TABLES order) so the reference resolves. ON DELETE SET
# NULL: dropping a cohort de-assigns its members (their own-row standing survives,
# re-formed on the next read) — never a cascade delete of a learner's standing.
FK_EXTRA = {
    "league_member": [("cohort_id", "league_cohort", "league_cohort_id", "SET NULL")],
}


def _load(rel: str) -> dict:
    return json.loads((SCHEMA / rel).read_text(encoding="utf-8"))


ENUMS = _load("enums/enums.schema.json")["$defs"]


def _refname(ref: str) -> str:
    return ref.split("#/$defs/")[-1]


def pg_type(prop: dict, ctx: str) -> tuple[str, str | None]:
    """Return (sql_type, enum_name_or_None). Fail loud on anything unrepresentable."""
    if "$ref" in prop:
        n = _refname(prop["$ref"])
        if "enums.json" in prop["$ref"]:
            d = ENUMS[n]
            if "enum" in d:
                return n, n
            return ("integer", None) if d.get("type") == "integer" else ("text", None)
        if n in ("uuid", "user_id"):
            return "uuid", None
        if n in ("content_id", "bcp47"):
            return "text", None
        return "jsonb", None  # open containers / payload objects
    if "oneOf" in prop:
        non_null = [x for x in prop["oneOf"] if x.get("type") != "null"]
        if len(non_null) != 1:
            raise SystemExit(f"L2: unrepresentable oneOf at {ctx}: {prop}")
        return pg_type(non_null[0], ctx)
    t = prop.get("type")
    if t == "string":
        fmt = prop.get("format")
        if fmt == "date-time":
            return "timestamptz", None
        if fmt == "uuid":
            return "uuid", None
        if fmt == "date":
            return "date", None
        return "text", None
    if t == "integer":
        return "integer", None
    if t == "number":
        return "double precision", None
    if t == "boolean":
        return "boolean", None
    if t in ("object", "array"):
        return "jsonb", None
    raise SystemExit(f"L2: unrepresentable construct at {ctx}: {prop}")


def generate() -> str:
    used_enums: set[str] = set()
    table_sql: list[str] = []

    for tbl in USER_TABLES:
        doc = _load(f"tables/{tbl}.schema.json")
        props = doc["properties"]
        required = set(doc.get("required", []))
        pk = PK[tbl]
        cols: list[str] = []
        for col, sub in props.items():
            sqlt, enm = pg_type(sub, f"{tbl}.{col}")
            if enm:
                used_enums.add(enm)
            not_null = " NOT NULL" if (col in required or col in pk) else ""
            cols.append(f'    {col} {sqlt}{not_null}')
        cols.append(f'    PRIMARY KEY ({", ".join(pk)})')
        for uq in UNIQUES.get(tbl, []):
            cols.append(f'    UNIQUE ({", ".join(uq)})')
        if tbl in FK_USER:
            cols.append('    FOREIGN KEY (user_id) REFERENCES "user" (user_id) ON DELETE CASCADE')
        for _col, _rtbl, _rcol, _ondel in FK_EXTRA.get(tbl, []):
            cols.append(
                f'    FOREIGN KEY ({_col}) REFERENCES "{_rtbl}" ({_rcol}) ON DELETE {_ondel}')
        body = ",\n".join(cols)
        part = f" PARTITION BY RANGE ({PARTITION_BY[tbl]})" if tbl in PARTITION_BY else ""
        table_sql.append(f'CREATE TABLE "{tbl}" (\n{body}\n){part};')
        for pname, lo, hi in PARTITIONS.get(tbl, []):
            table_sql.append(
                f'CREATE TABLE "{pname}" PARTITION OF "{tbl}" '
                f"FOR VALUES FROM ('{lo}') TO ('{hi}');")
        for idx in INDEXES.get(tbl, []):
            table_sql.append(
                f'CREATE INDEX ON "{tbl}" ({", ".join(idx)});')

    enum_sql = []
    for name in sorted(used_enums):
        vals = ", ".join(f"'{v}'" for v in ENUMS[name]["enum"])
        enum_sql.append(f"CREATE TYPE {name} AS ENUM ({vals});")

    header = (
        "-- GENERATED by ratel-tools/codegen_ddl.py from schema/ (P0-6). DO NOT EDIT BY HAND.\n"
        "-- Stage-3 user/runtime schema (P0-2). Apply to a DISPOSABLE pgserver DB only;\n"
        "-- the live Supabase project is never touched. Regenerate: python3 ratel-tools/codegen_ddl.py\n"
    )
    return header + "\n" + "\n".join(enum_sql) + "\n\n" + "\n\n".join(table_sql) + "\n"


if __name__ == "__main__":
    OUT.parent.mkdir(parents=True, exist_ok=True)
    sql = generate()
    OUT.write_text(sql, encoding="utf-8")
    print(f"wrote {OUT.relative_to(ROOT)} ({len(sql)} bytes, {sql.count('CREATE TABLE')} tables, "
          f"{sql.count('CREATE TYPE')} enum types)")
