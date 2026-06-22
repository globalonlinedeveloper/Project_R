"""★ Ckpt D — SCHEMA LOCK evidence (T3). Every pilot seed (EN·ES·TA·JA + B1)
validates against the FROZEN schema.json at zero schema change, passes the 12-axis
gate, and together the pilot set exercises all 12 break-point axes."""
import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
import schema_loader  # noqa: E402
from pipeline.axis_gate import gate_batch  # noqa: E402
from pipeline.validate import run_validators  # noqa: E402

REPO = pathlib.Path(__file__).resolve().parents[2]
PILOTS = ["en", "es", "ta", "ja", "_pilot"]


def load(area: str) -> dict:
    return json.loads((REPO / "assets" / "content" / area / "seed.batch.json").read_text(encoding="utf-8"))


def _validate_all(batch: dict):
    bad = []
    for table, rows in batch["tables"].items():
        for i, row in enumerate(rows):
            errs = run_validators(table, row)
            if errs:
                bad.append((table, i, errs))
    return bad


def test_every_pilot_seed_is_schema_valid_zero_change():
    for area in PILOTS:
        assert _validate_all(load(area)) == [], f"{area} has non-conformant rows"


def test_every_pilot_seed_passes_the_12_axis_gate():
    for area in PILOTS:
        rep = gate_batch(load(area)["tables"])
        assert rep.passed, f"{area} gate failures: {[(r.axis, r.name, r.detail) for r in rep.failures()]}"


def test_ja_no_space_tokenization_axis1_pass():
    assert gate_batch(load("ja")["tables"]).summary()[1] == "pass"


def test_ta_grapheme_clusters_axis3_pass():
    assert gate_batch(load("ta")["tables"]).summary()[3] == "pass"


def test_pair_specific_depth_exercised():
    es_items = load("es")["tables"]["item"]
    assert any(i.get("source_locale") and i.get("contrast_type") for i in es_items)
    b1_items = load("_pilot")["tables"]["item"]
    assert any(i.get("cefr_level") == "B1" and i.get("contrast_type") in ("false_friend", "l1_interference") for i in b1_items)


def test_locale_axes_pass_across_language_seeds():
    for area in ["en", "es", "ta", "ja"]:
        s = gate_batch(load(area)["tables"]).summary()
        assert s[4] == "pass" and s[6] == "pass" and s[7] == "pass" and s[11] == "pass", f"{area}: {s}"


def test_all_12_axes_pass_somewhere_in_the_pilot_set():
    passed = set()
    for area in PILOTS:
        for r in gate_batch(load(area)["tables"]).results:
            if r.status == "pass":
                passed.add(r.axis)
    missing = set(range(1, 13)) - passed
    assert not missing, f"axes never passing across pilots: {sorted(missing)}"
