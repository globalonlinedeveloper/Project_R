"""T2.3 — 12-axis gate: green on conformant, red on broken; EN end-to-end (Ckpt C)."""
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from pipeline.axis_gate import gate_batch  # noqa: E402
from pipeline.run import run_pipeline  # noqa: E402
from pipeline.tokenizers import reference_segments  # noqa: E402


def _ja_sentence(surfaces):
    return {"sentence_id": "sentence_ja_1", "locale": "ja", "target_text": "水を飲みました",
            "tokens": [{"surface": s} for s in surfaces], "cefr_level": "A2"}


def test_conformant_ja_batch_passes_axis1():
    text = "水を飲みました"
    rep = gate_batch({"sentence": [_ja_sentence(reference_segments("ja", text))]})
    assert rep.passed
    assert rep.summary()[1] == "pass"


def test_broken_ja_tokens_fail_axis1():
    rep = gate_batch({"sentence": [_ja_sentence(["水を飲みました"])]})  # one giant token
    assert not rep.passed
    assert rep.summary()[1] == "fail"


def test_grapheme_axis_fails_on_non_uax29_clusters():
    s = {"sentence_id": "s", "locale": "ta", "target_text": "நாய்",
         "tokens": [{"surface": "நாய்"}], "graphemes": ["ந", "ா", "ய", "்"], "cefr_level": "A1"}
    assert gate_batch({"sentence": [s]}).summary()[3] == "fail"


def test_locale_axes_pass_on_valid_locale():
    loc = {"code": "ja", "name": "Japanese", "direction": "ltr", "plural_categories": ["other"],
           "script_meta": {"script": "Jpan"}, "tts_tier": "hd", "pron_tier": "asr"}
    s = gate_batch({"locale": [loc]}).summary()
    assert s[4] == "pass" and s[6] == "pass" and s[7] == "pass" and s[11] == "pass"


def test_locale_axis_fails_on_bad_plural_category():
    loc = {"code": "xx", "name": "X", "direction": "ltr", "plural_categories": ["lots"],
           "script_meta": {"script": "Latn"}, "tts_tier": "hd", "pron_tier": "asr"}
    assert gate_batch({"locale": [loc]}).summary()[11] == "fail"


def test_ckpt_c_en_pipeline_batch_gated_end_to_end():
    batch, _, _ = run_pipeline("en", "mcq", 3)
    rep = gate_batch(batch["tables"])
    assert rep.passed                       # gated, schema-valid EN batch end-to-end
    assert rep.summary()[10] == "pass"      # items carry answer_spec
