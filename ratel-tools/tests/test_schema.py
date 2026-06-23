"""T0.2 schema-contract tests (TDD): schemas lint; valid rows pass; invalid rows
(rows-only violations, enum drift, missing required) are rejected."""
import sys
import pathlib

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from schema_loader import TABLES, check_all_schemas, validate_row  # noqa: E402

PROV = {
    "batch_id": "batch_en_0001", "provenance": "ai_generated",
    "review_status": "auto_certified", "content_version": 1,
    "created_at": "2026-06-23T00:00:00Z", "updated_at": "2026-06-23T00:00:00Z",
}

VALID = {
    "sentence": {"sentence_id": "sentence_en_0001", "locale": "en", "target_text": "I eat bread.",
                 "tokens": [{"surface": "I"}, {"surface": "eat", "lemma_ref": "vocab_eat_en"},
                            {"surface": "bread"}, {"surface": "."}], "cefr_level": "A1", "provenance": PROV},
    "vocab_entry": {"vocab_id": "vocab_eat_en", "locale": "en", "lemma": "eat", "pos": "verb",
                    "frequency_rank": 120, "cefr_level": "A1", "provenance": PROV},
    "sense": {"sense_id": "sense_bank_finance", "vocab_id": "vocab_bank_en", "pos": "noun",
              "examples": ["sentence_en_0001"], "provenance": PROV},
    "grammar_point": {"grammar_id": "grammar_ja_te_form", "locale": "ja", "name": "te-form",
                      "cefr_level": "A2", "concept_refs": ["concept_verb_conjugation"],
                      "feature_tags": {"aspect": "connective"}, "provenance": PROV},
    "phoneme": {"phoneme_id": "ph_th_05", "locale": "th", "ipa_symbol": "kʰ",
                "features": {"place": "velar", "manner": "plosive", "aspiration": True}, "provenance": PROV},
    "item": {"item_id": "item_es_0001", "locale": "es", "exercise_type": "translate", "enum_version": 1,
             "prompt_ref": "prompt_es_0001",
             "answer_spec": {"accepted": ["el bebé", "el bebe"],
                             "normalization_flags": {"strip_diacritics": True, "fold_case": True, "unicode_norm": "NFC"}},
             "skill_ids": ["skill_es_articles"], "cefr_level": "A1", "source_locale": "en",
             "contrast_type": "translate_from_l1", "direction": "l1_to_l2", "provenance": PROV},
    "locale": {"code": "ja", "name": "Japanese", "direction": "ltr", "plural_categories": ["other"],
               "script_meta": {"script": "Jpan", "uses_spaces": False}, "tts_tier": "hd",
               "pron_tier": "asr", "pron_method": "asr", "cefr_ceiling": "B2"},
    "media_asset": {"asset_id": "media_00x91", "type": "audio", "uri": "r2://audio/ja/00x91.v1.ogg",
                    "locale": "ja", "voice_id": "ja-JP-Chirp3-HD-Aoede", "tts_tier": "hd",
                    "duration_ms": 1840, "provenance": PROV},
    "gloss": {"content_id": "sense_dog_es", "content_kind": "sense", "ui_locale": "ta",
              "text": "நாய்", "provenance": PROV},
    "user": {"user_id": "11111111-1111-1111-1111-111111111111", "created_at": "2026-06-23T00:00:00Z", "updated_at": "2026-06-23T00:00:00Z", "pro_until": "2026-12-31T00:00:00Z", "fsrs_weights": [0.4, 0.6, 2.4, 5.8], "ui_locale": "en", "timezone": "Asia/Kolkata", "daily_goal_xp": 30},
    "user_course": {"user_course_id": "22222222-2222-2222-2222-222222222222", "user_id": "11111111-1111-1111-1111-111111111111", "target_locale": "es", "ui_locale": "en", "theta_per_skill": {"skill_es_articles": 0.5}, "cefr_target": "A1", "xp_total": 120, "created_at": "2026-06-23T00:00:00Z", "updated_at": "2026-06-23T00:00:00Z"},
    "user_item_state": {"user_item_state_id": "33333333-3333-3333-3333-333333333333", "user_id": "11111111-1111-1111-1111-111111111111", "item_id": "item_es_0001", "stability": 12.5, "difficulty": 5.0, "due": "2026-06-30T00:00:00Z", "last_review": "2026-06-23T00:00:00Z", "reps": 3, "lapses": 0, "scheduled_days": 7, "state": "review", "created_at": "2026-06-23T00:00:00Z", "updated_at": "2026-06-23T00:00:00Z"},
    "user_phoneme_state": {"user_phoneme_state_id": "44444444-4444-4444-4444-444444444444", "user_id": "11111111-1111-1111-1111-111111111111", "phoneme_id": "ph_th_05", "locale": "th", "mastery": 0.8, "attempts": 5, "last_score": 0.9, "due": "2026-06-30T00:00:00Z", "created_at": "2026-06-23T00:00:00Z", "updated_at": "2026-06-23T00:00:00Z"},
    "placement_session": {"placement_session_id": "55555555-5555-5555-5555-555555555555", "user_id": "11111111-1111-1111-1111-111111111111", "target_locale": "es", "started_at": "2026-06-23T00:00:00Z", "completed_at": "2026-06-23T00:10:00Z", "theta_estimate": 0.3, "se_estimate": 0.4, "items_administered": 12, "result_cefr": "A2", "responses": [{"item_id": "item_es_0001", "correct": True}], "created_at": "2026-06-23T00:00:00Z"},
    "review_log": {"review_log_id": "66666666-6666-6666-6666-666666666666", "user_id": "11111111-1111-1111-1111-111111111111", "item_id": "item_es_0001", "reviewed_at": "2026-06-23T00:00:00Z", "rating": 3, "state": "review", "elapsed_days": 5, "scheduled_days": 7, "stability_after": 15.0, "difficulty_after": 5.1, "duration_ms": 3400},
    "credit_ledger": {"credit_ledger_id": "77777777-7777-7777-7777-777777777777", "user_id": "11111111-1111-1111-1111-111111111111", "entry_type": "grant", "amount": 5, "balance_after": 5, "grant_source": "daily_free", "client_event_id": "88888888-8888-8888-8888-888888888888", "reason": "first daily free", "created_at": "2026-06-23T00:00:00Z"},
}

