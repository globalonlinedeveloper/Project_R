"""T2.2 deterministic validators (R-E4). Pure-Python, NETWORK-FREE.
Each validator returns list[str] (empty == pass). `run_validators` is the
row-intrinsic aggregator the pipeline calls; `no_leak_errors` and
`back_translation_errors` take extra inputs (prompt context / a translator hook)
and are invoked once generation supplies them."""
from __future__ import annotations

import difflib
import pathlib
import re
import sys
import unicodedata
from typing import Protocol

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
import schema_loader  # noqa: E402


# --- schema: structural conformance to the frozen schema.json ---
def schema_errors(table: str, row: dict) -> list[str]:
    return [f"schema: {e}" for e in schema_loader.validate_row(table, row)]


# --- length bounds ---
def length_errors(table: str, row: dict) -> list[str]:
    errs: list[str] = []
    if table == "sentence":
        tt = row.get("target_text", "")
        if not 1 <= len(tt) <= 500:
            errs.append(f"length: target_text {len(tt)} out of [1,500]")
        toks = row.get("tokens") or []
        if not 1 <= len(toks) <= 120:
            errs.append(f"length: tokens {len(toks)} out of [1,120]")
        for i, t in enumerate(toks):
            s = (t or {}).get("surface", "")
            if not 1 <= len(s) <= 100:
                errs.append(f"length: token[{i}].surface {len(s)} out of [1,100]")
    elif table == "item":
        acc = (row.get("answer_spec") or {}).get("accepted") or []
        if len(acc) > 50:
            errs.append(f"length: answer_spec.accepted has {len(acc)} > 50")
        for i, a in enumerate(acc):
            if not 1 <= len(a) <= 200:
                errs.append(f"length: accepted[{i}] {len(a)} out of [1,200]")
    elif table == "gloss":
        if len(row.get("text", "")) > 2000:
            errs.append("length: gloss.text > 2000")
    return errs


# --- script / charset + tokens[] coverage ---
_LATIN = [(0x41, 0x5A), (0x61, 0x7A), (0xC0, 0x24F)]
_SCRIPTS = {
    "en": _LATIN,
    "es": _LATIN,
    "ta": [(0x0B80, 0x0BFF)],
    "ja": [(0x3040, 0x309F), (0x30A0, 0x30FF), (0x31F0, 0x31FF),
           (0x3400, 0x4DBF), (0x4E00, 0x9FFF), (0xFF66, 0xFF9D)],
}


def _primary(loc: str) -> str:
    return (loc or "").split("-")[0].lower()


def _in_ranges(cp: int, ranges) -> bool:
    return any(lo <= cp <= hi for lo, hi in ranges)


def _strip_ws(s: str) -> str:
    return re.sub(r"\s+", "", s)


def _script_check(text: str, loc: str, field: str) -> list[str]:
    ranges = _SCRIPTS.get(loc)
    if not ranges:
        return []  # unmapped locale -> skip (avoid false negatives across 52 langs)
    bad = [ch for ch in text if unicodedata.category(ch).startswith("L") and not _in_ranges(ord(ch), ranges)]
    if bad:
        uniq = "".join(dict.fromkeys(bad))[:8]
        return [f"script: {field} has out-of-script letters for '{loc}': {uniq!r}"]
    return []


def script_charset_errors(table: str, row: dict) -> list[str]:
    errs: list[str] = []
    if table == "sentence":
        text = row.get("target_text", "")
        errs += _script_check(text, _primary(row.get("locale", "")), "target_text")
        toks = row.get("tokens") or []
        joined = _strip_ws("".join((t or {}).get("surface", "") for t in toks))
        if joined != _strip_ws(text):
            errs.append("tokens: surfaces do not cover target_text (non-space mismatch)")
    elif table == "gloss":
        errs += _script_check(row.get("text", ""), _primary(row.get("ui_locale", "")), "text")
    return errs


# --- no-leak: an accepted answer must not be visible in its prompt/context ---
def no_leak_errors(answer_terms, context: str, *, label: str = "context") -> list[str]:
    if not context:
        return []
    low = context.lower()
    return [f"no-leak: answer {t!r} leaks into {label}" for t in answer_terms if t and t.lower() in low]


# --- back-translation hook (real translator is subscription/local; no network at test time) ---
class BackTranslator(Protocol):
    def back_translate(self, text: str, src_locale: str, via_locale: str = "en") -> str: ...


def back_translation_errors(source_text: str, target_text: str, translator: BackTranslator,
                            *, src_locale: str = "", via_locale: str = "en",
                            threshold: float = 0.8) -> list[str]:
    bt = translator.back_translate(target_text, src_locale, via_locale)
    sim = difflib.SequenceMatcher(None, source_text.strip().lower(), bt.strip().lower()).ratio()
    return [] if sim >= threshold else [f"back-translation: similarity {sim:.2f} < {threshold}"]


# --- aggregator the pipeline calls (row-intrinsic checks) ---
def run_validators(table: str, row: dict) -> list[str]:
    errs = schema_errors(table, row)
    if errs:
        return errs  # deeper checks assume a schema-valid shape
    errs += length_errors(table, row)
    errs += script_charset_errors(table, row)
    return errs
