# Stage-3 PART 2 — "BUILD-AHEAD" LOCAL backlog (no money · no live accounts · no deploy · no real keys · reversible via git)

`RUN_STATUS: running · NEXT: M1 · GATE = pytest (+ Dart in CI) green · PUSH each item`

> **What this is.** Part 1 (L0–L7) is DONE on `main` (user tables + DDL + `pg_dump diff=0` + entitlement/credit RLS + per-table isolation + L7 client guards; `04f4c47`). This backlog is the **server/business LOGIC for Part 2 written + TESTED locally, for FREE, before any go-live** — so production is mostly **wiring credentials**, not writing logic. Closes draft threats **TS-5/6/9/10**, **TP-7**, findings **P0-6 / P0-7a / P0-7b / P1-1 / P1-6**, plus **R-H7 / R-M8**.
>
> **Hard constraints in every item.** LOCAL ONLY · no money · no live Supabase/Stripe/Play/Gemini/OpenAI/Cloudflare · no deploy · reversible via `git revert` · **the live Supabase project is NEVER touched** (all SQL on a disposable `pgserver`). **Every Part-2 source file MUST carry the header comment:** `BUILD-AHEAD — not deployed; pending human review + go-live wiring.` Every external dependency (Stripe/Play receipts, Gemini, OpenAI moderation, Turnstile, Cloudflare R2, device attestation) is **mocked/faked**; each item names the exact seam where the real call later goes, and marks what must STOP for go-live.
>
> **Toolchain reality.** Python `pytest` + `pgserver` run fully locally; Dart/Flutter runs in CI (`flutter-gate`). **Deno/TS is NOT reliably available unattended and there is no `supabase/functions/` in the tree** — so all "Edge Function" logic is authored as **pure testable units in the EXISTING toolchains**: Dart pure functions behind the Part-1 seams (`lib/services/...`) and/or SQL `SECURITY DEFINER` functions exercised by Python on pgserver. The thin Deno HTTP wrapper is a **go-live wiring task**, not built here.

## Chain-state / execution header (autonomous-safe)
```
RUN_STATUS: running
NEXT:       M1
ORDER:      M1 → M2 → M3 → M4 → M5 → M6 → M7 → M8   (lowest-risk / most self-contained first)
GATE:       python -m pytest ratel-tools/tests -q   (green locally, pgserver present)
            + Dart items: flutter-gate green in CI
PUSH:       commit + push after EACH item lands gate-green; one item per commit
STOP-LINE:  every item has a "GO-LIVE STOP" block — that part waits for the owner gate.
TOUCHES-LIVE: NONE. All SQL → disposable pgserver. No network. No real keys.
```
Ordering: M1–M3 pure-Dart behind seams (cost math, moderation state machine, Gemini adapter shape) — `flutter test` only. M4–M6 SQL functions on the existing `credit_ledger`/`user` tables + the existing pgserver harness (ledger, payments, R2 authz). M7 secret-scan CI guard. M8 anti-abuse velocity + wiring map.

## M1 — [R-H7 / R-M8 · TS-4] AI-relay cost guardrail + per-user caps (pure unit behind the `AiRelay` seam)
Goal: deterministic fail-closed cost/quota estimator + budget gate any future relay adapter must pass; per-user daily caps + global ceiling; zero network.
Where: pure Dart `lib/services/ai_relay/cost_guard.dart` — `CostGuard` (no I/O) + `BudgetedAiRelay implements AiRelay` decorator wrapping any inner relay; caps from injected config; `userSpentToday` sourced from the credit ledger (M4), never client-asserted. Header comment required.
Approach: `estimateCost(prompt)` integer credit units (deterministic heuristic, injected price table defaulting high); `check({userSpentToday,globalSpentToday,estimate})` → `Allow|DenyPerUserCap|DenyGlobalCeiling`, fail-closed on null/negative/over-cap; `BudgetedAiRelay.complete()` checks first, throws typed `RelayBudgetExceeded` on deny (inner relay never called), records spend on allow.
Tests `test/services/ai_cost_guard_test.dart` (flutter-gate): estimate monotonic & ≥ floor; under cap → Allow + inner called once; at/over per-user cap → deny, inner NEVER called (spy=0); over global ceiling → deny even if user under cap; negative/null inputs → deny (fail-closed); burst of N crossing cap → only in-budget delegate; denied call does not increment spend.
GO-LIVE STOP: real per-model price table + Gemini key/endpoint (M3); cap values are product decisions to confirm.

