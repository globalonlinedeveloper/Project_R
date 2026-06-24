"""Drift guard for the RTM generator (ratel-tools/gen_traceability.py).

Two cheap, hermetic checks (pure stdlib — no DB harness):

  (a) the canonical DATA list parses to exactly 161 UNIQUE, well-formed requirement IDs;
  (b) the committed docs/REQUIREMENTS_TRACEABILITY.md is UP TO DATE — re-running the
      generator must reproduce it byte-for-byte. A stale matrix (someone edited code/
      registry without regenerating) fails the build.

The generator is hermetic (the 161 ID+title pairs are mirrored in DATA) and idempotent
(its own override registry is excluded from the evidence scan), so this is deterministic
in CI.
"""
import importlib.util
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
TOOLS = os.path.dirname(HERE)
ROOT = os.path.dirname(TOOLS)
GEN = os.path.join(TOOLS, "gen_traceability.py")
MATRIX = os.path.join(ROOT, "docs", "REQUIREMENTS_TRACEABILITY.md")


def _load_gen():
    spec = importlib.util.spec_from_file_location("gen_traceability", GEN)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)  # safe: main() is guarded by __name__ == "__main__"
    return mod


def test_data_parses_to_161_unique_ids():
    mod = _load_gen()
    ids = [ln.split("|", 1)[0] for ln in mod.DATA.strip().splitlines()]
    assert len(ids) == 161, f"expected 161 requirement IDs, got {len(ids)}"
    assert len(set(ids)) == 161, "duplicate requirement IDs in DATA"
    bad = [i for i in ids if not re.match(r"R-[A-Za-z0-9-]+$", i)]
    assert not bad, f"malformed requirement IDs: {bad}"


def test_matrix_is_up_to_date():
    assert os.path.exists(MATRIX), (
        "docs/REQUIREMENTS_TRACEABILITY.md missing — run: "
        "python3 ratel-tools/gen_traceability.py"
    )
    before = open(MATRIX, encoding="utf-8").read()
    res = subprocess.run(
        [sys.executable, GEN], capture_output=True, text=True, cwd=ROOT
    )
    assert res.returncode == 0, f"generator exited {res.returncode}: {res.stderr}"
    after = open(MATRIX, encoding="utf-8").read()
    assert after == before, (
        "docs/REQUIREMENTS_TRACEABILITY.md is STALE vs the generator — rerun "
        "`python3 ratel-tools/gen_traceability.py` and commit the regenerated matrix."
    )
