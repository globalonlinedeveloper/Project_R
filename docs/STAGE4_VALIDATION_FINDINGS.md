# Stage-4 Validation — Consolidated Findings (2 independent review agents)

> **What this is:** the merged, de-duplicated output of two independent read-only review agents — one **security**, one **privacy + architecture-integrity** — run against the draft threat model, the spec, the 161 requirements, and the actual `lib/` + `schema/` code (Session 17). It is a **quality pass**, not the human dual sign-off; the Stage-4 gate is **still OPEN**. Nothing was modified, no backend exists, Supabase untouched — so nothing here is a live incident; these are things to get right **before** the paid backend is built.

## Headline
Both reviewers agree the draft's **direction is sound** and the 13 findings are real and roughly right. The problems are **coverage and two factual gaps in the prep**, not wrong analysis:
- **A real error in the prep was caught:** the checklist claimed the **5 portability seams are "built in code as stubs"** — they are **not**. `lib/services/` does not exist; no `ai_relay`/`analytics`/`billing`/`data_access` interface is in `lib/`. So "5 seams built" (a literal R-O1 sign-off criterion) is **not yet true**. (Both agents, independently.) The checklist Part A wording is now corrected to say "specified, not yet built."
- **`schema.json` has no Stage-3 user tables** (no `User`/`UserItemState`/`ReviewLog`/credit-ledger) → the Part D `pg_dump diff = 0` check would be meaningless until they're authored, and RLS-on-every-table can't be verified yet.

## What's already solid (verified in code — don't worry about these)
- Client genuinely enforces `additionalProperties:false` (`build.yaml`: `disallow_unrecognized_keys:true` + `checked:true`) — the analytics-allowlist claim is real for content.
- Fail-closed content loader (`lib/content/loader/content_loader.dart`) rejects partial/bad batches.
- Build pipeline is network-free by construction (`ratel-tools/pipeline/generate.py`, StubGenerator) — consistent with subscription-only / no metered API.
- Secrets hygiene clean (no keys/tokens in `lib/` or `ratel-tools/`; `.gitignore` covers `secrets.env`); CI reads creds only from `secrets.*` and skips gracefully.
- Supply chain conservative (all `pubspec.lock` deps hosted + pinned; Python reqs pinned).

---

## P0 — resolve before any Stage-3 code or before sign-off

- **P0-1 · "5 seams built" is not true — build them or correct the claim.** `lib/services/` is absent; only a concrete content loader exists (the R-M3 read path, local half). Spec says seams are built day-one, never retrofitted. **Action:** create the 5 seam interfaces/stubs (`ai_relay` R-H7, `analytics` R-M1, `billing` R-J7a, `data_access` R-M3, `auth.uid()` identity contract R-K6) under `lib/services/`, OR change the spec/requirements/checklist "5/5 PASS" language to "specified, not yet built." *(both agents)*
- **P0-2 · Author the Stage-3 user tables into `schema.json`.** `User` / `UserItemState` / `ReviewLog` / credit-ledger keyed on `auth.uid()` must be in the single source of truth so `pg_dump diff=0` (Part D) is meaningful and RLS-per-table (R-K6) is verifiable. *(privacy agent; ties to R-C1/R-M3/R-M)*
- **P0-3 · Entitlement & credit tables must be client-read-only in RLS.** Naïve `auth.uid()` RLS with a permissive `WITH CHECK` lets a user UPDATE their own `pro_until`/credit balance → free Pro / infinite credits. **Only** the Edge Function service-role may write them. Make this its own threat finding (distinct from generic row-tampering). *(security MISS-1; R-J3/R-J7a)*
- **P0-4 · Add Data-Subject Rights (export + delete).** R-K4 requires in-app data export + account deletion cascading across Supabase + auth + Firebase/Crashlytics within GDPR/CCPA/DPDP windows. The threat model has no finding for it, and it must be reconciled with the "ReviewLog kept forever" rule (R-M). Deletion-cascade is an architecture decision, not a Stage-3 detail. *(privacy P0-1)*
- **P0-5 · PII-in-telemetry → raise to P0; build the allow-list + CI guard.** The analytics event `props{}` is an open container; without a taxonomy allow-list enforced at the seam (and a CI guard that no PII / no minor identifier / no `auth.uid()` reaches the analytics or ad SDKs), it's a direct PII-leak path — worse because minors 13+ are in scope. The seam and guard don't exist yet. *(privacy TP-2 → P0; R-M1/R-K1/R-K6)*
- **P0-6 · Service-role key exposure → P0 (was P1).** A leaked Edge-Function service-role key bypasses all RLS = full multi-tenant breach. Keys only server-side, rotation plan (ahead of Supabase legacy-key deprecation), never logged, vendor endpoints pinned (anti-SSRF). *(security TS-5 re-rank)*
- **P0-7 · Add the missing economy + safety findings.** (a) **Credit-minting / ledger integrity** — referral + AI-sampler grant paths are a margin attack; controls = device attestation, Turnstile, per-account/device velocity caps, double-entry ledger, fail-closed-at-zero. (b) **AI-relay moderation bypass** — minors reach the Pro tutor; require input+output moderation that **fails closed when the moderation provider is down** (prompt-injection / output-exfil = OWASP-LLM-01/02). *(security MISS-2, MISS-4; R-H7/R-M8)*

