import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/loader/content_loader.dart';
import 'package:ratel/content/models/models.dart' show ExerciseType;
import 'package:ratel/features/lesson/engine/exercise_builder.dart';

const _prov =
    '{"batch_id":"t","provenance":"authored","review_status":"auto_certified",'
    '"content_version":1,"created_at":"2026-01-01T00:00:00Z",'
    '"updated_at":"2026-01-01T00:00:00Z"}';

String _batchJson() => '''
{
  "batch_id": "t",
  "tables": {
    "sentence": [
      {"sentence_id":"s1","locale":"en","target_text":"I eat bread.",
       "tokens":[{"surface":"I"},{"surface":"eat"},{"surface":"bread"}],
       "cefr_level":"A1","provenance":$_prov}
    ],
    "gloss": [
      {"content_id":"g1","content_kind":"sense","ui_locale":"en","text":"to eat","provenance":$_prov}
    ],
    "item": [
      {"item_id":"i_mcq","locale":"en","exercise_type":"mcq","prompt_ref":"p1",
       "answer_spec":{"accepted":["eat"]},"skill_ids":["sk1"],"cefr_level":"A1","provenance":$_prov},
      {"item_id":"i_cloze","locale":"en","exercise_type":"cloze","prompt_ref":"p2",
       "answer_spec":{"accepted":["eat"]},"skill_ids":["sk1"],"cefr_level":"A1","provenance":$_prov},
      {"item_id":"i_speak","locale":"en","exercise_type":"speak","prompt_ref":"p3",
       "answer_spec":{"accepted":["eat"]},"skill_ids":["sk1"],"cefr_level":"A1","provenance":$_prov}
    ]
  }
}
''';

void main() {
  final batch = const ContentLoader().loadString(_batchJson());

  test('builds gradable mcq/cloze exercises; skips non-selection types', () {
    final exercises = buildLessonExercises(batch);
    // speak is skipped in this slice -> only mcq + cloze
    expect(exercises.length, 2);
    expect(exercises.map((e) => e.type),
        containsAll([ExerciseType.mcq, ExerciseType.cloze]));
  });

  test('answer + options come off the batch; option set contains the answer', () {
    final e = buildLessonExercises(batch).first;
    expect(e.accepted, contains('eat'));
    expect(e.options, contains('eat'));
    expect(e.options.length, greaterThanOrEqualTo(2));
  });

  test('prompt falls back to a blanked sentence when no prompt gloss exists', () {
    final e = buildLessonExercises(batch).first;
    expect(e.prompt, contains('___'));
    expect(e.prompt.toLowerCase(), isNot(contains('eat')));
  });

  test('why-card uses the sense gloss in the templated fallback', () {
    final e = buildLessonExercises(batch).first;
    expect(e.whyCard, contains('to eat'));
    expect(e.whyCard, isNotEmpty);
  });
}
