#!/usr/bin/env python3
"""Integrate a drafted content wave into a course batch — FAIL-CLOSED (plan §5).

Usage: python3 ratel-tools/integrate_wave.py <draft.json> <course.batch.json>

The draft is {"tables": {<table>: [rows...]}} carrying ONLY new rows. Before
any write, the merged result must pass ALL checks; any failure exits non-zero
with the batch file untouched (no partial integration):
  1. every DRAFT row schema-valid (schema_loader.validate_row);
  2. no duplicate primary keys anywhere in the merged batch
     (gloss key = content_id + ui_locale + content_kind);
  3. referential closure over the MERGED batch: unit title/guide refs,
     item prompt_ref / skill_ids / option explain_refs, sense.vocab_id,
     sentence token lemma_refs, grammar_point.unit_id, passage sentence/check
     refs, scenario turn/sentence refs -> all resolve;
  4. authored-mcq contract: exactly one is_correct per options[] and
     answer_spec.accepted[0] == the correct option's text (INF-2.5 renderer
     grades by these).
On success appends draft rows AFTER existing rows (authored order preserved)
and rewrites the batch with the repo's 2-space indent. [R-C1 · R-A7]
"""
from __future__ import annotations

import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from schema_loader import validate_row  # noqa: E402

PK = {
    "unit": "unit_id", "grammar_point": "grammar_id", "vocab_entry": "vocab_id",
    "sense": "sense_id", "sentence": "sentence_id", "item": "item_id",
    "passage": "passage_id", "scenario": "scenario_id", "locale": "code",
    "media_asset": "asset_id", "phoneme": "phoneme_id",
}


def key(table: str, row: dict):
    if table == "gloss":
        return (row.get("content_id"), row.get("ui_locale"), row.get("content_kind"))
    return row.get(PK[table])


