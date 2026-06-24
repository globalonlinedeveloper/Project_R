# Ratel — Requirements Traceability Matrix (RTM)

> **GENERATED** by `ratel-tools/gen_traceability.py` from the 161 requirement IDs in `RATEL_REQUIREMENTS.md`. Do not hand-edit — rerun the generator. To correct a call, edit `ratel-tools/requirements_registry.json` (`overrides`) and rerun.

**How to read this**

- **MoSCoW** is *derived* from the spec (R-A1 v1 boundary · R-A8 launch floor · Part O phases) — interpretive, **please review/override**.
- **Phase**: Foundation/Stage1/Stage2 = local & complete per the S1–S27 build audit · Stage3 = DB/runtime/payments (owner + money gated) · Wave = post-launch (R-O3) · Cut = removed.
- **Status (build)** = completion of the *buildable* slice: `Built ✅` (Stage 1–2, per audit) · `Build-ahead 🟦` (Stage-3 logic written + tested, not yet live) · `Partial 🟨` · `Pending 🔒` (Stage-3, not started) · `Deferred ⏭` (wave) · `Removed ✖`.
- **Gate** = going live needs owner action / money.
- **Evidence** = source/test files citing the requirement ID (a floor — not every built file tags its ID).

## Coverage rollup (by MoSCoW × build status)

| Priority | Built | Build-ahead | Partial | Pending | Deferred | Removed | Spec/cross | Total |
|---|---|---|---|---|---|---|---|---|
| **Must** | 78 | 9 | 5 | 24 | 2 | 0 | 13 | 131 |
| **Should** | 12 | 0 | 0 | 3 | 1 | 0 | 0 | 16 |
| **Could** | 0 | 0 | 0 | 1 | 7 | 0 | 0 | 8 |
| **Won't** | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 |
| **Process** | 1 | 0 | 0 | 1 | 1 | 0 | 2 | 5 |
| **All** | 91 | 9 | 5 | 29 | 11 | 1 | 15 | 161 |

_Legend: Built=Stage1–2 complete · Build-ahead=Stage-3 logic done+tested (not live) · Pending=Stage-3 not started · Deferred=post-launch wave · Removed=cut · Spec/cross=policy/cross-cutting._

## Part §0 Foundations

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-FND-1 | Regenerate-in-place (hot-swap) of machine-made content | Must | Foundation | Built ✅ | — | — |
| R-FND-2 | Rows-only structural invariant | Must | Foundation | Built ✅ | — | `schema.json` |

## Part A — Scope, platforms & languages

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-A1 | v1 launch shape & scope boundary | Must | Spec | Spec/cross ▫ | — | — |
| R-A2 | Target platforms & device/OS minimums | Must | Spec | Spec/cross ▫ | — | — |
| R-A2a | Per-platform capability degradation matrix | Must | Spec | Spec/cross ▫ | — | — |
| R-A3 | Target-language & tier ratification (52 LTR) | Must | Stage1 | Built ✅ | — | — |
| R-A4 | UI/gloss launch set & any-to-any cell-lighting | Must | Stage1 | Built ✅ | — | — |
| R-A5 | Hindi/Swahili provisional-promotion rule | Must | Spec | Spec/cross ▫ | — | — |
| R-A6 | Pilot scope & schema-conformance exit gate | Must | Stage1 | Built ✅ | — | — |
| R-A7 | Pilot CEFR content scope | Must | Stage1 | Built ✅ | — | — |
| R-A8 | Launch-minimum bar & wave policy | Must | Spec | Spec/cross ▫ | — | — |

## Part B — Learning model & curriculum

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-B1 | CEFR can-do spine ratification | Must | Stage1 | Built ✅ | — | — |
| R-B2 | Skill/Concept prerequisite graph | Must | Stage1 | Built ✅ | — | — |
| R-B3 | Course-Section-Unit-Lesson containers & path rendering | Must | Stage1 | Built ✅ | — | — |
| R-B4 | TBLT task model + tap-to-define | Must | Stage1 | Built ✅ | — | — |
| R-B5 | Depth-as-data & CEFR-ceiling enforcement | Must | Stage1 | Built ✅ | — | — |
| R-B6 | Native realization & divergence nodes | Must | Stage1 | Built ✅ | — | — |
| R-B7 | Pair-specific / contrastive layer | Must | Stage1 | Built ✅ | — | — |
| R-B8 | Content difficulty model (IRT + cold-start) | Must | Stage1 | Built ✅ | — | — |

