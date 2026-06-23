# Stage-4 Architecture Sign-Off — Readiness Checklist & Workshop Template

> **Status: PLANNING TEMPLATE ONLY.** This document does **not** begin the sign-off, authorize Stage 3, touch Supabase, spend money, or change any decision. It organizes what the owner-assigned senior architects must verify so the eventual sign-off is fast and complete. The gate itself is **human-run and not automatable** (SPEC §9, R-O1).
>
> Canonical sources (authoritative; this doc only summarizes): `Apps/tasks/SPEC.md` (§3 seams, §8 boundaries, §9 sequencing), `Apps/RATEL_REQUIREMENTS.md` (the 161 requirements + the §M.1 one-way-door register), `docs/SCHEMA_LOCK.md` and `docs/STAGE2_EXIT.md` (R-O1 checks 1–3 and 4–6, already signed).
>
> Guardrails in force throughout the gate: local-only until sign-off · **NO backend DB / Supabase untouched** · subscription-only generation (no metered AI) · `schema/schema.json` frozen · requirements frozen at **161**.

---

## 0. What this gate is

Per **SPEC §9**, delivery is three build stages with a **Stage-4 architecture sign-off (R-O1)** standing between Stage 2 (done) and Stage 3 (the paid backend):

> **★ Stage-4 architecture sign-off (R-O1):** 5 seams built · 23 one-way doors locked · STRIDE+LINDDUN workshop · `pg_dump` diff = 0 → authorizes the backend (real engineers; not automatable).

**It gates:** the start of **Stage 3** — Supabase schema/auth/RLS, FSRS scheduling, the AI relay + credit wallet, IAP + web checkout, AdMob, and runtime cost guardrails (R-M8).

**It does NOT:** get performed by this automation. It needs **owner-assigned senior engineers**, a real threat-modeling workshop, and **dual human sign-off**. Nothing below is Claude performing the sign-off.

**Entry pre-conditions (all already met):**

- [x] R-O1 checks 1–3 signed — schema lock (`docs/SCHEMA_LOCK.md`).
- [x] R-O1 checks 4–6 signed — Stage-2 exit gate (`docs/STAGE2_EXIT.md`).
- [x] Stage 2 CI fully green (flutter-gate · 6-platform build-matrix · deploy-web · perf-bench).
- [x] Requirements frozen at 161; `schema/schema.json` frozen.

---

## Part A — The 5 portability seams (built day one, never retrofitted)

Abstraction boundaries that keep vendor/runtime choices swappable. ⚠ **CORRECTION (S17 validation):** these seams are **specified but NOT yet present in code** — `lib/services/` does not exist and no `ai_relay`/`analytics`/`billing`/`data_access` interface is in `lib/` (only a concrete content loader covers the R-M3 read path). So "built day one, never retrofitted" (SPEC §3) is **not yet satisfied** — building them is a P0 prerequisite (see `docs/STAGE4_VALIDATION_FINDINGS.md` P0-1). The `(stub)` labels below mark the *intended* location, not current state. Architects confirm each becomes a real boundary Stage 3 plugs into — not bypassed.

| # | Seam | Req | Where it lives (code) | Sign-off question |
|---|------|-----|------------------------|-------------------|
| 1 | **AI-vendor adapter** | R-H7 | `lib/services/ai_relay/` (stub) | All AI calls route through this adapter; Gemini is one implementation behind it, swappable without touching features. |
| 2 | **Analytics seam** | R-M1 | `lib/services/analytics/` (stub) | Every event goes through the taxonomy seam (anonymous-first, no PII/raw speech); no direct vendor SDK calls in features. |
| 3 | **Payment adapter** | R-J7a | `lib/services/billing/` (stub) | IAP (mobile) + web checkout sit behind one adapter; entitlement logic never hardcodes a store. |
| 4 | **Data-access layer** | R-M3 | `lib/services/data_access/` (stub) | Features read/write through the DAL only; Stage-1/2 back it with the local loader + Drift cache, Stage-3 adds Supabase **behind the same interface**. |
| 5 | **`auth.uid()` = the only user PK** | R-K6 | identity contract (all user-scoped data) | Every user-scoped row keys on `auth.uid()` and nothing else; no parallel user identifier introduced in Stage 3. |

