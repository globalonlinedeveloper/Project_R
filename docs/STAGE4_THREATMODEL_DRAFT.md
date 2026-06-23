# Stage-4 Threat-Model — FIRST-PASS DRAFT (Claude-generated, for architect review)

> **⚠ THIS IS A DRAFT, NOT THE SIGN-OFF.** Claude produced this first pass from the architecture in `docs/STAGE4_THREATMODEL_WORKSHEET.md` to give the workshop a head start. It is **not** the human STRIDE+LINDDUN workshop, **not** a dual senior-architect review, and it does **NOT** satisfy the Stage-4 gate. Two qualified, owner-assigned architects must validate it, add what's missing, set final severity/owners, and sign (`docs/STAGE4_SIGNOFF_CHECKLIST.md` Part E). No decisions were changed; **Supabase remains untouched; Stage 3 not started.**
>
> **S18 update (validation findings folded in).** This pass expands the draft per the two-agent validation (`docs/STAGE4_VALIDATION_FINDINGS.md`): new findings TS-8…TS-13 and TP-7/TP-8, re-ranks (service-role key → P0), and the privacy fixes (P1-8). **Everything here is DESIGN written on paper — nothing is implemented; all of it is Stage-3 work gated behind sign-off + the owner money-gate.** The one item already BUILT in code is the analytics allow-list (P0-5, TP-2) — noted inline.

## Architect seats (owner assigns the names — Claude cannot)

| Seat | Suggested focus | Reviews | Name (owner to fill) | Signed |
|------|-----------------|---------|----------------------|:--:|
| Reviewer 1 | Backend / security architect | Checklist A · B · C-STRIDE · D | ____________ | ☐ |
| Reviewer 2 | Privacy / data architect | Checklist A · B · C-LINDDUN · D | ____________ | ☐ |

---

## A. STRIDE — draft findings (security)

Severity is a **proposed** starting point; the architects confirm. Status starts `draft`. Findings TS-8…TS-13 are **S18 additions** (design-only — written, not built).

