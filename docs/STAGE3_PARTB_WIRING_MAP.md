# Stage-3 Part-2 BUILD-AHEAD → Go-Live Wiring Map

> BUILD-AHEAD — not deployed; pending human review + go-live wiring.
>
> Every Part-2 item (M1–M8) is built + tested LOCALLY with each external provider behind a
> named, injected seam whose default is a safe fake. Going live is therefore mostly
> **wiring real credentials/endpoints into these seams + deploying the thin Deno hosts** —
> not writing new business logic. This file is the single index of those swap points.
> The live Supabase/Stripe/Play/Gemini/OpenAI/Cloudflare projects are NEVER touched here.

## Swap-point table

| Item | Fake built (local) | Real dependency (owner, go-live) | Swap point (seam) |
|------|--------------------|----------------------------------|-------------------|
| M1 — AI cost guard [R-H7/R-M8·TS-4] | injected price table + usage counter | real per-model prices; server budget store | `CostGuard` config / `userSpentToday`+`globalSpentToday` counters |
| M2 — moderation [P0-7b·TS-10] | stub `ModerationProvider` (deterministic) | OpenAI/Gemini moderation key + endpoint | `ModerationProvider.classify` |
| M3 — Gemini relay [R-H7] | fake HTTP transport, no-key default | Gemini key, base URL, `aiRelayProvider` override | `GeminiAiRelay` transport + `GeminiConfig` |
| M4 — credit ledger fn [P0-7a·TS-9] | pgserver `post_credit_entry` | (none — pure DB; runs as-is) | called by the grant Edge fn |
| M5 — payments verify [P1-1·TS-6] | synthetic payloads + fake secret | Stripe/Play signing secret, webhook URL, receipt (S2S) validation | `PaymentsVerifier.verifyWebhook(secret)` → `apply_entitlement_event` |
| M6 — media authz [P1-6·TS-12] | fake `UrlSigner`, time-aware faked entitlement | Cloudflare R2 presign creds + bucket, Turnstile, KV | `UrlSigner.sign` (impl) |
| M7 — service-role key [P0-6·TS-5] | read-from-env contract + pytest secret-scan | real service-role key (server only) + rotation | `Deno.env` secret injection (server runtime) |
| M8 — anti-abuse gate [TS-9·TS-7] | fake attestation/Turnstile verifiers + spy mint | Play Integrity / App Attest, Turnstile keys, durable audit store | `AttestationVerifier` / `TurnstileVerifier` / `GrantAuditSink` |

## Composition at go-live (request paths)

- **AI relay:** `BudgetedAiRelay( ModeratedAiRelay( GeminiAiRelay(transport,config) ) )` — cost gate (M1) wraps moderation (M2) wraps the Gemini adapter (M3); fail-closed at every layer. Hosted behind a Deno relay-proxy Edge function.
- **Payments webhook:** Deno webhook → `PaymentsVerifier.verifyWebhook` (M5, real secret) → `parseEvent` → `apply_entitlement_event` (M5 SQL, dedupe table) — exactly-once `pro_until` grant/clawback.
- **Credit grant (ad/promo/referral):** Deno grant fn → `GrantGuard.authorizeAndMint` (M8: velocity + self-referral + attestation/Turnstile) → on Allow only → `post_credit_entry` (M4, idempotent, fail-closed-at-zero).
- **Media URL:** Deno presign fn → `MediaUrlService.issue` (M6: entitlement gate + GET-only/single-object/short-TTL policy) → on Grant only → real R2 `UrlSigner`.

## GO-LIVE STOP (consolidated — owner-gated, NOT built here)

- **Accounts + money:** Supabase project, Stripe + Google Play, Gemini + OpenAI keys, Cloudflare (R2 + Turnstile + KV), Play Integrity / App Attest.
- **Deploy:** the thin Deno Edge handlers hosting the M1–M6/M8 units (relay proxy, payments webhook, grant minting, media presign).
- **Key rotation (M7):** revoke → reissue → redeploy → invalidate, against the real project.
- **Human sign-off:** the dual senior-architect Stage-4 Part-E signatures (R-O1) still gate go-live; this build-ahead work informs, it does not replace them.
