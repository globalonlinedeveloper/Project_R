# Project_R (Ratel) — Build State
> session-craft tracker. Read FIRST each session. Newest status on top. Durable = this git remote + the owner's mounted `Apps/` folder. The VM resets every session.

## Header
- **Repo:** https://github.com/globalonlinedeveloper/Project_R (default `main`)
- **Stage 1 progress:** Phase 0 (scaffold/schema) ✓ · Phase 1 (models+loader) ✓ [Ckpt A+B] · Phase 2 (pipeline) ✓ [T2.1–T2.3, **Ckpt C**] → next Phase 3 seeds (**Ckpt D**). **Autonomy:** L1.
- **Invariants:** local-only · **NO DB** · **subscription-only generation (NO metered API)** · Supabase untouched · `Apps/RATEL_REQUIREMENTS.md` frozen at **161** · `schema/schema.json` FROZEN (Ckpt A) — generate from it, zero schema change.
- **Stack:** Flutter 3.44.1 / Dart 3.12.1 · freezed 4.0.0-dev.3 + json_serializable 6.14 · Python 3 · JSON-Schema 2020-12 · Riverpod · go_router · Drift (Stage 2+).
- **Planning (mounted, canonical):** `Apps/tasks/SPEC.md` · `plan.md` · `todo.md` · `idea-cheap-phone-champion.md` · `Apps/RATEL_REQUIREMENTS.md` (WHAT) · `Apps/RATEL_PROJECT_STATE.md` (master).

## Resume playbook (VM)
- **Flutter (resumable, §18):** `git clone --depth 1 -b 3.44.1 https://github.com/flutter/flutter.git /tmp/flutter`; `export PATH=/tmp/flutter/bin:$PATH; export PUB_CACHE=/tmp/.pub-cache; flutter --version` (re-run till Dart SDK done).
- **Python:** `pip install --break-system-packages -r ratel-tools/requirements.txt` (jsonschema/referencing/pytest + fugashi·unidic-lite·jieba·regex; first `jieba` use builds its cache ~10s — pre-warm in its own leg).
- **Clone+build:** `git clone …/Project_R.git $HOME/work/Project_R` → `flutter pub get` → `dart run build_runner build` (regenerates gitignored `.freezed/.g`).
- **Secrets:** `Apps/.cowork-private/secrets.env` (GITHUB_PAT…) — `source` per shell; NEVER print/commit.
- **Token-safe push:** `source <secrets>; git -c credential.helper='!f(){ echo username=globalonlinedeveloper; echo "password=$GITHUB_PAT"; }; f' push origin main`
- **Disk:** SDK+PUB_CACHE on `/`; clone on `/sessions`. File tools can't reach `/sessions` clones → author via heredocs.
- **Gate:** CI = `flutter-gate` (build_runner→analyze→test→build web) + `python-schema-gate` (pytest: schema+pipeline · model-drift). "Done"=CI green. Poll `/commits/<sha>/check-runs?cb=<ts>`.
- **Run pipeline:** `cd ratel-tools && python3 -m pipeline.run --locale en --type mcq --count 3` (dry-run) / `--out path` to write a batch.

