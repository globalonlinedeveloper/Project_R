# Ratel — Requirements Traceability Matrix (RTM)

> **GENERATED** by `ratel-tools/gen_traceability.py` from the 168 requirement IDs in `RATEL_REQUIREMENTS.md`. Do not hand-edit — rerun the generator. To correct a call, edit `ratel-tools/requirements_registry.json` (`overrides`) and rerun.

**How to read this**

- **MoSCoW** is *derived* from the spec (R-A1 v1 boundary · R-A8 launch floor · Part O phases) — interpretive, **please review/override**.
- **Phase**: Foundation/Stage1/Stage2 = local & complete per the S1–S27 build audit · Stage3 = DB/runtime/payments (owner + money gated) · Wave = post-launch (R-O3) · Cut = removed.
- **Status (build)** = completion of the *buildable* slice: `Built ✅` (Stage 1–2, per audit) · `Build-ahead 🟦` (Stage-3 logic written + tested, not yet live) · `Partial 🟨` · `Pending 🔒` (Stage-3, not started) · `Deferred ⏭` (wave) · `Removed ✖`.
- **Gate** = going live needs owner action / money.
- **Evidence** = source/test files citing the requirement ID (a floor — not every built file tags its ID).

## Coverage rollup (by MoSCoW × build status)

| Priority | Built | Build-ahead | Partial | Pending | Deferred | Removed | Spec/cross | Total |
|---|---|---|---|---|---|---|---|---|
| **Must** | 78 | 19 | 6 | 13 | 2 | 0 | 13 | 131 |
| **Should** | 18 | 1 | 0 | 2 | 1 | 0 | 0 | 22 |
| **Could** | 1 | 0 | 0 | 1 | 7 | 0 | 0 | 9 |
| **Won't** | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 |
| **Process** | 1 | 0 | 0 | 1 | 1 | 0 | 2 | 5 |
| **All** | 98 | 20 | 6 | 17 | 11 | 1 | 15 | 168 |

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
| R-A7 | Pilot CEFR content scope | Must | Stage1 | Built ✅ | — | `content_course_spine.dart`, `course_spine_test.dart` |
| R-A8 | Launch-minimum bar & wave policy | Must | Spec | Spec/cross ▫ | — | — |

## Part B — Learning model & curriculum

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-B1 | CEFR can-do spine ratification | Must | Stage1 | Built ✅ | — | — |
| R-B2 | Skill/Concept prerequisite graph | Must | Stage1 | Built ✅ | — | — |
| R-B3 | Course-Section-Unit-Lesson containers & path rendering | Must | Stage1 | Built ✅ | — | `content_wiring.dart`, `content_course_spine.dart`, `home_screen.dart`, `course_spine.dart` +1 |
| R-B4 | TBLT task model + tap-to-define | Must | Stage1 | Built ✅ | — | — |
| R-B5 | Depth-as-data & CEFR-ceiling enforcement | Must | Stage1 | Built ✅ | — | — |
| R-B6 | Native realization & divergence nodes | Must | Stage1 | Built ✅ | — | — |
| R-B7 | Pair-specific / contrastive layer | Must | Stage1 | Built ✅ | — | — |
| R-B8 | Content difficulty model (IRT + cold-start) | Must | Stage1 | Built ✅ | — | `content_course_spine.dart`, `course_spine.dart`, `lesson_runner_screen.dart`, `lesson_test.dart` |

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
| R-D10 | scripted_roleplay (a branching scripted conversation) | Must | Stage2 | Built ✅ | — | `adventures_screen.dart` |
| R-D11 | Phase-3 scaffolds: write + live_roleplay (scaffolded now) | Should | Wave | Deferred ⏭ | 🔒 owner/$$ | — |
| R-D12 | tap-to-define reading feature + comprehension-item policy | Must | Stage2 | Built ✅ | — | — |
| R-D13 | Autoscoring & answer-equivalence rules | Must | Stage2 | Built ✅ | — | `lesson_runner_screen.dart`, `lesson_test.dart` |
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
| R-G1 | One identity, many courses | Must | Stage3 | Partial 🟨 | 🔒 owner/$$ | `supabase_identity.dart` |
| R-G2 | theta ability model (global + per-skill) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `lesson_runner_screen.dart`, `progress_screen.dart`, `ability.dart`, `lesson_test.dart` +2 |
| R-G3 | IRT calibration (how hard each item is) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `irt.dart`, `irt_test.dart` |
| R-G4 | CAT placement test | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `learner_controller.dart`, `onboarding_screen.dart`, `placement_quiz_screen.dart`, `cat.dart` +3 |
| R-G5 | FSRS spaced-repetition scheduling | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `practice_hub_screen.dart`, `saved_words_controller.dart`, `fsrs.dart`, `practice_test.dart` +1 |
| R-G6 | Learner-state entities (what gets stored) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `progress_screen.dart`, `supabase_learner_state_store.dart`, `learner_state.dart`, `user.schema.json` +3 |
| R-G7 | Cold-start strategy (works from day one) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `learner_controller.dart`, `onboarding_screen.dart`, `placement_quiz_screen.dart`, `cold_start.dart` +3 |
| R-G8 | Launch path-serving (how lessons are sequenced) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `path_serving.dart`, `path_serving_test.dart` |
| R-G9 | Saved words - flashcards - graded review | Should | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `lesson_runner_screen.dart`, `practice_hub_screen.dart`, `progress_screen.dart`, `saved_words_controller.dart` +5 |

