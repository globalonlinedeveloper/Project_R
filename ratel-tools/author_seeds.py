#!/usr/bin/env python3
"""T3 pilot-seed authoring helper. Builds schema-conformant seed batches for
EN·ES·TA·JA + a B1 divergence slice, with JA tokens from fugashi and TA graphemes
from UAX-29 so the 12-axis gate passes by construction. Writes
assets/content/<area>/seed.batch.json (committed artifacts; the schema-lock test
validates + gates them). Subscription-only: content is authored, not API-generated."""
from __future__ import annotations

import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from pipeline.tokenizers import graphemes_uax29, reference_segments

ROOT = pathlib.Path(__file__).resolve().parent.parent
NOW = "2026-06-23T00:00:00Z"


def prov(bid: str) -> dict:
    return {"batch_id": bid, "provenance": "ai_generated", "model_version": "subscription/seed-0",
            "review_status": "auto_certified", "content_version": 1, "created_at": NOW, "updated_at": NOW}


def tok(surface, **extra):
    return {"surface": surface, **extra}


def write(area: str, batch: dict):
    p = ROOT / "assets" / "content" / area / "seed.batch.json"
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(batch, ensure_ascii=False, indent=2), encoding="utf-8")
    n = sum(len(v) for v in batch["tables"].values())
    print(f"  wrote {p.relative_to(ROOT)} ({n} rows across {len(batch['tables'])} tables)")


# ---- EN (axes: inflection via lemma_ref/features, answer_spec, gloss, plurals) ----
en_b = "batch_en_seed_0001"
EN = {"batch_id": en_b, "schema_version": "2020-12-1", "locale": "en", "tables": {
    "locale": [{"code": "en", "name": "English", "direction": "ltr", "plural_categories": ["one", "other"],
                "script_meta": {"script": "Latn", "uses_spaces": True}, "tts_tier": "hd",
                "pron_tier": "asr", "pron_method": "asr", "cefr_ceiling": "C2"}],
    "vocab_entry": [{"vocab_id": "vocab_eat_en", "locale": "en", "lemma": "eat", "pos": "verb",
                     "frequency_rank": 120, "cefr_level": "A1", "provenance": prov(en_b)}],
    "sense": [{"sense_id": "sense_eat_consume", "vocab_id": "vocab_eat_en", "pos": "verb",
               "provenance": prov(en_b)}],
    "sentence": [
        {"sentence_id": "sentence_en_1", "locale": "en", "target_text": "I eat bread.",
         "tokens": [tok("I"), tok("eat", lemma_ref="vocab_eat_en", features={"tense": "pres"}), tok("bread"), tok(".")],
         "cefr_level": "A1", "provenance": prov(en_b)},
        {"sentence_id": "sentence_en_2", "locale": "en", "target_text": "She reads a book.",
         "tokens": [tok("She"), tok("reads", lemma_ref="vocab_read_en", features={"tense": "pres", "person": "3"}), tok("a"), tok("book"), tok(".")],
         "cefr_level": "A2", "provenance": prov(en_b)}],
    "item": [
        {"item_id": "item_en_mcq_1", "locale": "en", "exercise_type": "mcq", "enum_version": 1,
         "prompt_ref": "prompt_en_mcq_1", "answer_spec": {"accepted": ["eat"], "normalization_flags": {"fold_case": True}},
         "skill_ids": ["skill_en_present_simple"], "cefr_level": "A1", "difficulty_band": "core", "provenance": prov(en_b)},
        {"item_id": "item_en_cloze_1", "locale": "en", "exercise_type": "cloze", "enum_version": 1,
         "prompt_ref": "prompt_en_cloze_1", "answer_spec": {"accepted": ["eat"]},
         "skill_ids": ["skill_en_present_simple"], "cefr_level": "A1", "provenance": prov(en_b)}],
    "gloss": [
        {"content_id": "sense_eat_consume", "content_kind": "sense", "ui_locale": "en", "text": "to eat", "provenance": prov(en_b)},
        {"content_id": "sense_eat_consume", "content_kind": "sense", "ui_locale": "es", "text": "comer", "provenance": prov(en_b)}]}}

# ---- ES (axes: pair-specific source_locale+contrast_type, gloss pivot ES->TA UI) ----
es_b = "batch_es_seed_0001"
ES = {"batch_id": es_b, "schema_version": "2020-12-1", "locale": "es", "tables": {
    "locale": [{"code": "es", "name": "Español", "direction": "ltr", "plural_categories": ["one", "many", "other"],
                "script_meta": {"script": "Latn", "uses_spaces": True}, "tts_tier": "hd", "pron_tier": "asr", "pron_method": "asr"}],
    "vocab_entry": [{"vocab_id": "vocab_comer_es", "locale": "es", "lemma": "comer", "pos": "verb", "cefr_level": "A1", "provenance": prov(es_b)}],
    "sense": [{"sense_id": "sense_comer_eat", "vocab_id": "vocab_comer_es", "pos": "verb", "provenance": prov(es_b)}],
    "sentence": [{"sentence_id": "sentence_es_1", "locale": "es", "target_text": "Yo como pan.",
                  "tokens": [tok("Yo"), tok("como", lemma_ref="vocab_comer_es"), tok("pan"), tok(".")],
                  "cefr_level": "A1", "provenance": prov(es_b)}],
    "item": [{"item_id": "item_es_translate_1", "locale": "es", "exercise_type": "translate", "enum_version": 1,
              "prompt_ref": "prompt_es_translate_1",
              "answer_spec": {"accepted": ["yo como pan", "como pan"], "normalization_flags": {"fold_case": True, "strip_diacritics": True}},
              "skill_ids": ["skill_es_present"], "cefr_level": "A1", "source_locale": "en",
              "contrast_type": "translate_from_l1", "direction": "l1_to_l2", "provenance": prov(es_b)}],
    "gloss": [  # Spanish content shown in a Tamil UI (pivot, both non-English) + English
        {"content_id": "sense_comer_eat", "content_kind": "sense", "ui_locale": "ta", "text": "சாப்பிடு", "provenance": prov(es_b)},
        {"content_id": "sense_comer_eat", "content_kind": "sense", "ui_locale": "en", "text": "to eat", "provenance": prov(es_b)}]}}

