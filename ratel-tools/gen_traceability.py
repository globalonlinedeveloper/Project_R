#!/usr/bin/env python3
"""Requirements Traceability Matrix (RTM) generator for Project_R.

Single source of truth for the 168 functional requirement IDs is RATEL_REQUIREMENTS.md
(owner planning folder, not in-repo). That ID+title list is mirrored here so the generator
runs hermetically in CI. For each requirement it records:

  * MoSCoW priority  - DERIVED from the spec's own scope/phasing (R-A1 v1 boundary,
                       R-A8 launch floor, Part O phases). Interpretive -> owner-reviewable.
  * Phase            - which build stage owns it (Foundation/Stage1/Stage2 = local & done
                       per the S1-27 audit; Stage3 = DB/runtime/payments, owner+money gated;
                       Wave = post-launch R-O3; Cut = removed).
  * Status (build)   - completion of the *buildable* slice. Stage1/2 = Built (audit);
                       Stage3 = Build-ahead if code+tests cite it, else Pending(gated);
                       Wave = Deferred; Cut = Removed. Code/test evidence is attached.
  * Gate             - whether going live needs owner/money (Stage3 + Wave).

Override file ratel-tools/requirements_registry.json (if present) wins over the derived
defaults per-id (keys: moscow, phase, status_override, notes) so humans can correct calls
without editing code. Run: python3 ratel-tools/gen_traceability.py
"""
import json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
REGISTRY = os.path.join(HERE, "requirements_registry.json")
OUT = os.path.join(ROOT, "docs", "REQUIREMENTS_TRACEABILITY.md")
SCAN_DIRS = ["lib", "test", "integration_test", "schema", "ratel-tools"]

