# Stage 2 (Modern UI/UX) — R-O1 Phase-Exit Gate · checks 4–6

> Companion to `docs/SCHEMA_LOCK.md` (which signed checks **1–3** at the Stage-1
> schema lock). This signs **checks 4–6**, closing the R-O1 6-check gate for the
> modern-UI rebuild. Local · NO DB · `schema/schema.json` frozen · requirements
> frozen at **161**. Date: 2026-06-23 (SESSION 15).

## Check 4 — every core screen renders OFF THE LOCAL LOADER (no DB)
All core surfaces build from the bundled `ContentBatch` (fail-closed
`ContentLoader`) and in-memory learner-state stubs — zero network, zero DB.

| Surface | Source | Evidence |
|---|---|---|
| Onboarding → first win | `seedBatchProvider` (real EN seed) | `test/features/onboarding_test.dart` |
| Lesson core loop + run UI | `lessonExercisesProvider` off the batch | `test/features/lesson/*` |
| Home / streak / review entry | in-memory `Streak`/`Energy` stubs | `test/features/home_test.dart`, `energy/*` |
| Adventures map + scene player | local placeholder catalog | `test/features/adventures/*` |
| App shell + tab IA | go_router `StatefulShellRoute` | `test/app/navigation_test.dart` |

**PASS** — every screen renders with no backend (R-O1 / R-FND-2).

## Check 5 — Rive + Adventures working, reduced-motion proven
- **Adventures**: 2-district map + scripted-roleplay scene player on rails
  (`ScenePlayer`); plays to completion. Evidence: `test/features/adventures/*`.
- **Mascot rig (R-L18 placeholder)**: `MascotView` is MotionTier-aware (R-N7) —
  **full → idle bob loop; reduced/static → paused pose** — and disposes its
  controller **offscreen (R-N8)**. Shown on the lesson- and scene-complete
  panels. Evidence: `test/features/mascot/mascot_view_test.dart` (both tiers).
- **`.riv` asset contract (C24)**: build-time validator rejects a bad header,
  an over-budget file, and any embedded raster (PNG/JPEG) — armed for
  `assets/rive/mascot.riv` the moment the owner drops the real vector rig.
  Evidence: `test/features/mascot/riv_contract_test.dart`.

**PASS (placeholder rig).** Owner action: author the real Duolingo-grade vector
`.riv` (State Machine + visemes) + Adventures art; then swap `RiveAnimation` into
`MascotView` behind the same MotionTier gate and verify rive web support in CI.

## Check 6 — performance gauntlet (R-N1 / R-N8)
- **Layout gauntlet**: every core screen pumped at a **360×690 cheap-phone**
  viewport with **zero overflow** (overflow = red build).
- **Animation stress**: the heaviest combo — the looping mascot + the 60-particle
  `levelUp` celebration — runs at full motion for ~12 frames with no exceptions
  and **disposes cleanly** on unmount (R-N8, no leaked controllers/timers).
- Evidence: `test/perf/perf_gauntlet_test.dart`.

**PASS (headless).** The headless gauntlet proves *structural* perf (layout +
animation correctness + dispose); the on-device **frame-timing / cold-start
bench** proves *timing* budgets. That bench is now implemented (SESSION 16):
`integration_test/perf_bench_test.dart` (cold-start boot→first frame, FrameTiming
build+raster summaries for the app shell and the heaviest mascot-loop + levelUp
combo, and mascot process RSS) is run under a PROFILE build on an Android
emulator by `.github/workflows/perf-bench.yml` via `flutter drive`, writing
`build/integration_response_data.json` as a CI artifact. That workflow is a
separate, non-required job (it never blocks `flutter-gate`) and is **gated to
skip-GREEN** when the runner lacks KVM, so it degrades cleanly.

## Verdict
**Checks 4–6 PASS** → with checks 1–3 (schema lock), the **R-O1 6-check exit gate
for Stage 2 is satisfied** (check 6's device-timing bench now
implemented as the gated `perf-bench.yml` emulator job). Stage 2 modern-UI rebuild is feature-complete on the loader:
**96 Dart tests green · `flutter analyze` clean · token-lint (R-N6) clean**.
Next per the build plan: ★ Stage-4 architecture sign-off (owner + engineers),
then Stage 3 (backend/runtime/payments, money-gated).