## M2 — [P0-7b · TS-10] AI-relay input + output moderation, FAILS CLOSED when provider down
Goal: moderation state machine gating every relay round-trip both sides; denies when the provider errors/times-out/returns-unknown; provable vs a fake provider.
Where: pure Dart `lib/services/ai_relay/moderation.dart` — abstract `ModerationProvider{Future<ModerationVerdict> classify(String)}` (seam for real OpenAI/Gemini moderation) + `ModeratedAiRelay implements AiRelay`. Seam order: `BudgetedAiRelay(ModeratedAiRelay(GeminiAiRelay(...)))`. Local default = deterministic fake. Decisions logged to a `ModerationAuditSink` interface (TS-7), no-op locally. Header comment required.
Approach (explicit states): input→classify (block⇒deny, never call relay); relay call; output→classify (block⇒deny, raw text never returned); **provider error/timeout/null/unknown at EITHER step ⇒ FAIL CLOSED** (typed `ModerationUnavailable`, candidate discarded). Allowed output still wrapped in `RelayText` (TS-13). Strip tool-style/system-prompt-injection markers from input first.
Tests `test/services/moderation_relay_test.dart` (flutter-gate): clean→returns RelayText, 2 classify calls, audit saw 2; input flagged→Blocked, relay never called; output flagged→Blocked, raw text never leaks; provider throws on input→Unavailable, relay not called; throws on output→Unavailable, candidate discarded; timeout→fail closed; unknown/empty verdict→deny; injection string→stripped/denied; moderation runs before the budget charge commits.
GO-LIVE STOP: real moderation key+endpoint; durable audit store (TS-7).

## M3 — [R-H7] Gemini adapter behind the `ai_relay` seam (fake transport, real shape)
Goal: `GeminiAiRelay implements AiRelay` with request-build/parse/error-map/`isAvailable` fully unit-tested against a faked HTTP transport; go-live = inject real URL+key.
Where: pure Dart `lib/services/ai_relay/gemini_relay.dart`; injected transport `Future<HttpLikeResponse> Function(HttpLikeRequest)` (seam for real http/Gemini client) + injected `GeminiConfig`(baseUrl,model,key) defaulting to "no key" → `isAvailable=false` + fail-closed `complete()` (parity with `UnconfiguredAiRelay`). `aiRelayProvider` NOT changed on main; the `BudgetedAiRelay(ModeratedAiRelay(GeminiAiRelay()))` wiring delivered as commented example, go-live-gated. Header comment required. No real key ever read here.
Tests `test/services/gemini_relay_test.dart` (flutter-gate): unconfigured→isAvailable false, complete throws, transport NEVER invoked; configured+fake 200→expected RelayText + request shape asserted; non-2xx→RelayUnavailable, no partial leak; malformed/empty JSON + empty candidates→RelayBadResponse no crash; transport throws/timeout→RelayUnavailable; return is RelayText, raw not reachable via toString; composition smoke test M1+M2+M3 with fakes.
GO-LIVE STOP: real Gemini key/project/baseUrl + `aiRelayProvider` override; the Deno host fn.

## M4 — [P0-7a · TS-9] Credit double-entry ledger: idempotent grant/spend/refund + fail-closed-at-zero (SQL fn on pgserver)
Goal: `service_role`-only `SECURITY DEFINER` SQL fn that atomically posts a ledger entry, recomputes `balance_after`, rejects spend below zero, idempotent on `client_event_id`.
Where: SQL `schema/sql/0004_credit_ledger_fn.sql` — `post_credit_entry(...)` (`SECURITY DEFINER`, GRANT EXECUTE to `service_role` only; REVOKE from authenticated/anon/public). Exercised by Python on the existing `rls_harness.py` pgserver. Header comment in the SQL.
Approach: single tx, per-user lock / latest balance_after; new balance by entry_type (grant +, spend -, refund + paired to related_ledger_id); idempotency via `UNIQUE(client_event_id)` ON CONFLICT DO NOTHING returning the posted row; spend < 0 result → raise + rollback (never clamp); refund must reference an existing spend, ≤ spent amount, not twice.
Tests `ratel-tools/tests/test_credit_ledger.py` (db-rls-gate): grant→spend balance tracks + reconciles; replayed grant (same client_event_id)→no double-grant, one row; replayed spend→charged once; spend > balance→raises, rolls back, no row (never negative); empty-to-zero allowed then any spend denied; refund>spend rejected, refund w/o related_id rejected, refund twice idempotent; `authenticated` cannot EXECUTE the fn and cannot INSERT directly (re-asserts 0002); concurrency: interleaved spends can't both pass zero; pg_dump parity still green.
GO-LIVE STOP: device attestation + Turnstile on grant paths (real accounts/devices) — callers of the fn; velocity logic in M8 vs fakes.