# --- canonical 161 (id | title), extracted from RATEL_REQUIREMENTS.md headers ----------
DATA = """\
R-FND-1|Regenerate-in-place (hot-swap) of machine-made content
R-FND-2|Rows-only structural invariant
R-A1|v1 launch shape & scope boundary
R-A2|Target platforms & device/OS minimums
R-A2a|Per-platform capability degradation matrix
R-A3|Target-language & tier ratification (52 LTR)
R-A4|UI/gloss launch set & any-to-any cell-lighting
R-A5|Hindi/Swahili provisional-promotion rule
R-A6|Pilot scope & schema-conformance exit gate
R-A7|Pilot CEFR content scope
R-A8|Launch-minimum bar & wave policy
R-B1|CEFR can-do spine ratification
R-B2|Skill/Concept prerequisite graph
R-B3|Course-Section-Unit-Lesson containers & path rendering
R-B4|TBLT task model + tap-to-define
R-B5|Depth-as-data & CEFR-ceiling enforcement
R-B6|Native realization & divergence nodes
R-B7|Pair-specific / contrastive layer
R-B8|Content difficulty model (IRT + cold-start)
R-C1|Standardization rule + open-container discipline
R-C2|Sentence entity + token model
R-C3|VocabEntry + per-sense model
R-C4|GrammarPoint entity
R-C5|Phoneme (per-language bank)
R-C6|Item + answer_spec
R-C7|Locale entity
R-C8|MediaAsset entity
R-C9|Gloss / localization layer
R-C10|Provenance / versioning on every row
R-C11|Stable language-neutral ID scheme
R-C12|Shared controlled vocabularies / enums
R-C13|App-shell strings vs DB gloss boundary
R-C14|Schema-conformance gate
R-D1|Shared item envelope + exercise-type enum
R-D2|mcq (multiple choice)
R-D3|cloze (fill in the blank)
R-D4|translate (one type, with a direction setting)
R-D5|listen (listen and choose)
R-D6|word_order (build the sentence by tapping words)
R-D7|match (matching pairs)
R-D8|dictation (type exactly what you hear)
R-D9|speak (on-device ASR intelligibility + shadowing, free)
R-D9a|Web/desktop on-device ASR is cloud - force shadowing
R-D10|scripted_roleplay (a branching scripted conversation)
R-D11|Phase-3 scaffolds: write + live_roleplay (scaffolded now)
R-D12|tap-to-define reading feature + comprehension-item policy
R-D13|Autoscoring & answer-equivalence rules
R-D14|Result - signal mapping (proficiency / memory / engagement)
R-E1|Build-time generation pipeline architecture
R-E2|Generator agent spec
R-E3|Verifier/critic + LLM jury (fresh context)
R-E4|Deterministic validation rules
R-E5|Confidence gating & regeneration thresholds
R-E6|Per-batch spot-audit
R-E7|Cross-batch drift control
R-E8|Per-language QA-certifiable CEFR ceiling
R-E9|C1-C2 gate (owner override)
R-E10|review_status lifecycle + provenance
R-E11|Batch idempotency & versioning
R-E12|Gloss generation + fallback chain
R-E13|Generation tooling / ops
R-E14|Companion-asset completeness gate
R-F1|Per-locale TTS voice selection
R-F2|Pre-render pipeline, SSML & storage/CDN
R-F3|tts_tier flag & degrade UX
R-F4|Audio format, caching & offline
R-F5|Visual / illustration asset policy
R-F6|Video-lesson asset pre-generation + codec/versioning rule
R-F7|Avatar / cosmetic asset pre-generation rule
R-G1|One identity, many courses
R-G2|theta ability model (global + per-skill)
R-G3|IRT calibration (how hard each item is)
R-G4|CAT placement test
R-G5|FSRS spaced-repetition scheduling
R-G6|Learner-state entities (what gets stored)
R-G7|Cold-start strategy (works from day one)
R-G8|Launch path-serving (how lessons are sequenced)
R-G9|Saved words - flashcards - graded review
R-H1|AI tutor chat
R-H2|Realtime voice conversations
R-H3|Launch pronunciation UX (shadowing, free)
R-H4|Advanced pronunciation scoring - REMOVED
R-H5|Grading written answers (later)
R-H6|Open-ended roleplay conversations (later)
R-H7|Runtime key mgmt, relay, rate-limit & abuse
R-H8|Reusable scaffolds (Scenario + GradingRubric)
R-I1|XP model (sources & amounts)
R-I2|Streak + streak-freeze + Society tiers
R-I3|Energy model (lesson cost, regen, caps)
R-I4|Gems soft-currency (earn / spend sinks)
R-I5|Rewarded-ads - energy / gems design
R-I6|Leagues / leaderboards (global, weekly reset)
R-I7|Daily goal + chest + quests + achievements
R-I8|Anti-dark-pattern guardrails
R-I9|Social: friends/feed, family plan, classroom, block/report
R-J1|Free vs Pro feature split (exact)
R-J2|Pro price point(s) + billing (regional/PPP, trial)
R-J3|AI access policy - Pro-only live AI, metered by credits
R-J4|Ad strategy + network/mediation
R-J5|Voice minute caps (even Pro)
R-J6|Store-safe paywall / cancel (single CTA, easy cancel)
R-J7|Payments / IAP integration (App Store / Play / web)
R-J7a|Desktop/web billing - web-checkout fallback (no native store)
R-K1|Age-gating + COPPA / minors path
R-K1a|OS age-range assurance has narrow real coverage
R-K2|Consent - GDPR/UMP + iOS ATT + non-personalized-ads path
R-K3|Data minimization & retention (no raw-speech retention)
R-K4|Regional privacy rights - export + delete (GDPR/DPDP/CCPA)
R-K5|Generated-content safety (AI-content; profanity; bias)
R-K6|Security - server-side keys, Supabase RLS, auth, PII
R-K7|Terms of Service + Privacy Policy - final copy & ownership
R-K8|Accessibility - WCAG 2.2 AA conformance (test-enforced)
R-L1|Auth & account flows
R-L2|Onboarding flow (language-motivation-goal-placement-first win)
R-L3|Core learning loop (lesson run, check/feedback, complete)
R-L4|Practice & AI hub
R-L4a|Adventures immersive surface (explorable roleplay world)
R-L5|Reading & listening (stories, listening feed, video, tap-to-define)
R-L6|Profile & settings hub
R-L7|Monetization screens
R-L8|Gamification & social screens
R-L9|Multi-course, course-switch, flip-UI & immersion
R-L10|Navigation / information architecture (tab shell, deep links)
R-L11|Notifications (push categories, opt-in, inbox)
R-L11a|Widgets are mobile-only; desktop/web get in-app/tray equivalent
R-L11b|Notifications: per-platform delivery profile
R-L12|Global search
R-L13|Offline mode & caching
R-L13a|Background sync is foreground-reconcile on iOS-PWA + desktop
R-L14|Cross-cutting UI states (loading/empty/error/skeleton)
R-L15|Brand character & motion/delight (the Ratel honey badger)
R-L16|Motion & interaction design-system
R-L17|Animated & interactive acceptance bar
R-L18|Mascot animation tech & rig contract
R-L19|Celebration & lesson-feedback kit
R-M1|Analytics event taxonomy & core KPIs
R-M2|Experimentation & feature flags (dark-launch, A/B, wave gating)
R-M3|Backend infrastructure (Supabase: Postgres, RLS, Edge, Storage/CDN)
R-M4|Content build/upload ops (batch tooling, staging-prod)
R-M5|Observability (logging & error tracking)
R-M6|CI/CD & store-release process
R-M6a|Linux distribution channel + desktop auto-update
R-M7|Backup / DR & data export
R-M8|Runtime cost guardrails & monitoring
R-AUT-1|Store-listing & ASO generation pipeline
R-AUT-2|Analytics-to-generation wave orchestrator
R-AUT-3|Scheduled recalibration & threshold-refresh job
R-AUT-4|Alert-to-incident response automation
R-N1|Performance budgets (cold start, lesson load, audio latency)
R-N2|Scalability (content volume, concurrent users)
R-N3|Reliability / availability targets
R-N4|Localization completeness & quality bars per tier
R-N5|Low-connectivity / low-end-device resilience + data budget
R-N6|Maintainability / charter conformance
R-N7|Unified motion-tier signal (accessibility precedence)
R-N8|Animation performance & power budget
R-O1|Phase-2 deliverables (local content model - NO DB)
R-O2|Phase-3 deliverables (DB + runtime + payments - gated, MONEY)
R-O3|Post-launch waves (tier climb, write/live-roleplay, RTL re-add)
R-O4|Risk register & mitigations
R-O5|Consolidated open-decisions tracker
R-WT1|World-theme template seam (palette + painters + traveller + vocabulary, app-wide + persisted)
R-WT2|Space world theme #1 (deep-space galaxy skin, app-wide re-skin)
R-WT3|Persisted theme selection (default Classic, opt-in Space)
R-WT4|Galaxy Home — CustomPainter backdrop + planet path + locked v8 pod traveller
R-WT5|Motion-tier preference (High/Reduced/Off) with OS reduce-motion hard floor
R-WT6|Profile settings surface (theme + motion + a11y toggles)
R-WT7|Tier-gated galaxy FX + pod auto-defense (HIGH-only, reduce-motion floor)
"""

