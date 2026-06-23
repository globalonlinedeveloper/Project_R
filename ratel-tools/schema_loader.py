"""Load the modular schema.json (P0-6, R-C1) into a referencing Registry and
expose per-table Draft 2020-12 validators. The schema/ dir is the single source
of truth, imported by generator, validator, and (via codegen) the app."""
from __future__ import annotations

import json
import pathlib
from functools import lru_cache

from jsonschema import Draft202012Validator
from referencing import Registry, Resource
from referencing.jsonschema import DRAFT202012

SCHEMA_DIR = pathlib.Path(__file__).resolve().parent.parent / "schema"

TABLES = (
    "sentence", "vocab_entry", "sense", "grammar_point", "phoneme",
    "item", "locale", "media_asset", "gloss",
    # Stage-3 user/runtime tables (P0-2, L1) — additive; content tables above stay frozen.
    "user", "user_course", "user_item_state", "user_phoneme_state",
    "placement_session", "review_log", "credit_ledger",
)


def schema_files() -> list[pathlib.Path]:
    files = [
        SCHEMA_DIR / "schema.json",
        SCHEMA_DIR / "enums" / "enums.schema.json",
        SCHEMA_DIR / "defs" / "common.schema.json",
    ]
    files += [SCHEMA_DIR / "tables" / f"{t}.schema.json" for t in TABLES]
    return files


def _load(path: pathlib.Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


@lru_cache(maxsize=1)
def build_registry() -> Registry:
    resources = []
    for f in schema_files():
        doc = _load(f)
        resources.append((doc["$id"], Resource.from_contents(doc, default_specification=DRAFT202012)))
    return Registry().with_resources(resources)


@lru_cache(maxsize=None)
def validator_for(table: str) -> Draft202012Validator:
    if table not in TABLES:
        raise KeyError(f"unknown table: {table}")
    doc = _load(SCHEMA_DIR / "tables" / f"{table}.schema.json")
    return Draft202012Validator(doc, registry=build_registry())


def validate_row(table: str, row: dict) -> list[str]:
    """Return human-readable error strings; [] means the row is valid."""
    return [f"{list(e.path)}: {e.message}" for e in validator_for(table).iter_errors(row)]


def check_all_schemas() -> list[tuple[str, str]]:
    """Assert every schema file is itself a valid 2020-12 schema (the lint)."""
    problems = []
    for f in schema_files():
        try:
            Draft202012Validator.check_schema(_load(f))
        except Exception as exc:  # noqa: BLE001
            problems.append((f.name, str(exc)))
    return problems
