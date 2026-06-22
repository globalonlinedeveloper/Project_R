# Project_R (Ratel) — Build State
> session-craft tracker. Read FIRST each session. Newest status on top. Durable stores = this git remote + the owner's mounted `Apps/` folder. The VM resets every session.

## Header
- **Repo:** https://github.com/globalonlinedeveloper/Project_R (default branch `main`)
- **Stage:** 1 (Foundation) — Phase 0 (scaffold/schema) ✓, Phase 1 (model+loader) ✓ (Ckpt A + B). **Next: Phase 2 (Python pipeline).** · **Autonomy:** L1
- **Invariants:** local-only · **NO DB** · subscription-only generation · Supabase untouched · `Apps/RATEL_REQUIREMENTS.md` frozen at **161** (do NOT re-open) · `schema/schema.json` FROZEN (Ckpt A) — generate from it, zero schema change
- **Stack:** Flutter 3.44.1 / Dart 3.12.1 · freezed 4.0.0-dev.3 + json_serializable 6.14 · Python 3 · JSON-Schema 2020-12 · Riverpod · go_router · Drift (Stage 2+)
- **Planning docs (mounted, canonical):** `Apps/tasks/SPEC.md` (HOW) · `plan.md` · `todo.md` · `idea-cheap-phone-champion.md` · `Apps/RATEL_REQUIREMENTS.md` (WHAT) · `Apps/RATEL_PROJECT_STATE.md` (master)

## Resume playbook (VM)
- **Flutter (not preinstalled; resumable, §18):** `git clone --depth 1 --single-branch -b 3.44.1 https://github.com/flutter/flutter.git /tmp/flutter`; `export PATH=/tmp/flutter/bin:$PATH; export PUB_CACHE=/tmp/.pub-cache; flutter --version` (re-run until Dart SDK done).
- **Python:** `pip install --break-system-packages -U "jsonschema>=4.20" "referencing>=0.30" pytest`.
- **Clone + build:** `git clone https://github.com/globalonlinedeveloper/Project_R.git $HOME/work/Project_R` → `flutter pub get` → `dart run build_runner build` (regenerates gitignored `.freezed/.g`) before analyze/test.
- **Secrets:** `Apps/.cowork-private/secrets.env` (GITHUB_PAT…) — `source` per shell; NEVER print/commit.
- **Token-safe push:** `source <secrets>; git -c credential.helper='!f(){ echo username=globalonlinedeveloper; echo "password=$GITHUB_PAT"; }; f' push origin main`
- **Disk:** SDK+PUB_CACHE on `/`; clone on `/sessions`. File tools can't reach `/sessions` clones — author repo files via heredocs.
- **Gate:** CI = `flutter-gate` (build_runner→analyze→test→build web) + `python-schema-gate` (schema lint · fixtures · model-drift). "Done"=CI green. Poll `/commits/<sha>/check-runs?cb=<ts>`.

## Increment log (newest first)
- **2026-06-23 · SESSION 12 · T1.2 ✓ (★ Ckpt B) · CI GREEN (`71e63d7`)** — `lib/content/loader/content_loader.dart`: web-safe (no dart:io) `loadString`/`loadMap` → typed `ContentBatch`. **Fail-closed:** bad row / missing field / unknown column / unknown table / bad JSON / missing batch_id each reject the whole batch (no partial load). `build.yaml` gained `checked` + `disallow_unrecognized_keys` (client mirror of `additionalProperties:false`). `assets/content/en/seed_demo.batch.json` fixture; 9 loader tests + 9 round-trips + smoke green.
- **2026-06-23 · SESSION 12 · T1.1 ✓ · CI GREEN (`129deb5`)** — schema → Dart freezed models via `ratel-tools/codegen_dart.py`; `.freezed/.g` gitignored + built in CI; schema→Dart drift gate.
- **2026-06-23 · SESSION 12 · T0.2 ✓ (★ Ckpt A) · CI GREEN (`37ad252`)** — modular JSON-Schema 2020-12 (9 tables + enums + open-container defs + provenance); rows-only via additionalProperties:false; conformance gate. **schema.json = frozen SoT.**
- **2026-06-23 · SESSION 12 · T0.1 ✓ (genesis) · CI GREEN (`5beff8a`)** — Flutter scaffold + CI gate.

## Gotchas
- Loader stays **web-safe**: NO `dart:io` in `lib/` (CI builds web). Read files/assets in callers/tests, pass the string to `loadString`.
- json_serializable: `explicit_to_json:true` (nested toJson) + `disallow_unrecognized_keys:true`/`checked:true` (fail-closed) live in `build.yaml`.
- `flutter analyze` (CI) fails on lint infos. freezed 4.x = `@freezed abstract class X with _$X`. `freezed_annotation` re-exports `json_annotation`.
- jsonschema preinstalled 3.2.0 (Draft-7) → `-U` ≥4.x. 45s/cmd cap → SDK bootstrap + first build_runner resumable.
- iOS/macOS/Windows platforms not scaffolded yet (need mac/win runners).

## Next-queue
1. **T2.1** Python pipeline scaffold (`ratel-tools/pipeline/`): generate → jury → deterministic validators → confidence gate → versioned JSON. **Subscription-only (NO metered API).** Dry-run emits a gated EN batch for one item type (reuse `schema_loader` to validate output rows). Typed (mypy), ruff/black, no network at test time. Add a CI step (pytest) for the pipeline.
2. **T2.2** deterministic validators (R-E4): schema · length · script/charset+`tokens[]` · no-leak · back-translation hook — each pass+fail test.
3. **T2.3** 12-axis gate (P0-7) + pinned tokenizers (MeCab/UniDic · Jieba · ICU, boundary-F1 ≥ 0.95) → **Ckpt C**.
4. **T3.1–3.5** pilot seeds EN·ES·TA·JA + B1 (zero schema change) → **★ Ckpt D schema lock**.

## SCORE / RETRO
- **SCORE (S12):** **4 increments shipped (T0.1, T0.2, T1.1, T1.2)** · 0 CI failures · 1 local red→green (explicit_to_json) · 0 avoidable retries.
- **RETRO:** generator-driven models + drift gate keep schema authoritative; web-safety (no dart:io in lib) matters because the gate builds web; disallow_unrecognized_keys made client fail-closed real (mirrors the schema). Surgical requirement reads kept context lean across 4 increments.

## Kickoff line (next session)
"Read `Project_R/PROJECT_STATE.md` + `Apps/RATEL_PROJECT_STATE.md` (SESSION 12), then proceed with **T2.1 (Python pipeline scaffold, subscription-only)** in auto mode — TDD, CI-green before done. Schema FROZEN; NO DB; no metered API." (VM wipes: re-install Flutter + Python deps, re-clone, pub get + build_runner.)