## Part C — Content data model

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-C1 | Standardization rule + open-container discipline | Must | Stage1 | Built ✅ | — | `schema_loader.py`, `common.schema.json`, `schema.json` |
| R-C2 | Sentence entity + token model | Must | Stage1 | Built ✅ | — | `common.schema.json`, `sentence.schema.json` |
| R-C3 | VocabEntry + per-sense model | Must | Stage1 | Built ✅ | — | `sense.schema.json`, `vocab_entry.schema.json` |
| R-C4 | GrammarPoint entity | Must | Stage1 | Built ✅ | — | `grammar_point.schema.json` |
| R-C5 | Phoneme (per-language bank) | Must | Stage1 | Built ✅ | — | `phoneme.schema.json` |
| R-C6 | Item + answer_spec | Must | Stage1 | Built ✅ | — | `common.schema.json`, `item.schema.json` |
| R-C7 | Locale entity | Must | Stage1 | Built ✅ | — | `locale.schema.json` |
| R-C8 | MediaAsset entity | Must | Stage1 | Built ✅ | — | `media_asset.schema.json` |
| R-C9 | Gloss / localization layer | Must | Stage1 | Built ✅ | — | `gloss.schema.json` |
| R-C10 | Provenance / versioning on every row | Must | Stage1 | Built ✅ | — | `common.schema.json` |
| R-C11 | Stable language-neutral ID scheme | Must | Stage1 | Built ✅ | — | — |
| R-C12 | Shared controlled vocabularies / enums | Must | Stage1 | Built ✅ | — | `codegen_dart.py`, `test_enum_forward_compat.py`, `enums.schema.json`, `schema.json` |
| R-C13 | App-shell strings vs DB gloss boundary | Must | Stage1 | Built ✅ | — | — |
| R-C14 | Schema-conformance gate | Must | Stage1 | Built ✅ | — | `content_loader.dart`, `axis_gate.py`, `schema.json` |

## Part D — Exercise types & grading

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-D1 | Shared item envelope + exercise-type enum | Must | Stage2 | Built ✅ | — | — |
| R-D2 | mcq (multiple choice) | Must | Stage2 | Built ✅ | — | — |
| R-D3 | cloze (fill in the blank) | Must | Stage2 | Built ✅ | — | — |
| R-D4 | translate (one type, with a direction setting) | Must | Stage2 | Built ✅ | — | — |
| R-D5 | listen (listen and choose) | Must | Stage2 | Built ✅ | — | — |
| R-D6 | word_order (build the sentence by tapping words) | Must | Stage2 | Built ✅ | — | — |
| R-D7 | match (matching pairs) | Must | Stage2 | Built ✅ | — | — |
| R-D8 | dictation (type exactly what you hear) | Must | Stage2 | Built ✅ | — | — |
| R-D9 | speak (on-device ASR intelligibility + shadowing, free) | Must | Stage2 | Built ✅ | — | — |
| R-D9a | Web/desktop on-device ASR is cloud - force shadowing | Must | Stage2 | Built ✅ | — | — |
| R-D10 | scripted_roleplay (a branching scripted conversation) | Must | Stage2 | Built ✅ | — | — |
| R-D11 | Phase-3 scaffolds: write + live_roleplay (scaffolded now) | Should | Wave | Deferred ⏭ | 🔒 owner/$$ | — |
| R-D12 | tap-to-define reading feature + comprehension-item policy | Must | Stage2 | Built ✅ | — | — |
| R-D13 | Autoscoring & answer-equivalence rules | Must | Stage2 | Built ✅ | — | — |
| R-D14 | Result - signal mapping (proficiency / memory / engagement) | Must | Stage2 | Built ✅ | — | — |

## Part E — Content generation & QA

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-E1 | Build-time generation pipeline architecture | Must | Stage1 | Built ✅ | — | — |
| R-E2 | Generator agent spec | Must | Stage1 | Built ✅ | — | — |
| R-E3 | Verifier/critic + LLM jury (fresh context) | Must | Stage1 | Built ✅ | — | `jury.py`, `types.py` |
| R-E4 | Deterministic validation rules | Must | Stage1 | Built ✅ | — | `validate.py`, `test_validators.py` |
| R-E5 | Confidence gating & regeneration thresholds | Must | Stage1 | Built ✅ | — | — |
| R-E6 | Per-batch spot-audit | Must | Stage1 | Built ✅ | — | — |
| R-E7 | Cross-batch drift control | Must | Stage1 | Built ✅ | — | — |
| R-E8 | Per-language QA-certifiable CEFR ceiling | Must | Stage1 | Built ✅ | — | — |
| R-E9 | C1-C2 gate (owner override) | Must | Stage1 | Built ✅ | — | — |
| R-E10 | review_status lifecycle + provenance | Must | Stage1 | Built ✅ | — | — |
| R-E11 | Batch idempotency & versioning | Must | Stage1 | Built ✅ | — | — |
| R-E12 | Gloss generation + fallback chain | Must | Stage1 | Built ✅ | — | — |
| R-E13 | Generation tooling / ops | Must | Stage1 | Built ✅ | — | — |
| R-E14 | Companion-asset completeness gate | Must | Stage1 | Built ✅ | — | — |

