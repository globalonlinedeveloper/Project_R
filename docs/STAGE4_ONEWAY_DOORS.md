# Ratel — The 23 One-Way Doors (enumerated register)

> **What this is.** The explicit, numbered **1–23 one-way-door register** that Stage-4 checklist **Part B** requires (validation finding **P1-9**). A "one-way door" is an architecture/product decision that is **costly or impossible to reverse once the paid backend ships** (bundle ID, data-residency region, identity PK, monetization model, …).
>
> **Status: SYNTHESIS FOR ARCHITECT RATIFICATION — not yet canonical.** It does **not** begin the sign-off, authorize Stage 3, touch Supabase, or change any decision.

## Critical structural finding (this is finding P1-9 itself)

There is **no enumerated 1–23 "§M.1" register anywhere in the repository.** `RATEL_REQUIREMENTS.md` has a `## Part M` section (`R-M1…R-M8`, `R-AUT-1..4`) but **no sub-section literally headed "§M.1"** and **no numbered door list**. "§M.1" appears only as an *inline cross-reference label* (e.g. R-L15 "closes §M.1 name/clearance one-way-door tracking"; R-O1 "all 23 §M.1 one-way doors confirmed locked"). The doors live **distributed across individual `R-` requirements**, each tagged in-place ("one-way door", "LOCKED 2026-06-22", "permanent", "non-reusable"); the "23/23 locked" tally is a **roll-up asserted** in `RATEL_PROJECT_STATE.md` and R-O1. The enumerated list below **did not previously exist** — which is exactly what P1-9 asked to be built. Treat it as a **proposed canonical list for the architects to ratify**, then write back into a real `§M.1` section so the count stops being virtual.

## The 23 doors

