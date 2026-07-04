import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/loader/content_loader.dart';
import 'package:ratel/content/models/models.dart';
import 'package:ratel/content/spine/content_course_spine.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// CI-only (needs build_runner content models): loads the authored ES course
/// batch through the fail-closed loader and asserts the batch→spine projection.
// [R-B3 · R-A7] content-driven path projection + authored CEFR course coverage.
void main() {
  const ContentLoader loader = ContentLoader();
  ContentBatch loadCourse() => loader.loadString(
      File('assets/content/es/course.batch.json').readAsStringSync());

  test('ES course batch loads + projects into CEFR units with real lessons', () {
    final CourseSpine spine = buildCourseSpine(loadCourse());
    expect(spine.courseCode, 'es');
    // Six authored grammar points → six lesson nodes across A1 + A2.
    expect(spine.lessonCount, 7); // +Colores (A1, S94)
    expect(spine.units.length, 2);
    // The authored Colores lesson (S94) projects into the A1 unit.
    final CourseLesson colors =
        spine.lessons.firstWhere((CourseLesson l) => l.title == 'Colores');
    expect(colors.cefr, 'A1');
    expect(colors.exerciseCount, 5); // 2 mcq + 2 translate + 1 authored listen
    expect(
      colors.exercises.any((CourseExercise e) => e.exerciseType == 'listen'),
      true,
    );
    expect(spine.units.first.section, 'SECTION 1 · LEVEL A1');
    expect(spine.units.last.title, 'Level A2');
  });

  test('a lesson carries its REAL items: prompt resolved + accepted answers', () {
    final CourseSpine spine = buildCourseSpine(loadCourse());
    final CourseLesson greetings =
        spine.lessons.firstWhere((CourseLesson l) => l.title == 'Saludos');
    expect(greetings.cefr, 'A1');
    expect(greetings.exerciseCount, 3); // mcq + translate + authored listen
    // The authored Listen item (S93) projects into the REAL spine.
    expect(
      greetings.exercises.any((CourseExercise e) => e.exerciseType == 'listen'),
      true,
    );
    final CourseExercise first = greetings.exercises.first;
    expect(first.prompt.isNotEmpty, true); // prompt_ref resolved via gloss
    expect(first.accepted, contains('hola'));
    expect(first.irtB, isNotNull); // carries IRT difficulty for the CAT engine
  });

  test('lessons are ordered A1 before A2 (CEFR band order)', () {
    final CourseSpine spine = buildCourseSpine(loadCourse());
    expect(spine.units.first.lessons.every((CourseLesson l) => l.cefr == 'A1'), true);
    expect(spine.units.last.lessons.every((CourseLesson l) => l.cefr == 'A2'), true);
  });

  // ---- S96: unit-driven Level→Section→Unit→Lesson projection (plan §3.2) ----

  Map<String, dynamic> prov() => <String, dynamic>{
        'batch_id': 'batch_en_s96_spine_test',
        'provenance': 'ai_generated',
        'review_status': 'auto_certified',
        'content_version': 1,
        'created_at': '2026-07-02T00:00:00Z',
        'updated_at': '2026-07-02T00:00:00Z',
      };
  Map<String, dynamic> gp(String id, String cefr, {String? unitId, int? order}) =>
      <String, dynamic>{
        'grammar_id': id,
        'locale': 'en',
        'name': id,
        'cefr_level': cefr,
        'unit_id': ?unitId,
        'lesson_order': ?order,
        'provenance': prov(),
      };
  Map<String, dynamic> unitRow(String id, int so, int uo, {String? guideRef}) =>
      <String, dynamic>{
        'unit_id': id,
        'locale': 'en',
        'cefr_level': 'A1',
        'section_order': so,
        'section_title_ref': 'sectiontitle_s$so',
        'unit_order': uo,
        'title_ref': 'unittitle_$id',
        'guide_ref': ?guideRef,
        'provenance': prov(),
      };
  Map<String, dynamic> glossRow(String cid, String text) => <String, dynamic>{
        'content_id': cid,
        'content_kind': 'instruction',
        'ui_locale': 'en',
        'text': text,
        'provenance': prov(),
      };
  ContentBatch unitBatch() => loader.loadMap(<String, dynamic>{
        'batch_id': 'batch_en_s96_spine_test',
        'locale': 'en',
        'tables': <String, dynamic>{
          // Units authored deliberately OUT of order — projection must follow
          // (section_order, unit_order), never authored file order.
          'unit': <Map<String, dynamic>>[
            unitRow('unit_en_u2', 1, 2),
            unitRow('unit_en_u1', 1, 1, guideRef: 'guide_en_u1'),
            unitRow('unit_en_u3', 2, 1),
          ],
          'grammar_point': <Map<String, dynamic>>[
            gp('skill_en_l2', 'A1', unitId: 'unit_en_u1', order: 2),
            gp('skill_en_l1', 'A1', unitId: 'unit_en_u1', order: 1),
            gp('skill_en_l3', 'A1', unitId: 'unit_en_u2'),
            gp('skill_en_l4', 'A1', unitId: 'unit_en_u3'),
            gp('skill_en_legacy', 'A2'), // NO unit_id → CEFR fallback
          ],
          'gloss': <Map<String, dynamic>>[
            glossRow('sectiontitle_s1', 'SECTION 1 · FOUNDATIONS'),
            glossRow('sectiontitle_s2', 'SECTION 2 · DAILY LIFE'),
            glossRow('unittitle_unit_en_u1', 'First Words'),
            glossRow('unittitle_unit_en_u2', 'People & Things'),
            glossRow('unittitle_unit_en_u3', 'Around Town'),
            glossRow('guide_en_u1', 'Welcome! In this unit you learn to greet people.'),
          ],
        },
      });

  test('authored unit rows project the REAL curriculum in pure data order', () {
    final CourseSpine spine = buildCourseSpine(unitBatch());
    // 3 authored units + 1 CEFR-fallback unit for the legacy grammar point.
    expect(spine.units.length, 4);
    expect(spine.units[0].title, 'First Words'); // unit_order 1 (authored 2nd)
    expect(spine.units[0].section, 'SECTION 1 · FOUNDATIONS');
    expect(spine.units[1].title, 'People & Things');
    expect(spine.units[1].section, 'SECTION 1 · FOUNDATIONS'); // shared section
    expect(spine.units[2].title, 'Around Town');
    expect(spine.units[2].section, 'SECTION 2 · DAILY LIFE');
    // Lessons within a unit follow lesson_order, not authored order.
    expect(spine.units[0].lessons.map((CourseLesson l) => l.id).toList(),
        <String>['skill_en_l1', 'skill_en_l2']);
  });

  test('grammar points w/o unit_id fall back to a CEFR band APPENDED after', () {
    final CourseSpine spine = buildCourseSpine(unitBatch());
    final CourseUnit fallback = spine.units.last;
    expect(fallback.section, 'SECTION 4 · LEVEL A2'); // numbering continues
    expect(fallback.title, 'Level A2');
    expect(fallback.lessons.single.id, 'skill_en_legacy');
    expect(fallback.guideText, isNull);
  });

  test('the 📖 Guide resolves through the gloss layer (pre-generated content)', () {
    final CourseSpine spine = buildCourseSpine(unitBatch());
    expect(spine.units[0].guideText, contains('Welcome!'));
    expect(spine.units[1].guideText, isNull); // no guide authored on u2
  });

  // ---- S96 PROOF WAVE: the REAL authored EN course batch (A1 S1 U1) ----

  test('EN proof wave: en/course.batch.json loads + projects the authored curriculum', () {
    final ContentBatch en = loader.loadString(
        File('assets/content/en/course.batch.json').readAsStringSync());
    expect(en.rowCount, greaterThanOrEqualTo(3050)); // A1 (S1+S2) + A2 S1 (S98); grows per wave
    final CourseSpine spine = buildCourseSpine(en);
    expect(spine.courseCode, 'en');
    final CourseUnit u1 = spine.units.first;
    expect(u1.section, 'SECTION 1 · FOUNDATIONS'); // authored section title gloss
    expect(u1.title, 'First Words'); // authored unit title gloss
    expect(u1.guideText, isNotNull); // 📖 Guide authored (pre-generated)
    // 4 lessons in lesson_order, every lesson 6-7 exercises incl. a listen.
    expect(u1.lessons.map((CourseLesson l) => l.id).toList(), <String>[
      'skill_en_a1_s1u1_l1',
      'skill_en_a1_s1u1_l2',
      'skill_en_a1_s1u1_l3',
      'skill_en_a1_s1u1_l4',
    ]);
    for (final CourseLesson l in u1.lessons) {
      // Graded drill exercises are 6-7 per lesson + 1 listen; Guided-Writing
      // (`write`) items are ADDITIONAL and exempt from these invariants (INF-5).
      final List<CourseExercise> drill = <CourseExercise>[
        for (final CourseExercise e in l.exercises)
          if (e.exerciseType != 'write') e,
      ];
      expect(drill.length, inInclusiveRange(6, 7), reason: l.id);
      expect(drill.any((CourseExercise e) => e.exerciseType == 'listen'),
          true, reason: '${l.id} needs a listen exercise');
      // Every non-listen exercise has a resolved, non-empty prompt gloss.
      expect(
          l.exercises.every((CourseExercise e) =>
              e.exerciseType == 'listen' || e.prompt.isNotEmpty),
          true,
          reason: '${l.id} has an unresolved prompt_ref');
    }
    // Ownership: surface-owned items (story checks, roleplay turns) never leak
    // onto the path. Guided-Writing `write` items DO now surface via their own
    // renderer (INF-5) -- graded by rubric_spec, not answer_spec.accepted.
    final Set<String> pathItemIds = <String>{
      for (final CourseLesson l in u1.lessons)
        for (final CourseExercise e in l.exercises) e.id,
    };
    expect(pathItemIds.contains('item_en_a1_s1u1_chk_1'), false);
    expect(pathItemIds.contains('item_en_a1_s1u1_meet_1'), false);
    expect(pathItemIds.contains('item_en_a1_s1u1_write_1'), true);
    // The write item projects with its display rubric + resolved required words.
    final CourseExercise writeEx = <CourseExercise>[
      for (final CourseLesson l in u1.lessons)
        for (final CourseExercise e in l.exercises)
          if (e.id == 'item_en_a1_s1u1_write_1') e,
    ].single;
    expect(writeEx.exerciseType, 'write');
    expect(writeEx.rubric, isNotNull);
    expect(writeEx.requiredWords, containsAll(<String>['hello', 'name']));
    // Every NON-write path exercise is gradable-as-data (accepted answers).
    expect(
        <CourseExercise>[
          for (final CourseLesson l in u1.lessons) ...l.exercises
        ]
            .where((CourseExercise e) => e.exerciseType != 'write')
            .every((CourseExercise e) => e.accepted.isNotEmpty),
        true,
        reason: 'every non-write PATH exercise must be gradable-as-data');

    // Word-bank hygiene: listen phrases tokenize clean (no trailing period tile).
    final Iterable<CourseExercise> listens = <CourseExercise>[
      for (final CourseLesson l in u1.lessons)
        ...l.exercises.where((CourseExercise e) => e.exerciseType == 'listen'),
    ];
    expect(listens.every((CourseExercise e) => !e.accepted.first.endsWith('.')),
        true);
    expect(
        listens.every(
            (CourseExercise e) => e.accepted.first.split(' ').length >= 2),
        true);
  });

  // ---- S96 type-sample set: ONE of EVERY content type, verified DYNAMICALLY
  // (loops over whatever rows exist — no hardcoded structure counts). ----

  test('type-sample: every passage/scenario/write row is coherent + all kinds covered', () {
    final ContentBatch en = loader.loadString(
        File('assets/content/en/course.batch.json').readAsStringSync());
    final Set<String> sentenceIds = <String>{
      for (final Sentence s in en.sentences) s.sentenceId
    };
    final Set<String> itemIds = <String>{for (final Item i in en.items) i.itemId};
    final Map<String, Gloss> glossById = <String, Gloss>{
      for (final Gloss g in en.glosses) g.contentId: g
    };

    // (1) Passages: all three kinds authored; EVERY ref resolves.
    expect({for (final Passage p in en.passages) p.kind},
        {PassageKind.story, PassageKind.podcast, PassageKind.video});
    for (final Passage p in en.passages) {
      expect(glossById.containsKey(p.titleRef), true, reason: p.passageId);
      for (final String sr in p.sentenceRefs) {
        expect(sentenceIds.contains(sr), true, reason: '$sr of ${p.passageId}');
      }
      for (final String cr in p.checkItemRefs ?? const <String>[]) {
        expect(itemIds.contains(cr), true, reason: 'check $cr of ${p.passageId}');
      }
      final String? er = p.explainRef;
      if (er != null) expect(glossById.containsKey(er), true);
      if (p.kind == PassageKind.video) {
        // Watch (INF-9): a video passage carries EITHER the legacy storyline
        // PROMPT (the S96 sample) OR a real video_ref -> media_asset MP4 (the
        // authored Watch lessons). At least one must be present.
        final bool hasPrompt =
            p.videoPrompt != null && p.videoPrompt!.trim().isNotEmpty;
        expect(hasPrompt || p.videoRef != null, true, reason: p.passageId);
      }
      if (p.kind == PassageKind.story) {
        // R-B4: every story line carries a pre-baked per-line explain gloss.
        for (final String sr in p.sentenceRefs) {
          expect(glossById[sr]?.contentKind, ContentKind.explanation,
              reason: 'per-line explain missing for $sr');
        }
        expect(p.checkItemRefs, isNotNull); // 1-3 comprehension checks
        expect(p.checkItemRefs!.length, inInclusiveRange(1, 3));
      }
    }

    // (2) Scenarios: both kinds; scenes fully wired; branching targets exist.
    expect({for (final Scenario sc in en.scenarios) sc.kind},
        {ScenarioKind.roleplay, ScenarioKind.adventure});
    for (final Scenario sc in en.scenarios) {
      expect(glossById.containsKey(sc.titleRef), true, reason: sc.scenarioId);
      expect(glossById.containsKey(sc.goalRef), true, reason: sc.scenarioId);
      final Set<String> sceneIds = <String>{
        for (final Map<String, Object?> m in sc.scenes) m['scene_id']! as String
      };
      for (final Map<String, Object?> m in sc.scenes) {
        expect(sentenceIds.contains(m['line_sentence_ref']! as String), true);
        final String? turn = m['turn_item_ref'] as String?;
        if (turn != null) {
          expect(itemIds.contains(turn), true,
              reason: 'R-D10 embedded atomic item $turn');
        }
        for (final Object? c in (m['choices'] as List<Object?>? ?? const <Object?>[])) {
          final Map<String, Object?> cm =
              Map<String, Object?>.from(c! as Map<Object?, Object?>);
          expect(glossById.containsKey(cm['label_ref']! as String), true);
          final String? next = cm['next_scene_id'] as String?;
          if (next != null) {
            expect(sceneIds.contains(next), true,
                reason: 'branch target $next of ${sc.scenarioId}');
          }
        }
      }
      if (sc.kind == ScenarioKind.roleplay) {
        // Multi-speaker + a GRADED player turn + a header rubric (R-D10).
        expect({for (final m in sc.scenes) m['speaker']! as String}.length,
            greaterThan(1));
        expect(sc.scenes.any((m) => m['turn_item_ref'] != null), true);
        expect(sc.rubricRef, isNotNull);
        expect(glossById[sc.rubricRef!]?.contentKind, ContentKind.rubric);
      }
    }

    // (3) Guided Writing: machine rubric + display rubric + explanation.
    final List<Item> writes = <Item>[
      for (final Item i in en.items)
        if (i.exerciseType == ExerciseType.write) i
    ];
    expect(writes, isNotEmpty);
    for (final Item w in writes) {
      expect(w.rubricSpec, isNotNull, reason: 'R-D11 #45 machine rubric');
      expect(w.rubricSpec!['min_tokens'], isA<int>());
      expect(glossById.containsKey(w.promptRef), true);
    }
    expect(
        en.glosses.any((Gloss g) => g.contentKind == ContentKind.rubric), true);
  });

  test('INF-6: passages(kind=story) project into spine.stories; podcast/video do not', () {
    final ContentBatch en = loader.loadString(
        File('assets/content/en/course.batch.json').readAsStringSync());
    final CourseSpine spine = buildCourseSpine(en);

    // Only kind=story projects (podcasts/video stay the owner-gated media type).
    final int storyCount =
        en.passages.where((Passage p) => p.kind == PassageKind.story).length;
    expect(storyCount, greaterThan(0));
    expect(spine.stories.length, storyCount);

    final CourseStory st = spine.stories.first;
    // sentence_refs resolved to their target_text (non-empty, in order).
    expect(st.sentences, isNotEmpty);
    expect(st.sentences.every((String s) => s.trim().isNotEmpty), true);
    expect(st.title.trim(), isNotEmpty);
    expect(st.cefr, isNotEmpty);
    // Comprehension checks project as gradable exercises...
    expect(st.checkExercises, isNotEmpty);
    // ...and those SAME check items never ALSO leak onto the learning path.
    final Set<String> pathItemIds = <String>{
      for (final CourseUnit u in spine.units)
        for (final CourseLesson l in u.lessons)
          for (final CourseExercise e in l.exercises) e.id,
    };
    for (final CourseExercise e in st.checkExercises) {
      expect(pathItemIds.contains(e.id), false,
          reason: 'story check ${e.id} leaked onto the path');
    }
  });

  test('INF-7: podcasts(kind=podcast + audio_ref) project into spine.podcasts '
      'with the audio_ref resolved to a media_asset uri', () {
    Map<String, dynamic> sentRow(String id, String text) => <String, dynamic>{
          'sentence_id': id,
          'locale': 'en',
          'target_text': text,
          'tokens': <dynamic>[],
          'cefr_level': 'A1',
          'provenance': prov(),
        };
    final ContentBatch b = loader.loadMap(<String, dynamic>{
      'batch_id': 'batch_en_inf7_spine_test',
      'locale': 'en',
      'tables': <String, dynamic>{
        'media_asset': <Map<String, dynamic>>[
          <String, dynamic>{
            'asset_id': 'aud_a1',
            'type': 'audio',
            'uri': 'https://pub-xyz.r2.dev/podcasts/a1.mp3',
            'tts_tier': 'hd',
            'duration_ms': 14000,
            'provenance': prov(),
          },
        ],
        'sentence': <Map<String, dynamic>>[
          sentRow('sen_a1_1', 'I wake up at seven.'),
          sentRow('sen_a1_2', 'I drink coffee.'),
          sentRow('sen_story', 'She walks to school.'),
        ],
        'item': <Map<String, dynamic>>[
          <String, dynamic>{
            'item_id': 'it_a1',
            'locale': 'en',
            'exercise_type': 'mcq',
            'prompt_ref': 'prm_a1',
            'skill_ids': <String>['none'],
            'cefr_level': 'A1',
            'options': <Map<String, dynamic>>[
              <String, dynamic>{'text': 'Seven', 'is_correct': true},
              <String, dynamic>{'text': 'Nine', 'is_correct': false},
            ],
            'provenance': prov(),
          },
        ],
        'gloss': <Map<String, dynamic>>[
          glossRow('pt_a1', 'My Morning'),
          glossRow('prm_a1', 'When does she wake up?'),
          glossRow('stt', 'Her First Day'),
        ],
        'passage': <Map<String, dynamic>>[
          <String, dynamic>{
            'passage_id': 'pod_a1',
            'locale': 'en',
            'kind': 'podcast',
            'title_ref': 'pt_a1',
            'cefr_level': 'A1',
            'theme': 'a daily routine',
            'sentence_refs': <String>['sen_a1_1', 'sen_a1_2'],
            'audio_ref': 'aud_a1',
            'check_item_refs': <String>['it_a1'],
            'provenance': prov(),
          },
          // A podcast with NO audio_ref -> honestly NOT projected (can't play).
          <String, dynamic>{
            'passage_id': 'pod_noaudio',
            'locale': 'en',
            'kind': 'podcast',
            'title_ref': 'pt_a1',
            'cefr_level': 'A1',
            'sentence_refs': <String>['sen_a1_1'],
            'provenance': prov(),
          },
          // A story -> projects into spine.stories, NEVER spine.podcasts.
          <String, dynamic>{
            'passage_id': 'story_a1',
            'locale': 'en',
            'kind': 'story',
            'title_ref': 'stt',
            'cefr_level': 'A1',
            'sentence_refs': <String>['sen_story'],
            'provenance': prov(),
          },
        ],
      },
    });
    final CourseSpine spine = buildCourseSpine(b);

    // Exactly the ONE podcast carrying a resolvable audio_ref projects.
    expect(spine.podcasts.length, 1);
    final CourseStory pod = spine.podcasts.single;
    expect(pod.id, 'pod_a1');
    expect(pod.title, 'My Morning');
    // audio_ref -> media_asset.uri: a real playable URL, NEVER the content-id.
    expect(pod.audioUrl, 'https://pub-xyz.r2.dev/podcasts/a1.mp3');
    expect(pod.audioUrl, isNot('aud_a1'));
    // Transcript sentences resolved in order.
    expect(pod.sentences, <String>['I wake up at seven.', 'I drink coffee.']);
    // Comprehension check projects as a gradable exercise.
    expect(pod.checkExercises.length, 1);
    expect(pod.checkExercises.single.options.length, 2);
    // INVARIANT: every projected podcast has a non-null audioUrl.
    expect(spine.podcasts.every((CourseStory p) => p.audioUrl != null), true);
    // Kinds stay in their own surface (podcast never leaks into stories).
    expect(spine.stories.map((CourseStory s) => s.id).toList(),
        <String>['story_a1']);
    expect(spine.podcasts.map((CourseStory p) => p.id).toList(),
        <String>['pod_a1']);
    // The podcast's check item never leaks onto the learning path.
    final Set<String> pathIds = <String>{
      for (final CourseUnit u in spine.units)
        for (final CourseLesson l in u.lessons)
          for (final CourseExercise e in l.exercises) e.id,
    };
    expect(pathIds.contains('it_a1'), false);
  });

  test('INF-9: passages(kind=video + video_ref) project into spine.watch '
      'with the video_ref resolved to a media_asset uri', () {
    Map<String, dynamic> sentRow(String id, String text) => <String, dynamic>{
          'sentence_id': id,
          'locale': 'en',
          'target_text': text,
          'tokens': <dynamic>[],
          'cefr_level': 'A1',
          'provenance': prov(),
        };
    final ContentBatch b = loader.loadMap(<String, dynamic>{
      'batch_id': 'batch_en_inf9_spine_test',
      'locale': 'en',
      'tables': <String, dynamic>{
        'media_asset': <Map<String, dynamic>>[
          <String, dynamic>{
            'asset_id': 'vid_asset_a1',
            'type': 'video',
            'uri': 'https://pub-xyz.r2.dev/videos/a1.mp4',
            'duration_ms': 10006,
            'provenance': prov(),
          },
        ],
        'sentence': <Map<String, dynamic>>[
          sentRow('sen_a1_1', 'A woman pours coffee.'),
          sentRow('sen_a1_2', 'She takes a slow sip.'),
          sentRow('sen_story', 'She walks to school.'),
        ],
        'item': <Map<String, dynamic>>[
          <String, dynamic>{
            'item_id': 'it_a1',
            'locale': 'en',
            'exercise_type': 'mcq',
            'prompt_ref': 'prm_a1',
            'skill_ids': <String>['none'],
            'cefr_level': 'A1',
            'options': <Map<String, dynamic>>[
              <String, dynamic>{'text': 'Coffee', 'is_correct': true},
              <String, dynamic>{'text': 'Tea', 'is_correct': false},
            ],
            'provenance': prov(),
          },
        ],
        'gloss': <Map<String, dynamic>>[
          glossRow('pt_a1', 'Morning Coffee'),
          glossRow('prm_a1', 'What does she make?'),
          glossRow('stt', 'Her First Day'),
        ],
        'passage': <Map<String, dynamic>>[
          <String, dynamic>{
            'passage_id': 'vid_a1',
            'locale': 'en',
            'kind': 'video',
            'title_ref': 'pt_a1',
            'cefr_level': 'A1',
            'theme': 'daily routines',
            'sentence_refs': <String>['sen_a1_1', 'sen_a1_2'],
            'video_ref': 'vid_asset_a1',
            'check_item_refs': <String>['it_a1'],
            'provenance': prov(),
          },
          // A video with NO video_ref -> honestly NOT projected (can't play).
          <String, dynamic>{
            'passage_id': 'vid_noref',
            'locale': 'en',
            'kind': 'video',
            'title_ref': 'pt_a1',
            'cefr_level': 'A1',
            'sentence_refs': <String>['sen_a1_1'],
            'video_prompt': 'a legacy storyline prompt',
            'provenance': prov(),
          },
          // A video whose video_ref resolves to NO media_asset -> NOT projected.
          <String, dynamic>{
            'passage_id': 'vid_dangling',
            'locale': 'en',
            'kind': 'video',
            'title_ref': 'pt_a1',
            'cefr_level': 'A1',
            'sentence_refs': <String>['sen_a1_1'],
            'video_ref': 'missing_asset',
            'provenance': prov(),
          },
          // A story -> projects into spine.stories, NEVER spine.watch.
          <String, dynamic>{
            'passage_id': 'story_a1',
            'locale': 'en',
            'kind': 'story',
            'title_ref': 'stt',
            'cefr_level': 'A1',
            'sentence_refs': <String>['sen_story'],
            'provenance': prov(),
          },
        ],
      },
    });
    final CourseSpine spine = buildCourseSpine(b);

    // Exactly the ONE video carrying a RESOLVABLE video_ref projects.
    expect(spine.watch.length, 1);
    final CourseStory w = spine.watch.single;
    expect(w.id, 'vid_a1');
    expect(w.title, 'Morning Coffee');
    // video_ref -> media_asset.uri: a real playable URL, NEVER the content-id.
    expect(w.videoUrl, 'https://pub-xyz.r2.dev/videos/a1.mp4');
    expect(w.videoUrl, isNot('vid_asset_a1'));
    // Narration transcript resolved in order.
    expect(w.sentences,
        <String>['A woman pours coffee.', 'She takes a slow sip.']);
    // Comprehension check projects as a gradable exercise.
    expect(w.checkExercises.length, 1);
    expect(w.checkExercises.single.options.length, 2);
    // INVARIANT: every projected Watch lesson has a non-null videoUrl.
    expect(spine.watch.every((CourseStory p) => p.videoUrl != null), true);
    // Kinds stay in their own surface (video never leaks into stories/podcasts;
    // story never leaks into watch).
    expect(spine.watch.map((CourseStory p) => p.id).toList(),
        <String>['vid_a1']);
    expect(spine.stories.map((CourseStory s) => s.id).toList(),
        <String>['story_a1']);
    expect(spine.podcasts, isEmpty);
    // The video's check item never leaks onto the learning path.
    final Set<String> pathIds = <String>{
      for (final CourseUnit u in spine.units)
        for (final CourseLesson l in u.lessons)
          for (final CourseExercise e in l.exercises) e.id,
    };
    expect(pathIds.contains('it_a1'), false);
  });

  test('INF-9: the real en batch projects exactly 12 Watch lessons, each with '
      'a resolvable R2 video and no path leak', () {
    final ContentBatch en = loader.loadString(
        File('assets/content/en/course.batch.json').readAsStringSync());
    final CourseSpine spine = buildCourseSpine(en);
    // 12 authored Watch lessons (2 per level A1..C2); the legacy video-sample
    // (video_prompt only, no video_ref) is honestly excluded.
    expect(spine.watch.length, 12);
    for (final CourseStory w in spine.watch) {
      expect(w.videoUrl, isNotNull);
      expect(w.videoUrl!.startsWith('https://'), true, reason: w.id);
      expect(w.videoUrl!.endsWith('.mp4'), true, reason: w.id);
      expect(w.sentences, isNotEmpty, reason: w.id);
      expect(w.checkExercises, isNotEmpty, reason: w.id);
    }
    // 2 per CEFR level.
    final Map<String, int> byLevel = <String, int>{};
    for (final CourseStory w in spine.watch) {
      byLevel[w.cefr] = (byLevel[w.cefr] ?? 0) + 1;
    }
    expect(byLevel, <String, int>{
      'A1': 2,
      'A2': 2,
      'B1': 2,
      'B2': 2,
      'C1': 2,
      'C2': 2,
    });
    // The Watch comprehension checks never leak onto the learning path.
    final Set<String> pathIds = <String>{
      for (final CourseUnit u in spine.units)
        for (final CourseLesson l in u.lessons)
          for (final CourseExercise e in l.exercises) e.id,
    };
    for (final CourseStory w in spine.watch) {
      for (final CourseExercise e in w.checkExercises) {
        expect(pathIds.contains(e.id), false,
            reason: 'watch check ${e.id} leaked onto the path');
      }
    }
  });
}