# --- part-level derived defaults: (moscow, phase) -------------------------------------
PART_DEFAULT = {
    "0": ("Must", "Foundation"), "A": ("Must", "Spec"), "B": ("Must", "Stage1"),
    "C": ("Must", "Stage1"), "D": ("Must", "Stage2"), "E": ("Must", "Stage1"),
    "F": ("Should", "Stage2"), "G": ("Must", "Stage3"), "H": ("Should", "Stage3"),
    "I": ("Should", "Stage2"), "J": ("Must", "Stage3"), "K": ("Must", "Stage3"),
    "L": ("Must", "Stage2"), "M": ("Should", "Stage3"), "AUT": ("Could", "Wave"),
    "N": ("Must", "Cross"), "O": ("Process", "Program"), "WT": ("Should", "Stage2"),
}
# --- per-id overrides grounded in R-A1 / R-A8 / Part O --------------------------------
OVERRIDE = {
    "R-A3": ("Must", "Stage1"), "R-A4": ("Must", "Stage1"),
    "R-A6": ("Must", "Stage1"), "R-A7": ("Must", "Stage1"),
    "R-D9": ("Must", "Stage2"), "R-D9a": ("Must", "Stage2"), "R-D11": ("Should", "Wave"),
    "R-F1": ("Must", "Stage3"), "R-F2": ("Must", "Stage3"), "R-F3": ("Must", "Stage2"),
    "R-F4": ("Must", "Stage2"), "R-F5": ("Should", "Stage2"),
    "R-F6": ("Could", "Wave"), "R-F7": ("Could", "Wave"),
    "R-G4": ("Must", "Stage3"), "R-G5": ("Must", "Stage3"), "R-G9": ("Should", "Stage3"),
    "R-H1": ("Should", "Stage3"), "R-H2": ("Could", "Stage3"), "R-H3": ("Must", "Stage2"),
    "R-H4": ("Won't", "Cut"), "R-H5": ("Could", "Wave"), "R-H6": ("Could", "Wave"),
    "R-H7": ("Must", "Stage3"), "R-H8": ("Should", "Stage2"),
    "R-I9": ("Should", "Stage3"), "R-K8": ("Must", "Stage2"),
    "R-L4a": ("Must", "Stage2"), "R-L11": ("Should", "Stage3"),
    "R-L11a": ("Could", "Stage3"), "R-L11b": ("Should", "Stage3"),
    "R-L12": ("Should", "Stage2"), "R-L13": ("Should", "Stage2"), "R-L13a": ("Should", "Stage2"),
    "R-M1": ("Must", "Stage3"), "R-M3": ("Must", "Stage3"), "R-M4": ("Must", "Stage3"),
    "R-M5": ("Should", "Stage3"), "R-M6": ("Must", "Stage3"), "R-M6a": ("Could", "Wave"),
    "R-M7": ("Should", "Stage3"), "R-M8": ("Must", "Stage3"),
    "R-O1": ("Process", "Stage1"), "R-O2": ("Process", "Stage3"), "R-O3": ("Process", "Wave"),
}

