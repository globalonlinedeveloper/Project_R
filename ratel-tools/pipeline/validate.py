from __future__ import annotations

import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
import schema_loader  # noqa: E402


def schema_errors(table: str, row: dict) -> list[str]:
    """Validate a COMPLETE row (incl. provenance) against the frozen schema.json.
    T2.1 = schema conformance; the deterministic R-E4 validators land in T2.2."""
    return schema_loader.validate_row(table, row)