## M5 — [P1-1 · TS-6] Payments signature-verify + event-dedupe/idempotency + refund/chargeback clawback
Goal: pure signature-verify + event-dedupe + entitlement-transition core vs synthetic Stripe/Play payloads + a fake secret; server-side `pro_until` grant/clawback on pgserver.
Where: (1) pure Dart `lib/services/billing/payments_verify.dart` — `verifyWebhook(rawBody,sigHeader,secret,tolerance)` (HMAC over raw body, constant-time compare, timestamp tolerance) + `parseEvent(...)`→ normalized `PaymentEvent{eventId,type∈{grant,refund,chargeback,lapse},userId,until?}`; real signing secret/endpoint is the seam, secret injected. (2) SQL `schema/sql/0005_entitlement_fn.sql` — `service_role`-only `apply_entitlement_event(event_id,user_id,kind,until)` (`SECURITY DEFINER`) setting/clearing `user.pro_until`, idempotent on event_id via a `processed_payment_event(event_id PK)` dedupe table. Header comments required.
Approach: recompute expected sig from secret+timestamp+body, reject missing/malformed/out-of-tolerance/mismatch (constant-time); accepted event has stable eventId; `apply_entitlement_event` inserts into dedupe ON CONFLICT DO NOTHING → transition exactly once; grant⇒extend pro_until, refund/chargeback/lapse⇒clawback (now/null), all service_role; optionally post paired refund to credit_ledger via M4.
Tests — Dart `test/services/payments_verify_test.dart` (flutter-gate): valid payload+secret→verifies+parses; tampered body→rejected; wrong/missing secret→rejected; stale timestamp→rejected; constant-time compare no early return; malformed/unknown type→ignored, no crash. Python `ratel-tools/tests/test_entitlement_events.py` (db-rls-gate): first grant→pro_until set; replayed event_id→unchanged (no double-grant); refund/chargeback→revoked; authenticated cannot EXECUTE the fn nor write pro_until (re-asserts P0-3); out-of-order events deterministic; lapse-then-grant lifecycle.
GO-LIVE STOP: real Stripe/Play signing secrets, receipts, live webhook URL, store S2S validation.

## M6 — [P1-6 · TS-12] R2 signed-URL TTL/scope + Pro-only-audio authorization logic
Goal: pure authorization + signed-URL-policy core deciding whether a user may receive a media URL and what TTL/scope it must carry; vs a fake signer + fake entitlement.
Where: pure Dart `lib/services/billing/media_authz.dart` — `MediaAccessPolicy.authorize({assetTier,isPro,now})`→`Grant{ttl,scopePath}|Deny` + `SignedUrlPolicy` (max TTL, single-object scope, GET-only). Real R2 presign is an injected `UrlSigner` seam; local fake records (path,ttl,method). Entitlement from Part-1 `Entitlements.isPro` (faked per test). Header comment required.
Approach: assetTier∈{free,pro_audio}; pro_audio+!isPro⇒Deny (authorization not obscurity); free⇒Grant short TTL; pro_audio+isPro⇒Grant. Grant mandates short TTL (≤N min from config, policy refuses longer), tight scope (exact object key never prefix), GET-only — all defined in `SignedUrlPolicy` so an over-broad request is impossible. Entitlement read server-side, never client claim.
Tests `test/services/media_authz_test.dart` (flutter-gate): free+free→Grant, signer asked GET-only/single-object/short-TTL; pro_audio+free→Deny, signer NEVER invoked; pro_audio+Pro→Grant; TTL beyond max→clamped/refused; prefix scope→rejected; now past faked expiry→non-Pro→Deny; non-GET→refused.
GO-LIVE STOP: real R2 bucket/presign creds, Turnstile keys, KV.

## M7 — [P0-6 · TS-5] Service-role key handling + CI secret-scan guard
Goal: (a) read-from-env contract so the real key is never a repo literal; (b) a CI secret-scan that fails the build if a service-role/Supabase/Stripe/private-key pattern is committed.
Where: (1) `lib/services/identity/service_role_contract.dart` (or a docs note + comment) stating the key is read only server-side from `Deno.env`/Supabase secrets at go-live, never in client code; least-privilege note that M4/M5 fns are the only `service_role`-EXECUTE surfaces. Header comment required. (2) `ratel-tools/tests/test_secret_scan.py` walking the tree, asserting no match for: service_role JWT shape (`eyJ…"role":"service_role"`), `sb_secret_`/legacy service_role, Stripe `sk_live_`/`sk_test_`, Google `AIza…`, `-----BEGIN … PRIVATE KEY-----`; runs in python-schema-gate + an explicit CI step.
Approach: allow-list this backlog's example patterns + exclude the test-fixtures dir so intentional fakes don't self-trip; contract doc enumerates the rotation runbook (revoke→reissue→redeploy→invalidate) as a go-live checklist.
Tests `ratel-tools/tests/test_secret_scan.py`: clean tree→pass; a temp file with a fake service_role JWT / sk_live_ / AIza / BEGIN PRIVATE KEY in a scanned path→flagged (then removed); backlog + fixtures excluded; near-miss (var named service_role, no value)→not flagged.
GO-LIVE STOP: actual key rotation + injecting the real key into the server runtime (real project).