**Plus the master invariant:** `schema.json` is the **single source of truth** (R-C1 / P0-6) — imported by generator, validator, and app; `additionalProperties:false` everywhere (rows-only, R-FND-2).

- [ ] All 5 seams reviewed as genuine, exercised boundaries (not stubs Stage 3 would bypass).
- [ ] `schema.json` confirmed as the only contract the backend will conform to.

---

## Part B — The 23 one-way doors (irreversible decisions, locked)

"One-way doors" = decisions costly/impossible to reverse once the backend ships. The **authoritative register is `RATEL_REQUIREMENTS.md` (§M.1)** — architects verify each of the 23 is still locked **and consistent with the built Stage-1/2 code** before the backend is built on top of it.

Session-9 history (`RATEL_PROJECT_STATE.md`): the **5 genuinely-open** doors were closed; the remaining ~18 were already locked in the spec. The 5 formerly-open doors and their resolved values:

| Door (formerly open) | Locked value | Ref |
|----------------------|-------------|-----|
| App bundle identifier | `com.learnwithratel.ratel` | R-A2 |
| Data-residency region | Supabase `ap-south-1` (Mumbai), project `ratel` | live-verified (read-only) |
| IAP product SKU skeleton | `pro.monthly` | R-J7 |
| `ReviewLog` partitioning | `pg_partman` time-partitioning | R-M (ops) |
| Trademark / name gate | "Ratel" wordmark + honey-badger logo; attorney clearance + filing **pre-launch** (Class 9/41/42 · US·EU·India·Nigeria + WIPO); avoid "Honey Badger Don't Care" | R-K1 / brand |

Key spec-locked doors to re-confirm (subset — the full 23 are in §M.1):

| Locked decision | Value | Ref |
|-----------------|-------|-----|
| Backend platform | Supabase Postgres + Edge Functions | D7 |
| Edge / media | Cloudflare Pages · R2 (zero-egress CDN) · Turnstile · KV | D7 / R-M6 |
| Runtime AI | Gemini (behind the R-H7 adapter) | D7 |
| Mascot runtime | Rive ≥0.14 + `rive_native`, **Rive-only, no PNG/WebP runtime** | D7 / R-L18 |
| Scheduling | FSRS-7 (with -6 fallback) | D7 |
| Audio codec | OGG/Opus | D7 |
| State management | Riverpod | D4 |
| Navigation | go_router | D5 |
| On-device storage | Drift (SQLite) — on-device only, **not** the backend | D6 |
| Generation funding | **Subscription-only**, no metered AI API | §8 |
| Platform target | All 6 platforms (Android/iOS/web/Linux/macOS/Windows) | R-A2a |
| Requirement count | Frozen at **161** | — |

- [ ] All 23 doors in §M.1 confirmed locked (use this table as a starting cross-check; §M.1 is canonical).
- [ ] Each door is consistent with what Stage 1–2 actually built (no spec↔code drift).
- [ ] Any door that must change is raised **now** (pre-backend) — never after brand/data equity exists.

---

## Part C — STRIDE + LINDDUN threat-modeling workshop

A facilitated session over the Stage-3 architecture **before** any backend is provisioned. Model each data flow across the four tiers (App / Backend / Runtime-AI / Edge) and each of the 5 seams.

**STRIDE — security threats (per element/data-flow):**

| Category | Prompt for this architecture |
|----------|------------------------------|
| **S**poofing | `auth.uid()` identity, JWT handling, Turnstile bot defense |
| **T**ampering | RLS correctness, schema constraints, client-supplied content |
| **R**epudiation | audit/event logging via the analytics seam |
| **I**nformation disclosure | RLS row scoping, no PII in analytics, R2 object ACLs |
| **D**enial of service | runtime cost guardrails (R-M8), rate limits, AI relay caps |
| **E**levation of privilege | RLS bypass paths, Edge Function service-role usage |

