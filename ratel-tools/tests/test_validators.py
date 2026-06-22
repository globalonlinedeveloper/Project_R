"""T2.2 — each R-E4 validator has a pass + fail case (deterministic, offline)."""
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from pipeline.validate import (  # noqa: E402
    back_translation_errors, length_errors, no_leak_errors, run_validators, script_charset_errors,
)

PROV = {"batch_id": "b", "provenance": "ai_generated", "review_status": "auto_certified",
        "content_version": 1, "created_at": "2026-06-23T00:00:00Z", "updated_at": "2026-06-23T00:00:00Z"}


def _sentence(**over):
    row = {"sentence_id": "sentence_x", "locale": "en", "target_text": "I eat bread.",
           "tokens": [{"surface": "I"}, {"surface": "eat"}, {"surface": "bread"}, {"surface": "."}],
           "cefr_level": "A1", "provenance": PROV}
    row.update(over)
    return row


def test_length_pass_and_fail():
    assert length_errors("sentence", _sentence()) == []
    assert length_errors("sentence", _sentence(target_text="")) != []
    assert length_errors("sentence", _sentence(tokens=[])) != []


def test_script_pass_latin_and_tamil():
    assert script_charset_errors("sentence", _sentence()) == []
    ta = {"sentence_id": "s", "locale": "ta", "target_text": "நாய்",
          "tokens": [{"surface": "நாய்"}], "cefr_level": "A1", "provenance": PROV}
    assert script_charset_errors("sentence", ta) == []


def test_script_fail_wrong_script():
    assert script_charset_errors("sentence", _sentence(locale="ta")) != []  # Latin text, ta locale


def test_tokens_coverage_fail():
    assert script_charset_errors("sentence", _sentence(tokens=[{"surface": "I"}, {"surface": "eat"}])) != []


def test_no_leak_pass_and_fail():
    assert no_leak_errors(["bebé"], "Translate: the baby") == []
    assert no_leak_errors(["baby"], "Translate the baby please") != []


def test_back_translation_pass_and_fail():
    class Good:
        def back_translate(self, text, src_locale, via_locale="en"):
            return "the baby"

    class Bad:
        def back_translate(self, text, src_locale, via_locale="en"):
            return "zzzzz"

    assert back_translation_errors("the baby", "el bebé", Good()) == []
    assert back_translation_errors("the baby", "el bebé", Bad()) != []


def test_run_validators_aggregates_schema_and_intrinsics():
    assert run_validators("sentence", _sentence()) == []
    assert run_validators("sentence", _sentence(cefr_level="ZZ")) != []  # schema enum
    assert run_validators("sentence", _sentence(locale="ta")) != []      # script
