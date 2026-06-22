import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/loader/content_loader.dart';

const prov =
    '{"batch_id":"b","provenance":"ai_generated","review_status":"auto_certified",'
    '"content_version":1,"created_at":"2026-06-23T00:00:00Z","updated_at":"2026-06-23T00:00:00Z"}';

String batch(String tablesBody) => '{"batch_id":"batch_t","locale":"en","tables":{$tablesBody}}';

void main() {
  const loader = ContentLoader();

  test('valid multi-table batch loads (string)', () {
    final b = loader.loadString(batch(
        '"sentence":[{"sentence_id":"sentence_x1","locale":"en","target_text":"Hi.",'
        '"tokens":[{"surface":"Hi"},{"surface":"."}],"cefr_level":"A1","provenance":$prov}],'
        '"item":[{"item_id":"item_x1","locale":"en","exercise_type":"cloze","prompt_ref":"prompt_x1",'
        '"skill_ids":["skill_x"],"cefr_level":"A1","provenance":$prov}]'));
    expect(b.batchId, 'batch_t');
    expect(b.sentences.length, 1);
    expect(b.items.length, 1);
    expect(b.rowCount, 2);
    expect(b.items.first.exerciseType.name, 'cloze');
  });

  test('valid batch loads from the seed fixture file', () {
    final src = File('assets/content/en/seed_demo.batch.json').readAsStringSync();
    final b = loader.loadString(src);
    expect(b.locale, 'en');
    expect(b.rowCount, 3);
    expect(b.locales.single.code, 'en');
    expect(b.sentences.single.tokens.length, 4);
  });

  test('FAIL CLOSED: one bad row rejects the whole batch (no partial load)', () {
    expect(
      () => loader.loadString(batch(
          '"sentence":[{"sentence_id":"sentence_ok","locale":"en","target_text":"ok",'
          '"tokens":[{"surface":"ok"}],"cefr_level":"A1","provenance":$prov},'
          '{"sentence_id":"sentence_bad","locale":"en","target_text":"bad",'
          '"tokens":[{"surface":"x"}],"cefr_level":"ZZ","provenance":$prov}]')),
      throwsA(isA<BatchLoadException>()),
    );
  });

  test('FAIL CLOSED: missing required field', () {
    expect(
      () => loader.loadString(batch('"item":[{"item_id":"i","locale":"en","cefr_level":"A1","provenance":$prov}]')),
      throwsA(isA<BatchLoadException>()),
    );
  });

  test('FAIL CLOSED: unknown column (rows-only) rejected', () {
    expect(
      () => loader.loadString(batch(
          '"gloss":[{"content_id":"sense_x","content_kind":"sense","ui_locale":"en","text":"x","provenance":$prov,"surprise":1}]')),
      throwsA(isA<BatchLoadException>()),
    );
  });

  test('FAIL CLOSED: unknown table rejected', () {
    expect(() => loader.loadString('{"batch_id":"b","tables":{"widgets":[]}}'),
        throwsA(isA<BatchLoadException>()));
  });

  test('FAIL CLOSED: malformed JSON', () {
    expect(() => loader.loadString('{not json'), throwsA(isA<BatchLoadException>()));
  });

  test('FAIL CLOSED: missing batch_id', () {
    expect(() => loader.loadString('{"tables":{}}'), throwsA(isA<BatchLoadException>()));
  });

  test('empty tables load to zero rows', () {
    expect(loader.loadString('{"batch_id":"b","tables":{}}').rowCount, 0);
  });
}