## Part F — Media

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-F1 | Per-locale TTS voice selection | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-F2 | Pre-render pipeline, SSML & storage/CDN | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-F3 | tts_tier flag & degrade UX | Must | Stage2 | Built ✅ | — | — |
| R-F4 | Audio format, caching & offline | Must | Stage2 | Built ✅ | — | — |
| R-F5 | Visual / illustration asset policy | Should | Stage2 | Built ✅ | — | — |
| R-F6 | Video-lesson asset pre-generation + codec/versioning rule | Could | Wave | Deferred ⏭ | 🔒 owner/$$ | — |
| R-F7 | Avatar / cosmetic asset pre-generation rule | Could | Wave | Deferred ⏭ | 🔒 owner/$$ | — |

## Part G — Adaptivity, placement & SRS

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-G1 | One identity, many courses | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-G2 | theta ability model (global + per-skill) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-G3 | IRT calibration (how hard each item is) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-G4 | CAT placement test | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-G5 | FSRS spaced-repetition scheduling | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-G6 | Learner-state entities (what gets stored) | Must | Stage3 | Partial 🟨 | 🔒 owner/$$ | `user.schema.json`, `user_item_state.schema.json` |
| R-G7 | Cold-start strategy (works from day one) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-G8 | Launch path-serving (how lessons are sequenced) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-G9 | Saved words - flashcards - graded review | Should | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |

## Part H — AI, tutor & conversation

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-H1 | AI tutor chat | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-H2 | Realtime voice conversations | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-H3 | Launch pronunciation UX (shadowing, free) | Must | Stage2 | Built ✅ | — | — |
| R-H4 | Advanced pronunciation scoring - REMOVED | Won't | Cut | Removed ✖ | — | — |
| R-H5 | Grading written answers (later)<br>_Owner S28: Must priority; spec schedules the LLM-grading engine in R-O3 Wave C (later)._ | Must | Wave | Deferred ⏭ | 🔒 owner/$$ | — |
| R-H6 | Open-ended roleplay conversations (later)<br>_Owner S28: Must priority; spec schedules open-roleplay engine in R-O3 Wave C (later)._ | Must | Wave | Deferred ⏭ | 🔒 owner/$$ | — |
| R-H7 | Runtime key mgmt, relay, rate-limit & abuse | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `ai_relay.dart`, `cost_guard.dart`, `gemini_relay.dart`, `relay_pipeline.dart` +7 |
| R-H8 | Reusable scaffolds (Scenario + GradingRubric) | Should | Stage2 | Built ✅ | — | — |

## Part I — Gamification, economy & social

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-I1 | XP model (sources & amounts) | Should | Stage2 | Built ✅ | — | — |
| R-I2 | Streak + streak-freeze + Society tiers | Should | Stage2 | Built ✅ | — | — |
| R-I3 | Energy model (lesson cost, regen, caps) | Should | Stage2 | Built ✅ | — | — |
| R-I4 | Gems soft-currency (earn / spend sinks) | Should | Stage2 | Built ✅ | — | — |
| R-I5 | Rewarded-ads - energy / gems design | Should | Stage2 | Built ✅ | — | — |
| R-I6 | Leagues / leaderboards (global, weekly reset) | Should | Stage2 | Built ✅ | — | — |
| R-I7 | Daily goal + chest + quests + achievements | Should | Stage2 | Built ✅ | — | — |
| R-I8 | Anti-dark-pattern guardrails | Should | Stage2 | Built ✅ | — | — |
| R-I9 | Social: friends/feed, family plan, classroom, block/report | Should | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |

## Part J — Monetization

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-J1 | Free vs Pro feature split (exact) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-J2 | Pro price point(s) + billing (regional/PPP, trial) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-J3 | AI access policy - Pro-only live AI, metered by credits | Must | Stage3 | Partial 🟨 | 🔒 owner/$$ | `play_receipt_verify.dart`, `user.schema.json` |
| R-J4 | Ad strategy + network/mediation | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-J5 | Voice minute caps (even Pro) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-J6 | Store-safe paywall / cancel (single CTA, easy cancel) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `home_screen.dart`, `lesson_screen.dart`, `credit_ledger.schema.json`, `lesson_screen_test.dart` |
| R-J7 | Payments / IAP integration (App Store / Play / web) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `play_receipt_verify.dart`, `user.schema.json`, `user_course.schema.json`, `play_receipt_verify_test.dart` |
| R-J7a | Desktop/web billing - web-checkout fallback (no native store) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `billing.dart`, `media_authz.dart`, `payments_verify.dart`, `play_receipt_verify.dart` +4 |

