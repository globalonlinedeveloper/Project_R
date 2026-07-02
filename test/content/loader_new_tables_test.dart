import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/loader/content_loader.dart';
import 'package:ratel/content/models/models.dart';

/// S96 schema increment (content-build plan §2, Option B): the loader parses the
/// three NEW curriculum tables (unit / passage / scenario), the nullable
/// grammar_point.unit_id + lesson_order columns, and the rubric + explanation
/// gloss kinds (pre-generated "Explain this"). [R-A7 · R-C1 rows-only]
void main() {
  const loader = ContentLoader();

  Map<String, dynamic> prov() => {
        'batch_id': 'batch_en_s96_test',
        'provenance': 'ai_generated',
        'review_status': 'auto_certified',
        'content_version': 1,
        'created_at': '2026-07-02T00:00:00Z',
        'updated_at': '2026-07-02T00:00:00Z',
      };

  Map<String, dynamic> batch() => {
        'batch_id': 'batch_en_s96_test',
        'locale': 'en',
        'tables': <String, dynamic>{
          'unit': [
            {
              'unit_id': 'unit_en_a1_s1_u1',
              'locale': 'en',
              'cefr_level': 'A1',
              'section_order': 1,
              'section_title_ref': 'sectiontitle_en_a1_s1',
              'unit_order': 1,
              'title_ref': 'unittitle_en_a1_s1_u1',
              'guide_ref': 'guide_en_a1_s1_u1',
              'provenance': prov(),
            }
          ],
          'grammar_point': [
            {
              'grammar_id': 'skill_en_greetings',
              'locale': 'en',
              'name': 'Greetings',
              'cefr_level': 'A1',
              'unit_id': 'unit_en_a1_s1_u1',
              'lesson_order': 1,
              'provenance': prov(),
            },
            {
              // Legacy shape: NO unit_id/lesson_order — must stay valid (CEFR fallback).
              'grammar_id': 'skill_en_legacy',
              'locale': 'en',
              'name': 'Legacy lesson',
              'cefr_level': 'A1',
              'provenance': prov(),
            },
          ],
          'passage': [
            {
              'passage_id': 'passage_en_a1_story_0001',
              'locale': 'en',
              'kind': 'story',
              'title_ref': 'passagetitle_en_a1_0001',
              'cefr_level': 'A1',
              'sentence_refs': ['sentence_en_0001'],
              'provenance': prov(),
            }
          ],
          'scenario': [
            {
              'scenario_id': 'scenario_en_a1_cafe',
              'locale': 'en',
              'kind': 'roleplay',
              'title_ref': 'scenariotitle_en_a1_cafe',
              'cefr_level': 'A1',
              'goal_ref': 'goal_en_a1_cafe',
              'scenes': [
                {
                  'scene_id': 's1',
                  'speaker': 'barista',
                  'line_sentence_ref': 'sentence_en_0001',
                  'choices': [
                    {'label_ref': 'choicelabel_en_1', 'next_scene_id': 's2', 'is_correct': true}
                  ],
                },
              ],
              'provenance': prov(),
            }
          ],
          'item': [
            {
              'item_id': 'item_en_0001',
              'locale': 'en',
              'exercise_type': 'mcq',
              'prompt_ref': 'prompt_en_0001',
              'answer_spec': {
                'accepted': ['I am']
              },
              'options': [
                {'option_id': 'a', 'text': 'I am', 'is_correct': true, 'explain_ref': 'expl_en_0001_a'},
                {'option_id': 'b', 'text': 'I is', 'explain_ref': 'expl_en_0001_b'},
                {'option_id': 'c', 'text': 'I are', 'explain_ref': 'expl_en_0001_c'},
              ],
              'skill_ids': ['skill_en_greetings'],
              'cefr_level': 'A1',
              'provenance': prov(),
            },
            {
              // Legacy item: NO options — synthesized choices keep working.
              'item_id': 'item_en_0002',
              'locale': 'en',
              'exercise_type': 'translate',
              'prompt_ref': 'prompt_en_0002',
              'answer_spec': {
                'accepted': ['you are']
              },
              'skill_ids': ['skill_en_greetings'],
              'cefr_level': 'A1',
              'provenance': prov(),
            },
          ],
          'gloss': [
            {
              'content_id': 'item_en_0001',
              'content_kind': 'explanation',
              'ui_locale': 'en',
              'text': 'We say "am" with "I" — I am, you are.',
              'provenance': prov(),
            },
            {
              'content_id': 'expl_en_0001_b',
              'content_kind': 'explanation',
              'ui_locale': 'en',
              'text': '"I is" is wrong: "is" goes with he/she/it, never "I".',
              'provenance': prov(),
            },
            {
              'content_id': 'item_en_0002',
              'content_kind': 'rubric',
              'ui_locale': 'en',
              'text': 'Use 2 sentences; include a greeting.',
              'provenance': prov(),
            },
          ],
        },
      };

  test('unit/passage/scenario rows parse; rowCount counts them', () {
    final b = loader.loadMap(batch());
    expect(b.units.single.unitId, 'unit_en_a1_s1_u1');
    expect(b.units.single.sectionOrder, 1);
    expect(b.units.single.guideRef, 'guide_en_a1_s1_u1');
    expect(b.passages.single.kind, PassageKind.story);
    expect(b.scenarios.single.kind, ScenarioKind.roleplay);
    expect(b.scenarios.single.scenes, hasLength(1));
    expect(b.rowCount, 10); // 1 unit + 2 grammar + 1 passage + 1 scenario + 2 item + 3 gloss
  });

  test('grammar_point.unit_id + lesson_order are nullable (legacy batches valid)', () {
    final b = loader.loadMap(batch());
    final wired = b.grammar.firstWhere((g) => g.grammarId == 'skill_en_greetings');
    final legacy = b.grammar.firstWhere((g) => g.grammarId == 'skill_en_legacy');
    expect(wired.unitId, 'unit_en_a1_s1_u1');
    expect(wired.lessonOrder, 1);
    expect(legacy.unitId, isNull);
    expect(legacy.lessonOrder, isNull);
  });

  test('authored MCQ options parse; per-option explain_refs present; legacy item null', () {
    final b = loader.loadMap(batch());
    final mcq = b.items.firstWhere((i) => i.itemId == 'item_en_0001');
    final legacy = b.items.firstWhere((i) => i.itemId == 'item_en_0002');
    expect(mcq.options, hasLength(3));
    expect(mcq.options!.first['option_id'], 'a');
    expect(mcq.options!.first['is_correct'], true);
    expect(mcq.options!.map((o) => o['explain_ref']).whereType<String>(),
        hasLength(3), reason: 'EVERY option carries its own Explain-this ref');
    expect(legacy.options, isNull);
  });

  test('rubric + explanation gloss kinds decode', () {
    final b = loader.loadMap(batch());
    expect(b.glosses.map((g) => g.contentKind),
        containsAll([ContentKind.explanation, ContentKind.rubric]));
  });

  test('loader stays fail-closed: unknown table + unknown unit column reject', () {
    final unknownTable = batch();
    (unknownTable['tables'] as Map<String, dynamic>)['made_up'] = <Object>[];
    expect(() => loader.loadMap(unknownTable), throwsA(isA<BatchLoadException>()));

    final badUnit = batch();
    (((badUnit['tables'] as Map<String, dynamic>)['unit'] as List).first
        as Map<String, dynamic>)['sneaky'] = 1;
    expect(() => loader.loadMap(badUnit), throwsA(isA<BatchLoadException>()));
  });
}
