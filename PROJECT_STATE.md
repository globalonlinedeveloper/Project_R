# Project_R (Ratel) — Build State
> session-craft tracker. Read FIRST each session. Newest status on top. Durable = this git remote + the owner's mounted `Apps/` folder. The VM resets every session.

## Header
- **Repo:** https://github.com/globalonlinedeveloper/Project_R (default `main`)
- **★ STAGE 1 COMPLETE** — Phases 0–3 ✓ (Ckpt A schema · B model+loader · C pipeline+gate · **D schema lock**). **Next: Stage 2 — Modern UI/UX** (local, NO DB). **Autonomy:** L1.
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
- Subscription-only: never add a metered-API call in `generate`/`jury`; keep pipeline tests offline.
- Loader/pipeline web-safe (no `dart:io` in `lib/`; gate builds web). json_serializable: `explicit_to_json` + `disallow_unrecognized_keys` + `checked` in `build.yaml`.
- `flutter analyze` (CI) fails on lint infos. freezed 4.x = `@freezed abstract class X with _$X`; `freezed_annotation` re-exports `json_annotation`.
- jsonschema preinstalled 3.2.0 (Draft-7) → use `requirements.txt` (≥4.x). jieba builds its cache on first cut (~10s) — pre-warm. fugashi+unidic-lite+jieba are wheels (no libicu/system-MeCab needed); PyICU/TH deferred (not in pilot).
- `ratel-tools` is not a Python package → tests `sys.path.insert` the dir, then `import schema_loader` / `from pipeline... import`.
- iOS/macOS/Windows platforms not scaffolded (need mac/win runners). ruff/mypy not yet in CI.

## Next-queue (Stage 2 — Modern UI/UX · local · NO DB)
1. **Design system** `lib/core/design_system/` — tokens + components (theme · motion-tier R-N7 · WCAG a11y harness R-K8), built fresh ("beat Duolingo"); old 82-screen shell = reference only.
2. **Core-loop screens on the loader** — onboarding → lesson → review → streak, offline-first + instant start, beachhead-first (cheap-phone champion); render from `ContentBatch`.
3. **Adventures slice + Rive mascot rig** (pure-vector `.riv`, reduce-motion → paused-frame) within the **R-N1** perf budgets.
4. **→ R-O1 6-check Phase-exit gate** (adds checks 4–6: UI on loader · Adventures+Rive · perf budgets) → ★ Stage-4 architecture sign-off → Stage 3 (backend/runtime/payments, owner + money-gated). Content fan-out beyond the pilot is now unlocked (rows-only).

## SCORE / RETRO
- **SCORE (S12):** **8 increments shipped — T0.1·T0.2·T1.1·T1.2·T2.1·T2.2·T2.3·T3 — ★ STAGE 1 COMPLETE (Ckpt A·B·C·D)** · 0 CI failures · 1 local red→green (explicit_to_json) · 0 avoidable retries.
- **RETRO:** one frozen `schema.json` threaded through generator + validator + Dart models + loader + 12-axis gate kept everything honest end-to-end; seam-first design (Protocols/stubs) made subscription-only + offline tests enforceable; wheels (fugashi/unidic-lite/jieba) dodged native-install pain; authoring seeds *from* the tokenizers made the gate pass by construction.

## Kickoff line (next session)
"Read `Project_R/PROJECT_STATE.md` + `Apps/RATEL_PROJECT_STATE.md` (SESSION 12), then begin **Stage 2 — Modern UI/UX**: design system → core-loop screens on the loader → Adventures + Rive → the R-O1 6-check gate, in auto mode — local, NO DB, schema frozen." (VM wipes: re-install Flutter + `pip install -r ratel-tools/requirements.txt`, re-clone, pub get + build_runner.)
