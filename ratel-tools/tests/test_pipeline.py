"""T2.1 pipeline scaffold tests: dry-run emits a gated, schema-valid EN batch;
deterministic + offline (subscription-only, no metered API); gate routes
low-jury / invalid candidates to needs_review (held back, not published)."""
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
import schema_loader  # noqa: E402
from pipeline.generate import StubGenerator  # noqa: E402
from pipeline.jury import StubJury  # noqa: E402
from pipeline.run import main, run_pipeline  # noqa: E402
from pipeline.types import JuryVerdict  # noqa: E402


def test_dryrun_emits_gated_en_batch():
    batch, summary, _ = run_pipeline("en", "mcq", 3)
    assert batch["locale"] == "en"
    assert summary == {"candidates": 3, "auto_certified": 3, "needs_review": 0}
    items = batch["tables"]["item"]
    assert len(items) == 3
    for row in items:
        assert schema_loader.validate_row("item", row) == []  # schema-valid output
        assert row["provenance"]["review_status"] == "auto_certified"
        assert row["provenance"]["provenance"] == "ai_generated"


def test_deterministic_and_offline():
    a, _, _ = run_pipeline("en", "mcq", 4)
    b, _, _ = run_pipeline("en", "mcq", 4)
    assert a == b  # reproducible; StubGenerator/StubJury never touch the network


def test_low_jury_routes_to_needs_review_and_publishes_nothing():
    class LowJury(StubJury):
        def assess(self, candidate):
            return JuryVerdict(score=0.5, notes="forced-low")

    batch, summary, _ = run_pipeline("en", "mcq", 2, jury=LowJury())
    assert summary["auto_certified"] == 0
    assert summary["needs_review"] == 2
    assert batch["tables"] == {}  # nothing below threshold is published


def test_invalid_candidate_is_blocked_from_publish():
    class BadGen(StubGenerator):
        def generate(self, locale, exercise_type, count):
            cands = super().generate(locale, exercise_type, count)
            cands[0].row["cefr_level"] = "ZZ"  # invalid enum -> validator fails
            return cands

    batch, summary, _ = run_pipeline("en", "mcq", 2, generator=BadGen())
    assert summary["needs_review"] >= 1
    published = batch["tables"].get("item", [])
    assert all(schema_loader.validate_row("item", r) == [] for r in published)
    assert "item_en_mcq_0001" not in [r["item_id"] for r in published]


def test_cli_dry_run_returns_zero():
    assert main(["--locale", "en", "--type", "mcq", "--count", "2"]) == 0


def test_emitted_batch_is_loadable_shape():
    # the emitted batch matches the ContentLoader envelope (batch_id/locale/tables{})
    batch, _, _ = run_pipeline("en", "mcq", 1)
    assert set(batch) >= {"batch_id", "locale", "tables"}
    assert isinstance(batch["tables"], dict)
