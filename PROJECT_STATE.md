# Project_R (Ratel) — Build State
> session-craft tracker. Read FIRST each session. Newest status on top. Durable = this git remote + the owner's mounted `Apps/` folder. The VM resets every session.

## Header
- **Repo:** https://github.com/globalonlinedeveloper/Project_R (default `main`)
- **★ STAGE 1 COMPLETE** — Phases 0–3 ✓ (Ckpt A schema · B model+loader · C pipeline+gate · **D schema lock**). **Next: Stage 2 — Modern UI/UX** (local, NO DB). **Autonomy:** L1.
- **STAGE 2 — Modern UI/UX IN PROGRESS (S13, auto/L2):** S2-Inc1..Inc4 shipped (design system -> components -> app shell/go_router IA -> onboarding-on-loader). Next: lesson core loop -> home/streak -> Adventures + Rive -> R-O1 6-check gate.
- **Invariants:** local-only · **NO DB** · **subscription-only generation (NO metered API)** · Supabase untouched · `Apps/RATEL_REQUIREMENTS.md` frozen at **161** · `schema/schema.json` FROZEN (Ckpt A) — generate from it, zero schema change.
- **Stack:** Flutter 3.44.1 / Dart 3.12.1 · freezed 4.0.0-dev.3 + json_serializable 6.14 · Python 3 · JSON-Schema 2020-12 · Riverpod · go_router · Drift (Stage 2+).
- **Planning (mounted, canonical):** `Apps/tasks/SPEC.md` · `plan.md` · `todo.md` · `idea-cheap-phone-champion.md` · `Apps/RATEL_REQUIREMENTS.md` (WHAT) · `Apps/RATEL_PROJECT_STATE.md` (master).

## Resume playbook (VM)
- **Flutter (resumable, §18):** `git clone --depth 1 -b 3.44.1 https://github.com/flutter/flutter.git /tmp/flutter`; `export PATH=/tmp/flutter/bin:$PATH; export PUB_CACHE=/tmp/.pub-cache; flutter --version` (re-run till Dart SDK done).
- **Python:** `pip install --break-system-packages -r ratel-tools/requirements.txt` (jsonschema/referencing/pytest + fugashi·unidic-lite·jieba·regex). Pre-warm jieba (`python3 -c "import jieba; jieba.initialize()"`) in its own leg so pytest stays under the 45s cap.
- **Clone + build:** `git clone …/Project_R.git $HOME/work/Project_R` → `flutter pub get` → `dart run build_runner build` (regenerates the gitignored `.freezed/.g`).
- **Secrets:** `Apps/.cowork-private/secrets.env` (GITHUB_PAT…) — `source` per shell; NEVER print/commit.
- **Token-safe push:** `source <secrets>; git -c credential.helper='!f(){ echo username=globalonlinedeveloper; echo "password=$GITHUB_PAT"; }; f' push origin main`
- **Disk:** SDK+PUB_CACHE on `/`; clone on `/sessions`. File tools can't reach `/sessions` clones → author repo files via bash heredocs.
- **Gate:** CI = `flutter-gate` (build_runner→analyze→test→build web) + `python-schema-gate` (pytest: schema+pipeline+validators+tokenizers+axis+schema-lock · model-drift). "Done"=CI green. Poll `/commits/<sha>/check-runs?cb=<ts>`.
- **Run pipeline:** `cd ratel-tools && python3 -m pipeline.run --locale en --type mcq --count 3` · **Re-author seeds:** `python3 ratel-tools/author_seeds.py`.

## Stage 2 increment log (newest first) — SESSION 13 (Modern UI/UX - local - NO DB - schema frozen)
- **S2-Inc4 done (`0720e83`)** - guest-first onboarding (R-L2) renders a real first win OFF THE LOADER. ContentRepository + Riverpod `seedBatchProvider` load the bundled EN seed via the fail-closed ContentLoader (NO DB; assets declared). Flow: language -> motivation -> goal -> first win (<=7 steps; step dots; token cross-fades). First win builds a real MCQ from the ContentBatch (prompt blanked from a seed sentence; options from batch tokens) -> correct -> R-L19 celebration + XP count-up. First-run router redirect to /onboarding (in-memory flag; learner-state stays stubs per R-O1). 45 Dart tests green (onboarding test drives the real seed asset).
- **S2-Inc3 done (`ada9d86`)** - app shell + go_router tab IA (R-L10): Learn/Practice/Adventures/Profile StatefulShellRoute; RatelShell bottom NavigationBar (token-themed; 48dp + a11y labels); token-driven page transitions (R-L17); flutter_riverpod ProviderScope at root; placeholder tokenized+keyed feature screens. Added go_router 17.3.0 + flutter_riverpod 2.6.1 (D4/D5, pre-decided in SPEC). Nav + no-overflow@360 tests.
- **S2-Inc2 done (`1d903ae`)** - component + motion + celebration kit. RatelButton (token-styled over Material -> rest/hover/focus/pressed/disabled +loading, R-L17; 48dp, R-K8), RatelCard, RatelScreen (centered maxContentWidth for cheap phones); motion kit R-L16 (CountUp - ProgressRing ring-fill - FadeThrough); RatelCelebration R-L19 (GPU particles; flourish/lessonComplete/levelUp escalation). All MotionTier-aware (static -> still, R-N7). 41 Dart tests green; analyze clean.
- **S2-Inc1 done (`6ba8922`)** - design-system foundation `lib/core/design_system/`: color/spacing/type/motion tokens (R-L16) + RatelTheme light+dark (ThemeExtension); MotionTier resolver (R-N7 - OS reduce-motion hard floor over perf/low-power); WCAG contrast util + AA contrast tests over every token pair (R-K8); token-lint test guarding lib/features vs raw Color/Duration/Curve (R-N6); main.dart routed through RatelTheme (boot-marker smoke intact). 32 Dart tests green.
- **CI note (S13):** web_fetch GitHub check-runs polling returned empty/stale-cached this session, so CI green is NOT API-confirmed. The local gate (build_runner -> analyze -> test = the exact CI commands) is green for both increments and `lib/` is web-safe. **Confirm flutter-gate on the Actions tab for 6ba8922 + 1d903ae.**

