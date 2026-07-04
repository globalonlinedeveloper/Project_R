#!/usr/bin/env python3
"""Deterministic emitter for the Watch / Video wave (content type #5, INF-9).

Turns compact per-level creative specs (JSON, one file per CEFR level, authored
by the parallel drafters) into schema-correct rows for a Direction-A Watch
lesson: a passage(kind=video) carrying a REAL video_ref -> a media_asset (the
language-neutral MP4 already uploaded to Cloudflare R2), a CEFR-level NARRATION
(sentence rows, each with a per-line explain gloss, R-B4) describing the wordless
scene, 2 comprehension MCQs (item + per-option explain + item-level "Explain
this") kept surfaceOwned off the lesson path, and title/goal glosses.

Mirrors gen_podcasts_wave.py EXACTLY (same gloss/mcq scaffolding + the S96 sample
shape) and adds, per the passage schema, `video_ref` + `duration_ms` on the
passage and a `media_asset` row (type=video, R2 uri). The 12 clips are shared
across all 52 languages (Direction A) — this emitter authors ENGLISH data only.

Spec JSON contract (per level file `_watch_spec_<lvl>.json`):
  {"level":"A1","clips":[
     {"n":"w1","slug":"watch_a1_w1","title":"Morning Coffee","theme":"...",
      "about":"one-line goal/what-the-clip-is-about",
      "lines":[["narration sentence","per-line explain gloss"], ...],
      "checks":[{"q":"question","opts":[["opt",true/false,"explain"],...3],
                 "why":"item-level Explain this"}, ...2]}, ...2]}
"""
import json, re, sys, pathlib

R2_BASE = "https://pub-506169294d394678b41c2fcd4792375f.r2.dev/videos/"
DURATION_MS = 10006  # every clip = ffprobe-measured 10.006s (H.264/AAC 1280x720)
LEVELS = ["a1", "a2", "b1", "b2", "c1", "c2"]
PROV = {"batch_id": "batch_en_course_0001", "provenance": "ai_generated",
        "review_status": "auto_certified", "content_version": 1,
        "created_at": "2026-07-04T00:00:00Z", "updated_at": "2026-07-04T00:00:00Z"}
IRT = {"A1": -1.5, "A2": -0.6, "B1": 0.4, "B2": 1.2, "C1": 2.0, "C2": 2.7}
OIDS = ["a", "b", "c", "d"]


def toks(text):
    return [{"surface": s} for s in re.findall(r"[A-Za-z']+|[^\sA-Za-z]", text)] or [{"surface": text}]


def gloss(cid, kind, text):
    return {"content_id": cid, "content_kind": kind, "ui_locale": "en", "text": text, "provenance": PROV}


