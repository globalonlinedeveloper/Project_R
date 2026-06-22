# Project_R (Ratel) — Build State
> session-craft tracker. Read FIRST each session. Newest status on top. Durable stores = this git remote + the owner's mounted `Apps/` folder. The VM resets every session.

## Header
- **Repo:** https://github.com/globalonlinedeveloper/Project_R (default branch `main`)
- **Stage:** 1 (Foundation) · **Autonomy:** L1 (auto within scope)
- **Invariants:** local-only · **NO DB** · subscription-only generation · Supabase untouched · `Apps/RATEL_REQUIREMENTS.md` frozen at **161** (do NOT re-open)
- **Stack:** Flutter 3.44.1 / Dart 3.12.1 · Python 3 pipeline · JSON-Schema 2020-12 · Riverpod · go_router · Drift (Stage 2+) · freezed codegen from schema.json
- **Planning docs (mounted, canonical):** `Apps/tasks/SPEC.md` (HOW) · `Apps/tasks/plan.md` · `Apps/tasks/todo.md` · `Apps/tasks/idea-cheap-phone-champion.md` (strategy) · `Apps/RATEL_REQUIREMENTS.md` (WHAT) · `Apps/RATEL_PROJECT_STATE.md` (master tracker)

## Resume playbook (VM)
- **Toolchain (not preinstalled — install resumably, session-craft §18):**
  `git clone --depth 1 --single-branch -b 3.44.1 https://github.com/flutter/flutter.git /tmp/flutter`
  `export PATH=/tmp/flutter/bin:$PATH; export PUB_CACHE=/tmp/.pub-cache; flutter --version` (re-run until the Dart SDK finishes; ~2 legs under the 45s cap).
- **Clone:** `git clone https://github.com/globalonlinedeveloper/Project_R.git $HOME/work/Project_R`
- **Secrets:** `Apps/.cowork-private/secrets.env` (GITHUB_PAT + others) — `source` per shell call; NEVER print/echo/commit.
- **Token-safe push:** `source <secrets>; git -c credential.helper='!f(){ echo username=globalonlinedeveloper; echo "password=$GITHUB_PAT"; }; f' push origin main`
- **Disk:** SDK + PUB_CACHE on `/` (~4.1G free); clone on `/sessions` (`$HOME`, ~2.6G). **File tools CANNOT reach `/sessions` clones — author repo files via bash heredocs.**
- **Gate:** `.github/workflows/ci.yml` (analyze + test + build web). "Done" = CI green.

## Increment log (newest first)
- **2026-06-23 · SESSION 12 · T0.1 ✓ (genesis)** — provisioned Flutter 3.44.1/Dart 3.12.1 in the VM; `flutter create` scaffold (project `ratel`, bundle `com.learnwithratel.ratel`, platforms android/web/linux); replaced the counter demo with a minimal boot shell (`boot-marker`) + smoke test; **local `flutter analyze` clean + `flutter test` green**; added CI gate, hardened `.gitignore`, README, this tracker. **CI GREEN** (run on 5beff8a)

## Gotchas
- `flutter analyze` (what CI runs) FAILS on lint **infos**; `dart analyze` exits 0 on them — always gate with `flutter analyze`.
- Shallow `-b <tag>` clone here KEPT the tag (`git describe`=3.44.1). If a future clone reports `0.0.0`: `git -C /tmp/flutter tag -f 3.44.1 HEAD; rm -f /tmp/flutter/bin/cache/flutter.version.json`.
- 45s/command cap: SDK bootstrap + first analyze/test exceed it — resumable, just re-run.
- iOS/macOS/Windows platforms NOT scaffolded yet (need mac/win runners) — add in a later increment (additive `flutter create --platforms`).
- Planning docs not yet mirrored into repo `tasks/` (stale-mount copy risk) — canonical copies stay in `Apps/`.

## Next-queue
1. **T0.2** `schema/schema.json` — modular per-table files via `$ref` (tables + 4 open-container payloads + R-C12 enums), JSON-Schema 2020-12 + Python `jsonschema` fixtures (valid passes / invalid rejected) → **Ckpt A** freeze.
2. **T1.1** freezed/json_serializable models codegen from schema (round-trip tests) → **T1.2** local loader (validate rows, fail closed) → **Ckpt B**.
3. **T2.1–2.3** Python pipeline (generate→jury→validators→12-axis gate, pinned tokenizers) → **Ckpt C**.
4. **T3.1–3.5** pilot seeds EN·ES·TA·JA+B1 (zero schema change) → **★ Ckpt D schema lock**.

## SCORE / RETRO
- **SCORE (S12):** 1 increment shipped (T0.1) · 0 CI failures · 0 avoidable retries · clean handoff.
- **RETRO:** Flutter VM install (2 legs under the 45s cap) was the main setup cost — resumable recipe captured in the resume playbook. Gotcha: jsonschema preinstalled at 3.2.0 (Draft-7 only) -> T0.2 must force-upgrade to >=4.x for JSON-Schema-2020-12.

## Kickoff line (next session)
"Read Project_R/PROJECT_STATE.md + Apps/RATEL_PROJECT_STATE.md (SESSION 12), then proceed with T0.2 (schema.json) in auto mode — TDD, CI-green before done."