## Part K — Compliance, privacy & safety

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-K1 | Age-gating + COPPA / minors path | Must | Stage3 | Partial 🟨 | 🔒 owner/$$ | `taxonomy.dart` |
| R-K1a | OS age-range assurance has narrow real coverage | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-K2 | Consent - GDPR/UMP + iOS ATT + non-personalized-ads path | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-K3 | Data minimization & retention (no raw-speech retention) | Must | Stage3 | Partial 🟨 | 🔒 owner/$$ | `0006_review_log_partitions.sql`, `0007_dsar_delete_anchor.sql`, `0008_audit_log.sql` |
| R-K4 | Regional privacy rights - export + delete (GDPR/DPDP/CCPA) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `test_dsar_delete_anchor.py`, `0007_dsar_delete_anchor.sql`, `0008_audit_log.sql` |
| R-K5 | Generated-content safety (AI-content; profanity; bias) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-K6 | Security - server-side keys, Supabase RLS, auth, PII | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `taxonomy.dart`, `data_access.dart`, `identity.dart`, `audit_sink.dart` +6 |
| R-K7 | Terms of Service + Privacy Policy - final copy & ownership | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-K8 | Accessibility - WCAG 2.2 AA conformance (test-enforced) | Must | Stage2 | Built ✅ | — | `shell.dart`, `wcag.dart`, `ratel_motion_tier.dart`, `ratel_color_tokens.dart` +5 |

## Part L — App screens & UX

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-L1 | Auth & account flows | Must | Stage2 | Built ✅ | — | — |
| R-L2 | Onboarding flow (language-motivation-goal-placement-first win) | Must | Stage2 | Built ✅ | — | `onboarding_flow.dart`, `onboarding_test.dart` |
| R-L3 | Core learning loop (lesson run, check/feedback, complete) | Must | Stage2 | Built ✅ | — | `energy_controller.dart`, `energy_state.dart`, `exercise.dart`, `exercise_builder.dart` +5 |
| R-L4 | Practice & AI hub | Must | Stage2 | Built ✅ | — | `home_screen.dart` |
| R-L4a | Adventures immersive surface (explorable roleplay world) | Must | Stage2 | Built ✅ | — | `adventure_model.dart`, `adventures_screen.dart`, `scene_screen.dart`, `adventures_screen_test.dart` +1 |
| R-L5 | Reading & listening (stories, listening feed, video, tap-to-define) | Must | Stage2 | Built ✅ | — | — |
| R-L6 | Profile & settings hub | Must | Stage2 | Built ✅ | — | — |
| R-L7 | Monetization screens | Must | Stage2 | Built ✅ | — | — |
| R-L8 | Gamification & social screens | Must | Stage2 | Built ✅ | — | `lesson_screen.dart`, `streak_controller.dart`, `user.schema.json`, `home_test.dart` +1 |
| R-L9 | Multi-course, course-switch, flip-UI & immersion | Must | Stage2 | Built ✅ | — | — |
| R-L10 | Navigation / information architecture (tab shell, deep links) | Must | Stage2 | Built ✅ | — | `router.dart`, `shell.dart` |
| R-L11 | Notifications (push categories, opt-in, inbox) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-L11a | Widgets are mobile-only; desktop/web get in-app/tray equivalent | Could | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-L11b | Notifications: per-platform delivery profile | Should | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-L12 | Global search | Should | Stage2 | Built ✅ | — | — |
| R-L13 | Offline mode & caching | Must | Stage2 | Built ✅ | — | — |
| R-L13a | Background sync is foreground-reconcile on iOS-PWA + desktop | Should | Stage2 | Built ✅ | — | — |
| R-L14 | Cross-cutting UI states (loading/empty/error/skeleton) | Must | Stage2 | Built ✅ | — | — |
| R-L15 | Brand character & motion/delight (the Ratel honey badger) | Must | Stage2 | Built ✅ | — | — |
| R-L16 | Motion & interaction design-system | Must | Stage2 | Built ✅ | — | `router.dart`, `ratel_color_tokens.dart`, `ratel_motion.dart`, `ratel_count_up.dart` +1 |
| R-L17 | Animated & interactive acceptance bar | Must | Stage2 | Built ✅ | — | `router.dart`, `ratel_button.dart`, `ratel_fade_through.dart`, `lesson_screen.dart` +1 |
| R-L18 | Mascot animation tech & rig contract | Must | Stage2 | Built ✅ | — | `perf_bench_test.dart`, `mascot_view.dart`, `riv_contract.dart`, `riv_contract_test.dart` |
| R-L19 | Celebration & lesson-feedback kit | Must | Stage2 | Built ✅ | — | `perf_bench_test.dart`, `ratel_celebration.dart`, `onboarding_flow.dart` |

