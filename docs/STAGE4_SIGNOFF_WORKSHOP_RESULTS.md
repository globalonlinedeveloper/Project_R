# Ratel — Stage-4 Sign-Off Workshop RESULTS (R-O1, Gate 0)

> **What this is.** The filled-in results of the Stage-4 architecture review (sign-off checklist Parts A–D), produced on **2026-06-23 (Session 26)** by **two independent AI review agents** — one security/STRIDE, one privacy/architecture (LINDDUN + Parts A/B/D) — reading the actual built code (`lib/services` M1–M8, `schema/sql` 0001–0005, the pgserver security tests) and the Stage-3 design (the 4 Deno hosts + wiring map).
>
> **Status of the gate.** These findings **INFORM** the R-O1 sign-off; they do **NOT** replace it. The R-O1 standard is two qualified **human** senior architects. That standard is **NOT met** here. The owner has elected to **self-attest as a solo founder** — recorded honestly as an explicit **R-O1 deviation** in §9 below (not two fabricated architect signatures). Nothing here authorizes spending money or touching a live backend.
>
> **Full evidence (verbatim agent output):** `docs/STAGE4_REVIEW_AGENT1_SECURITY.md` (34.6 KB, 28 STRIDE findings) · `docs/STAGE4_REVIEW_AGENT2_PRIVACY_ARCH.md` (32.1 KB, LINDDUN + Parts A/B/D, full 23-door table). This doc is the consolidated synthesis + the actionable punch list.

---

## 1. Method & scope

Two independent agents reviewed in parallel, read-only, no live system touched:

- **Agent 1 — Security (STRIDE):** spoofing/`auth.uid()`, RLS bypass, Edge service-role usage, payments idempotency, credit-mint abuse, AI cost/DoS, moderation fail-closed, and the 4 Deno-host designs.
- **Agent 2 — Privacy/Architecture (LINDDUN + Parts A/B/D):** PII/analytics, raw-audio/voiceprint, consent/DPDP/GDPR/COPPA, the 5 portability seams (Part A), the 23 one-way doors (Part B), and the `pg_dump diff=0` procedure (Part D).

This is the legitimate use of agents the project always allowed: agents **do the review work**; humans **sign**. (`RATEL_PROJECT_STATE` has said throughout: "the agent review informs it but CANNOT replace the signatures.")

## 2. Headline verdict

Both reviewers independently concluded the built surface is **materially stronger than a typical pre-backend Stage-4 baseline** — and unusually, the hard controls are **proven with negative tests**, not just asserted. But neither rubber-stamped: there is a **named punch list (§8)** that must be closed before the relevant pieces go live, and **one finding both agents converged on**:

