# Ratel

Free, ad-supported, **52-language** language-learning app across **6 platforms** (iOS, Android, Web/PWA, Windows, macOS, Linux). Pre-generated content is **free + unlimited**; live AI (voice, tutor chat, AI-graded writing) is **Pro-only, credit-metered**. Built so the free tier costs ~**$0 per user at scale** and content scales by **rows only**.

`Project_R` is the fresh, modern build. The product requirements (the WHAT — 161 reqs) and the build spec (the HOW) live in the owner's planning folder; see `PROJECT_STATE.md`.

## Stack
- **App:** Flutter 3.44.1 / Dart 3.12.1 — Riverpod, go_router, Drift (Stage 2+), immutable models codegen'd (freezed/json_serializable) from `schema/schema.json`.
- **Build pipeline:** Python (`ratel-tools/`) — generate → jury → deterministic validators → 12-axis gate → versioned JSON. Subscription-only (no metered API).
- **Backend (Stage 3, gated):** Supabase Postgres + Edge Functions (`ap-south-1`).
- **Edge/media (Stage 3):** Cloudflare Pages · R2 · Turnstile · KV.
- **Contract:** `schema/schema.json` (JSON-Schema 2020-12) — the single source of truth, imported by generator, validator, and app.

## Build stages
1. **Foundation** (local, no DB): schema → models + loader → pipeline → pilot seed (EN·ES·TA + JA) → ★ schema lock.
2. **Modern UI/UX** (local, no DB): design system → core-loop screens → Adventures + Rive → perf budgets.
3. **Backend, runtime & payments** (behind the Stage-4 architecture sign-off).

## Develop
```sh
flutter pub get
flutter analyze
flutter test
flutter build web --pwa-strategy=none
```
CI (`.github/workflows/ci.yml`) runs analyze + test + build web on every push to `main`; green CI is the definition of done.