## Part M — Analytics, ops & infrastructure

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-M1 | Analytics event taxonomy & core KPIs | Must | Stage3 | Partial 🟨 | 🔒 owner/$$ | `analytics.dart`, `taxonomy.dart`, `audit_sink.dart`, `services.dart` +1 |
| R-M2 | Experimentation & feature flags (dark-launch, A/B, wave gating) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-M3 | Backend infrastructure (Supabase: Postgres, RLS, Edge, Storage/CDN) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `content_providers.dart`, `content_repository.dart`, `data_access.dart`, `services.dart` +2 |
| R-M4 | Content build/upload ops (batch tooling, staging-prod) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-M5 | Observability (logging & error tracking) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `audit_sink.dart`, `observability.dart`, `test_audit_log.py`, `0008_audit_log.sql` +1 |
| R-M6 | CI/CD & store-release process | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-M6a | Linux distribution channel + desktop auto-update | Could | Wave | Deferred ⏭ | 🔒 owner/$$ | — |
| R-M7 | Backup / DR & data export | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-M8 | Runtime cost guardrails & monitoring | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `ai_relay.dart`, `cost_guard.dart`, `moderation.dart`, `relay_pipeline.dart` +8 |

## Part M — Automation (R-AUT)

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-AUT-1 | Store-listing & ASO generation pipeline | Could | Wave | Deferred ⏭ | 🔒 owner/$$ | — |
| R-AUT-2 | Analytics-to-generation wave orchestrator | Could | Wave | Deferred ⏭ | 🔒 owner/$$ | — |
| R-AUT-3 | Scheduled recalibration & threshold-refresh job | Could | Wave | Deferred ⏭ | 🔒 owner/$$ | `0006_review_log_partitions.sql` |
| R-AUT-4 | Alert-to-incident response automation | Could | Wave | Deferred ⏭ | 🔒 owner/$$ | — |

## Part N — Non-functional quality bars

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-N1 | Performance budgets (cold start, lesson load, audio latency) | Must | Cross | Spec/cross ▫ | — | `perf_bench_test.dart`, `ratel_motion_tier.dart`, `ratel_typography.dart`, `riv_contract.dart` +1 |
| R-N2 | Scalability (content volume, concurrent users) | Must | Cross | Spec/cross ▫ | — | — |
| R-N3 | Reliability / availability targets | Must | Cross | Spec/cross ▫ | — | — |
| R-N4 | Localization completeness & quality bars per tier | Must | Cross | Spec/cross ▫ | — | — |
| R-N5 | Low-connectivity / low-end-device resilience + data budget | Must | Cross | Spec/cross ▫ | — | `ratel_typography.dart` |
| R-N6 | Maintainability / charter conformance | Must | Cross | Spec/cross ▫ | — | `design_system.dart`, `ratel_color_tokens.dart`, `ratel_motion.dart`, `token_lint_test.dart` |
| R-N7 | Unified motion-tier signal (accessibility precedence) | Must | Cross | Spec/cross ▫ | — | `context_ext.dart`, `ratel_motion_tier.dart`, `ratel_motion.dart`, `mascot_view.dart` +2 |
| R-N8 | Animation performance & power budget | Must | Cross | Spec/cross ▫ | — | `perf_bench_test.dart`, `mascot_view.dart`, `riv_contract.dart`, `perf_gauntlet_test.dart` |

## Part O — Program, phasing & risks

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-O1 | Phase-2 deliverables (local content model - NO DB) | Process | Stage1 | Built ✅ | — | `perf_bench_test.dart`, `app_flags.dart`, `energy_state.dart`, `home_screen.dart` +4 |
| R-O2 | Phase-3 deliverables (DB + runtime + payments - gated, MONEY) | Process | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-O3 | Post-launch waves (tier climb, write/live-roleplay, RTL re-add) | Process | Wave | Deferred ⏭ | 🔒 owner/$$ | — |
| R-O4 | Risk register & mitigations | Process | Program | Spec/cross ▫ | — | — |
| R-O5 | Consolidated open-decisions tracker | Process | Program | Spec/cross ▫ | — | — |

