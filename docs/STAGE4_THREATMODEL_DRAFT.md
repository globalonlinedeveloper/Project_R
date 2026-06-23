# Stage-4 Threat-Model — FIRST-PASS DRAFT (Claude-generated, for architect review)

> **⚠ THIS IS A DRAFT, NOT THE SIGN-OFF.** Claude produced this first pass from the architecture in `docs/STAGE4_THREATMODEL_WORKSHEET.md` to give the workshop a head start. It is **not** the human STRIDE+LINDDUN workshop, **not** a dual senior-architect review, and it does **NOT** satisfy the Stage-4 gate. Two qualified, owner-assigned architects must validate it, add what's missing, set final severity/owners, and sign (`docs/STAGE4_SIGNOFF_CHECKLIST.md` Part E). No decisions were changed; **Supabase remains untouched; Stage 3 not started.**

## Architect seats (owner assigns the names — Claude cannot)

| Seat | Suggested focus | Reviews | Name (owner to fill) | Signed |
|------|-----------------|---------|----------------------|:--:|
| Reviewer 1 | Backend / security architect | Checklist A · B · C-STRIDE · D | ____________ | ☐ |
| Reviewer 2 | Privacy / data architect | Checklist A · B · C-LINDDUN · D | ____________ | ☐ |

---

## A. STRIDE — draft findings (security)

Severity is a **proposed** starting point; the architects confirm. Status starts `draft`.

| ID | Element / flow | STRIDE | Threat (draft) | Proposed mitigation (draft) | Sev (proposed) | Status |
|----|----------------|--------|----------------|------------------------------|:--:|:--:|
| TS-1 | E12 Auth | Spoofing | Forged/replayed JWT impersonates a learner | Derive identity only from verified `auth.uid()`; short-lived access tokens + rotating refresh; never trust any client-supplied user id | P0 | draft |
| TS-2 | E5→E13 DAL→Postgres | Tampering | Client writes rows it shouldn't (other users' rows, entitlement flags) | Deny-by-default RLS keyed on `auth.uid()` on every table; server-validated writes; no service-role on the client | P0 | draft |
| TS-3 | E13 Postgres+RLS | Info disclosure | A missing/overbroad RLS policy leaks another learner's rows | Per-table RLS with **negative** tests; audit `SECURITY DEFINER` functions; default-deny posture | P0 | draft |
| TS-4 | E2→E14 AI relay | DoS / cost | Unbounded AI/relay calls cause runaway spend | Per-user rate limits + credit-wallet caps (R-M8); server-side budget ceiling + circuit-breaker; Turnstile gate | P1 | draft |
| TS-5 | E14 Edge Functions | Elevation of priv | Service-role key leak or SSRF in the relay | Least-privilege keys server-side only; pin allowed model endpoints; validate/scope relay inputs; no arbitrary outbound URL | P1 | draft |
| TS-6 | E4↔E16/E17 entitlement | Tampering | Forged IAP/checkout receipt grants Pro for free | Server-side receipt validation + signed store/Stripe webhooks; entitlement computed server-side, never client-asserted | P1 | draft |
| TS-7 | E3 analytics | Repudiation | No reliable audit of sensitive actions | Append-only, server-timestamped event log via the analytics seam (anonymous) | P2 | draft |

## B. LINDDUN — draft findings (privacy)

| ID | Element / flow | LINDDUN | Threat (draft) | Proposed mitigation (draft) | Sev (proposed) | Status |
|----|----------------|---------|----------------|------------------------------|:--:|:--:|
| TP-1 | E3 analytics | Linkability | Events linkable into a behavioural profile tied to a person | Pseudonymous `user_id` only; no PII join keys; no cross-device/cross-vendor linking | P1 | draft |
| TP-2 | E3 analytics | Identifiability | An event payload smuggles PII (email, name, free-text) | Enforce a taxonomy allow-list at the seam — reject unknown fields (the client mirror of `additionalProperties:false`) | P1 | draft |
| TP-3 | E1 on-device ASR | Disclosure | Raw audio or a voiceprint is uploaded/persisted | On-device ASR only; upload derived scores/text, **never raw audio** (§8 hard rule); no voiceprint storage | P0 | draft |
| TP-4 | E13 residency | Non-compliance | Learner data lands outside `ap-south-1` or crosses borders unlawfully | Pin Supabase `ap-south-1`; document any transfer; GDPR/DPDP retention + deletion (DSAR) | P1 | draft |
| TP-5 | consent / listing | Unawareness | Users not meaningfully informed; child-directed-classification risk | Clear privacy notice + consent; general-audience store listing (R-K1); no child-directed design (COPPA) | P1 | draft |
| TP-6 | E13 logs / ReviewLog | Detectability / retention | Indefinite retention of learner records | Retention limits + TTL; partition `ReviewLog` (`pg_partman`) with purge; honour deletion requests | P2 | draft |

## C. STRIDE matrix (draft — cells reference a finding above)

| Element / flow | Spoof | Tamper | Repud | Info-disc | DoS | Elev |
|----------------|:--:|:--:|:--:|:--:|:--:|:--:|
| E12 Auth / auth.uid() | TS-1 | — | — | — | — | — |
| E5 DAL → E13 Postgres | — | TS-2 | — | TS-3 | — | — |
| E13 Postgres + RLS | — | — | — | TS-3 | — | TS-2 |
| E2 AI adapter → E14 relay | — | — | — | — | TS-4 | TS-5 |
| E14 Edge Functions | — | — | — | — | TS-4 | TS-5 |
| E4 payment ↔ stores | — | TS-6 | — | — | — | — |
| E3 analytics | — | — | TS-7 | — | — | — |

## D. LINDDUN matrix (draft)

| Element / flow | Link | Ident | Non-rep | Detect | Disc | Unaware | Non-comply |
|----------------|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| E1 on-device ASR | — | — | — | — | TP-3 | — | — |
| E3 analytics events | TP-1 | TP-2 | — | — | — | TP-5 | — |
| E13 Postgres records | — | — | — | TP-6 | — | — | TP-4 |

---

## Still required to CLOSE the gate (none of this is done — human work)

- [ ] Owner **assigns** the two architects (fill the seats above).
- [ ] Architects **validate** this draft against the live design, correct the diagram, add missing threats/elements.
- [ ] Set **final** severity + named owner per finding; resolve every **P0/P1** with an accepted mitigation.
- [ ] Complete checklist **Part A** (5 seams) and **Part B** (23 doors vs §M.1).
- [ ] Run **Part D** — `pg_dump` diff = 0 against a disposable DB (live project untouched).
- [ ] **Both** architects sign **Part E**.

Only when every box above is checked does Stage 3 become authorized (still owner + money-gated).

*Claude first-pass draft (Session 17). No analysis is authoritative until architect-validated; no sign-off performed; no backend touched. Canonical copy: repo `docs/`; owner mirror: `Apps/RATEL_STAGE4_THREATMODEL_DRAFT.md`.*
