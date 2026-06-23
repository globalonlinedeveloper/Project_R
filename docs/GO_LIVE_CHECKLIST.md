# Ratel — PHASED GO-LIVE CHECKLIST

> **PLANNING DOCUMENT ONLY.** Authoring/committing this file creates **no accounts, spends no money, deploys nothing, and never touches the live Supabase / Stripe / Razorpay / Gemini / OpenAI / Cloudflare / Play / Apple projects.** It describes the steps to *execute later*, each clearly marked as **OWNER** or **CLAUDE** work, and which step gates the next.
>
> **Master gate (never faked):** the **human dual senior-architect Stage-4 Part-E sign-off (R-O1)** must be SIGNED by two real architects before ANY phase goes live. The Part-2 build-ahead (M1–M8) *informs* that review — it does **not** replace the signatures. See `docs/STAGE4_SIGNOFF_CHECKLIST.md` Part E.
>
> Canonical companions: `docs/VENDOR_DECISIONS.md` (locked free-first vendors) · `docs/STAGE3_PARTB_WIRING_MAP.md` (adapter→provider swap points) · `docs/STAGE3_PARTB_LOCAL_BACKLOG.md` (M1–M8 spec). Code tip `main`=`cb1e8dc` (logic) / `49071af` (vendor docs); every adapter is built + locally tested, $0 spent, no live backend touched.

---

## 0. How to read this

| Tag | Who acts | Examples |
|-----|----------|----------|
| **[OWNER]** | The human owner only | Create accounts, enter a card, fill store forms, paste secrets, click "Publish", sign contracts |
| **[ARCHITECTS]** | Two senior architects (human) | The R-O1 dual sign-off — irreplaceable, never faked |
| **[CLAUDE]** | Claude, on local code + config | Write the Deno Edge functions, wire an adapter→provider in code, draft legal/store copy, configure CI deploy |
| **[CLAUDE✋]** | Claude, **only after** owner authorization **and** R-O1 sign-off | Apply SQL migrations to the *real* project, deploy the Deno hosts, flip `aiRelayProvider` to live — the steps that touch live infra or are spend-adjacent |

**Golden rule:** nothing in **[CLAUDE✋]** runs until (1) the owner has provisioned the account + secret it needs, **and** (2) Gate 0 (R-O1) is signed. Until then it stays a plan.

**Cost reality:** the whole stack launches at **$0/month** (all free tiers). The only guaranteed upfront costs are **$25 one-time Google Play** (Phase 2) and **$99/yr Apple** (Phase 3). AI spend is bounded by `CostGuard` (per-user caps + global ceiling) and is tied to paying Pro users by design.

---

## 1. Locked vendor decisions (recap — free default + free fallback)

Every capability is a portable adapter; swapping providers is a one-adapter change. **Free-first is owner-LOCKED.**

| Capability | Adapter (seam) | Default (FREE) | Free fallback | Out of scope |
|---|---|---|---|---|
| AI tutor | `AiRelay` / `GeminiAiRelay` | **Gemini** free tier | (reuse Gemini safety) | OpenAI/Anthropic (paid) |
| Content safety | `ModerationProvider` | **OpenAI Moderation** | Perspective API · Gemini safety | Azure / AWS / Hive (**do NOT wire**) |
| Web hosting | — | **Cloudflare Pages** (live) | — | — |
| Media + signed URLs | `UrlSigner` | **Cloudflare R2** (10 GB, zero egress) | **Backblaze B2** | S3 / Bunny (paid) |
| Bot protection | `TurnstileVerifier` | **Cloudflare Turnstile** (unlimited; enable LAST) | hCaptcha/reCAPTCHA ≤10k/mo | paid tiers |
| DB + auth + RLS | `ContentRepository`/`LearnerStateStore`/`Identity` | **Supabase** free | **Neon** (keeps RLS, no rewrite) | Supabase Pro (~$25/mo at scale) |
| Edge functions | — | **Supabase Edge** (Deno) / Cloudflare Workers | — | — |
| Payments — web | `billing` + `verifyWebhook` | **Razorpay** (India: UPI, GST) | Stripe (international) | Paddle/Dodo |
| Payments — Android | `billing` | **Play Billing** (India user-choice) | — | — |
| Analytics / crash / push | `Analytics` (+ taxonomy allow-list) | **Firebase** GA4 / Crashlytics / FCM | — | — |
| Device attestation | `AttestationVerifier` | **Play Integrity / App Attest** | — | — |
| AI spend control | `CostGuard` | provider-agnostic | — | — |