## Part H — AI, tutor & conversation

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-H1 | AI tutor chat | Must | Stage3 | Partial 🟨 | 🔒 owner/$$ | `ai_tutor_screen.dart` |
| R-H2 | Realtime voice conversations | Must | Stage3 | Partial 🟨 | 🔒 owner/$$ | `ai_tutor_screen.dart` |
| R-H3 | Launch pronunciation UX (shadowing, free) | Must | Stage2 | Built ✅ | — | — |
| R-H4 | Advanced pronunciation scoring - REMOVED | Won't | Cut | Removed ✖ | — | — |
| R-H5 | Grading written answers (later)<br>_Owner S28: Must priority; spec schedules the LLM-grading engine in R-O3 Wave C (later)._ | Must | Wave | Deferred ⏭ | 🔒 owner/$$ | — |
| R-H6 | Open-ended roleplay conversations (later)<br>_Owner S28: Must priority; spec schedules open-roleplay engine in R-O3 Wave C (later)._ | Must | Wave | Deferred ⏭ | 🔒 owner/$$ | `adventures_screen.dart`, `ai_tutor_screen.dart` |
| R-H7 | Runtime key mgmt, relay, rate-limit & abuse | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `adventures_screen.dart`, `ai_tutor_screen.dart`, `ai_relay.dart`, `cost_guard.dart` +10 |
| R-H8 | Reusable scaffolds (Scenario + GradingRubric) | Should | Stage2 | Built ✅ | — | — |

## Part I — Gamification, economy & social

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-I1 | XP model (sources & amounts) | Should | Stage2 | Built ✅ | — | `lesson_runner_screen.dart`, `progress_screen.dart`, `lesson_test.dart`, `progress_test.dart` |
| R-I2 | Streak + streak-freeze + Society tiers | Should | Stage2 | Built ✅ | — | `progress_screen.dart`, `progress_test.dart` |
| R-I3 | Energy model (lesson cost, regen, caps) | Should | Stage2 | Built ✅ | — | — |
| R-I4 | Gems soft-currency (earn / spend sinks) | Should | Stage2 | Built ✅ | — | — |
| R-I5 | Rewarded-ads - energy / gems design | Should | Stage2 | Built ✅ | — | — |
| R-I6 | Leagues / leaderboards (global, weekly reset) | Should | Stage2 | Built ✅ | — | — |
| R-I7 | Daily goal + chest + quests + achievements | Should | Stage2 | Built ✅ | — | `achievements_controller.dart`, `onboarding_screen.dart`, `progress_screen.dart`, `quests_controller.dart` +7 |
| R-I8 | Anti-dark-pattern guardrails | Should | Stage2 | Built ✅ | — | — |
| R-I9 | Social: friends/feed, family plan, classroom, block/report | Should | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |

## Part J — Monetization

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-J1 | Free vs Pro feature split (exact) | Must | Stage3 | Partial 🟨 | 🔒 owner/$$ | `adventures_screen.dart`, `ai_tutor_screen.dart` |
| R-J2 | Pro price point(s) + billing (regional/PPP, trial) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-J3 | AI access policy - Pro-only live AI, metered by credits | Must | Stage3 | Partial 🟨 | 🔒 owner/$$ | `ai_tutor_screen.dart`, `play_receipt_verify.dart`, `user.schema.json` |
| R-J4 | Ad strategy + network/mediation | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-J5 | Voice minute caps (even Pro) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-J6 | Store-safe paywall / cancel (single CTA, easy cancel) | Must | Stage3 | Partial 🟨 | 🔒 owner/$$ | `credit_ledger.schema.json` |
| R-J7 | Payments / IAP integration (App Store / Play / web) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `play_receipt_verify.dart`, `user.schema.json`, `user_course.schema.json`, `play_receipt_verify_test.dart` |
| R-J7a | Desktop/web billing - web-checkout fallback (no native store) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `billing.dart`, `media_authz.dart`, `payments_verify.dart`, `play_receipt_verify.dart` +4 |