## M8 — [TS-9 velocity · TS-7 audit · wiring map] Anti-abuse velocity caps + fake attestation/Turnstile gates + go-live wiring map
Goal: pure velocity/abuse policy (per-account & per-device caps, self-referral detection, grant-path Turnstile/attestation gating) deciding whether a grant may reach `post_credit_entry` (M4); vs fake verifiers; + a committed wiring map.
Where: pure Dart `lib/services/billing/grant_guard.dart` — `GrantGuard.check({userId,deviceId,grantSource,recentGrants,attestationVerdict,turnstileVerdict,now})`→`Allow|DenySelfReferral|DenyVelocity|DenyAttestation|DenyTurnstile`. Real Play Integrity/App Attest + Turnstile are injected verifier seams (`AttestationVerifier`,`TurnstileVerifier`), faked. `recentGrants` from the ledger (M4). Runs BEFORE M4. Header comment required.
Approach: > N grants per account/device per window→DenyVelocity (fail-closed on unknown counts); referral where referrer/referee share deviceId→DenySelfReferral; grant sources needing it (ad_reward/promo/referral) with non-pass/unavailable attestation or Turnstile→deny (fail-closed when verifier down); only Allow proceeds to mint; denial logged to audit sink (TS-7).
Tests `test/services/grant_guard_test.dart` (flutter-gate): under caps + passing verifiers→Allow (M4 reached only on Allow, spy); self-referral→DenySelfReferral no mint; over per-account/per-device velocity→DenyVelocity; failed/unavailable attestation→deny fail-closed; failed/unavailable Turnstile→deny fail-closed; replay burst deduped by M4 + rate-limited here never over-grants; denied grant produces an audit record, never reaches the ledger.
Go-live wiring map (committed text):
| Item | Fake built (local) | Real dependency (owner go-live) | Swap point (seam) |
|------|--------------------|--------------------------------|-------------------|
| M1 | injected price table + usage counter | real per-model prices; server budget store | CostGuard config/counter |
| M2 | stub ModerationProvider | OpenAI/Gemini moderation key+endpoint | ModerationProvider.classify |
| M3 | fake HTTP transport, no-key default | Gemini key, base URL, aiRelayProvider override | GeminiAiRelay transport+GeminiConfig |
| M4 | pgserver post_credit_entry | (none — pure DB; runs as-is) | called by the grant Edge fn |
| M5 | synthetic payloads + fake secret | Stripe/Play signing secret, webhook URL, receipt validation | verifyWebhook secret / handler |
| M6 | fake UrlSigner, faked entitlement | Cloudflare R2 presign creds, bucket, KV | UrlSigner impl |
| M7 | read-from-env contract + pytest scan | real service-role key (server only) + rotation | Deno.env secret injection |
| M8 | fake attestation/Turnstile verifiers | Play Integrity/App Attest, Turnstile keys | AttestationVerifier / TurnstileVerifier |
GO-LIVE STOP: real attestation + Turnstile (accounts/devices/keys); durable audit store (TS-7); the Deno grant Edge fn chaining GrantGuard→post_credit_entry.

## Cross-cutting acceptance (every item, before PUSH)
- [ ] New source file carries header: `BUILD-AHEAD — not deployed; pending human review + go-live wiring.`
- [ ] No network, no real key, no live Supabase/Stripe/Gemini/OpenAI/Cloudflare; every external dep is a named injected seam with a fake default.
- [ ] Fail-closed wherever a provider/input is missing/null/errored (cost, moderation, attestation, signature, ledger-at-zero).
- [ ] SQL runs only on disposable pgserver; `test_pg_dump_parity.py` still green; P0-3 client-read-only (0002) re-asserted, not weakened.
- [ ] GATE green: `pytest ratel-tools/tests -q` locally + flutter-gate in CI for Dart items; `importorskip("pgserver")` keeps db-rls-gate green where pgserver absent.
- [ ] One item per commit; push after each; reversible via git revert. Update the chain-state `NEXT:` pointer on each landing.

## What MUST stop for the owner go-live gate (consolidated)
- Accounts + money: Supabase project, Stripe + Google Play, Gemini + OpenAI keys, Cloudflare (R2 + Turnstile + KV), Play Integrity/App Attest.
- Deploy: the thin Deno Edge handlers hosting the M1–M6/M8 units (relay proxy, payments webhook, grant minting, media presign).
- Key rotation (M7) against the real project.
- Human sign-off: the dual senior-architect Stage-4 Part-E signatures (R-O1) still gate go-live; this backlog informs, not replaces.

*Built-ahead spec by the Stage-4 security review against post-Part-1 `origin/main` (`04f4c47`). No file modified by the spec; no backend touched; no spend.*