## Increment log (newest first) — SESSION 12, all CI-green
- **T3 ✓ (★ Ckpt D — SCHEMA LOCK · `1896cd2`)** — pilot seeds `assets/content/{en,es,ta,ja,_pilot}/seed.batch.json` (JA tokens fugashi-aligned, TA graphemes UAX-29; via `author_seeds.py`). `tests/test_schema_lock.py` + `test/content/seed_load_test.dart`: every seed schema-valid at **zero schema change**, passes the 12-axis gate, loads via the fail-closed loader; union exercises all 12 axes. `docs/SCHEMA_LOCK.md` = signed checklist (R-O1 checks 1–3). **★ STAGE 1 COMPLETE.**
- **T2.3 ✓ (★ Ckpt C · `f05be1f`)** — 12-axis gate + pinned tokenizers (fugashi+unidic-lite JA · jieba ZH · regex UAX-29 · ICU optional); `boundary_f1`; wired into `run.main`.
- **T2.2 ✓ (`4107e2f`)** — deterministic R-E4 validators (schema·length·script/charset+tokens[]·no-leak·back-translation hook).
- **T2.1 ✓ (`3268dcc`)** — subscription-only pipeline scaffold (generate→jury→validate→gate→versioned JSON; network-free seams).
- **T1.2 ✓ (★ Ckpt B · `71e63d7`)** — web-safe fail-closed `ContentLoader` → typed `ContentBatch`.
- **T1.1 ✓ (`129deb5`)** — schema→Dart freezed models via `codegen_dart.py`; CI drift gate.
- **T0.2 ✓ (★ Ckpt A · `37ad252`)** — modular JSON-Schema 2020-12 (9 tables + enums + open-containers + provenance); rows-only. **schema.json frozen.**
- **T0.1 ✓ (genesis · `5beff8a`)** — Flutter scaffold + CI gate (bundle `com.learnwithratel.ratel`).

## Gotchas
- **Secrets:** `source Apps/.cowork-private/secrets.env` with `2>/dev/null` - a non-bash line (~17) errors under `set -e`; `GITHUB_PAT` still loads from an earlier line. Never `set -e` across the source.
- **CI status polling (S13):** web_fetch on `api.github.com/.../check-runs` returns empty and plain repo metadata serves a STALE cached body - unreliable for live CI here. Trust the local gate; confirm via the Actions tab or a future interactive session.
- **Flutter SDK path:** install to `/tmp/flutter` (root `/` is NOT writable; `/flutter` -> Permission denied). `PUB_CACHE=/tmp/.pub-cache`. `-b 3.44.1` carried the tag (no 0.0.0 trap).
- Subscription-only: never add a metered-API call in `generate`/`jury`; keep pipeline tests offline.
- Loader/pipeline web-safe (no `dart:io` in `lib/`; gate builds web). json_serializable: `explicit_to_json` + `disallow_unrecognized_keys` + `checked` in `build.yaml`.
- `flutter analyze` (CI) fails on lint infos. freezed 4.x = `@freezed abstract class X with _$X`; `freezed_annotation` re-exports `json_annotation`.
- jsonschema preinstalled 3.2.0 (Draft-7) → use `requirements.txt` (≥4.x). jieba builds its cache on first cut (~10s) — pre-warm. fugashi+unidic-lite+jieba are wheels (no libicu/system-MeCab needed); PyICU/TH deferred (not in pilot).
- `ratel-tools` is not a Python package → tests `sys.path.insert` the dir, then `import schema_loader` / `from pipeline... import`.
- iOS/macOS/Windows platforms not scaffolded (need mac/win runners). ruff/mypy not yet in CI.

