# Ratel — Vendor decisions & swap map (FREE-FIRST)

> Every external capability sits behind a **portable adapter (interface)** — no vendor is hard-wired. **Rule: free-first** — each capability defaults to a FREE provider; swapping is a one-adapter change, no feature/UI/test changes. **Every capability has a free default AND a free fallback.** Paid options are listed only as "later, if needed."

## ★ Owner-LOCKED decision — Content safety / moderation
The moderation adapter (`ModerationProvider`, built in Part-2 item M2) may use **ONLY these three free providers**:
1. **OpenAI Moderation API** — DEFAULT. Free; text + images; doesn't count against usage.
2. **Google Perspective API** — free; text toxicity scoring (swap-in alternative).
3. **Gemini built-in safety filters** — free; already included since the tutor uses Gemini (always-on layer).

**Out of scope (do NOT wire):** Azure AI Content Safety, AWS Rekognition, Hive, and any other paid moderation vendor. Go-live wiring + the autopilot must honor this list.

> Note: a specialized **child-safety / CSAM** provider (e.g. Thorn Safer) is typically PAID and is **deferred to the human sign-off** as a compliance add-on — NOT a launch blocker. Free OpenAI Moderation already covers harmful text + images.

## Free-first swap map (all capabilities)

| Capability | Adapter (interface) | Default (FREE) | Free swap-in alternatives | Paid (later, only if needed) |
|---|---|---|---|---|
| **Content safety** | `ModerationProvider` | **OpenAI Moderation** | Perspective API · Gemini safety | — (Azure/AWS/Hive = out of scope) |
| AI tutor | `AiRelay` | **Gemini** (free tier) | Gemini-safety reuse | OpenAI / Anthropic |
| Web hosting | — | **Cloudflare Pages** (live) | — | — |
| Media storage + signed URLs | `UrlSigner` | **Cloudflare R2** (10 GB free, zero egress) | **Backblaze B2** (10 GB free + free egress via Cloudflare) | S3 / Bunny (both PAID) |
| Bot protection | `TurnstileVerifier` | **Cloudflare Turnstile** (UNLIMITED free, enable LAST) | hCaptcha / reCAPTCHA (free only ≤10k/mo — worse than Turnstile) | hCaptcha Pro / reCAPTCHA Ent |
| Database + auth + security | `ContentRepository` / `LearnerStateStore` / `Identity` | **Supabase** free tier (Postgres + Auth + RLS) | **Neon** (free Postgres — keeps RLS, no rewrite) · D1 / Turso (free but SQLite = security rewrite) | Supabase Pro ~$25/mo at scale |
| Edge functions | — | **Cloudflare Workers** free / Supabase Edge free | — | — |
| Caching / config | — | **Cloudflare KV** (free) | — | — |
| Payments — web | `billing` + `verifyWebhook` | **Razorpay** (India: UPI, GST) | Stripe (international) | Paddle / Dodo (MoR) |
| Payments — Android | `billing` | **Play Billing** / India user-choice billing | — | — |
| Analytics | `Analytics` (+ taxonomy allow-list) | **Firebase / GA4** (free) | — | — |
| Crash / push | — | **Firebase** Crashlytics + FCM (free) | — | — |
| Device attestation | `AttestationVerifier` | **Play Integrity / App Attest** (free) | — | — |
| AI spend control | `CostGuard` (injected prices) | provider-agnostic | — | — |

**Net:** the entire stack launches at **$0/month**. The only guaranteed upfront cost is the **$25 Google Play** one-time (and **$99/yr Apple** when iOS is added). Each provider above is swappable later by changing one adapter.

*Recorded as an owner decision (2026-06-23). Build-ahead code already uses these adapters with faked defaults; this doc constrains which concrete providers get wired at go-live.*