## Part K — Compliance, privacy & safety

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-K1 | Age-gating + COPPA / minors path | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `analytics_identity.dart`, `taxonomy.dart`, `analytics_identity_test.dart` |
| R-K1a | OS age-range assurance has narrow real coverage | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-K2 | Consent - GDPR/UMP + iOS ATT + non-personalized-ads path | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-K3 | Data minimization & retention (no raw-speech retention) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `test_voice_no_audio_persist.py`, `0006_review_log_partitions.sql`, `0007_dsar_delete_anchor.sql`, `0008_audit_log.sql` |
| R-K4 | Regional privacy rights - export + delete (GDPR/DPDP/CCPA) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `test_dsar_delete_anchor.py`, `0007_dsar_delete_anchor.sql`, `0008_audit_log.sql` |
| R-K5 | Generated-content safety (AI-content; profanity; bias) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-K6 | Security - server-side keys, Supabase RLS, auth, PII | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `login_screen.dart`, `signup_screen.dart`, `taxonomy.dart`, `auth_service.dart` +13 |
| R-K7 | Terms of Service + Privacy Policy - final copy & ownership | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-K8 | Accessibility - WCAG 2.2 AA conformance (test-enforced) | Must | Stage2 | Built ✅ | — | — |

## Part L — App screens & UX

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-L1 | Auth & account flows | Must | Stage2 | Built ✅ | — | `login_screen.dart`, `signup_screen.dart`, `auth.dart`, `auth_service.dart` |
| R-L2 | Onboarding flow (language-motivation-goal-placement-first win) | Must | Stage2 | Built ✅ | — | `login_screen.dart`, `signup_screen.dart`, `onboarding_screen.dart`, `onboarding_test.dart` |
| R-L3 | Core learning loop (lesson run, check/feedback, complete) | Must | Stage2 | Built ✅ | — | `lesson_runner_screen.dart`, `lesson_test.dart` |
| R-L4 | Practice & AI hub | Must | Stage2 | Built ✅ | — | — |
| R-L4a | Adventures immersive surface (explorable roleplay world) | Must | Stage2 | Built ✅ | — | — |
| R-L5 | Reading & listening (stories, listening feed, video, tap-to-define) | Must | Stage2 | Built ✅ | — | — |
| R-L6 | Profile & settings hub | Must | Stage2 | Built ✅ | — | — |
| R-L7 | Monetization screens | Must | Stage2 | Built ✅ | — | — |
| R-L8 | Gamification & social screens | Must | Stage2 | Built ✅ | — | `user.schema.json` |
| R-L9 | Multi-course, course-switch, flip-UI & immersion | Must | Stage2 | Built ✅ | — | — |
| R-L10 | Navigation / information architecture (tab shell, deep links) | Must | Stage2 | Built ✅ | — | — |
| R-L11 | Notifications (push categories, opt-in, inbox) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-L11a | Widgets are mobile-only; desktop/web get in-app/tray equivalent | Could | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-L11b | Notifications: per-platform delivery profile | Should | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-L12 | Global search | Should | Stage2 | Built ✅ | — | — |
| R-L13 | Offline mode & caching | Must | Stage2 | Built ✅ | — | — |
| R-L13a | Background sync is foreground-reconcile on iOS-PWA + desktop | Should | Stage2 | Built ✅ | — | — |
| R-L14 | Cross-cutting UI states (loading/empty/error/skeleton) | Must | Stage2 | Built ✅ | — | `progress_screen.dart`, `progress_test.dart` |
| R-L15 | Brand character & motion/delight (the Ratel honey badger) | Must | Stage2 | Built ✅ | — | — |
| R-L16 | Motion & interaction design-system | Must | Stage2 | Built ✅ | — | — |
| R-L17 | Animated & interactive acceptance bar | Must | Stage2 | Built ✅ | — | — |
| R-L18 | Mascot animation tech & rig contract | Must | Stage2 | Built ✅ | — | — |
| R-L19 | Celebration & lesson-feedback kit | Must | Stage2 | Built ✅ | — | `lesson_runner_screen.dart`, `lesson_test.dart` |