| ID | Element / flow | STRIDE | Threat (draft) | Proposed mitigation (draft) | Sev (proposed) | Status |
|----|----------------|--------|----------------|------------------------------|:--:|:--:|
| TS-1 | E12 Auth | Spoofing | Forged/replayed JWT impersonates a learner | Derive identity only from verified `auth.uid()`; short-lived access tokens + rotating refresh; never trust any client-supplied user id | P0 | draft |
| TS-2 | E5→E13 DAL→Postgres | Tampering | Client writes rows it shouldn't (other users' rows) | Deny-by-default RLS keyed on `auth.uid()` on every table; server-validated writes; no service-role on the client | P0 | draft |
| TS-3 | E13 Postgres+RLS | Info disclosure | A missing/overbroad RLS policy leaks another learner's rows | Per-table RLS with **negative** tests; audit `SECURITY DEFINER` functions; default-deny posture | P0 | draft |
| TS-4 | E2→E14 AI relay | DoS / cost | Unbounded AI/relay calls cause runaway spend | Per-user rate limits + credit-wallet caps (R-M8); server-side budget ceiling + circuit-breaker; Turnstile gate | P1 | draft |
| TS-5 | E14 Edge Functions | Elevation of priv | **Service-role key leak bypasses ALL RLS = full multi-tenant breach** (re-ranked P1→**P0**, finding P0-6); or SSRF in the relay | Service-role key **server-side only, never in client / never logged**; key-rotation plan (ahead of Supabase legacy-key deprecation); pin allowed model/vendor endpoints (anti-SSRF), no arbitrary outbound URL; least-privilege function roles | **P0** | draft |
| TS-6 | E4↔E16/E17 entitlement | Tampering | Forged/replayed IAP/checkout receipt grants Pro for free | **Payments hardening (P1-1):** server-side receipt validation **+** webhook **signature verification** **+ idempotency / event-dedupe** (a replayed webhook can't re-grant Pro) **+ refund/chargeback/lapse clawback** (revoke entitlement server-side); entitlement computed server-side, never client-asserted | P1 | draft |
| TS-7 | E3 analytics vs audit log | Repudiation | No reliable audit of sensitive security actions | **Separate stores (P2-2):** a dedicated append-only, server-timestamped **security audit log** (retained, non-repudiation) — distinct from the minimized anonymous **analytics** stream (TP-1/TP-6). Don't blur the two | P2 | draft |
| **TS-8** | E13 entitlement & credit tables | Tampering / Elev | **Naïve `auth.uid()` RLS with a permissive `WITH CHECK` lets a user UPDATE their own `pro_until` / credit balance → free Pro / infinite credits** (finding P0-3; distinct from generic TS-2 row-tampering) | Entitlement & credit/ledger tables are **client-READ-ONLY** in RLS — **no** client-writable `WITH CHECK` on entitlement columns; **only the Edge-Function service-role may write them**; entitlement state is server-derived | **P0** | draft |
| **TS-9** | E14 credit grant paths | Tampering (economic) | **Credit-minting / ledger integrity** — referral + AI-sampler grant paths are a margin attack (self-referral, multi-account, replay) | Device attestation; Turnstile on **every** grant path; per-account & per-device velocity caps; **double-entry ledger** (grants and spends reconcile); **fail-closed at zero**; server-authoritative balance | **P0** | draft |
| **TS-10** | E2→E14 AI relay (moderation) | Info-disc / Elev | **AI-relay moderation bypass** — minors (13+) reach the Pro tutor; prompt-injection / output-exfiltration (OWASP-LLM-01/02) | Input **and** output moderation on the relay; **fail CLOSED when the moderation provider is down** (no un-moderated path to a minor); strip/deny tool-style instructions in user input; log moderation decisions to the audit store (TS-7) | **P0** | draft |
| **TS-11** | E12 Auth (anon→auth) | Spoofing / IDOR | **Anonymous→authenticated migration** — a client claims another user's anonymous local state on sign-in (finding P1-4) | Bind local/anon state to `auth.uid()` **server-side** with a one-time, server-issued claim token; never trust a client-supplied anon id; add **refresh-token rotation + revocation** and bound the **leaked-JWT blast radius** (ties to TS-1) | P1 | draft |
| **TS-12** | E14 Edge (R2 · Turnstile · KV) | Info-disc / Elev | **Edge perimeter row was blank** (finding P1-6): unscoped R2 URLs, Pro audio protected only by obscurity, Turnstile only at signup | **R2 signed URLs with short TTL + tight scope**; **Pro-only audio authorized** (entitlement-checked), not just unguessable; **Turnstile on every free-credit-grant entry point**, not only signup; KV holds no secrets | P1 | draft |
| **TS-13** | E2/E13 → UI render | Tampering | **Server/AI output is untrusted** (finding P1-7): the same models deserialize relay/Postgres + AI text into the UI | Treat all server + AI output as untrusted; **no rendering into rich-text/HTML sinks without sanitization** (OWASP-LLM-02); schema-validate relay payloads on the client; cap/escape AI text | P1 | draft |

## B. LINDDUN — draft findings (privacy)

Findings TP-7/TP-8 are **S18 additions**; TP-2/3/4/5/6 carry the P1-8/P1-2/P2-3 fixes.

| ID | Element / flow | LINDDUN | Threat (draft) | Proposed mitigation (draft) | Sev (proposed) | Status |
|----|----------------|---------|----------------|------------------------------|:--:|:--:|
| TP-1 | E3 analytics | Linkability | Events linkable into a behavioural profile tied to a person | Pseudonymous `user_id` only; no PII join keys; no cross-device/cross-vendor linking | P1 | draft |
| TP-2 | E3 analytics | Identifiability | An event payload smuggles PII (email, name, free-text) or `auth.uid()` | **✅ CLIENT GUARD BUILT (P0-5, S18):** taxonomy allow-list enforced at the seam (`additionalProperties:false` mirror) + CI guard that no `auth.uid()`/PII reaches a vendor/ad SDK. **Stage-3 remaining:** server-side/SDK-egress enforcement + the known-minor two-ID split (R-M1) | **P0** | client-built |
| TP-3 | E1 on-device ASR | Disclosure | A **voiceprint is derived** or raw audio is uploaded/persisted | On-device ASR only; upload derived scores/text, **never raw audio** (§8) and **never DERIVE a voiceprint** (not merely "don't upload one"); no biometric template stored. **One lawful exception:** a CSAE→NCMEC report may retain the minimal **text** record ~1 year (R-K-safety) — audio is never the artifact | P0 | draft |
| TP-4 | E13 + E3 + E2 residency | Non-compliance | **Cross-border transfer is real (finding P1-2):** "pin `ap-south-1`" covers the **DB only** — analytics (Firebase/GA4 + Crashlytics, US), the AI relay (Gemini), and moderation (OpenAI) **send data outside the region by design** (R-M1 accepts weaker EU residency) | Pin Supabase `ap-south-1` for first-party data; **document the lawful-transfer basis (SCCs, R-K7)** for each egress; **stop implying data stays in-region**; map each flow's destination + safeguard | P1 | draft |
| TP-5 | consent / listing | Unawareness | Users not meaningfully informed; child-directed-classification risk | **Enumerate the obligations (P2-3):** locked **age-gate → UMP → ATT** order (R-K2); clear privacy notice + consent; general-audience listing (R-K1, no child-directed design / COPPA); **EU AI Act Art. 50** "you're talking to an AI" disclosure + **C2PA** media provenance (R-K5, in force Aug 2026) | P1 | draft |
| TP-6 | E13 ReviewLog / logs | Detectability / **retention-vs-erasure** | **Reframed (P1-8):** the tension is **indefinite `ReviewLog` retention (kept forever, R-M) vs the DSAR right to erasure** — not a TTL problem | Reconcile the two explicitly: `ReviewLog` is retained for the learning model, **but a DSAR delete must still erase or anonymize the user's rows** (see TP-8). **Drop** the earlier "TTL/purge ReviewLog" mitigation — it contradicts R-M | P1 | draft |
| **TP-7** | E2/E3/E14 third-party SDKs | Disclosure / Non-compliance | **Sub-processor exposure (finding P1-3):** AdMob, Firebase, Gemini, OpenAI, Cloudflare each see some identifier/data | Per-SDK: document **what identifier each sees**; consent-gate (UMP/ATT, `npa=1` for non-personalized ads); **India under-18 ad HARD-GATE (DPDP)**; publish a **sub-processor list** (R-K5/R-K7/R-J4); DPAs in place | P1 | draft |
| **TP-8** | E13 + E12 + E3 (cascade) | Non-compliance | **Data-Subject Rights missing (finding P0-4):** R-K4 requires in-app **data export + account deletion** cascading across Supabase + auth + Firebase/Crashlytics within GDPR/CCPA/DPDP windows | Design the **export + delete cascade** now (architecture, not a Stage-3 detail): enumerate every store holding user data; define the deletion order + `ReviewLog` reconciliation (anonymize vs delete, TP-6); SLA timers per regime | **P0** | draft |

## C. STRIDE matrix (draft — cells reference a finding above)

| Element / flow | Spoof | Tamper | Repud | Info-disc | DoS | Elev |
|----------------|:--:|:--:|:--:|:--:|:--:|:--:|
| E12 Auth / auth.uid() | TS-1 / TS-11 | — | — | — | — | — |
| E5 DAL → E13 Postgres | — | TS-2 | — | TS-3 | — | — |
| E13 Postgres + RLS | — | TS-2 / **TS-8** | — | TS-3 | — | TS-8 |
| E13 entitlement/credit | — | **TS-8 / TS-9** | — | — | — | TS-8 |
| E2 AI adapter → E14 relay | — | — | — | **TS-10** | TS-4 | TS-5 |
| E14 Edge Functions / R2·Turnstile·KV | — | **TS-9** | — | **TS-12** | TS-4 | TS-5 / **TS-12** |
| E2/E13 → UI render | — | **TS-13** | — | **TS-13** | — | — |
| E4 payment ↔ stores | — | TS-6 | — | — | — | — |
| E3 analytics / audit | — | — | TS-7 | — | — | — |

## D. LINDDUN matrix (draft)

| Element / flow | Link | Ident | Non-rep | Detect | Disc | Unaware | Non-comply |
|----------------|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| E1 on-device ASR | — | — | — | — | TP-3 | — | — |
| E3 analytics events | TP-1 | TP-2 | — | — | TP-7 | TP-5 | TP-7 |
| E2/E14 AI + moderation | — | — | — | — | TP-7 | TP-5 | TP-4 |
| E13 Postgres records | — | — | — | TP-6 | — | — | TP-4 / TP-8 |
| E12+E13+E3 DSAR cascade | — | — | — | — | — | — | TP-8 |

---

## S18 design-only additions — explicitly NOT implemented

Per the build guardrails, the following were **written into this model as design** and **must not be built before Stage-3 sign-off + the owner money-gate**: TS-8 (entitlement/ledger RLS client-read-only · P0-3), TS-9 (credit-minting · P0-7a), TS-10 (AI-moderation bypass · P0-7b), TS-11 (anon→auth migration · P1-4), TS-5 re-rank + rotation (service-role key · P0-6), TS-6 expansion (payments hardening · P1-1), TS-12 (Edge perimeter · P1-6), TS-13 (untrusted output · P1-7), TP-8 (DSAR cascade · P0-4), TP-7 (sub-processors · P1-3), and the TP-3/TP-4/TP-5/TP-6 privacy fixes (P1-8/P1-2/P2-3). The only thing built in code is the TP-2 client allow-list (P0-5). Supabase remains untouched.

## Still required to CLOSE the gate (none of this is done — human work)

- [ ] Owner **assigns** the two architects (fill the seats above).
- [ ] Architects **validate** this draft against the live design, correct the diagram, add missing threats/elements, and confirm the new TS-8…TS-13 / TP-7/TP-8 severities.
- [ ] Set **final** severity + named owner per finding; resolve every **P0/P1** with an accepted mitigation.
- [ ] Complete checklist **Part A** (5 seams) and **Part B** (ratify the 23-door register, `docs/STAGE4_ONEWAY_DOORS.md`).
- [ ] **P0-2 (owner-gated):** author the Stage-3 user tables into `schema.json` so Part D `pg_dump diff=0` is meaningful and per-table RLS (incl. TS-8) is verifiable.
- [ ] Run **Part D** — `pg_dump` diff = 0 against a disposable DB (live project untouched).
- [ ] **Both** architects sign **Part E**.

Only when every box above is checked does Stage 3 become authorized (still owner + money-gated).

*Claude first-pass draft (Session 17; expanded Session 18 with the validation findings). No analysis is authoritative until architect-validated; no sign-off performed; no backend touched. Canonical copy: repo `docs/`; owner mirror: `Apps/RATEL_STAGE4_THREATMODEL_DRAFT.md`.*