# ---- TA (axes: non-Latin script, grapheme clusters == UAX-29) ----
ta_b = "batch_ta_seed_0001"
ta_word = "நாய்"
TA = {"batch_id": ta_b, "schema_version": "2020-12-1", "locale": "ta", "tables": {
    "locale": [{"code": "ta", "name": "தமிழ்", "direction": "ltr", "plural_categories": ["one", "other"],
                "script_meta": {"script": "Taml", "uses_spaces": True, "has_grapheme_clusters": True},
                "tts_tier": "basic", "pron_tier": "shadowing", "pron_method": "shadowing"}],
    "vocab_entry": [{"vocab_id": "vocab_naai_ta", "locale": "ta", "lemma": ta_word, "pos": "noun", "cefr_level": "A1", "provenance": prov(ta_b)}],
    "sense": [{"sense_id": "sense_naai_dog", "vocab_id": "vocab_naai_ta", "pos": "noun", "provenance": prov(ta_b)}],
    "sentence": [{"sentence_id": "sentence_ta_1", "locale": "ta", "target_text": ta_word,
                  "tokens": [tok(ta_word, lemma_ref="vocab_naai_ta")],
                  "graphemes": graphemes_uax29(ta_word), "cefr_level": "A1", "provenance": prov(ta_b)}],
    "gloss": [{"content_id": "sense_naai_dog", "content_kind": "sense", "ui_locale": "en", "text": "dog", "provenance": prov(ta_b)}]}}

# ---- JA (axes: no-space tokenization boundary-F1, tone/prosody, CJK) ----
ja_b = "batch_ja_seed_0001"
ja_text = "水を飲みました"
JA = {"batch_id": ja_b, "schema_version": "2020-12-1", "locale": "ja", "tables": {
    "locale": [{"code": "ja", "name": "日本語", "direction": "ltr", "plural_categories": ["other"],
                "script_meta": {"script": "Jpan", "uses_spaces": False}, "tts_tier": "hd",
                "pron_tier": "asr", "pron_method": "asr", "cefr_ceiling": "B2"}],
    "vocab_entry": [{"vocab_id": "vocab_nomu_ja", "locale": "ja", "lemma": "飲む", "pos": "verb", "cefr_level": "A2", "provenance": prov(ja_b)}],
    "sense": [{"sense_id": "sense_nomu_drink", "vocab_id": "vocab_nomu_ja", "pos": "verb", "provenance": prov(ja_b)}],
    "sentence": [{"sentence_id": "sentence_ja_1", "locale": "ja", "target_text": ja_text,
                  "tokens": [tok(s) for s in reference_segments("ja", ja_text)],  # fugashi-aligned
                  "prosody": {"pitch_accent": "LHHHL"}, "ipa": "mizu o nomimaɕita",
                  "cefr_level": "A2", "provenance": prov(ja_b)}],
    "item": [{"item_id": "item_ja_cloze_1", "locale": "ja", "exercise_type": "cloze", "enum_version": 1,
              "prompt_ref": "prompt_ja_cloze_1", "answer_spec": {"accepted": ["飲み"], "normalization_flags": {"accept_kana_for_kanji": True}},
              "skill_ids": ["skill_ja_past_polite"], "cefr_level": "A2", "provenance": prov(ja_b)}],
    "gloss": [{"content_id": "sense_nomu_drink", "content_kind": "sense", "ui_locale": "en", "text": "to drink", "provenance": prov(ja_b)}]}}

# ---- B1 divergence slice (axes: pair-specific depth at B1 — false_friend, l1_interference) ----
b1_b = "batch_b1_divergence_0001"
B1 = {"batch_id": b1_b, "schema_version": "2020-12-1", "locale": "es", "tables": {
    "item": [
        {"item_id": "item_es_ff_b1", "locale": "es", "exercise_type": "translate", "enum_version": 1,
         "prompt_ref": "prompt_es_ff_b1", "answer_spec": {"accepted": ["embarazada"], "normalization_flags": {"fold_case": True}},
         "skill_ids": ["skill_es_false_friends"], "cefr_level": "B1", "source_locale": "en",
         "contrast_type": "false_friend", "direction": "l1_to_l2", "provenance": prov(b1_b)},
        {"item_id": "item_ja_l1i_b1", "locale": "ja", "exercise_type": "translate", "enum_version": 1,
         "prompt_ref": "prompt_ja_l1i_b1", "answer_spec": {"accepted": ["わたしはがくせいです", "私は学生です"], "normalization_flags": {"accept_kana_for_kanji": True}},
         "skill_ids": ["skill_ja_topic_particle"], "cefr_level": "B1", "source_locale": "en",
         "contrast_type": "l1_interference", "direction": "l1_to_l2", "provenance": prov(b1_b)}]}}

print("authoring pilot seeds...")
write("en", EN); write("es", ES); write("ta", TA); write("ja", JA); write("_pilot", B1)
print("JA tokens:", [t["surface"] for t in JA["tables"]["sentence"][0]["tokens"]])
print("TA graphemes:", TA["tables"]["sentence"][0]["graphemes"])