| # | Door | Locked value | Req / decision ref | Why irreversible (one line) | Consistent with built Stage-1/2 code? |
|---|------|--------------|--------------------|------------------------------|----------------------------------------|
| 1 | App bundle ID / `applicationId` | `com.learnwithratel.ratel` (identical all 6 platforms + both stores) | R-A2; checklist Part B | Apple: never changeable post-publish; Google: change = new listing, forfeits installs/ratings/ASO | Local-only in Stage 1–2 (no publish yet); must be set identically in all 6 platform manifests before first signed build — verify no conflicts |
| 2 | Data-residency region | Supabase `ap-south-1` (Mumbai), project `ratel` | R-M3; live-verified read-only | Supabase can't move a project's region in place; change = full backend re-home + data migration + repoint | Reversible as spec text until Phase 3; DB untouched (one read-only region check). No code dependency yet |
| 3 | IAP product SKU catalog | `…pro.monthly`/`…pro.annual` (subs) + `…credits.small/medium/large` (consumables), prefixed `com.learnwithratel.ratel` | R-J7, R-J2; checklist Part B | Store product IDs are permanent + non-reusable on both stores even after deletion | No products created in Stage 1–2; entitlement-map seam (`pro_until`, `credit_grant:N`) is interface/stub. Confirm SKU strings aren't hardcoded outside a catalog |
| 4 | `ReviewLog` partitioning | `pg_partman` time-partitioning, born-partitioned (R-G6) | R-M3 / R-G6; checklist Part B | Re-partitioning a populated high-write table in place is a costly migration; must be born-partitioned | No DB in Stage 1–2; `ReviewLog`/learner-state is stubbed (R-O1). Schema-first in `schema.json` — verify the partition intent is encoded. **Ref is soft (`pg_partman` named in checklist/state, not R-M3 prose) — confirm vs R-G6** |
| 5 | Trademark / name gate | "Ratel" wordmark + honey-badger logo; attorney clearance + filing pre-launch (Class 9/41/42 · US·EU·India·Nigeria + WIPO); avoid "Honey Badger Don't Care" | R-K1 / R-L15; checklist Part B | Brand equity, store name, ASO spend can't be unwound after launch; rename must precede equity | Name/logo pervade UI copy + assets; off the build critical path but gates public launch |
| 6 | Backend platform | Supabase Postgres + Edge Functions | SPEC §5 D7; R-M3; checklist Part B | Core data/identity/AI-relay substrate; swapping after launch = re-platform of auth, RLS, ledger, relay | Stage 1–2 explicitly NO backend (R-O1). The R-M3 data-access seam must exist day one, never retrofitted (built: `lib/content/repository/` + `lib/services/data_access/`) |
| 7 | Edge / media platform | Cloudflare — Pages · R2 (zero-egress CDN) · Turnstile · KV | SPEC §5 D7; R-M3, R-M6; checklist Part B | Media paths, bot-defense, hosting, and "$0/play" economics bind to this account (R2↔Bunny is a deliberate swap seam, account anchored) | Stage 1–2 loads bundled JSON; hash/version-keyed asset paths (R-FND-1) keep the CDN swappable. Confirm asset paths follow that convention |
| 8 | Runtime AI provider | Gemini (Flash-Lite default) behind the R-H7 adapter | SPEC §5 D7; R-H7; R-M3; checklist Part B | Runtime-AI key/relay + credit economics bind here; provider is explicitly abstracted/swappable via the adapter | Stage 1–2 tutor is a stub; the R-H7 AI-vendor adapter seam exists (`lib/services/ai_relay/`). No live AI keys in client |
| 9 | Mascot runtime tech | Rive ≥0.14 + `rive_native`, **Rive-only, NO PNG/WebP runtime images**; fallback = rig paused on a static frame | SPEC §5 D7; R-L18, R-A2; checklist Part B | "No bitmap runtime" + a from-scratch vector rig is a deep authoring + per-platform native-lib commitment | Stage 2 builds the placeholder rig (R-O1 exit check 5; paused-frame tested). Owner WebP are source art only. Verify no PNG/WebP mascot bitmaps ship at runtime |
| 10 | Spaced-repetition scheduler | FSRS-7 (with FSRS-6 fallback) | SPEC §5 D7; R-G5; checklist Part B | The scheduler shapes stored learner-state semantics; changing it post-launch disrupts review history/intervals | Stage 1–2 learner-state is interfaces/stubs. Confirm the state model is FSRS-shaped in `schema.json` so it survives to Phase 3 |
| 11 | Audio codec | OGG/Opus | SPEC §5 D7; R-F4; checklist Part B | The pre-rendered media library + offline caches are encoded once; re-encoding the whole corpus is costly | Stage 2 pre-render pipeline targets this codec. Verify bundled pilot audio + offline cache use OGG/Opus |
| 12 | State management | Riverpod | SPEC §5 D4; checklist Part B | Pervasive cross-cutting architecture; replacing it = rewrite of every screen's state wiring | Built directly into Stage 1–2 screens — highest spec↔code drift risk. Confirm no competing state lib crept in |
| 13 | Navigation | go_router | SPEC §5 D5; R-L10; checklist Part B | Deep-link / universal-link contracts + 6-platform routing bind to it; switching reworks all routes | Built into Stage 1–2. Verify the route table + deep-link config are go_router and match R-L10 web URLs |
| 14 | On-device storage | Drift (SQLite) — on-device cache + learner-state, **on-device only, NOT the backend** | SPEC §5 D6; R-L13/R-L13a; checklist Part B | Offline bundles + background-sync build on this; the "not the backend" boundary is load-bearing | Stage 1 loads bundled JSON; Drift powers offline + sync from Stage 2. Confirm Drift is never treated as the source-of-truth backend |
| 15 | Generation funding model | Subscription-only; **no metered/per-call AI API** for free content; build-time pipeline only | SPEC §8/§1; R-J3; checklist Part B | The entire $0-at-scale unit economics + free-tier promise depend on no metered free AI | Build pipeline (`ratel-tools/`, Python) is subscription-only (network-free StubGenerator). Reserved AI-sampler A/B ships OFF (R-J3) |
| 16 | Platform target set | All 6 platforms first-class & QA-gated (Android/iOS/Web-PWA/Windows/macOS/Linux) | R-A2/R-A2a; SPEC §3; checklist Part B | "First-class six" sets store listings, per-OS signing/notarization, the capability matrix; dropping one post-launch breaks users | Stage 1–2 build all 6 from one codebase (build-matrix CI). R-A2a capability matrix enforces per-platform fallbacks |
| 17 | Identity primary key | `auth.uid()` = the **only** user PK (one identity, many courses) | R-K6 (seam); R-O1; SPEC §3 | The PK threads RLS, entitlements, analytics-ID separation, every user-scoped row; changing it re-keys the whole data model | Learner-state stubbed but designed around this PK; identity seam built (`lib/services/identity/`). Known-minor two-ID model (R-M1): `auth.uid()` never passed to analytics — now CI-guarded (P0-5) |
| 18 | Schema single-source-of-truth | `schema.json` (JSON Schema 2020-12) is the single SoT; `additionalProperties:false` everywhere | R-C1 / R-FND-2; SPEC §3, §5 D2/D3 | Generator, validator, app, and Stage-3 SQL all derive from it; the closed-container contract can't loosen without invalidating every artifact | Codegen (freezed/json_serializable) from `schema.json` in Stage 1–2. `pg_dump` diff = 0 is the Stage-4 Part-D gate. Strongest day-one anchor |
| 19 | Rows-only structural invariant | Content/schema scale by **rows or flags only** — no per-language code branching, no parallel schema | R-FND-2 (§0.2); R-A1; SPEC §1/§8 | Once corpus + clients assume rows-only, adding a code-branching vertical needs a parallel schema = a different product | Enforced from Stage 1. Non-language subjects out of scope. Verify no per-language `if` branches in built screens |
| 20 | Web/PWA brand domain | `learnwithratel.com` (brand + marketing + web checkout + privacy/support URLs); Web/PWA on Cloudflare Pages | R-A2, R-M6, R-K7; PROJECT_STATE | The domain anchors store contact, deep-link association, legal/DSA contact, ASO; abandoning it post-launch breaks links + email. (The Pages deploy *target* itself is reversible → GitHub Pages) | Domain bought + wired 2026-06-22; web build deploys the static artifact. Confirm `/.well-known/` deep-link files + SPF/DKIM/DMARC for Phase-3 readiness |
| 21 | Payments / billing posture | Native IAP-first (StoreKit 2 / Play Billing) + server-side `pro_until`; Web/PWA via own Stripe / MoR checkout | R-J7/R-J7a | The server-side entitlement model + store relationships are foundational to cross-platform Pro; the entitlement schema is permanent once subscribers exist | No billing in Stage 1–2; the payment-adapter seam (R-J7a) is built (`lib/services/billing/`). Confirm nothing hardcodes a store |
| 22 | Pro monetization model | Single thin Pro tier, PPP-banded, annual-led + 7-day trial; all live AI in one Pro; AI metered by credits, no free allowance | R-J1/R-J2/R-J3 | The free/Pro split + "all AI in one Pro" + credit-metering is the core business-model door; reshaping tiers post-launch disrupts entitlements + expectations (price *numbers* are A/B-tunable; the *model* is the door) | No paywall logic active (paywall is a stub). Free-vs-Pro split is a design contract Stage 3 implements. Verify nothing gates pre-generated content behind Pro |
| 23 | Requirement-set freeze | 161 requirements, frozen | PROJECT_STATE; SPEC §1/§4; checklist Part B | The frozen scope is the contract every gate measures against; unfreezing mid-build invalidates the "23/23 · 5/5 · §H clean · 161" basis | Verified structurally (`### R-` header count = 161). A process/governance door rather than a code artifact |