> **Child-safety / CSAM** specialist (e.g. Thorn Safer) is typically **paid** → deferred to the human sign-off as a compliance add-on, **NOT a launch blocker**. Free OpenAI Moderation already covers harmful text + images.

---

## 2. The four thin Deno Edge hosts (built-ahead logic → wired at go-live)

The M1–M8 business logic already exists + is tested behind injected seams. Going live = wiring real credentials into those seams and **deploying four thin Deno handlers**. Default host = **Supabase Edge Functions** (Deno-native; the service-role key is injected via `supabase secrets set` → `Deno.env`, exactly matching the M7 read-from-env contract). Cloudflare Workers is the noted alternative.

| Deno host | Composes (built-ahead units) | Real secrets it needs | First needed in |
|---|---|---|---|
| **relay-proxy** | `BudgetedAiRelay( ModeratedAiRelay( GeminiAiRelay ) )` — M1 cost gate ▸ M2 moderation ▸ M3 Gemini; fail-closed at every layer | Gemini key, OpenAI Moderation key, per-model price table | Phase 1 |
| **payments-webhook** | `PaymentsVerifier.verifyWebhook(secret)` → `parseEvent` → `apply_entitlement_event` (exactly-once `pro_until` grant/clawback) | Razorpay webhook secret (P1); Play RTDN + S2S (P2); Apple ASSN (P3) | Phase 1 |
| **grant-minting** | `GrantGuard.authorizeAndMint` (velocity + self-referral + attestation/Turnstile) → on Allow only → `post_credit_entry` | Turnstile secret (P1); Play Integrity (P2); App Attest (P3); durable audit store | Phase 1 |
| **media-presign** | `MediaUrlService.issue` (entitlement gate + GET-only / single-object / short-TTL policy) → on Grant only → real R2 `UrlSigner` | R2 presign creds + bucket, KV | Phase 1 |

---

## ▣ GATE 0 — PRE-FLIGHT (gates ALL phases; do this before Phase 1 goes live)

- [ ] **[OWNER]** Assign two senior architects (the R-O1 seats; names into `docs/STAGE4_SIGNOFF_CHECKLIST.md` Part E).
- [ ] **[ARCHITECTS]** Run the Stage-4 workshop (STRIDE + LINDDUN; the draft threat model + validation findings are the head start), ratify the 23 one-way-door register, confirm `pg_dump diff=0` procedure.
- [ ] **[ARCHITECTS]** **Dual-sign R-O1.** ← **HARD GATE. Never faked. No live wiring before both signatures exist.**
- [ ] **[OWNER]** Confirm the four free foundational accounts will be created in Phase 1 (Supabase, Cloudflare, Gemini, OpenAI, Firebase) and the secret-handling rule: every key is pasted by the owner into Supabase Edge secrets / GitHub Actions secrets — **never into the repo** (CI secret-scan from M7 enforces this).
- [ ] **[CLAUDE]** Confirm CI is green on `main` and the secret-scan guard is active; confirm no `[CLAUDE✋]` step has run.

---

## ▣ PHASE 1 — FREE WEB LAUNCH ($0)

Goal: the real product live on the web — sign-up + saved progress + AI tutor (Pro) + moderation + payments, all on free tiers at `learnwithratel.com`.

### 1a · Accounts the OWNER creates (all FREE)
- [ ] **[OWNER]** **Supabase** free project → capture `SUPABASE_URL`, project ref, anon/publishable key, **service-role key**, DB password.
- [ ] **[OWNER]** **Cloudflare** (already hosts Pages): create an **R2** bucket + S3-style API token (presign creds), a **KV** namespace, and **Turnstile** site+secret keys (do not enable enforcement yet — Turnstile goes LAST).
- [ ] **[OWNER]** **Google AI Studio** → `GEMINI_API_KEY` (free tier).
- [ ] **[OWNER]** **OpenAI** account → API key for the **Moderation** endpoint (free; does not count against usage). $0.
- [ ] **[OWNER]** **Razorpay** merchant account (India KYC + GST) → key id, key secret, **webhook secret**. Account is free; per-transaction fees apply only on real sales.
- [ ] **[OWNER]** **Firebase** (Spark/free) project → add a **Web app**, capture config; link GA4.
- [ ] **[OWNER]** Paste every secret above into **Supabase Edge secrets** (for the Deno hosts) and the two **GitHub Actions secrets** for web deploy (`CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`). Never commit them.