## Increment log (newest first)
- **2026-06-23 · S12 · T2.3 ✓ (★ Ckpt C) · CI GREEN (`f05be1f`)** — 12-axis gate + pinned tokenizers. `pipeline/tokenizers.py` (fugashi+unidic-lite JA · jieba ZH · regex UAX-29 · ICU optional TH) + `boundary_f1`; `pipeline/axis_gate.py` runs the 12 break-point axes (boundary-F1≥0.95 · graphemes==UAX-29 · plurals==CLDR · answer_spec · locale flags · structural rows-only) → per-axis report, wired into `run.main` (emits a *gated* batch). `requirements.txt` pinned; CI installs it. 11 new tests → **28 python green**.
- **2026-06-23 · S12 · T2.2 ✓ · CI GREEN (`4107e2f`)** — deterministic R-E4 validators in `pipeline/validate.py` (schema · length · script/charset + tokens[] coverage · no-leak · back-translation hook); `run_validators` wired into the gate + post-emit guard; 7 validator tests (each pass+fail) → 17 python green.
- **2026-06-23 · S12 · T2.1 ✓ · CI GREEN (`3268dcc`)** — subscription-only generation/QA pipeline scaffold `ratel-tools/pipeline/` (generate→jury→validate→confidence gate→versioned JSON). Network-free seams (`StubGenerator`/`StubJury`; real subscription content enters at `generate`; **no metered API**). Reuses frozen `schema_loader` to validate output; gate publishes only `auto_certified` (needs_review held for regen, D1). CLI dry-run emits a gated EN batch; 6 pipeline tests (offline/deterministic) + 4 schema green.
- **2026-06-23 · S12 · T1.2 ✓ (★ Ckpt B) · CI GREEN (`71e63d7`)** — web-safe fail-closed `ContentLoader` → typed `ContentBatch`; `build.yaml` `checked`+`disallow_unrecognized_keys`; seed fixture; 9 loader tests.
- **2026-06-23 · S12 · T1.1 ✓ · CI GREEN (`129deb5`)** — schema→Dart freezed models via `codegen_dart.py`; `.freezed/.g` gitignored+built in CI; schema→Dart drift gate.
- **2026-06-23 · S12 · T0.2 ✓ (★ Ckpt A) · CI GREEN (`37ad252`)** — modular JSON-Schema 2020-12 (9 tables+enums+open-containers+provenance); rows-only; conformance gate. **schema.json frozen.**
- **2026-06-23 · S12 · T0.1 ✓ (genesis) · CI GREEN (`5beff8a`)** — Flutter scaffold + CI gate.

## Gotchas
- Pipeline = **subscription-only**: never add a metered-API call in `generate`/`jury`; keep tests offline (no network).
- Loader stays **web-safe** (no `dart:io` in `lib/`; gate builds web). json_serializable: `explicit_to_json` + `disallow_unrecognized_keys` + `checked` in `build.yaml`.
- `flutter analyze` (CI) fails on lint infos. freezed 4.x = `@freezed abstract class X with _$X`. `freezed_annotation` re-exports `json_annotation`.
- jsonschema preinstalled 3.2.0 (Draft-7) → `-U` ≥4.x. 45s/cmd cap → SDK bootstrap + first build_runner resumable.
- Hyphenated `ratel-tools` isn't a Python package → tests `sys.path.insert` the dir, then `import schema_loader` / `from pipeline... import`.
- iOS/macOS/Windows platforms not scaffolded (need mac/win runners). ruff/mypy not yet in CI (pytest is the gate) — optional add.

## Next-queue
1. **T3.1–3.5** pilot seeds — EN (A1–A2 + A1–C2 spine) · ES · TA (non-Latin + graphemes[]) · JA (CJK; boundary-F1 ≥ 0.95 via fugashi) · B1 divergence slice. Each: author a batch JSON, run it through `run_validators` + the 12-axis `gate_batch`, **zero schema change** (the loader/schema_loader prove no new column) → **★ Ckpt D schema lock**: 12 axes pass on EN·ES·TA·JA + B1 → signed checklist (authorizes fan-out + the Stage-3 DB). Tip: the StubGenerator emits items only — author seed sentences/locale/gloss rows by hand (or extend the generator) so axes 1/3/4/6/7/11 are exercised.

## SCORE / RETRO
- **SCORE (S12):** **7 increments shipped (T0.1, T0.2, T1.1, T1.2, T2.1, T2.2, T2.3)** · 0 CI failures · 1 local red→green (explicit_to_json) · 0 avoidable retries.
- **RETRO:** seam-first pipeline (Protocols + stubs) keeps "subscription-only" enforceable and tests offline/deterministic; reusing schema_loader to validate pipeline output ties the whole chain to the one frozen contract.

## Kickoff line (next session)
"Read `Project_R/PROJECT_STATE.md` + `Apps/RATEL_PROJECT_STATE.md` (SESSION 12), then proceed with **T3.1 (EN pilot seed → validate + 12-axis gate)**, then T3.2–T3.5 → ★ Ckpt D schema lock, in auto mode — TDD, CI-green before done. Schema FROZEN; NO DB; subscription-only (no metered API)." (VM wipes: re-install Flutter + Python deps, re-clone, pub get + build_runner.)