## Part M — Analytics, ops & infrastructure

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-M1 | Analytics event taxonomy & core KPIs | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `analytics.dart`, `analytics_identity.dart`, `taxonomy.dart`, `audit_sink.dart` +3 |
| R-M2 | Experimentation & feature flags (dark-launch, A/B, wave gating) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `feature_flags.dart`, `feature_flags_test.dart` |
| R-M3 | Backend infrastructure (Supabase: Postgres, RLS, Edge, Storage/CDN) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `content_providers.dart`, `content_repository.dart`, `data_access.dart`, `supabase_learner_state_store.dart` +4 |
| R-M4 | Content build/upload ops (batch tooling, staging-prod) | Must | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-M5 | Observability (logging & error tracking) | Must | Stage3 | Build-ahead 🟦 | 🔒 owner/$$ | `audit_sink.dart`, `crash_telemetry.dart`, `observability.dart`, `test_audit_log.py` +3 |
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
| R-N1 | Performance budgets (cold start, lesson load, audio latency) | Must | Cross | Spec/cross ▫ | — | — |
| R-N2 | Scalability (content volume, concurrent users) | Must | Cross | Spec/cross ▫ | — | — |
| R-N3 | Reliability / availability targets | Must | Cross | Spec/cross ▫ | — | — |
| R-N4 | Localization completeness & quality bars per tier | Must | Cross | Spec/cross ▫ | — | — |
| R-N5 | Low-connectivity / low-end-device resilience + data budget | Must | Cross | Spec/cross ▫ | — | — |
| R-N6 | Maintainability / charter conformance | Must | Cross | Spec/cross ▫ | — | — |
| R-N7 | Unified motion-tier signal (accessibility precedence) | Must | Cross | Spec/cross ▫ | — | — |
| R-N8 | Animation performance & power budget | Must | Cross | Spec/cross ▫ | — | — |

## Part O — Program, phasing & risks

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-O1 | Phase-2 deliverables (local content model - NO DB) | Process | Stage1 | Built ✅ | — | `learner_controller.dart`, `practice_hub_screen.dart`, `progress_screen.dart`, `saved_words_controller.dart` +5 |
| R-O2 | Phase-3 deliverables (DB + runtime + payments - gated, MONEY) | Process | Stage3 | Pending 🔒 | 🔒 owner/$$ | — |
| R-O3 | Post-launch waves (tier climb, write/live-roleplay, RTL re-add) | Process | Wave | Deferred ⏭ | 🔒 owner/$$ | — |
| R-O4 | Risk register & mitigations | Process | Program | Spec/cross ▫ | — | — |
| R-O5 | Consolidated open-decisions tracker | Process | Program | Spec/cross ▫ | — | — |

## Part W — World themes (Space galaxy skin + future packs)

| ID | Requirement | MoSCoW | Phase | Status | Gate | Evidence |
|----|-------------|--------|-------|--------|------|----------|
| R-WT1 | World-theme template seam (palette + painters + traveller + vocabulary, app-wide + persisted)<br>_S33: galaxy / world-theme feature added to the requirements baseline (owner-directed, page-by-page)._ | Should | Stage2 | Built ✅ | — | — |
| R-WT2 | Space world theme #1 (deep-space galaxy skin, app-wide re-skin)<br>_S33: galaxy / world-theme feature added to the requirements baseline (owner-directed, page-by-page)._ | Should | Stage2 | Built ✅ | — | — |
| R-WT3 | Persisted theme selection (default Classic, opt-in Space)<br>_S33: galaxy / world-theme feature added to the requirements baseline (owner-directed, page-by-page)._ | Should | Stage2 | Built ✅ | — | — |
| R-WT4 | Galaxy Home — CustomPainter backdrop + planet path + locked v8 pod traveller<br>_S33-S34: galaxy Home built page-by-page to completion — scrollable seeded planet-path + v8 pod + ion trail, lesson-preview sheet, real θ→CEFR level + coach, locate FAB, daily strip (goal-ring picker + persisted dailyGoal + real energy regen + due reviews), course bar + section map, animated tier-gated header HUD._ | Should | Stage2 | Built ✅ | — | — |
| R-WT5 | Motion-tier preference (High/Reduced/Off) with OS reduce-motion hard floor<br>_S33: galaxy / world-theme feature added to the requirements baseline (owner-directed, page-by-page)._ | Should | Stage2 | Built ✅ | — | — |
| R-WT6 | Profile settings surface (theme + motion + a11y toggles)<br>_S33: galaxy / world-theme feature added to the requirements baseline (owner-directed, page-by-page)._ | Should | Stage2 | Built ✅ | — | — |
| R-WT7 | Tier-gated galaxy FX + pod auto-defense (HIGH-only, reduce-motion floor)<br>_S34: tier-gated WOW FX built — animation-loop FX (shooting stars/comet/pulsar/black-hole/galaxy), HIGH-only supernova + pod auto-defense (2 homing missiles → 18 sparkle dust, capped), palette-driven colours; reduce-motion HARD floor (minimal/none clear the canvas). Deterministic seeded model unit-tested._ | Could | Stage2 | Built ✅ | — | — |