### 1b · What CLAUDE wires (adapter → provider, per the wiring map)
- [ ] **[CLAUDE]** `ModerationProvider` → **OpenAI Moderation** impl (default); keep Perspective / Gemini-safety as the coded fallbacks. (M2 — fail-closed already proven.)
- [ ] **[CLAUDE]** `GeminiAiRelay` transport + `GeminiConfig(baseUrl, model, key)` → real Gemini; set `CostGuard` real per-model price table + per-user/global caps; budget counters read from the credit ledger. (M1+M3.)
- [ ] **[CLAUDE]** `UrlSigner` impl → **Cloudflare R2** presign (bucket + creds); `SignedUrlPolicy` (GET-only / single-object / short-TTL) already enforced. (M6.)
- [ ] **[CLAUDE]** `PaymentsVerifier` → **Razorpay** webhook secret; `parseEvent` maps Razorpay events → `grant/refund/chargeback/lapse`; `billing` adapter → Razorpay (web). (M5.)
- [ ] **[CLAUDE]** `ContentRepository` / `LearnerStateStore` / `Identity` → **Supabase** (Postgres + Auth + RLS). Fallback **Neon** keeps RLS with no rewrite.
- [ ] **[CLAUDE]** `GrantGuard` wired; on **web there is no Play Integrity / App Attest**, so attestation-gated grant sources (ad-reward / promo / referral) are **disabled or Turnstile+velocity-only** until mobile (Phase 2/3). (M8.)
- [ ] **[CLAUDE]** `AllowListAnalytics` → **Firebase / GA4** (taxonomy allow-list blocks unknown events + PII + `auth.uid()`-shaped values). (P0-5.)
- [ ] **[CLAUDE]** Service-role key consumed **only** server-side in the Deno hosts via `Deno.env` (M7 contract); CI secret-scan stays armed.

### 1c · Deploy step — the Deno Edge hosts
- [ ] **[CLAUDE✋]** Apply SQL migrations `0001`–`0005` to the **real** Supabase project; verify `pg_dump diff=0` + RLS (client cannot self-grant Pro / mint credits) on the live project.
- [ ] **[CLAUDE✋]** Author + deploy the four Deno functions to **Supabase Edge**: **relay-proxy**, **payments-webhook**, **grant-minting**, **media-presign**; inject secrets via `supabase secrets set` (→ `Deno.env`).
- [ ] **[CLAUDE✋]** Flip `aiRelayProvider` to `BudgetedAiRelay(ModeratedAiRelay(GeminiAiRelay(...)))` pointing at relay-proxy.
- [ ] **[OWNER]** In Razorpay, set the **webhook URL** → the deployed payments-webhook function.
- [ ] **[OWNER]** Add `CLOUDFLARE_API_TOKEN` + `CLOUDFLARE_ACCOUNT_ID` to GitHub Actions secrets → `deploy-web.yml` stops skipping and ships the web build to **Cloudflare Pages** (project `ratel`); confirm `learnwithratel.com` serves the live app.

### 1d · Store listing + legal + Firebase (web)
- [ ] **[OWNER]** Provide counsel-reviewed **Privacy Policy** + **Terms** copy. **[CLAUDE]** swaps it into the existing `/privacy-policy` + `/terms` draft scaffolds (replaces the "Draft — pending legal review" banner) and publishes the privacy policy at a public URL (reused by Play + Apple later).
- [ ] **[CLAUDE]** Confirm consent screens (default-OFF) + DSAR **export/delete cascade** (P0-4) work end-to-end on the live project — **DPDP (India)** + GDPR (if EU users) posture.
- [ ] **[CLAUDE]** Integrate the **Firebase web** SDK (GA4 analytics behind the allow-list; Crashlytics-web + FCM web push optional). **[OWNER]** owns the Firebase project + config values.