def emit_clip(lvl, ll, clip):
    n = clip["n"]
    assert n in ("w1", "w2"), f"{ll}: bad clip n={n}"
    slug = clip["slug"]
    assert slug == f"watch_{ll}_{n}", f"slug mismatch: {slug} != watch_{ll}_{n}"
    pid = f"passage_en_{ll}_watch_{n}"
    mid = f"mediaasset_en_{ll}_watch_{n}"
    tref = f"passagetitle_en_{ll}_watch_{n}"
    eref = f"passageexpl_en_{ll}_watch_{n}"
    skill = f"skill_en_{ll}_s1u1_l1"
    P, S, I, G, M = [], [], [], [], []
    G.append(gloss(tref, "instruction", clip["title"]))
    G.append(gloss(eref, "explanation", clip["about"]))
    sent_refs = []
    lines = clip["lines"]
    assert len(lines) >= 3, f"{pid}: need >=3 narration lines, got {len(lines)}"
    for i, pair in enumerate(lines, 1):
        text, expl = pair
        sid = f"sentence_en_{ll}_watch_{n}_{i:02d}"
        S.append({"sentence_id": sid, "locale": "en", "target_text": text,
                  "tokens": toks(text), "cefr_level": lvl.upper(), "provenance": PROV})
        G.append(gloss(sid, "explanation", expl))  # R-B4 per-line explain
        sent_refs.append(sid)
    chk_refs = []
    checks = clip["checks"]
    assert len(checks) == 2, f"{pid}: need exactly 2 checks, got {len(checks)}"
    for j, c in enumerate(checks, 1):
        iid = f"item_en_{ll}_watch_{n}_chk_{j}"
        pref = f"prompt_en_{ll}_watch_{n}_chk_{j}"
        opts, correct_text = [], None
        assert len(c["opts"]) >= 2, f"{iid}: need >=2 options"
        for oi, (otext, ok, oexpl) in enumerate(c["opts"]):
            oid = OIDS[oi]
            oref = f"expl_{iid}_{oid}"
            o = {"option_id": oid, "text": otext, "explain_ref": oref}
            if ok:
                o["is_correct"] = True
                correct_text = otext
            opts.append(o)
            G.append(gloss(oref, "explanation", oexpl))
        assert correct_text is not None, f"{iid}: no correct option"
        assert sum(1 for _, ok, _ in c["opts"] if ok) == 1, f"{iid}: need exactly one correct"
        G.append(gloss(pref, "instruction", c["q"]))
        G.append(gloss(iid, "explanation", c["why"]))  # item-level "Explain this"
        I.append({"item_id": iid, "locale": "en", "exercise_type": "mcq",
                  "prompt_ref": pref,
                  "answer_spec": {"accepted": [correct_text],
                                  "normalization_flags": {"fold_case": True, "collapse_whitespace": True}},
                  "options": opts, "skill_ids": [skill], "cefr_level": lvl.upper(),
                  "difficulty_band": "core", "irt_b": IRT[lvl.upper()], "provenance": PROV})
        chk_refs.append(iid)
    M.append({"asset_id": mid, "type": "video", "uri": f"{R2_BASE}{slug}.mp4",
              "locale": "en", "duration_ms": DURATION_MS, "provenance": PROV})
    P.append({"passage_id": pid, "locale": "en", "kind": "video",
              "title_ref": tref, "cefr_level": lvl.upper(), "theme": clip["theme"],
              "collection_id": f"collection_en_{ll}_watch_1",
              "sentence_refs": sent_refs, "check_item_refs": chk_refs,
              "explain_ref": eref, "video_ref": mid, "duration_ms": DURATION_MS,
              "provenance": PROV})
    return P, S, I, G, M


def build(specdir):
    P, S, I, G, M = [], [], [], [], []
    seen = set()
    for ll in LEVELS:
        spec = json.load(open(pathlib.Path(specdir) / f"_watch_spec_{ll}.json", encoding="utf-8"))
        assert spec["level"].lower() == ll, f"level mismatch in _watch_spec_{ll}.json"
        clips = spec["clips"]
        assert len(clips) == 2, f"{ll}: need exactly 2 clips, got {len(clips)}"
        for clip in clips:
            p, s, i, g, m = emit_clip(spec["level"], ll, clip)
            for row_id in [p[0]["passage_id"], m[0]["asset_id"]]:
                assert row_id not in seen, f"duplicate id {row_id}"
                seen.add(row_id)
            P += p; S += s; I += i; G += g; M += m
    return {"tables": {"passage": P, "media_asset": M, "sentence": S, "item": I, "gloss": G}}


if __name__ == "__main__":
    specdir = sys.argv[1] if len(sys.argv) > 1 else "ratel-tools"
    out = sys.argv[2] if len(sys.argv) > 2 else "watch_wave_draft.json"
    draft = build(specdir)
    json.dump(draft, open(out, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    c = {t: len(v) for t, v in draft["tables"].items()}
    print(f"emitted 12 watch lessons -> {out}  rows={c}  total={sum(c.values())}")