## P1 — design into the threat model before building that subsystem

- **P1-1 · Payments hardening (TS-6 → P0/P1 boundary).** Server-side receipt validation **+** webhook signature verification **+ idempotency/event-dedupe** (stop replayed webhooks re-granting Pro) **+ refund/chargeback/lapse clawback** (revoke entitlement server-side). *(security MISS-3; R-J7a)*
- **P1-2 · Cross-border transfer is real — split TP-4.** "Pin `ap-south-1`" covers the DB only. Analytics (Firebase/GA4 + Crashlytics, Google/US), the AI relay (Gemini), and moderation (OpenAI) **send data outside the region by design** (R-M1 explicitly accepts weaker EU residency). Document the lawful-transfer basis (SCCs, R-K7); stop implying data stays in-region. *(privacy P1-1)*
- **P1-3 · Add a third-party-SDK / sub-processor finding.** AdMob, Firebase, Gemini, OpenAI, Cloudflare — what identifiers each sees, consent gating (UMP/ATT, `npa=1`), the India-under-18 ad hard-gate (DPDP), and a published sub-processor list (R-K5/R-K7/R-J4). *(privacy P1-2)*
- **P1-4 · Anonymous → authenticated identity migration.** Define how local/anon state binds to `auth.uid()` on sign-in without letting a client claim another user's anon data (IDOR/spoof seam). Add refresh-token rotation/revocation + leaked-JWT blast radius to TS-1. *(security MISS-5; `lib/app/app_flags.dart`)*
- **P1-5 · Make the data-access seam abstract.** `ContentRepository` is concrete + content-only and hardcodes the asset path; turn it into an interface (bundled loader = one impl) so Stage-3 Supabase plugs in behind it without touching features. *(privacy P1-5; R-M3)*
- **P1-6 · Fill the Edge (R2/Turnstile/KV) threat row.** R2 signed-URL TTL/scope, Pro-only audio authorization (not just obscurity), and Turnstile on **every** free-credit-grant entry point (not just signup). The worksheet left this row blank. *(security MISS-6; R-H7)*
- **P1-7 · State "server/AI output is untrusted."** At Stage 3 the same models deserialize relay/Postgres + AI text into the UI — no rendering into rich-text/HTML sinks without sanitization (OWASP-LLM-02). Cheap to assert now. *(security MISS-7)*
- **P1-8 · Fix two privacy mis-statements.** TP-3 → "never *derive* a voiceprint" (not just "don't upload"), and note the one lawful retention exception (CSAE→NCMEC 1-year text). TP-6 → reframe as retention-vs-erasure (forever `ReviewLog` vs DSAR delete); drop the "TTL/purge ReviewLog" mitigation, which contradicts R-M. *(privacy P1-3/P1-4)*
- **P1-9 · Build the explicit numbered 23-door register.** Neither the requirements nor §M.1 contains an enumerated 1–23 list; "23/23 PASS" is asserted, not checkable. The architects should write the register so Part B is verifiable. *(both)*

## P2 — track / decide (lower urgency)

- **P2-1 · Enum forward-compat decision.** `lib/content/models/enums.dart` has no `unknownEnumValue` fallback → an older client hard-rejects any batch with a newer enum value (fails closed — safe, but a content-versioning fragility). Decide hard-reject vs graceful-degrade before shipping versioned backend content. *(security MISS-8; R-C12)*
- **P2-2 · Separate the security audit log from anonymous analytics.** Non-repudiation of sensitive security actions (retained) vs minimized anonymous analytics are two different stores; the draft blurs them (TS-7 vs TP-1/TP-6). *(security)*
- **P2-3 · Enumerate consent/transparency obligations in TP-5.** Locked age-gate → UMP → ATT order (R-K2); EU AI Act Art. 50 "you're talking to an AI" + C2PA media provenance (R-K5, in force Aug 2026). *(privacy P2-1)*
- **P2-4 · Pin the analytics sink in the data-flow diagram** and confirm the CI guard that `auth.uid()`/any minor id never reaches analytics/ad SDKs (R-K6). *(both)*

---

## What this means for the gate
This pass **improves** the draft and the checklist; it does **not** close the gate. The Stage-4 sign-off still needs a human owner decision: the two checklist preconditions ("5 seams built", "pg_dump diff=0") are **not yet satisfiable** (P0-1, P0-2), so the honest current status is **"prerequisites not met — backend not authorized."** For a solo dev with no backend and no users yet, that's the *cheap* time to fix these — they're schema/RLS/seam design decisions made on paper, once, before any data exists.

*Source: two independent Claude review agents (security-auditor + general-purpose privacy/architecture), Session 17, read-only. Findings are advisory until you (the owner) accept them. Canonical copy: repo `docs/`; owner mirror: `Apps/RATEL_STAGE4_VALIDATION_FINDINGS.md`.*
