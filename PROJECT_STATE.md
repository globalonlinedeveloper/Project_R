# Project_R (Ratel) — Build State
> session-craft tracker. Read FIRST each session. Newest status on top. Durable stores = this git remote + the owner's mounted `Apps/` folder. The VM resets every session.

## Header
- **Repo:** https://github.com/globalonlinedeveloper/Project_R (default branch `main`)
- **Stage:** 1 (Foundation) · **Autonomy:** L1 (auto within scope)
- **Invariants:** local-only · **NO DB** · subscription-only generation · Supabase untouched · `Apps/RATEL_REQUIREMENTS.md` frozen at **161** (do NOT re-open) · `schema/schema.json` FROZEN (Ckpt A) — generate from it, hold at zero schema change
- **Stack:** Flutter 3.44.1 / Dart 3.12.1 · freezed 4.0.0-dev.3 + json_serializable 6.14 · Python 3 pipeline · JSON-Schema 2020-12 · Riverpod · go_router · Drift (Stage 2+)
- **Planning docs (mounted, canonical):** `Apps/tasks/SPEC.md` (HOW) · `plan.md` · `todo.md` · `idea-cheap-phone-champion.md` · `Apps/RATEL_REQUIREMENTS.md` (WHAT) · `Apps/RATEL_PROJECT_STATE.md` (master tracker)

## Resume playbook (VM)
- **Flutter (not preinstalled; resumable, §18):** `git clone --depth 1 --single-branch -b 3.44.1 https://github.com/flutter/flutter.git /tmp/flutter`; `export PATH=/tmp/flutter/bin:$PATH; export PUB_CACHE=/tmp/.pub-cache; flutter --version` (re-run until Dart SDK done).
- **Python:** `pip install --break-system-packages -U "jsonschema>=4.20" "referencing>=0.30" pytest` (preinstalled jsonschema 3.2.0 is Draft-7 only).
- **Clone:** `git clone https://github.com/globalonlinedeveloper/Project_R.git $HOME/work/Project_R` → `flutter pub get` → `dart run build_runner build` (regenerates the gitignored `.freezed/.g` parts) before analyze/test.
- **Secrets:** `Apps/.cowork-private/secrets.env` (GITHUB_PAT…) — `source` per shell; NEVER print/commit.
- **Token-safe push:** `source <secrets>; git -c credential.helper='!f(){ echo username=globalonlinedeveloper; echo "password=$GITHUB_PAT"; }; f' push origin main`
- **Disk:** SDK+PUB_CACHE on `/` (~4.1G); clone on `/sessions` (`$HOME`). **File tools can't reach `/sessions` clones — author repo files via bash heredocs.**
- **Gate:** `.github/workflows/ci.yml` = `flutter-gate` (build_runner → analyze → test → build web) + `python-schema-gate` (schema lint · fixtures · model-drift). "Done" = CI green. Poll `/commits/<sha>/check-runs?cb=<ts>`.

## Increment log (newest first)
- **2026-06-23 · SESSION 12 · T1.1 ✓ · CI GREEN (`129deb5`)** — schema → Dart freezed models. `ratel-tools/codegen_dart.py` emits `lib/content/models/{enums,payloads,tables,models}.dart` (9 entities + 16 enums + payload/provenance classes) from `schema/` (SoT). freezed 4 + json_serializable (`build.yaml` `explicit_to_json:true`); `.freezed/.g` gitignored, built in CI. 9 round-trip tests + smoke green; analyze clean. CI: build_runner step + **schema→Dart drift gate** (regenerate, `git diff --exit-code`).
- **2026-06-23 · SESSION 12 · T0.2 ✓ (★ Ckpt A) · CI GREEN (`37ad252`)** — modular JSON-Schema 2020-12 under `schema/`: 9 Part-C tables + R-C12 enums + open-container defs + R-C10 provenance; `additionalProperties:false` = rows-only (R-FND-2). `schema_loader.py` + conformance tests; CI python-schema-gate. **schema.json = frozen SoT.**
- **2026-06-23 · SESSION 12 · T0.1 ✓ (genesis) · CI GREEN (`5beff8a`)** — Flutter 3.44.1 scaffold (bundle `com.learnwithratel.ratel`; android/web/linux) + CI gate + tracker.

## Gotchas
- `flutter analyze` (CI) fails on lint **infos**; gate with it (not `dart analyze`).
- json_serializable: nested freezed objects need **`explicit_to_json: true`** (build.yaml) or `toJson` leaks child objects → round-trip cast error. (Hit + fixed in T1.1.)
- freezed 4.x syntax = `@freezed abstract class X with _$X {...}`. `freezed_annotation` re-exports `json_annotation` (so models import only freezed_annotation; enums import json_annotation).
- `build_runner build` no longer takes `--delete-conflicting-outputs` (removed; deletes by default).
- jsonschema preinstalled 3.2.0 (Draft-7) → `-U` to ≥4.x. 45s/cmd cap → SDK bootstrap + first build_runner are resumable; re-run.
- iOS/macOS/Windows platforms not scaffolded yet (need mac/win runners).

## Next-queue
1. **T1.2** local loader/repository — read a versioned batch JSON (envelope: version/locale/rows[]), parse each row into the typed models (structural validate via fromJson), **fail closed** on any bad row (reject the batch + log the offender; never load partial), NO DB. Tests: valid batch loads; invalid fails closed → **★ Ckpt B** (model + loader proven on a fixture).
2. **T2.1–2.3** Python pipeline (generate→jury→deterministic validators→12-axis gate, pinned MeCab/UniDic·Jieba·ICU, F1≥0.95) → **Ckpt C**.
3. **T3.1–3.5** pilot seeds EN·ES·TA·JA + B1 (zero schema change) → **★ Ckpt D schema lock**.

## SCORE / RETRO
- **SCORE (S12):** **3 increments shipped (T0.1, T0.2, T1.1)** · 0 CI failures (1 local red→green: explicit_to_json) · 0 avoidable retries.
- **RETRO:** schema→Dart via a generator (not hand-models) keeps the SoT honest + enables the drift gate. explicit_to_json was the one trap. Probing freezed syntax with a 1-class build before generating all 9 saved a rework loop.

## Kickoff line (next session)
"Read `Project_R/PROJECT_STATE.md` + `Apps/RATEL_PROJECT_STATE.md` (SESSION 12), then proceed with **T1.2 (local loader, fail-closed)** in auto mode — TDD, CI-green before done. Schema is FROZEN." (VM wipes: re-install Flutter, re-clone, `flutter pub get` + `dart run build_runner build` per the resume playbook.)
