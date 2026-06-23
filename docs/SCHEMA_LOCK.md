# ★ Checkpoint D — SCHEMA LOCK (Stage-1 finale)

**Status: MET (automated evidence) — 2026-06-23, Session 12.**
Authorizes content fan-out beyond the pilot + the Stage-3 backend DB (still owner + money-gated behind the Stage-4 architecture sign-off, R-O1).

## The lock condition
> The 12 break-point axes pass on the pilot set **EN · ES · TA · JA + a B1 divergence slice**, with **zero schema change** against the frozen `schema/schema.json` (Ckpt A).

## Evidence (CI-gated, reproducible)
- **Seeds:** `assets/content/{en,es,ta,ja,_pilot}/seed.batch.json` (authored via `ratel-tools/author_seeds.py`; JA tokens are fugashi/UniDic-aligned, TA `graphemes[]` are UAX-29 — conformant by construction).
- **Zero schema change:** every seed row validates against the frozen `schema.json` via `schema_loader` (each table is `additionalProperties:false`, so any new column = hard fail). Schema untouched since Ckpt A (`37ad252`).
- **12-axis gate:** `ratel-tools/pipeline/axis_gate.py` — `tests/test_schema_lock.py` asserts every pilot seed passes and the union of the pilot set passes all 12 axes.
- **Loader:** `test/content/seed_load_test.dart` loads all five seeds through the fail-closed `ContentLoader` (CJK tokens + Tamil grapheme clusters + pair-specific items preserved).
- **Gates green:** `python-schema-gate` (35 tests) + `flutter-gate` (23 tests).

## The 12 axes × where exercised
| # | Axis | Predicate | Pilot proof |
|---|---|---|---|
| 1 | no-space tokenization | boundary-F1 ≥ 0.95 vs fugashi/Jieba | JA `水を飲みました` |
| 2 | inflection | `lemma_ref` + `features{}` | EN `eat`/`reads` |
| 3 | grapheme clusters | `graphemes[]` == UAX-29 | TA `நாய்` → நா · ய் |
| 4 | directionality | `direction ∈ {ltr,rtl}` | all locale rows |
| 5 | tone / pitch / stress | `prosody{}` | JA pitch-accent LHHHL |
| 6 | pronunciation capability | `pron_tier ∈ {asr,shadowing}` | TA shadowing, JA asr |
| 7 | TTS coverage | `tts_tier ∈ {hd,basic,none}` | TA basic, others hd |
| 8 | gloss / pivot (both non-EN) | `(content_id, ui_locale)` → sense | ES sense glossed in TA UI |
| 9 | pair-specific depth | `source_locale` + `contrast_type` | ES translate_from_l1; B1 false_friend / l1_interference |
| 10 | answer equivalence | `answer_spec` parses | EN/ES/JA items |
| 11 | plurals / gender / counters | CLDR `plural_categories` | en[one,other] · es[one,many,other] · ja[other] |
| 12 | exercise N/A | feature-absent = zero rows | structural (rows-only) |

## Delivers R-O1 exit-gate checks 1–3
1. **schema lock** ✓ · 2. **pipeline proven** ✓ (generate→jury→validate→12-axis gate) · 3. **seed conforms** ✓.
Checks 4–6 (modern UI on the loader · Adventures + Rive · perf budgets) = **Stage 2**.

## Owner sign-off
The automated lock is MET. Final human sign-off (owner) confirms the pilot is representative before large-scale fan-out — recorded here when given.

---

## ▶ 2026-06-23 (Session 19) — Stage-3 extension: content schema stays LOCKED; user tables UN-FROZEN (scoped · reversible)

**Authorization.** Per the Session-18 owner directive ("push to full automation") and the agent-reviewed
`docs/STAGE3_LOCAL_BUILD_BACKLOG.md` (item **L0**), the Ckpt-D freeze is lifted for **one scoped, additive purpose only**:
authoring the Stage-3 **user/runtime tables** (finding **P0-2**) into the single source of truth so that
Part-D `pg_dump diff = 0` and the entitlement/credit + per-table RLS become locally provable.

**Scope of the unfreeze (precise).**
- **STILL FROZEN — the 9 content tables** (`sentence, vocab_entry, sense, grammar_point, phoneme, item, locale, media_asset, gloss`).
  The Ckpt-D lock condition above (12 axes pass at zero content-schema change) remains MET and is unaffected; the
  content seeds keep validating `additionalProperties:false` against the unchanged content schemas.
- **NOW EDITABLE — additive only — the 7 user tables** (`user, user_course, user_item_state, user_phoneme_state,
  placement_session, review_log, credit_ledger`, per R-G6/R-J3/R-J7/R-M). These are **NEW** `additionalProperties:false`
  table schemas; no existing content table is modified.

**Guardrails.** LOCAL only · no live Supabase · every change reversible via `git revert` · **requirements stay frozen at 161**
(the user tables are Stage-3 **schema additions**, NOT new product requirements) · subscription-only.

**Tooling pin.** `ratel-tools/requirements-dev.txt` adds the dev-only local DB harness (`pgserver`, `pg8000`) used by the
Part-D / RLS tests. It is not a runtime dependency and is never deployed.

**Reversal.** `git revert` the L1–L7 commits (and this note) restores the fully-frozen Ckpt-D state.