> **★ Convergent critical finding — payments provider drift.** The only built webhook verifier is **Stripe-shaped** (`t=,v1=` HMAC over `"<t>.<rawBody>"`), but the owner-LOCKED vendor (2026-06-23) is **Razorpay (web) + Play Billing (Android)**, which sign differently. The `billing`/`verifyWebhook` seam abstracts the provider and the normalized `PaymentEvent` → `apply_entitlement_event` path is provider-agnostic, so this is **not a gate-blocker** — but a real **Razorpay HMAC verifier + Play S2S receipt validation must be written before payments go live**. This slightly qualifies the earlier "go-live is mostly wiring, not logic" claim: there is a payment verifier to *build*. (Tracked as PAY-1 + one-way Door #21.)

## 3. Part A — the 5 portability seams → **PASS**

Both confirm the 5 seams (`ai_relay`, `analytics`, `billing`, `data_access`, `identity`) are **genuine, fail-closed boundaries** Stage 3 plugs into — not stubs Stage 3 would bypass. Each provider is injected; defaults fail closed (no-key Gemini ⇒ unavailable; moderation-down ⇒ deny; in-memory learner store; anonymous identity). `schema.json` remains the single contract.

## 4. Part B — the 23 one-way doors → **ACCEPT WITH ADJUSTMENTS**

The 23-row register is a defensible construction and is honestly flagged as "asserted, not yet enumerated in §M.1" (finding P1-9). Ratified as the working canonical list, with **two named drifts to close before the backend ships** (full 23-row cross-check table is in `STAGE4_REVIEW_AGENT2_PRIVACY_ARCH.md` §3):

- **Door #4 — ReviewLog partitioning.** The *born-partitioned-by-time* invariant is correctly locked in `0001`, **but** only two static monthly partitions exist (2026-06, 2026-07) and **`pg_partman` is not encoded** → inserts fail after 2026-07 without the go-live maintenance job. ★ **Time-sensitive** (PARTMAN-1).
- **Door #21 — web payments processor.** Posture (server-side `pro_until`, store-agnostic) is locked and consistent, but the concrete web processor drifted: requirements said Stripe/Paddle/Lemon Squeezy, the 2026-06-23 lock says **Razorpay**, and the built verifier is Stripe-shaped. Reconcile (PAY-1). Candidate split for a deliberate 23rd door: native-IAP entitlement vs web-checkout processor.

No door is open or blocking; #4 and #21 carry named drift. Standing action: enumerate the 23 into a real `§M.1`.

## 5. Part C — STRIDE (security) summary

**Verdict: CONDITIONAL PASS.** 28 findings — **7 P0 / 11 P1 / ~10 P2**. Of the 7 P0s, **5 are already mitigated and proven in built code**; only 2 are open (both unbuilt edges).

**Mitigated + proven (preserve exactly — do not weaken):**

- Self-grant Pro / self-mint credits / cross-user read-write — blocked by `0002` (client-read-only on `user`/`credit_ledger`) + `0003` (per-table deny-by-default RLS); negative tests prove a client cannot EXECUTE the `SECURITY DEFINER` fns or write directly.
- Credit ledger — double-entry, fail-closed-at-zero, idempotent on `client_event_id`, with a real two-thread concurrency proof (`0004`).
- Payments — constant-time HMAC + timestamp tolerance + replay window; exactly-once `pro_until` via `processed_payment_event` dedupe; refund/chargeback clawback (`0005`). *(Stripe-shape — see PAY-1.)*
- Service-role key never in repo — read-from-env contract + CI secret-scan guard (`service_role_contract.dart`, `test_secret_scan.py`).
- Analytics PII/`auth.uid()` egress — blocked by the taxonomy allow-list before any vendor SDK (`taxonomy.dart`).
- Untrusted-output `RelayText` box + server-only `AnonymousClaimToken` make unsafe paths unrepresentable at the type level; moderation fails closed on input **and** output.

**Open P0/P1 → see punch list (§8):** SEC-JWT (JWT issuance), SEC-EDGE (Deno-host hardening), PAY-1 (Razorpay/Play verifier), COST-1 (cap-bypass on blocked output), AUDIT-1 (durable audit store), CAPS-1 (confirm cap values).

## 6. Part C — LINDDUN (privacy) summary

**Verdict: sound architecture, not clean.** **3 P0 / 5 P1 / 5 P2.** The privacy-critical gaps are exactly the ones a paid backend hinges on:

- **DSAR-1 (P0)** — the delete cascade has **no anchor from `auth.users` → `public.user`**; intra-`public` cascade is correct, but Supabase Auth account deletion would orphan `public.user` + children. Add the FK or a service-role delete routine.
- **DSAR-2 (P0)** — "ReviewLog kept forever" (R-M3) collides with DSAR erasure; current `ON DELETE CASCADE` would erase it. Make an explicit **anonymize-vs-delete** decision and encode it.
- **VOICE-1 (P0)** — raw-audio/voiceprint non-derivation is unverifiable (no voice code in the surface); confirm the Stage-3 voice path keeps only transient text.
- **P1s:** PAY-1 (provider drift), XBORDER-1 (document SCC/DPDP basis for egress outside `ap-south-1`), SUBPROC-1 (publish per-SDK sub-processor list + India under-18 ad hard-gate), ANALYTICS-ID (pin a pseudonymous analytics id; never `auth.uid()`, none for minors), CONSENT-1 (consent order age-gate→UMP→ATT + EU AI Act Art. 50 + C2PA).

## 7. Part D — `pg_dump diff = 0` → **PASS with caveats**

The procedure is methodologically sound, disposable, and live-safe (proven locally + in CI: round-trip parity = 0 drift on pgserver 16.2; live project never connected). Caveats to carry to go-live: (1) it proves **DDL round-trip + generator-artifact parity**, not a direct `schema.json` diff (transitive via codegen); (2) it covers **structural DDL only** (`--no-privileges`, `0001`) — RLS/policies/functions are proven by the *separate* isolation test, not by the dump diff; (3) the round-trip **skips where pgserver is absent**, so a human must run the live/branch parity at go-live and attach artifacts.

---

## 8. ★ Consolidated P0/P1 PUNCH LIST (named mitigations + where each closes)

Every item has a named owner action and the go-live phase/step (per `GO_LIVE_CHECKLIST.md`) where it must close. **These are go-live-gating conditions, not yet resolved.**

| ID | Finding | Sev | Type | Disposition / where it closes |
|----|---------|-----|------|-------------------------------|
| **PAY-1** | Built verifier is Stripe-shaped; locked vendor is Razorpay/Play (both agents) | P1 | Build | Write Razorpay HMAC verify + Play S2S behind the `PaymentEvent` seam. **Phase 1 §1b (Razorpay) + Phase 2 §2b (Play).** Reconciles Door #21. |
| **SEC-JWT** | JWT issuance unbuilt; `auth.uid()` is sole PK | P0 | Config | Supabase Auth: short-lived + rotating/revocable tokens; confirm `auth.uid()` end-to-end. **Phase 1 §1b/§1c.** |
| **SEC-EDGE** | The 4 Deno hosts hold the service-role key; no code yet | P0 | Build+review | Dedicated host-hardening review before deploy: anti-SSRF endpoint pinning, key-never-logged, verify-before-mint/grant, fail-closed. **Gate Phase 1 §1c deploy on this.** |
| **DSAR-1** | No `auth.users → public.user` delete anchor (orphan on account delete) | P0 | Decide+migrate | Add FK `ON DELETE CASCADE` or a service-role delete routine. **Decide now; Phase 1 §1c migration.** |
| **DSAR-2** | ReviewLog "kept forever" vs DSAR erasure conflict | P0 | Owner decision | Explicit anonymize-vs-delete decision, then encode. **Phase 1 §1d.** |
| **VOICE-1** | Raw-audio/voiceprint non-derivation unverifiable | P0 | Confirm at build | Confirm voice path derives only transient text; never persist raw audio/voiceprint. **At voice build (Phase 1+).** |
| **COST-1** | Per-user cap bypass: spend recorded only after a *successful* inner call, but output moderation is inside the inner relay → blocked/failed outputs not charged | P1 | Build fix | Record spend on "attempted," not "succeeded." Small local fix (can land build-ahead-style) or **Phase 1 §1b.** |
| **AUDIT-1** | Grant-denial + moderation audit sinks are no-op locally | P1 | Build | Wire a durable append-only audit store. **Phase 1 §1c.** |
| **CAPS-1** | Placeholder per-user/global cost caps + grant velocity caps | P1/P2 | Owner decision | Confirm real cap values (product decision). **Phase 1.** |
| **XBORDER-1** | Cross-border egress (analytics/Gemini/OpenAI) outside `ap-south-1` | P1 | Legal/doc | Document SCC/DPDP transfer basis. **Phase 1 §1d.** |
| **SUBPROC-1** | Sub-processor transparency + India under-18 ads | P1 | Legal/config | Publish per-SDK sub-processor list (incl. Razorpay); hard-gate under-18 ads. **Phase 1 §1d / Phase 2 ads.** |
| **ANALYTICS-ID** | Pseudonymous analytics-id strategy undefined | P1 | Build+decide | Pin it: never `auth.uid()`; none for minors. **Phase 1 §1b.** |
| **CONSENT-1** | Consent order + AI-disclosure | P1 | Build+legal | age-gate → UMP → ATT order; EU AI Act Art. 50 disclosure; C2PA. **Phase 1 §1d / Phase 3 ATT.** |
| **PARTMAN-1** | `pg_partman` maintenance not encoded; static partitions expire after 2026-07 | P2 | Ops/build | Wire `pg_partman` `run_maintenance()` via pg_cron. ★ Time-sensitive. **Phase 1 §1c.** Reconciles Door #4. |

---

## 9. Part E — R-O1 sign-off: SELF-ATTESTATION (DEVIATION, recorded honestly)

**The R-O1 standard — two qualified, independent, human senior architects sign — is NOT met.** The owner has chosen, as a solo founder, to self-attest in lieu of a second independent human reviewer, having commissioned the two-agent independent review above. This is recorded as a deviation, not disguised as a dual human sign-off.

| Seat | Required | Status |
|------|----------|--------|
| Architect 1 (human, independent) | qualified senior architect | **UNFILLED** — not satisfied |
| Architect 2 (human, independent) | qualified senior architect | **UNFILLED** — not satisfied |
| Independent review (informational) | — | ✅ two AI agents (security + privacy/arch), 2026-06-23 — see §1, evidence files |

**Owner self-attestation**

- Owner: **Rajasekar Selvam** (rajasekarjavaee@gmail.com) · Date: **2026-06-23**
- I acknowledge R-O1 requires two independent human senior architects and that **this is not that**. I am self-attesting as a solo founder.
- I have read the two-agent review and the §8 punch list. I accept every P0/P1 as a **go-live-gating condition** that must be closed at the mapped phase/step before that piece goes live (nothing live until then; Turnstile enabled last).
- I **explicitly accept the residual risk** of proceeding without two independent human reviewers — including the classes the dual review exists to catch (RLS bypass, credit-mint abuse, payments idempotency, PII leakage, irreversible one-way doors).
- This self-attestation can be **superseded** later by obtaining real human signatures in the table above; doing so is recommended before scaling.

**Honest criteria status:** Part A ✅ seams real · Part B ✅ accept-with-adjustments (#4, #21) · Part C ⚠ done, P0/P1 named but several **OPEN** (not "no unmitigated P0/P1") · Part D ✅ local/CI, human live-diff pending · Two human architects ❌ **not signed** (self-attestation deviation).

## 10. Bottom line — what this authorizes

This self-attestation lets the project **proceed into Stage-3 go-live wiring** with the §8 punch list as explicit gating conditions — it does **not** declare the architecture "signed clean." Each P0/P1 closes at its mapped phase/step before that piece goes live; the live `pg_dump`/RLS parity is run by a human at provisioning; Turnstile is enabled last. Obtaining two real human signatures remains the recommended upgrade and would supersede this record.

*Session 26, 2026-06-23. Agent-produced review (informational) + owner self-attestation (deviation). No accounts, no money, no deploy, live backend untouched. Reversible via git. Canonical copy in the repo; owner-facing mirror in `Apps/`.*
