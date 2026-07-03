#!/usr/bin/env python3
"""Build the S108 scenario-scale wave: 12 Roleplay + 12 Adventure (2/level A1->C2).

Reads the creative specs (author lanes) and deterministically compiles a
FAIL-CLOSED integrate_wave.py draft {"tables": {...}} of schema-perfect rows:
  - scene lines -> `sentence` rows (tokens auto-built);
  - title/goal/(roleplay) rubric/choice-label -> `gloss` rows;
  - per-roleplay-choice EXPLANATION gloss keyed by the choice label_ref (content_kind
    explanation) so the scenario renderer's per-choice "Explain this" resolves;
  - roleplay you-turns -> real `item` (mcq) rows (surfaceOwned off the path);
  - `scenario` rows (kind roleplay|adventure).

Gloss ordering: explanation-kind emitted BEFORE instruction-kind so buildCourseSpine's
`glossText` (last-en-wins) resolves a choice label_ref to its LABEL, while `explainOf`
(explanation-only) resolves the EXPLAIN. Self-validates before writing (one-correct-per
you-turn, branch reachability, id-uniqueness, no collision with the live batch).

Usage: python3 build_scenario_scale.py <specs.json> <course.batch.json> <out_draft.json>
"""
import json, re, sys, pathlib

PROV = {
    "batch_id": "batch_en_course_0001",
    "provenance": "ai_generated",
    "review_status": "auto_certified",
    "content_version": 1,
    "created_at": "2026-07-04T00:00:00Z",
    "updated_at": "2026-07-04T00:00:00Z",
}
IRT_B = {"A1": -1.7, "A2": -1.1, "B1": -0.4, "B2": 0.3, "C1": 1.0, "C2": 1.6}
LETTERS = "abcdefgh"
CID_RE = re.compile(r"^[a-z][a-z0-9]*_[A-Za-z0-9_-]+$")

def prov():
    return dict(PROV)

def toks(text):
    return [{"surface": s} for s in re.findall(r"\w+(?:['’]\w+)*|[^\s\w]", text)]

def san(s):
    s = re.sub(r"[^A-Za-z0-9_-]", "", str(s))
    return s or "x"