**LINDDUN — privacy threats (per personal-data flow):**

| Category | Prompt for this architecture |
|----------|------------------------------|
| **L**inkability | pseudonymous `user_id` only; no cross-linking of behavior |
| **I**dentifiability | anonymous-first events; never attach PII to behavior (R-M1) |
| **N**on-repudiation (privacy) | learner can't be forced to own an action they didn't take |
| **D**etectability | presence-of-record leakage |
| **D**isclosure of information | minimization; **never persist raw audio/voiceprints** (§8) |
| **U**nawareness | consent, transparency, general-audience store listing (R-K1) |
| **N**on-compliance | GDPR/COPPA posture, data-residency `ap-south-1`, retention |

**Workshop outputs (attach when done):**

- [ ] Data-flow diagram across the 4 tiers + 5 seams.
- [ ] STRIDE findings table (threat → mitigation → owner → status).
- [ ] LINDDUN findings table (threat → mitigation → owner → status).
- [ ] All P0/P1 threats have a named mitigation **before** Stage 3 code begins.

---

## Part D — `pg_dump` diff = 0 verification

Goal: prove the intended Stage-3 schema matches the frozen contract with **zero drift** — the database is built from `schema.json`, not hand-edited.

- [ ] Generate the canonical DDL from `schema/schema.json` (the `ratel-tools` schema/DDL path).
- [ ] `pg_dump --schema-only` a throwaway/branch DB built from that DDL — **never** the live project.
- [ ] Normalize both (ordering, whitespace) and `diff` → **must be empty (= 0)**.
- [ ] Record the command, both artifacts, and the empty diff here.
- [ ] Confirm the live Supabase project is still **untouched** (read-only checks only).

> This is a *parity check on the intended schema*, run against a disposable DB. Provisioning the real backend is **Stage 3**, after sign-off.

---

## Part E — Dual senior-architect sign-off

Two qualified, **owner-assigned** senior architects independently review Parts A–D and sign. (This automation cannot and does not sign.)

| Reviewer | Scope reviewed | Findings resolved? | Name | Date | Signature |
|----------|----------------|--------------------|------|------|-----------|
| Architect 1 | A · B · C · D | ☐ | | | |
| Architect 2 | A · B · C · D | ☐ | | | |

**Sign-off criteria (all must hold):**

- [ ] Part A — 5 seams verified as real boundaries.
- [ ] Part B — 23 one-way doors confirmed locked & consistent with built code.
- [ ] Part C — STRIDE + LINDDUN done; no unmitigated P0/P1.
- [ ] Part D — `pg_dump` diff = 0 recorded; live DB untouched.
- [ ] Both architects signed.

---

## Exit → what sign-off authorizes

On dual sign-off, **and only then**, Stage 3 may begin (still owner + money-gated, per SPEC §9 / §8 "Ask first: entering Stage 3"):

Supabase schema/auth/RLS · FSRS scheduling · AI relay + credit wallet · IAP + web checkout · AdMob · runtime cost guardrails (R-M8). Definition of done carries to R-O5 (zero open decisions) and the free tier ≈ $0/user.

Until every box above is checked and both signatures are present, the project stays as-is: **local-only, no backend DB, Supabase untouched.**

---

### Appendix — references

- `Apps/tasks/SPEC.md` — §3 (tiers + 5 seams), §8 (boundaries), §9 (3 stages + Stage-4 gate), §10 (definition of done).
- `Apps/RATEL_REQUIREMENTS.md` — the 161 requirements; **§M.1** = canonical one-way-door register; R-H7/R-M1/R-J7a/R-M3/R-K6 (seams); R-K1 (audience/trademark); R-M8 (cost guardrails).
- `docs/SCHEMA_LOCK.md` — R-O1 checks 1–3 (signed). `docs/STAGE2_EXIT.md` — R-O1 checks 4–6 (signed).

*Prepared as a planning aid (Session 17). No decisions changed; no sign-off performed. Canonical copy lives in the repo; an owner-facing mirror is in `Apps/RATEL_STAGE4_SIGNOFF_CHECKLIST.md`.*