def main(draft_path: str, batch_path: str) -> int:
    draft = json.load(open(draft_path, encoding="utf-8"))["tables"]
    batch = json.load(open(batch_path, encoding="utf-8"))
    tables = batch["tables"]
    errs: list[str] = []

    # 1. schema-validate every draft row
    checked = 0
    for t, rows in draft.items():
        if t != "gloss" and t not in PK:
            errs.append(f"unknown table: {t}")
            continue
        for r in rows:
            checked += 1
            for e in validate_row(t, r):
                errs.append(f"{t} {key(t, r)}: {e}")

    # 2. duplicate keys. Parallel wave drafters cannot see each other, so two
    #    waves may legitimately re-teach a shared word (S97: U4 + U5 both
    #    taught 'apple'/'egg'): a vocab/sense row SEMANTICALLY IDENTICAL to an
    #    already-present row is SKIPPED; any other duplicate is a hard FAIL.
    semantic = {"vocab_entry": ("lemma", "pos", "cefr_level", "locale"),
                "sense": ("vocab_id", "pos")}
    existing: dict = {}
    for t, rows in tables.items():
        for r in rows:
            existing[(t, key(t, r))] = r
    skipped: list[str] = []
    kept: dict = {}
    for t, rows in draft.items():
        kept[t] = []
        for r in rows:
            k = (t, key(t, r))
            prev = existing.get(k)
            if prev is not None:
                fields = semantic.get(t)
                if fields and all(prev.get(f) == r.get(f) for f in fields):
                    skipped.append(f"{t} {key(t, r)}")
                    continue
                errs.append(f"duplicate key {t} {key(t, r)}")
                continue
            kept[t].append(r)
            existing[k] = r
    draft = kept
    merged = {t: list(tables.get(t, [])) + list(draft.get(t, []))
              for t in set(list(tables) + list(draft))}

    # 3. referential closure over the MERGED batch
    gloss_ids = {g["content_id"] for g in merged.get("gloss", [])}
    vocab_ids = {v["vocab_id"] for v in merged.get("vocab_entry", [])}
    sent_ids = {s["sentence_id"] for s in merged.get("sentence", [])}
    skill_ids = {g["grammar_id"] for g in merged.get("grammar_point", [])}
    item_ids = {i["item_id"] for i in merged.get("item", [])}
    unit_ids = {u["unit_id"] for u in merged.get("unit", [])}

    def need(cond: bool, msg: str) -> None:
        if not cond:
            errs.append(msg)

    for u in merged.get("unit", []):
        for f in ("section_title_ref", "title_ref", "guide_ref"):
            if u.get(f):
                need(u[f] in gloss_ids, f"unit {u['unit_id']}.{f} dangling: {u[f]}")
    for g in merged.get("grammar_point", []):
        if g.get("unit_id"):
            need(g["unit_id"] in unit_ids,
                 f"grammar_point {g['grammar_id']}.unit_id dangling: {g['unit_id']}")
    for i in merged.get("item", []):
        if i.get("prompt_ref"):
            need(i["prompt_ref"] in gloss_ids,
                 f"item {i['item_id']}.prompt_ref dangling: {i['prompt_ref']}")
        for sk in i.get("skill_ids", []):
            need(sk in skill_ids, f"item {i['item_id']} skill dangling: {sk}")
        opts = i.get("options") or []
        for o in opts:
            if o.get("explain_ref"):
                need(o["explain_ref"] in gloss_ids,
                     f"item {i['item_id']} option {o.get('option_id')} explain_ref dangling")
        # 4. authored-mcq contract (the INF-2.5 renderer grades by this)
        if opts:
            correct = [o for o in opts if o.get("is_correct") is True]
            need(len(correct) == 1,
                 f"item {i['item_id']}: {len(correct)} correct options (need exactly 1)")
            acc = (i.get("answer_spec") or {}).get("accepted") or []
            if correct and acc:
                need(acc[0] == correct[0].get("text"),
                     f"item {i['item_id']}: accepted[0] != correct option text")
            elif opts:
                need(bool(acc), f"item {i['item_id']}: options without accepted[]")
    for s in merged.get("sense", []):
        need(s["vocab_id"] in vocab_ids,
             f"sense {s['sense_id']}.vocab_id dangling: {s['vocab_id']}")
    for s in merged.get("sentence", []):
        for tk in s.get("tokens", []):
            if tk.get("lemma_ref"):
                need(tk["lemma_ref"] in vocab_ids,
                     f"sentence {s['sentence_id']} lemma_ref dangling: {tk['lemma_ref']}")
    for p in merged.get("passage", []):
        for f in ("title_ref", "explain_ref"):
            if p.get(f):
                need(p[f] in gloss_ids, f"passage {p['passage_id']}.{f} dangling")
        for sr in p.get("sentence_refs") or []:
            need(sr in sent_ids, f"passage {p['passage_id']} sentence_ref dangling: {sr}")
        for cr in p.get("check_item_refs") or []:
            need(cr in item_ids, f"passage {p['passage_id']} check_item_ref dangling: {cr}")
    for sc in merged.get("scenario", []):
        for f in ("title_ref", "goal_ref", "rubric_ref"):
            if sc.get(f):
                need(sc[f] in gloss_ids, f"scenario {sc['scenario_id']}.{f} dangling")
        for scene in sc.get("scenes") or []:
            if scene.get("turn_item_ref"):
                need(scene["turn_item_ref"] in item_ids,
                     f"scenario {sc['scenario_id']} turn_item_ref dangling")
            if scene.get("line_sentence_ref"):
                need(scene["line_sentence_ref"] in sent_ids,
                     f"scenario {sc['scenario_id']} line_sentence_ref dangling")

    if errs:
        print(f"FAIL — {len(errs)} problem(s); batch NOT modified "
              f"(schema-checked {checked} draft rows):")
        for e in errs[:40]:
            print(" -", e)
        return 1

    for t, rows in draft.items():
        tables.setdefault(t, []).extend(rows)
    out = json.dumps(batch, ensure_ascii=False, indent=2) + "\n"
    pathlib.Path(batch_path).write_text(out, encoding="utf-8")
    total = sum(len(v) for v in tables.values())
    note = f", skipped {len(skipped)} identical dupes" if skipped else ""
    print(f"OK — integrated {sum(len(v) for v in draft.values())} rows "
          f"({checked} schema-checked, closure verified{note}); "
          f"batch now {total} rows:")
    print(" ", {t: len(v) for t, v in sorted(tables.items())})
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(2)
    sys.exit(main(sys.argv[1], sys.argv[2]))