## Next-queue (Stage 2 — Modern UI/UX · local · NO DB)

**S13 status:** design system + components + app shell/IA + onboarding-on-loader = DONE (S2-Inc1..Inc4). **Remaining (auto mode):**
1. **Lesson core loop on the loader (R-L3)** - ordered on-device-graded queue, immediate feedback + pre-gen why-card, complete screen + R-L19 celebration, gentle-energy (charge 1 on complete only; NEVER gate reviews / first daily lesson - R-N6 guardrail tests). Render off ContentBatch.
2. **Home/streak + review entry (R-L4/L8)** - replace placeholder Home with a real lesson list off the loader + account-streak (device-local midnight); 'Practice your mistakes' review entry. Layer-F learner-state = interfaces/stubs.
3. **Adventures system (R-L4a)** - themed-districts map + scene-player over scripted-roleplay rails; ~1-2 zones; placeholder/programmatic art.
4. **Rive mascot integration (R-L18)** - single shared-rig manager (dispose offscreen, R-N8/B8) + MotionTier-aware controller (animate->paused pose->none, no bitmap) + asset-build-time .riv validator (reject embedded rasters / over-budget, C24). Ship a PLACEHOLDER rig.
5. **R-O1 6-check exit gate (checks 4-6)** - (4) all core screens off the loader [onboarding done; lesson/home pending], (5) Rive+Adventures working (paused-frame + reduced-motion tested), (6) reference-device perf bench (cold-start/frame + animation-stress + mascot memory, R-N1/N8) in CI.

**OWNER ACTIONS (real-world, not buildable here):** (a) author the Duolingo-grade vector Rive mascot `.riv` rig (State Machine + visemes) - Inc 8 ships integration + a placeholder; (b) Adventures map + scene illustration art; (c) glance at the GitHub **Actions tab** to confirm `flutter-gate` green for the S13 commits (web_fetch CI polling was unreliable this session).

_(Original 4-line queue below is superseded by the above.)_
1. **Design system** `lib/core/design_system/` — tokens + components (theme · motion-tier R-N7 · WCAG a11y harness R-K8), built fresh ("beat Duolingo"); old 82-screen shell = reference only.
2. **Core-loop screens on the loader** — onboarding → lesson → review → streak, offline-first + instant start, beachhead-first (cheap-phone champion); render from `ContentBatch`.
3. **Adventures slice + Rive mascot rig** (pure-vector `.riv`, reduce-motion → paused-frame) within the **R-N1** perf budgets.
4. **→ R-O1 6-check Phase-exit gate** (adds checks 4–6: UI on loader · Adventures+Rive · perf budgets) → ★ Stage-4 architecture sign-off → Stage 3 (backend/runtime/payments, owner + money-gated). Content fan-out beyond the pilot is now unlocked (rows-only).

## SCORE / RETRO

- **SCORE (S13):** 4 increments shipped - S2-Inc1.Inc2.Inc3.Inc4 (design system -> components -> app shell/IA -> onboarding-on-loader) - 0 local-gate failures - 1 trivial fix (unnecessary_import after barrel export) - ~45 Dart tests green. CI green NOT API-confirmed (web_fetch unreliable; local gate = exact CI commands).
- **RETRO (S13):** token-styled wrappers over Material gave accessible R-L17 states ~free; MotionTier threaded into every animated widget made reduced-motion test-enforced; onboarding driving the REAL seed asset through the loader proved the content->UI seam with no DB. Token waste: web_fetch CI-status polling (cached/empty) - skip it next session, confirm via Actions tab.- **SCORE (S12):** **8 increments shipped — T0.1·T0.2·T1.1·T1.2·T2.1·T2.2·T2.3·T3 — ★ STAGE 1 COMPLETE (Ckpt A·B·C·D)** · 0 CI failures · 1 local red→green (explicit_to_json) · 0 avoidable retries.
- **RETRO:** one frozen `schema.json` threaded through generator + validator + Dart models + loader + 12-axis gate kept everything honest end-to-end; seam-first design (Protocols/stubs) made subscription-only + offline tests enforceable; wheels (fugashi/unidic-lite/jieba) dodged native-install pain; authoring seeds *from* the tokenizers made the gate pass by construction.

## Kickoff line (next session)
"Read `Project_R/PROJECT_STATE.md` + `Apps/RATEL_PROJECT_STATE.md` (SESSION 13), then continue **Stage 2 - Modern UI/UX** from the **lesson core loop (R-L3)** -> home/streak -> Adventures + Rive -> the R-O1 6-check gate, in auto mode - local, NO DB, schema frozen." (VM wipes: re-install Flutter to **/tmp/flutter** + `pip install --break-system-packages -r ratel-tools/requirements.txt`, re-clone, `flutter pub get` + `dart run build_runner build`.)
