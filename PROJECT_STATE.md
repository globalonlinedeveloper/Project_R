# Project_R (Ratel) — Build State
> session-craft tracker. Read FIRST each session. Newest status on top. Durable stores = this git remote + the owner's mounted `Apps/` folder. The VM resets every session.

## Header
- **Repo:** https://github.com/globalonlinedeveloper/Project_R (default branch `main`)
- **Stage:** 1 (Foundation) · **Autonomy:** L1 (auto within scope)
- **Invariants:** local-only · **NO DB** · subscription-only generation · Supabase untouched · `Apps/RATEL_REQUIREMENTS.md` frozen at **161** (do NOT re-open)
- **Stack:** Flutter 3.44.1 / Dart 3.12.1 · Python 3 pipeline · JSON-Schema 2020-12 · Riverpod · go_router · Drift (Stage 2+) · freezed codegen from schema.json
- **Planning docs (mounted, canonical):** `Apps/tasks/SPEC.md` (HOW) · `Apps/tasks/plan.md` · `Apps/tasks/todo.md` · `Apps/tasks/idea-cheap-phone-champion.md` · `Apps/RATEL_REQUIREMENTS.md` (WHAT) · `Apps/RATEL_PROJECT_STATE.md` (master tracker)

## Resume playbook (VM)
- **Toolchain (not preinstalled — install resumably, session-craft §18):**
  `git clone --depth 1 --single-branch -b 3.44.1 https://github.com/flutter/flutter.git /tmp/flutter`
  `export PATH=/tmp/flutter/bin:$PATH; export PUB_CACHE=/tmp/.pub-cache; flutter --version` (re-run until the Dart SDK finishes; ~2 legs under the 45s cap).
- **Python:** `pip install --break-system-packages -U "jsonschema>=4.20" "referencing>=0.30" pytest` (the preinstalled jsonschema 3.2.0 is Draft-7 only).
- **Clone:** `git clone https://github.com/globalonlinedeveloper/Project_R.git $HOME/work/Project_R`
- **Secrets:** `Apps/.cowork-private/secrets.env` (GITHUB_PAT + others) — `source` per shell call; NEVER print/echo/commit.
- **Token-safe push:** `source <secrets>; git -c credential.helper='!f(){ echo username=globalonlinedeveloper; echo "password=$GITHUB_PAT"; }; f' push origin main`
- **Disk:** SDK + PUB_CACHE on `/` (~4.1G free); clone on `/sessions` (`$HOME`). **File tools CANNOT reach `/sessions` clones — author repo files via bash heredocs.**
- **Gate:** `.github/workflows/ci.yml` = `flutter-gate` (analyze + test + build web) + `python-schema-gate` (schema lint + conformance fixtures). "Done" = CI green. Poll via GitHub API `/commits/<sha>/check-runs?cb=<ts>`.

## Increment log (newest first)
- **2026-06-23 · SESSION 12 · T0.2 ✓ (★ Ckpt A) · CI GREEN (`37ad252`)** — Part-C content data model as modular, `$ref`-composed **JSON-Schema 2020-12** under `schema/` (root `schema.json` + `enums/` + `defs/` + 9 `tables/`): Sentence·VocabEntry·Sense·GrammarPoint·Phoneme·Item·Locale·MediaAsset·Gloss. Shared **R-C12 enums**, the four **open-container** payload defs (array/map/flag/reference, R-C1), the R-C10 **provenance** block; `additionalProperties:false` everywhere = operational **rows-only (R-FND-2)**. `ratel-tools/schema_loader.py` (referencing Registry by `$id`) + `ratel-tools/tests/test_schema.py` (schemas lint · valid rows pass · invalid rejected: enum drift `MCQ`, unknown column, missing required, non-canonical `review_status`). Added **CI `python-schema-gate`**. **`schema/schema.json` = frozen single source of truth (P0-6)** — subsequent slices hold it at zero schema change.
- **2026-06-23 · SESSION 12 · T0.1 ✓ (genesis) · CI GREEN (`5beff8a`)** — Flutter 3.44.1 scaffold (bundle `com.learnwithratel.ratel`; android/web/linux), minimal boot shell + smoke test, CI gate, `.gitignore`, README, this tracker.

## Gotchas
- `flutter analyze` (CI) FAILS on lint **infos**; `dart analyze` exits 0 on them — gate with `flutter analyze`.
- jsonschema preinstalled at **3.2.0 (Draft-7 only)** → must `-U` to ≥4.x for 2020-12 (now installed by the CI python job).
- Cross-file `$ref` resolves via a `referencing.Registry` keyed by each file's absolute `$id` (https://ratel.dev/schema/...); file paths need not match `$id`.
- 45s/command cap: SDK bootstrap + first analyze/test exceed it — resumable, re-run.
- iOS/macOS/Windows platforms NOT scaffolded yet (need mac/win runners) — additive later.

## Next-queue
1. **T1.1** Dart models — codegen immutable models (freezed + json_serializable via build_runner) from `schema/` for the 9 tables; round-trip (json→model→json) test per entity. Add deps to `pubspec.yaml` (freezed, json_annotation, build_runner, json_serializable, freezed_annotation). Wire `flutter analyze`/`flutter test` + (optionally) a CI codegen-drift check (`build_runner build` then `git diff --exit-code`).
2. **T1.2** local loader/repository — reads versioned batch JSON, validates each row vs the schema contract, NO DB; valid loads / invalid fails closed → **★ Ckpt B**.
3. **T2.1–2.3** Python pipeline (generate→jury→deterministic validators→12-axis gate w/ pinned MeCab/UniDic·Jieba·ICU, F1≥0.95) → **Ckpt C**.
4. **T3.1–3.5** pilot seeds EN·ES·TA·JA + B1 (zero schema change vs frozen schema.json) → **★ Ckpt D schema lock**.

## SCORE / RETRO
- **SCORE (S12):** **2 increments shipped (T0.1, T0.2)** · 0 CI failures · 0 avoidable retries · clean handoff.
- **RETRO:** main setup cost = Flutter VM install (2 legs, recipe captured). Resolved: jsonschema Draft-7→≥4.x; cross-file `$ref` via referencing Registry. Schema design read only Part C + R-C12 (surgical, kept context lean).

## Kickoff line (next session)
"Read `Project_R/PROJECT_STATE.md` + `Apps/RATEL_PROJECT_STATE.md` (SESSION 12), then proceed with **T1.1 (freezed models codegen from schema.json)** in auto mode — TDD, CI-green before done. The schema is FROZEN (Ckpt A): generate Dart from it, do not change it." (VM wipes: re-install Flutter + re-clone per the resume playbook.)
