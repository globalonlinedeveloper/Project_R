"""T2.3 — pinned reference tokenizers + boundary-F1 (deterministic)."""
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from pipeline.tokenizers import boundary_f1, graphemes_uax29, reference_segments  # noqa: E402


def test_spaced_locale_has_no_reference():
    assert reference_segments("en", "I eat bread.") is None
    assert boundary_f1("en", ["I", "eat", "bread", "."], "I eat bread.") is None


def test_ja_matching_tokens_score_one():
    text = "水を飲みました"
    ref = reference_segments("ja", text)  # fugashi/unidic-lite
    assert ref and boundary_f1("ja", ref, text) == 1.0


def test_ja_wrong_tokens_below_floor():
    text = "水を飲みました"
    assert boundary_f1("ja", [text], text) < 0.95  # one giant token vs 5


def test_zh_matching_tokens_score_one():
    text = "我喜欢学习中文"
    ref = reference_segments("zh", text)
    assert ref and boundary_f1("zh", ref, text) == 1.0


def test_graphemes_uax29_tamil_clusters():
    assert graphemes_uax29("நாய்") == ["நா", "ய்"]
