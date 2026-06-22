"""Pinned reference tokenizers for the 12-axis gate (P0-7).
JA = MeCab/UniDic (fugashi + unidic-lite) · ZH = Jieba · TH = ICU (optional).
boundary_f1 compares authored token boundaries to the reference segmentation for
no-space scripts; spaced/unknown locales return None (axis-1 trivially satisfied)."""
from __future__ import annotations

import regex as _regex  # UAX-29 grapheme clusters via \X

_ja_tagger = None


def primary(locale: str) -> str:
    return (locale or "").split("-")[0].lower()


def _ja_segments(text: str) -> list[str]:
    global _ja_tagger
    if _ja_tagger is None:
        import fugashi
        _ja_tagger = fugashi.Tagger()
    return [w.surface for w in _ja_tagger(text) if w.surface]


def reference_segments(locale: str, text: str) -> list[str] | None:
    """Reference word segmentation for no-space scripts; None for spaced/unknown."""
    p = primary(locale)
    if p == "ja":
        return _ja_segments(text)
    if p == "zh":
        import jieba
        return [t for t in jieba.cut(text, cut_all=False) if t.strip()]
    if p == "th":
        try:
            import icu  # PyICU (optional; TH not in the pilot)
        except Exception:
            return None
        bi = icu.BreakIterator.createWordInstance(icu.Locale("th"))
        bi.setText(text)
        segs, prev = [], 0
        for b in bi:
            seg = text[prev:b]
            if seg.strip():
                segs.append(seg)
            prev = b
        return segs
    return None  # spaced (en/es/ta/...) or unmapped -> axis 1 trivially satisfied


def graphemes_uax29(text: str) -> list[str]:
    return _regex.findall(r"\X", text)


def _boundaries(segs: list[str]) -> set[int]:
    bounds, pos = set(), 0
    for s in segs[:-1]:
        pos += len(s)
        bounds.add(pos)
    return bounds


def boundary_f1(locale: str, authored_surfaces: list[str], text: str) -> float | None:
    """Boundary-F1 of authored token splits vs the reference tokenizer.
    None when the locale has no no-space reference (axis 1 is then trivially met)."""
    ref = reference_segments(locale, text)
    if ref is None:
        return None
    a, r = _boundaries(authored_surfaces), _boundaries(ref)
    if not a and not r:
        return 1.0
    tp = len(a & r)
    prec = tp / len(a) if a else (1.0 if not r else 0.0)
    rec = tp / len(r) if r else (1.0 if not a else 0.0)
    return 0.0 if (prec + rec) == 0 else 2 * prec * rec / (prec + rec)