# Each invalid case must produce >= 1 validation error.
INVALID = [
    ("sentence", {k: v for k, v in VALID["sentence"].items() if k != "tokens"}, "missing required tokens[]"),
    ("sentence", {**VALID["sentence"], "extra_col": 1}, "rows-only: unknown column rejected"),
    ("sentence", {**VALID["sentence"], "cefr_level": "A9"}, "bad cefr_level enum"),
    ("item", {**VALID["item"], "exercise_type": "MCQ"}, "enum drift (MCQ vs mcq)"),
    ("item", {**VALID["item"], "answer_spec": {"accepted": ["x"], "normalization_flags": {"lowercase": True}}}, "unknown normalization flag"),
    ("locale", {**VALID["locale"], "direction": "sideways"}, "bad text_direction"),
    ("locale", {**VALID["locale"], "plural_categories": ["lots"]}, "bad CLDR plural category"),
    ("gloss", {**VALID["gloss"], "content_kind": "footnote"}, "bad content_kind"),
    ("sentence", {**VALID["sentence"], "provenance": {**PROV, "review_status": "approved"}}, "review_status must be the canonical 5-state"),
    ("item", {k: v for k, v in VALID["item"].items() if k != "exercise_type"}, "missing required exercise_type"),
    ("user", {**VALID["user"], "is_admin": True}, "rows-only: unknown column on user"),
    ("user_course", {**VALID["user_course"], "secret": 1}, "rows-only: unknown column on user_course"),
    ("user_item_state", {**VALID["user_item_state"], "foo": 1}, "rows-only: unknown column on user_item_state"),
    ("user_phoneme_state", {**VALID["user_phoneme_state"], "foo": 1}, "rows-only: unknown column on user_phoneme_state"),
    ("placement_session", {**VALID["placement_session"], "foo": 1}, "rows-only: unknown column on placement_session"),
    ("review_log", {**VALID["review_log"], "foo": 1}, "rows-only: unknown column on review_log"),
    ("credit_ledger", {**VALID["credit_ledger"], "foo": 1}, "rows-only: unknown column on credit_ledger"),
    ("user_item_state", {**VALID["user_item_state"], "state": "mastered"}, "bad fsrs_state enum"),
    ("review_log", {**VALID["review_log"], "rating": 9}, "rating out of 1..4 range"),
    ("credit_ledger", {**VALID["credit_ledger"], "entry_type": "chargeback"}, "bad ledger_entry_type enum"),
]


def test_all_schemas_lint():
    problems = check_all_schemas()
    assert problems == [], f"invalid schema files: {problems}"


def test_every_table_has_a_valid_fixture():
    assert set(VALID) == set(TABLES), "every table needs a valid fixture"


def test_valid_rows_pass():
    for table, row in VALID.items():
        errs = validate_row(table, row)
        assert errs == [], f"{table} valid row rejected: {errs}"


def test_invalid_rows_rejected():
    for table, row, why in INVALID:
        errs = validate_row(table, row)
        assert errs, f"{table} should have failed ({why}) but passed"


if __name__ == "__main__":
    fns = [test_all_schemas_lint, test_every_table_has_a_valid_fixture, test_valid_rows_pass, test_invalid_rows_rejected]
    failed = 0
    for fn in fns:
        try:
            fn()
            print(f"PASS  {fn.__name__}")
        except AssertionError as e:
            failed += 1
            print(f"FAIL  {fn.__name__}: {e}")
    sys.exit(1 if failed else 0)
