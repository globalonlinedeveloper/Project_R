import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/models/models.dart';

Map<String, dynamic> _j(String s) => jsonDecode(s) as Map<String, dynamic>;

const prov =
    '{"batch_id":"batch_0001","provenance":"ai_generated","review_status":"auto_certified",'
    '"content_version":1,"created_at":"2026-06-23T00:00:00Z","updated_at":"2026-06-23T00:00:00Z"}';

void rt<T>(T Function(Map<String, dynamic>) from, Map<String, dynamic> Function(T) to, String json) {
  final a = from(_j(json));
  final b = from(to(a)); // fromJson(toJson(fromJson(x))) must equal fromJson(x)
  expect(b, a);
}

void main() {
  test('Sentence round-trips (tokens[], enum, provenance)', () {
    final s = Sentence.fromJson(_j(
        '{"sentence_id":"sentence_en_0001","locale":"en","target_text":"I eat bread.",'
        '"tokens":[{"surface":"I"},{"surface":"eat","lemma_ref":"vocab_eat_en"},{"surface":"bread"},{"surface":"."}],'
        '"cefr_level":"A1","provenance":$prov}'));
    expect(s.tokens.length, 4);
    expect(s.cefrLevel, CefrLevel.a1);
    expect(s.tokens[1].lemmaRef, 'vocab_eat_en');
    expect(Sentence.fromJson(s.toJson()), s);
  });

  test('VocabEntry round-trips', () {
    rt<VocabEntry>(VocabEntry.fromJson, (x) => x.toJson(),
        '{"vocab_id":"vocab_eat_en","locale":"en","lemma":"eat","pos":"verb","frequency_rank":120,"cefr_level":"A1","provenance":$prov}');
  });

  test('Sense round-trips', () {
    rt<Sense>(Sense.fromJson, (x) => x.toJson(),
        '{"sense_id":"sense_bank_finance","vocab_id":"vocab_bank_en","pos":"noun","examples":["sentence_en_0001"],"provenance":$prov}');
  });

  test('GrammarPoint round-trips (open feature_tags map)', () {
    rt<GrammarPoint>(GrammarPoint.fromJson, (x) => x.toJson(),
        '{"grammar_id":"grammar_ja_te_form","locale":"ja","name":"te-form","cefr_level":"A2",'
        '"concept_refs":["concept_verb_conjugation"],"feature_tags":{"aspect":"connective"},"provenance":$prov}');
  });

  test('Phoneme round-trips (open features map)', () {
    rt<Phoneme>(Phoneme.fromJson, (x) => x.toJson(),
        '{"phoneme_id":"ph_th_05","locale":"th","ipa_symbol":"kʰ",'
        '"features":{"place":"velar","manner":"plosive","aspiration":true},"provenance":$prov}');
  });

  test('Item round-trips (answer_spec + normalization_flags + enums)', () {
    final i = Item.fromJson(_j(
        '{"item_id":"item_es_0001","locale":"es","exercise_type":"translate","enum_version":1,'
        '"prompt_ref":"prompt_es_0001","answer_spec":{"accepted":["el bebé","el bebe"],'
        '"normalization_flags":{"strip_diacritics":true,"fold_case":true,"unicode_norm":"NFC"}},'
        '"skill_ids":["skill_es_articles"],"cefr_level":"A1","source_locale":"en",'
        '"contrast_type":"translate_from_l1","direction":"l1_to_l2","provenance":$prov}'));
    expect(i.exerciseType, ExerciseType.translate);
    expect(i.direction, ItemDirection.l1ToL2);
    expect(i.answerSpec!.accepted, ['el bebé', 'el bebe']);
    expect(i.answerSpec!.normalizationFlags!.unicodeNorm, UnicodeNorm.nfc);
    expect(Item.fromJson(i.toJson()), i);
  });

  test('Locale round-trips (plural_categories list + script_meta)', () {
    final l = Locale.fromJson(_j(
        '{"code":"ja","name":"Japanese","direction":"ltr","plural_categories":["other"],'
        '"script_meta":{"script":"Jpan","uses_spaces":false},"tts_tier":"hd","pron_tier":"asr",'
        '"pron_method":"asr","cefr_ceiling":"B2"}'));
    expect(l.direction, TextDirection.ltr);
    expect(l.pluralCategories, [PluralCategory.other]);
    expect(l.ttsTier, TtsTier.hd);
    expect(Locale.fromJson(l.toJson()), l);
  });

  test('MediaAsset round-trips', () {
    rt<MediaAsset>(MediaAsset.fromJson, (x) => x.toJson(),
        '{"asset_id":"media_00x91","type":"audio","uri":"r2://audio/ja/00x91.v1.ogg","locale":"ja",'
        '"voice_id":"ja-JP-Chirp3-HD-Aoede","tts_tier":"hd","duration_ms":1840,"provenance":$prov}');
  });

  test('Gloss round-trips (non-Latin text)', () {
    rt<Gloss>(Gloss.fromJson, (x) => x.toJson(),
        '{"content_id":"sense_dog_es","content_kind":"sense","ui_locale":"ta","text":"நாய்","provenance":$prov}');
  });
}