class Build:
    def __init__(self, batch):
        self.sent, self.items, self.gloss_expl, self.gloss_lbl, self.scen = [], [], [], [], []
        self.errs = []
        # existing pks to guard against collisions
        T = batch["tables"]
        self.exist = set()
        for t, pk in (("sentence","sentence_id"),("item","item_id"),("scenario","scenario_id")):
            for r in T.get(t, []):
                self.exist.add((t, r[pk]))
        self.exist_gloss = {(g["content_id"], g["ui_locale"], g["content_kind"]) for g in T.get("gloss", [])}
        self.newids = {"sentence": set(), "item": set(), "scenario": set()}
        self.newgloss = set()

    def cid(self, cid, ctx):
        if not CID_RE.match(cid):
            self.errs.append(f"{ctx}: bad content_id '{cid}'")
        return cid

    def add_sent(self, sid, text, cefr, ctx):
        self.cid(sid, ctx)
        if ("sentence", sid) in self.exist or sid in self.newids["sentence"]:
            self.errs.append(f"{ctx}: dup/collision sentence {sid}")
        self.newids["sentence"].add(sid)
        if not text or not text.strip():
            self.errs.append(f"{ctx}: empty line for {sid}")
        self.sent.append({"sentence_id": sid, "locale": "en", "target_text": text,
                          "tokens": toks(text) or [{"surface": text}], "cefr_level": cefr,
                          "provenance": prov()})

    def add_gloss(self, cid, kind, text, ctx):
        self.cid(cid, ctx)
        key = (cid, "en", kind)
        if key in self.exist_gloss or key in self.newgloss:
            self.errs.append(f"{ctx}: dup gloss {key}")
        self.newgloss.add(key)
        row = {"content_id": cid, "content_kind": kind, "ui_locale": "en", "text": text, "provenance": prov()}
        # explanation rows FIRST (list built later), instruction/rubric after
        (self.gloss_expl if kind == "explanation" else self.gloss_lbl).append(row)

    def add_scenario(self, sid, row, ctx):
        self.cid(sid, ctx)
        if ("scenario", sid) in self.exist or sid in self.newids["scenario"]:
            self.errs.append(f"{ctx}: dup scenario {sid}")
        self.newids["scenario"].add(sid)
        self.scen.append(row)

    def add_item(self, iid, row, ctx):
        self.cid(iid, ctx)
        if ("item", iid) in self.exist or iid in self.newids["item"]:
            self.errs.append(f"{ctx}: dup item {iid}")
        self.newids["item"].add(iid)
        self.items.append(row)

    # ---------- ROLEPLAY ----------
    def roleplay(self, lvl, lc, sc):
        slug = sc["slug"]
        base = f"en_{lc}_{slug}"
        sid = f"scenario_{base}"
        ctx = sid
        self.add_gloss(f"scenariotitle_{base}", "instruction", sc["title"], ctx)
        self.add_gloss(f"goal_{base}", "instruction", sc["goal"], ctx)
        self.add_gloss(f"rubric_{base}", "rubric", sc["rubric"], ctx)
        scenes_spec = sc["scenes"]
        scene_ids = [f"sc{i+1}" for i in range(len(scenes_spec))]
        out_scenes = []
        youturns = 0
        for i, sp in enumerate(scenes_spec):
            scnid = scene_ids[i]
            speaker = sp["speaker"]
            is_you = speaker == "you"
            text = sp.get("cue") if is_you else sp.get("line")
            sent_id = f"sentence_{base}_{scnid}"
            self.add_sent(sent_id, text, lvl, ctx)
            scene = {"scene_id": scnid, "speaker": speaker, "line_sentence_ref": sent_id}
            if is_you:
                youturns += 1
                k = youturns
                item_id = f"item_{base}_t{k}"
                prompt_id = f"prompt_{base}_t{k}"
                self.add_gloss(prompt_id, "instruction", sp["prompt"], ctx)
                choices = sp["choices"]
                ncorrect = sum(1 for c in choices if c.get("correct") is True)
                if ncorrect != 1:
                    self.errs.append(f"{ctx} {scnid}: {ncorrect} correct (need 1)")
                nxt = scene_ids[i+1] if i+1 < len(scene_ids) else None
                opts, sc_choices, correct_text = [], [], None
                for j, c in enumerate(choices):
                    letter = LETTERS[j]
                    lbl_id = f"choicelabel_{base}_t{k}_{letter}"
                    corr = c.get("correct") is True
                    if corr:
                        correct_text = c["text"]
                    # explanation gloss (keyed by label_ref) + label gloss (same content_id)
                    self.add_gloss(lbl_id, "explanation", c["explain"], ctx)
                    self.add_gloss(lbl_id, "instruction", c["text"], ctx)
                    opts.append({"option_id": letter, "text": c["text"], "is_correct": corr,
                                 "explain_ref": lbl_id})
                    ch = {"label_ref": lbl_id, "option_id": letter, "is_correct": corr}
                    if nxt:
                        ch["next_scene_id"] = nxt
                    sc_choices.append(ch)
                item = {
                    "item_id": item_id, "locale": "en", "exercise_type": "mcq",
                    "prompt_ref": prompt_id,
                    "answer_spec": {"accepted": [correct_text] if correct_text else [],
                                    "normalization_flags": {"fold_case": True, "collapse_whitespace": True}},
                    "options": opts,
                    "skill_ids": [f"skill_en_{lc}_s1u1_l1"],
                    "cefr_level": lvl, "difficulty_band": "core", "irt_b": IRT_B[lvl],
                    "provenance": prov(),
                }
                self.add_item(item_id, item, ctx)
                scene["turn_item_ref"] = item_id
                scene["choices"] = sc_choices
            out_scenes.append(scene)
        if youturns < 1:
            self.errs.append(f"{ctx}: no you-turns")
        self.add_scenario(sid, {
            "scenario_id": sid, "locale": "en", "kind": "roleplay",
            "title_ref": f"scenariotitle_{base}", "cefr_level": lvl, "world": sc.get("world", ""),
            "goal_ref": f"goal_{base}", "rubric_ref": f"rubric_{base}",
            "skill_ids": [f"skill_en_{lc}_s1u1_l1", f"skill_en_{lc}_s1u1_l2"],
            "scenes": out_scenes, "provenance": prov(),
        }, ctx)

    # ---------- ADVENTURE ----------
    def adventure(self, lvl, lc, sc):
        slug = sc["slug"]
        base = f"en_{lc}_{slug}"
        sid = f"scenario_{base}"
        ctx = sid
        self.add_gloss(f"scenariotitle_{base}", "instruction", sc["title"], ctx)
        self.add_gloss(f"goal_{base}", "instruction", sc["goal"], ctx)
        scenes_spec = sc["scenes"]
        raw_ids = [san(sp["id"]) for sp in scenes_spec]
        if len(set(raw_ids)) != len(raw_ids):
            self.errs.append(f"{ctx}: duplicate scene ids {raw_ids}")
        idset = set(raw_ids)
        if raw_ids and raw_ids[0] != "start":
            self.errs.append(f"{ctx}: first scene id is '{raw_ids[0]}' not 'start'")
        out_scenes, graph, endings = [], {}, 0
        for sp in scenes_spec:
            scnid = san(sp["id"])
            sent_id = f"sentence_{base}_{scnid}"
            self.add_sent(sent_id, sp.get("line", ""), lvl, ctx)
            scene = {"scene_id": scnid, "speaker": sp.get("speaker", "narrator"),
                     "line_sentence_ref": sent_id}
            # normalize choices: explicit choices win; else scene-level 'next' -> single Continue; else ending
            spec_choices = sp.get("choices")
            if not spec_choices and sp.get("next"):
                spec_choices = [{"label": "Continue", "next": sp["next"]}]
            graph[scnid] = []
            if spec_choices:
                ch_out = []
                for j, c in enumerate(spec_choices):
                    lbl_id = f"choicelabel_{base}_{scnid}_{j+1}"
                    self.add_gloss(lbl_id, "instruction", c["label"], ctx)
                    nxt = san(c["next"])
                    graph[scnid].append(nxt)
                    if nxt not in idset:
                        self.errs.append(f"{ctx} {scnid}: choice next '{nxt}' not a scene")
                    ch_out.append({"label_ref": lbl_id, "next_scene_id": nxt})
                scene["choices"] = ch_out
            else:
                endings += 1
            out_scenes.append(scene)
        if endings < 1:
            self.errs.append(f"{ctx}: no ending scene")
        # reachability from start
        if "start" in idset:
            seen, stack = set(), ["start"]
            while stack:
                n = stack.pop()
                if n in seen:
                    continue
                seen.add(n)
                stack.extend(graph.get(n, []))
            unreach = idset - seen
            if unreach:
                self.errs.append(f"{ctx}: unreachable scenes {sorted(unreach)}")
        self.add_scenario(sid, {
            "scenario_id": sid, "locale": "en", "kind": "adventure",
            "title_ref": f"scenariotitle_{base}", "cefr_level": lvl, "world": sc.get("world", ""),
            "goal_ref": f"goal_{base}", "scenes": out_scenes, "provenance": prov(),
        }, ctx)

    def draft(self):
        # explanation glosses FIRST, then instruction/rubric (protects glossText label resolution)
        gloss = self.gloss_expl + self.gloss_lbl
        return {"tables": {"sentence": self.sent, "item": self.items, "gloss": gloss,
                           "scenario": self.scen}}