PART_NAMES = {
    "0": "§0 Foundations", "A": "A — Scope, platforms & languages",
    "B": "B — Learning model & curriculum", "C": "C — Content data model",
    "D": "D — Exercise types & grading", "E": "E — Content generation & QA",
    "F": "F — Media", "G": "G — Adaptivity, placement & SRS", "H": "H — AI, tutor & conversation",
    "I": "I — Gamification, economy & social", "J": "J — Monetization",
    "K": "K — Compliance, privacy & safety", "L": "L — App screens & UX",
    "M": "M — Analytics, ops & infrastructure", "AUT": "M — Automation (R-AUT)",
    "N": "N — Non-functional quality bars", "O": "O — Program, phasing & risks",
    "WT": "W — World themes (Space galaxy skin + future packs)",
}
PART_ORDER = ["0","A","B","C","D","E","F","G","H","I","J","K","L","M","AUT","N","O","WT"]


def part_of(rid):
    if rid.startswith("R-FND"):
        return "0"
    if rid.startswith("R-AUT"):
        return "AUT"
    if rid.startswith("R-WT"):
        return "WT"
    m = re.match(r"R-([A-O])", rid)
    return m.group(1) if m else "?"


def scan_evidence(ids):
    """Return {id: set(relpaths)} for every requirement id cited in scanned source."""
    pats = {rid: re.compile(r"(?<![0-9A-Za-z-])" + re.escape(rid) + r"(?![0-9A-Za-z])") for rid in ids}
    ev = {rid: set() for rid in ids}
    me = os.path.relpath(__file__, ROOT)
    # The override registry mirrors every requirement ID (the human `overrides` plus the
    # generated `derived` block), so it must NOT count as implementation evidence — else
    # the generator is non-idempotent (a 2nd run would find all 161 IDs in it and flip
    # every Pending row to Partial). Skip the generator and its registry.
    skip = {me, os.path.relpath(REGISTRY, ROOT)}
    for d in SCAN_DIRS:
        base = os.path.join(ROOT, d)
        for dp, _, fns in os.walk(base):
            for fn in fns:
                if not fn.endswith((".dart", ".py", ".sql", ".json", ".yaml", ".yml")):
                    continue
                rp = os.path.relpath(os.path.join(dp, fn), ROOT)
                if rp in skip:
                    continue
                try:
                    txt = open(os.path.join(dp, fn), encoding="utf-8", errors="ignore").read()
                except OSError:
                    continue
                for rid, pat in pats.items():
                    if pat.search(txt):
                        ev[rid].add(rp)
    return ev


