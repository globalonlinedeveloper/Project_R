#!/usr/bin/env python3
"""Deterministic emitter for the Stories / Read&Listen wave (content type #2).
Turns compact Opus-authored story specs into schema-correct passage(kind=podcast)
+ sentence + comprehension item + gloss rows. audio_ref is LEFT NULL (text-first
+ browser-TTS; real audio/video stays owner-gated). Mirrors the S96 story sample
exactly so it passes the integrator + course_spine_test story contract (R-B4:
every line carries a per-line explain gloss; 1-3 comprehension checks)."""
import json, re, sys

PROV = {"batch_id": "batch_en_course_0001", "provenance": "ai_generated",
        "review_status": "auto_certified", "content_version": 1,
        "created_at": "2026-07-03T00:00:00Z", "updated_at": "2026-07-03T00:00:00Z"}
IRT = {"A1": -1.5, "A2": -0.6, "B1": 0.4, "B2": 1.2, "C1": 2.0, "C2": 2.7}
OIDS = ["a", "b", "c", "d"]

def toks(text):
    return [{"surface": s} for s in re.findall(r"[A-Za-z']+|[^\sA-Za-z]", text)] or [{"surface": text}]

def gloss(cid, kind, text):
    return {"content_id": cid, "content_kind": kind, "ui_locale": "en", "text": text, "provenance": PROV}

def emit(spec):
    lvl = spec["level"]; ll = lvl.lower(); k = spec["k"]
    pid = f"passage_en_{ll}_podcast_{k}"
    tref = f"passagetitle_en_{ll}_podcast_{k}"
    eref = f"passageexpl_en_{ll}_podcast_{k}"
    skill = f"skill_en_{ll}_s1u1_l1"
    P, S, I, G = [], [], [], []
    G.append(gloss(tref, "instruction", spec["title"]))
    G.append(gloss(eref, "explanation", spec["about"]))
    sent_refs = []
    for i, (text, expl) in enumerate(spec["lines"], 1):
        sid = f"sentence_en_{ll}_podcast_{k}_{i:02d}"
        S.append({"sentence_id": sid, "locale": "en", "target_text": text,
                  "tokens": toks(text), "cefr_level": lvl, "provenance": PROV})
        G.append(gloss(sid, "explanation", expl))  # R-B4 per-line explain
        sent_refs.append(sid)
    chk_refs = []
    for j, c in enumerate(spec["checks"], 1):
        iid = f"item_en_{ll}_podcast_{k}_chk_{j}"
        pref = f"prompt_en_{ll}_podcast_{k}_chk_{j}"
        opts = []
        correct_text = None
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
                  "options": opts, "skill_ids": [skill], "cefr_level": lvl,
                  "difficulty_band": "core", "irt_b": IRT[lvl], "provenance": PROV})
        chk_refs.append(iid)
    P.append({"passage_id": pid, "locale": "en", "kind": "podcast",
              "title_ref": tref, "cefr_level": lvl, "theme": spec["theme"],
              "collection_id": f"collection_en_{ll}_podcasts_1",
              "sentence_refs": sent_refs, "check_item_refs": chk_refs,
              "explain_ref": eref, "provenance": PROV})
    return P, S, I, G

def build(stories):
    P, S, I, G = [], [], [], []
    for sp in stories:
        p, s, i, g = emit(sp)
        P += p; S += s; I += i; G += g
    return {"tables": {"passage": P, "sentence": S, "item": I, "gloss": G}}

if __name__ == "__main__":
    from podcasts_specs import PODCASTS
    draft = build(PODCASTS)
    out = sys.argv[1] if len(sys.argv) > 1 else "podcasts_wave_draft.json"
    json.dump(draft, open(out, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    c = {t: len(v) for t, v in draft["tables"].items()}
    print(f"emitted {len(PODCASTS)} podcasts -> {out}  rows={c}  total={sum(c.values())}")
