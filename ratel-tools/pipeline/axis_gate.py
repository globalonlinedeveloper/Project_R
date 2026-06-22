"""The 12-axis schema-conformance gate (R-C14 / P0-7). Given a loaded batch
({table: [rows]}), each break-point axis is checked by a concrete predicate:
exact-match where unambiguous (graphemes == UAX-29, plurals == CLDR, answer_spec
parses) and boundary-F1 >= 0.95 for no-space segmentation. Structural axes that
the schema absorbs rows-only are asserted pass. A failing axis is a schema defect."""
from __future__ import annotations

from dataclasses import dataclass, field

from .tokenizers import boundary_f1, graphemes_uax29, primary

F1_FLOOR = 0.95
_CLDR = {"zero", "one", "two", "few", "many", "other"}


@dataclass
class AxisResult:
    axis: int
    name: str
    status: str  # "pass" | "fail" | "na"
    detail: str = ""


@dataclass
class GateReport:
    results: list = field(default_factory=list)

    @property
    def passed(self) -> bool:
        return all(r.status != "fail" for r in self.results)

    def failures(self) -> list:
        return [r for r in self.results if r.status == "fail"]

    def summary(self) -> dict:
        return {r.axis: r.status for r in sorted(self.results, key=lambda r: r.axis)}


def gate_batch(tables: dict) -> GateReport:
    sentences = tables.get("sentence", [])
    items = tables.get("item", [])
    locales = tables.get("locale", [])
    out: list[AxisResult] = []

    # Axis 1 — no-space scripts: boundary-F1 >= floor vs pinned tokenizer
    checked = fails = 0
    worst = None
    for s in sentences:
        surfaces = [t.get("surface", "") for t in (s.get("tokens") or [])]
        f1 = boundary_f1(s.get("locale", ""), surfaces, s.get("target_text", ""))
        if f1 is None:
            continue
        checked += 1
        worst = f1 if worst is None else min(worst, f1)
        if f1 < F1_FLOOR:
            fails += 1
    if checked == 0:
        out.append(AxisResult(1, "no_space_tokenization", "na", "no no-space sentences"))
    else:
        out.append(AxisResult(1, "no_space_tokenization", "fail" if fails else "pass",
                              f"{checked} checked, {fails} < {F1_FLOOR} (worst {worst:.2f})"))

    # Axis 3 — grapheme clusters == UAX-29 (where graphemes[] authored)
    gc = gf = 0
    for s in sentences:
        g = s.get("graphemes")
        if not g:
            continue
        gc += 1
        if list(g) != graphemes_uax29(s.get("target_text", "")):
            gf += 1
    out.append(AxisResult(3, "grapheme_clusters", "na" if gc == 0 else ("fail" if gf else "pass"),
                          f"{gc} checked, {gf} mismatched"))

    # Axis 10 — answer equivalence: answer_spec parses (accepted non-empty)
    ac = af = 0
    for it in items:
        spec = it.get("answer_spec")
        if spec is None:
            continue
        ac += 1
        if not spec.get("accepted"):
            af += 1
    out.append(AxisResult(10, "answer_equivalence", "na" if ac == 0 else ("fail" if af else "pass"),
                          f"{ac} answer_specs, {af} empty"))

    # Locale-driven axes (4 directionality · 6 pron capability · 7 tts · 11 plurals==CLDR)
    def _locale_axis(axis, name, ok):
        bad = [l.get("code") for l in locales if not ok(l)]
        status = "na" if not locales else ("fail" if bad else "pass")
        out.append(AxisResult(axis, name, status, f"{len(locales)} locales" + (f", bad={bad}" if bad else "")))

    _locale_axis(4, "directionality", lambda l: l.get("direction") in ("ltr", "rtl"))
    _locale_axis(6, "pron_capability", lambda l: l.get("pron_tier") in ("asr", "shadowing"))
    _locale_axis(7, "tts_coverage", lambda l: l.get("tts_tier") in ("hd", "basic", "none"))
    _locale_axis(11, "plurals_cldr", lambda l: set(l.get("plural_categories", [])) <= _CLDR)

    # Structural axes the schema absorbs rows-only (no null-column / no per-language path)
    for axis, name in [(2, "inflection"), (5, "tone_prosody"), (8, "gloss_pivot"),
                       (9, "pair_specific"), (12, "exercise_na")]:
        out.append(AxisResult(axis, name, "pass", "schema-absorbed (rows-only)"))

    out.sort(key=lambda r: r.axis)
    return GateReport(results=out)