def status_for(phase, ev_files, override):
    if override:
        return override
    has_test = any(("test" in f) for f in ev_files)
    has_code = any(f.startswith(("lib/", "schema/")) or (f.startswith("ratel-tools/") and "test" not in f) for f in ev_files)
    if phase in ("Foundation", "Stage1", "Stage2"):
        return "Built ✅"
    if phase == "Stage3":
        if has_code and has_test:
            return "Build-ahead 🟦"
        if has_code or has_test:
            return "Partial 🟨"
        return "Pending 🔒"
    if phase == "Wave":
        return "Deferred ⏭"
    if phase == "Cut":
        return "Removed ✖"
    return "Spec/cross ▫"


def gate_for(phase):
    return "🔒 owner/$$" if phase in ("Stage3", "Wave") else "—"


def build_rows():
    """Parse the canonical list, merge derived defaults + registry overrides + code evidence."""
    rows = []
    for line in DATA.strip().splitlines():
        rid, title = line.split("|", 1)
        rows.append({"id": rid, "title": title.strip(), "part": part_of(rid)})

    overrides = {}
    if os.path.exists(REGISTRY):
        try:
            overrides = json.load(open(REGISTRY, encoding="utf-8")).get("overrides", {})
        except (OSError, ValueError):
            overrides = {}

    ev = scan_evidence([r["id"] for r in rows])
    for r in rows:
        rid, part = r["id"], r["part"]
        mo, ph = OVERRIDE.get(rid, PART_DEFAULT.get(part, ("Should", "Stage3")))
        ovr = overrides.get(rid, {})
        r["moscow"] = ovr.get("moscow", mo)
        r["phase"] = ovr.get("phase", ph)
        r["evidence"] = sorted(ev[rid])
        r["status"] = status_for(r["phase"], r["evidence"], ovr.get("status_override"))
        r["notes"] = ovr.get("notes", "")
    return rows, overrides