def main(specs_path, batch_path, out_path):
    specs = json.load(open(specs_path, encoding="utf-8"))
    batch = json.load(open(batch_path, encoding="utf-8"))
    b = Build(batch)
    for lane in specs["lanes"]:
        lvl = lane["level"]
        lc = lvl.lower()
        for sc in lane["scenarios"]:
            if sc["kind"] == "roleplay":
                b.roleplay(lvl, lc, sc)
            elif sc["kind"] == "adventure":
                b.adventure(lvl, lc, sc)
            else:
                b.errs.append(f"unknown kind {sc.get('kind')}")
    if b.errs:
        print(f"BUILD FAILED — {len(b.errs)} problem(s):")
        for e in b.errs:
            print("  -", e)
        return 1
    draft = b.draft()
    pathlib.Path(out_path).write_text(json.dumps(draft, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    rp = sum(1 for s in b.scen if s["kind"] == "roleplay")
    ad = sum(1 for s in b.scen if s["kind"] == "adventure")
    print(f"OK — built draft: {len(b.scen)} scenarios ({rp} roleplay + {ad} adventure), "
          f"{len(b.sent)} sentence, {len(b.items)} item, {len(draft['tables']['gloss'])} gloss")
    print(f"   wrote {out_path}")
    return 0

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print(__doc__); sys.exit(2)
    sys.exit(main(sys.argv[1], sys.argv[2], sys.argv[3]))