### 1e · GATE 1 → advance to Phase 2
- [ ] **[ARCHITECTS]** R-O1 signed (Gate 0) — prerequisite.
- [ ] **[OWNER]** Declare the web launch stable over an agreed soak window (e.g. 7–14 days).
- [ ] **[CLAUDE]** Verify: CI green on `main`; Razorpay payments reconcile (test → live mode); **moderation fail-closed** observed against the live relay; `CostGuard` global ceiling never breached under real load; crash-free sessions ≥ target; DSAR export/delete verified on the live project; no open P0 incident.

---

## ▣ PHASE 2 — $25 ANDROID / GOOGLE PLAY

Goal: ship the Android app (AAB) with Play Billing + Play Integrity, reusing the Phase-1 backend.

### 2a · Account the OWNER creates (the one guaranteed upfront cost)
- [ ] **[OWNER]** **Google Play Developer** account — **$25 one-time**. **Prefer an ORGANIZATION account** (needs a D-U-N-S number) to skip the new-personal-account closed-testing requirement (~12 testers / 14 days).
- [ ] **[OWNER]** Enable the **Play Integrity API** (free) in the linked Google Cloud project.
- [ ] **[OWNER]** Complete the Play **merchant/payments profile** + tax/GST for Play Billing.

### 2b · What CLAUDE wires
- [ ] **[CLAUDE]** `billing` adapter → **Play Billing** (India user-choice billing allowed → Razorpay may remain a user-choice alternative on Android).
- [ ] **[CLAUDE]** **payments-webhook** gains **Play RTDN** (Real-time Developer Notifications) + Play **S2S receipt validation** → `apply_entitlement_event` (same exactly-once grant/clawback).
- [ ] **[CLAUDE]** `AttestationVerifier` → **Play Integrity** (real). Ad-reward / promo / referral grants are now gated by real attestation + Turnstile + velocity in **grant-minting**.
- [ ] **[CLAUDE]** Wire **Firebase Android**: FCM push + Crashlytics.

### 2c · Deploy step
- [ ] **[CLAUDE]** Configure **Play App Signing** (upload key) and build a signed **AAB** (bundle id `com.learnwithratel.ratel`).
- [ ] **[CLAUDE✋]** Update the **payments-webhook** + **grant-minting** Deno functions with the Play credentials (RTDN topic, Integrity verification).
- [ ] **[OWNER]** Upload the AAB to Play Console and promote **internal → closed → production** (org account skips the personal-account closed-testing gate).

### 2d · Store listing + legal + Firebase (Android)
- [ ] **[OWNER]** Fill the Play **Data Safety** form; **[CLAUDE]** drafts the answers from the analytics taxonomy + data-flow map.
- [ ] **[OWNER]** Complete the **content rating** (IARC questionnaire) and **Target audience & content** (children policy — a language app can attract minors; the built-in age-gate + parental screens inform this).
- [ ] **[OWNER]** Store listing: title, short + full description, screenshots, feature graphic, icon; set the **Privacy Policy URL** (from Phase 1). **[CLAUDE]** drafts the copy.
- [ ] **[OWNER]** Download `google-services.json` from Firebase; **[CLAUDE]** adds it under `android/app/`.

### 2e · GATE 2 → advance to Phase 3
- [ ] **[OWNER]** Android stable in production: Play **vitals** (ANR + crash rate) under threshold; Play Billing reconciling; Play Integrity passing. Decide whether iOS is worth **$99/yr** now.
- [ ] **[CLAUDE]** Verify: `build-matrix` green (incl. iOS compile); no open P0; payments-webhook handling Play RTDN correctly.

---

## ▣ PHASE 3 — iOS ($99/yr)

Goal: ship the iOS app, reusing the same backend + Deno hosts.

### 3a · Account the OWNER creates
- [ ] **[OWNER]** **Apple Developer Program** — **$99/yr** (Organization enrollment needs a D-U-N-S number; Individual is faster but shows no org name).
- [ ] **[OWNER]** Create the **App Store Connect** app record (bundle id `com.learnwithratel.ratel`).

### 3b · What CLAUDE wires
- [ ] **[CLAUDE]** `billing` adapter → **StoreKit / Apple IAP** (Apple requires IAP for digital goods). **payments-webhook** gains **App Store Server Notifications** + receipt validation → `apply_entitlement_event`.
- [ ] **[CLAUDE]** `AttestationVerifier` → **App Attest / DeviceCheck** in grant-minting.
- [ ] **[CLAUDE]** Wire **Firebase iOS** (`GoogleService-Info.plist`).
- [ ] **[CLAUDE]** Add **Sign in with Apple** if any other social login is offered (Apple Guideline 4.8).