## Provenance & gaps (what an architect must resolve before signing Part B)

- **High confidence (named as doors in the checklist Part B + PROJECT_STATE):** rows **1–16** + **23** map directly onto the checklist's two tables (the 5 formerly-open doors #1–5, the 12 spec-locked doors #6–16/#23), each corroborated by its `R-` requirement.
- **Inferred to complete the count to 23 (grounded but not labelled "door N"):** rows **17–22** are irreversible decisions named *outside* the checklist's two summary tables but treated as one-way by R-O1's seam list (#17 `auth.uid()` PK, #21 payment adapter), the foundational requirements (#18 `schema.json` SoT, #19 rows-only — SPEC §8 flags "any `schema.json` change (one-way contract)"), and irreversible product anchors (#20 brand domain, #22 monetization model).
- **The central ambiguity (the heart of P1-9):** the number **23 is not derivable from any enumerated source** — it is asserted, never listed. This table reaches 23 by a defensible construction (16 checklist-named + 6 R-O1/SPEC-named + the freeze), but the *partition* is a judgment call: reasonable alternatives could **split** doors (e.g. Supabase-Postgres vs Edge-Functions; native-IAP vs web-checkout) pushing the count >23, or **merge** doors (#18+#19; #21+#22) dropping it <23. The checklist itself hedges ("~18" already-locked + 5 formerly-open) without ever reconciling to 23.
- **Specific items to confirm:** #4 `pg_partman` exact tool vs R-G6 wording; #1 bundle-ID placement across all 6 manifests; whether #20's domain vs the (reversible) Pages deploy target is one door or two; and whether #23 (the 161-freeze) counts as an architecture door at all (if not, the count drops to 22 and a 23rd must come from a split above).

### Architect actions for checklist Part B
1. **Ratify the partition** — accept this 23-row decomposition or adjust splits/merges to a deliberately-enumerated 23, then write it into a real `§M.1` section so the list is no longer virtual.
2. **Stage-1/2 code-consistency** (Part B's second test) — highest-risk rows are the ones actually *built*: #12 Riverpod, #13 go_router, #14 Drift, #16 six-platform, #18 schema-codegen, #19 rows-only. The DB/billing/region doors (#2/#3/#4/#6/#21) are "reversible-as-spec-text" until Phase 3 and have no built code to drift against yet.

## §M.1 reference text (so the synthesis is verifiably grounded)

There is **no heading to quote** — §M.1 is a label applied to one-way decisions distributed across the `R-` requirements. Verbatim references that exist:

- `RATEL_REQUIREMENTS.md` R-L15: *"Trademark clearance = attorney-gated pre-launch step (2026-06-22; closes §M.1 name/clearance one-way-door tracking)…"*
- `RATEL_REQUIREMENTS.md` R-O1 (the Stage-4 gate): *"all 23 §M.1 one-way doors confirmed locked (independently audited clean 2026-06-22 — 5/5 portability seams · 23/23 doors · §H clean · 161 reqs · PASS)"* and *"the moment the 'reversible-as-spec-text-until-build' decisions (e.g. the `ap-south-1` region R-M3, the IAP SKU catalog R-J2) become physically irreversible."*
- `docs/STAGE4_SIGNOFF_CHECKLIST.md`: *"the authoritative register is `RATEL_REQUIREMENTS.md` (§M.1) … the full 23 are in §M.1."*
- `docs/STAGE4_VALIDATION_FINDINGS.md` P1-9: *"Neither the requirements nor §M.1 has an enumerated 1–23 list; '23/23 PASS' is asserted, not checkable."*

*Synthesized Session 18 from `RATEL_REQUIREMENTS.md`, the SPEC, the checklist, and the built `lib/`. Advisory until architect-ratified; no decision changed; no sign-off performed; Supabase untouched. Canonical copy: repo `docs/`; owner mirror: `Apps/RATEL_STAGE4_ONEWAY_DOORS.md`.*

---

## Door #18 addendum — enum forward-compatibility policy (P2-1; Session 20 / L6)

Door #18 (schema single-source-of-truth) governs the closed `enums.schema.json` controlled
vocabularies (R-C12: *"Adding a value is a global, versioned catalog event — never a per-language
addition"*). The Stage-3 client must decide, **per enum**, what happens when it receives a wire value
it does not recognize (the server is on a newer catalog version than the installed client):

- **HARD_REJECT (fail-closed) — the default; applied to all 19 string enums today.** The generated
  Dart emits **no `unknown` sentinel**, so `json_serializable`'s decoder raises on an unrecognized
  value. Rationale: every current enum is a finite scale (`cefr_level`), safety-critical scheduler
  state (`fsrs_state`), or financial semantics (`ledger_entry_type`, `grant_source`) — a client older
  than the catalog must fail **loudly** rather than silently coerce versioned meaning. Consistent with
  the R-C12 closed/versioned contract and the fail-closed posture used elsewhere (analytics allow-list,
  AI-relay moderation).
- **GRACEFUL_DEGRADE — reserved, none today.** Appends a single `unknown` sentinel (no `@JsonValue`)
  so a read-only/display-only enum can render a forward value as "unknown" instead of crashing an
  older client. Opting an enum in is itself a reviewable change (a field site must add
  `@JsonKey(unknownEnumValue: <Enum>.unknown)`).

Encoded in `ratel-tools/codegen_dart.py` (`ENUM_FORWARD_COMPAT` registry + `gen_enum(policy=…)`);
**every string enum must be classified or codegen aborts** (the door guard), so a new enum can never
ship without an explicit reject-vs-degrade decision. Proven by
`ratel-tools/tests/test_enum_forward_compat.py`; hard-reject output is byte-identical to the
pre-policy generator (no Dart churn). Advisory until architect-ratified; no live system touched.