def render(rows):
    from collections import Counter, defaultdict
    mo_order = ["Must", "Should", "Could", "Won't", "Process"]
    by_mo_status = defaultdict(Counter)
    for r in rows:
        by_mo_status[r["moscow"]][r["status"]] += 1
    status_keys = ["Built ✅", "Build-ahead 🟦", "Partial 🟨", "Pending 🔒", "Deferred ⏭", "Removed ✖", "Spec/cross ▫"]

    L = []
    L.append("# Ratel — Requirements Traceability Matrix (RTM)")
    L.append("")
    L.append("> **GENERATED** by `ratel-tools/gen_traceability.py` from the 168 requirement IDs in "
             "`RATEL_REQUIREMENTS.md`. Do not hand-edit — rerun the generator. To correct a call, edit "
             "`ratel-tools/requirements_registry.json` (`overrides`) and rerun.")
    L.append("")
    L.append("**How to read this**")
    L.append("")
    L.append("- **MoSCoW** is *derived* from the spec (R-A1 v1 boundary · R-A8 launch floor · Part O phases) — "
             "interpretive, **please review/override**.")
    L.append("- **Phase**: Foundation/Stage1/Stage2 = local & complete per the S1–S27 build audit · "
             "Stage3 = DB/runtime/payments (owner + money gated) · Wave = post-launch (R-O3) · Cut = removed.")
    L.append("- **Status (build)** = completion of the *buildable* slice: `Built ✅` (Stage 1–2, per audit) · "
             "`Build-ahead 🟦` (Stage-3 logic written + tested, not yet live) · `Partial 🟨` · "
             "`Pending 🔒` (Stage-3, not started) · `Deferred ⏭` (wave) · `Removed ✖`.")
    L.append("- **Gate** = going live needs owner action / money.")
    L.append("- **Evidence** = source/test files citing the requirement ID (a floor — not every built file tags its ID).")
    L.append("")
    L.append("## Coverage rollup (by MoSCoW × build status)")
    L.append("")
    L.append("| Priority | " + " | ".join(s.split()[0] for s in status_keys) + " | Total |")
    L.append("|" + "---|" * (len(status_keys) + 2))
    for mo in mo_order:
        if not by_mo_status.get(mo):
            continue
        c = by_mo_status[mo]
        tot = sum(c.values())
        L.append("| **" + mo + "** | " + " | ".join(str(c.get(s, 0)) for s in status_keys) + " | " + str(tot) + " |")
    grand = Counter()
    for mo in by_mo_status:
        grand.update(by_mo_status[mo])
    L.append("| **All** | " + " | ".join(str(grand.get(s, 0)) for s in status_keys) + " | " + str(sum(grand.values())) + " |")
    L.append("")
    L.append("_Legend: Built=Stage1–2 complete · Build-ahead=Stage-3 logic done+tested (not live) · "
             "Pending=Stage-3 not started · Deferred=post-launch wave · Removed=cut · Spec/cross=policy/cross-cutting._")
    L.append("")

    for part in PART_ORDER:
        prows = [r for r in rows if r["part"] == part]
        if not prows:
            continue
        L.append("## Part " + PART_NAMES.get(part, part))
        L.append("")
        L.append("| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |")
        L.append("|----|-------------|--------|-------|--------|------|----------|")
        for r in prows:
            ev_s = ", ".join("`" + os.path.basename(f) + "`" for f in r["evidence"][:4]) or "—"
            if len(r["evidence"]) > 4:
                ev_s += " +" + str(len(r["evidence"]) - 4)
            note = ("<br>_" + r["notes"] + "_") if r["notes"] else ""
            L.append("| " + r["id"] + " | " + r["title"] + note + " | " + r["moscow"] + " | "
                     + r["phase"] + " | " + r["status"] + " | " + gate_for(r["phase"]) + " | " + ev_s + " |")
        L.append("")
    return "\n".join(L) + "\n", by_mo_status


def main():
    rows, overrides = build_rows()
    md, by_mo_status = render(rows)

    snap = {"_doc": "Edit 'overrides' to correct any moscow/phase/status_override/notes; rerun the generator.",
            "overrides": overrides,
            "derived": {r["id"]: {"moscow": r["moscow"], "phase": r["phase"], "status": r["status"]} for r in rows}}
    json.dump(snap, open(REGISTRY, "w", encoding="utf-8"), indent=2, ensure_ascii=False)

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    open(OUT, "w", encoding="utf-8").write(md)
    print("WROTE", os.path.relpath(OUT, ROOT), "(" + str(len(rows)) + " requirements)")
    print("ROLLUP by MoSCoW x status:")
    for mo in ["Must", "Should", "Could", "Won't", "Process"]:
        if by_mo_status.get(mo):
            print(" ", mo, dict(by_mo_status[mo]))
    return 0 if len(rows) == 168 else 1


if __name__ == "__main__":
    sys.exit(main())