### 3c · Deploy step
- [ ] **[OWNER]** Provide signing certificates + provisioning profiles (Apple).
- [ ] **[CLAUDE]** Configure iOS signing; archive the build (needs a **macOS runner**; `build-matrix` already builds iOS `--no-codesign`, signed builds need the owner certs + a Mac).
- [ ] **[OWNER]** Upload to App Store Connect; **TestFlight → App Review → release**.

### 3d · Store listing + legal + Firebase (iOS)
- [ ] **[OWNER]** Fill **App Privacy** "nutrition labels"; **[CLAUDE]** drafts from the data-flow map.
- [ ] **[OWNER]** App Store listing: name, subtitle, description, per-device screenshots, keywords; age rating; **Privacy Policy URL**. **[CLAUDE]** drafts the copy.
- [ ] **[CLAUDE]** Add the **App Tracking Transparency** prompt only if any tracking is introduced (default build does not track).

### 3e · EXIT GATE → steady state
- [ ] **[OWNER]** iOS approved + stable in the App Store.
- [ ] **[CLAUDE]** Enable **Turnstile** enforcement everywhere it was held back (the LAST hardening step).
- [ ] **[OWNER + CLAUDE]** Schedule the **M7 key-rotation runbook** (revoke → reissue → redeploy → invalidate) against the real project; keep `CostGuard` ceilings + Play/Apple vitals monitored.

---

## 3. Master secrets inventory (who provides, where it lives)

Grounded in the M7 read-from-env contract — keys live in server runtimes, never the repo.

| Secret | Used by | Provided by | Stored in | Phase |
|---|---|---|---|---|
| `SUPABASE_URL` / anon key | app + hosts | OWNER | app config + Edge secrets | 1 |
| `SUPABASE_SERVICE_ROLE_KEY` | all 4 Deno hosts (server only) | OWNER | **Supabase Edge secrets** (`Deno.env`) | 1 |
| `GEMINI_API_KEY` | relay-proxy | OWNER | Edge secrets | 1 |
| OpenAI Moderation key | relay-proxy | OWNER | Edge secrets | 1 |
| Razorpay key + **webhook secret** | payments-webhook | OWNER | Edge secrets | 1 |
| R2 presign creds + bucket, KV id | media-presign | OWNER | Edge secrets | 1 |
| Turnstile site + **secret** key | grant-minting / auth | OWNER | Edge secrets (enable LAST) | 1 |
| `CLOUDFLARE_API_TOKEN` + `ACCOUNT_ID` | web deploy (`deploy-web.yml`) | OWNER | **GitHub Actions secrets** | 1 |
| Firebase web config | app analytics | OWNER | app config | 1 |
| Play RTDN + Integrity creds | payments-webhook / grant-minting | OWNER | Edge secrets | 2 |
| `google-services.json` | Android app | OWNER | `android/app/` (gitignored) | 2 |
| Apple IAP + App Attest + ASSN | payments-webhook / grant-minting | OWNER | Edge secrets | 3 |
| `GoogleService-Info.plist` | iOS app | OWNER | `ios/` (gitignored) | 3 |

---

## 4. Guardrails reaffirmed — what authoring this did NOT do

- ✅ No account created · ✅ no card entered · ✅ no money spent · ✅ no deploy · ✅ live Supabase / Stripe / Razorpay / Gemini / OpenAI / Cloudflare / Play / Apple **untouched**.
- ✅ The R-O1 dual senior-architect sign-off is the **master gate** for every phase and is **never faked** — both human signatures must exist before any `[CLAUDE✋]` step runs.
- ✅ Content safety stays locked to the **three free providers** (OpenAI Moderation + Perspective + Gemini-safety); paid moderation vendors are out of scope.
- ✅ Every `[CLAUDE✋]` step is doubly gated: the owner must first provision the account/secret, **and** Gate 0 must be signed.
- ✅ This file is reversible via git; it is committed `[skip ci]` and mirrored to `Apps/RATEL_GO_LIVE_CHECKLIST.md`.

*Authored 2026-06-23 as the planned go-live path over `main`=`cb1e8dc` / vendor docs `49071af`. Planning only — execution remains owner-gated and R-O1-gated.*
