import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/loader/content_loader.dart';
import 'package:ratel/content/spine/content_course_spine.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// CI-only: the INF-2.5 projection — authored `item.options[]` + the authored
/// "Explain this" texts (per-option `explain_ref` + item-level
/// `content_id == item_id` glosses, `content_kind: explanation`) surface on
/// [CourseExercise] for the runner, straight from the REAL en batch.
// [R-D10 · R-B4] authored MCQ options + pre-generated explanation projection.
void main() {
  const ContentLoader loader = ContentLoader();
  ContentBatch loadEn() => loader.loadString(
      File('assets/content/en/course.batch.json').readAsStringSync());

  List<CourseExercise> pathExercises(CourseSpine spine) => <CourseExercise>[
        for (final CourseUnit u in spine.units)
          for (final CourseLesson l in u.lessons) ...l.exercises,
      ];

  test('authored options[] project: texts, exactly-one-correct, explains', () {
    final CourseSpine spine = buildCourseSpine(loadEn());
    final List<CourseExercise> mcqs = <CourseExercise>[
      for (final CourseExercise e in pathExercises(spine))
        if (e.exerciseType == 'mcq' && e.options.isNotEmpty) e,
    ];
    expect(mcqs, isNotEmpty,
        reason: 'the EN course carries authored mcq options');
    for (final CourseExercise e in mcqs) {
      expect(e.options.length, greaterThanOrEqualTo(2), reason: e.id);
      expect(e.options.where((CourseOption o) => o.isCorrect).length, 1,
          reason: '${e.id} must carry exactly one correct option');
      expect(e.options.every((CourseOption o) => o.text.isNotEmpty), true,
          reason: e.id);
      // Owner rule (S96): EVERY option ships a pre-generated explanation.
      expect(
          e.options.every((CourseOption o) => (o.explain ?? '').isNotEmpty),
          true,
          reason: '${e.id} options need resolved explain_ref glosses');
      // The authored accepted[0] IS the correct option's text.
      expect(e.accepted.first,
          e.options.firstWhere((CourseOption o) => o.isCorrect).text,
          reason: e.id);
    }
  });

  test('U2 About You wave projects as the 2nd authored unit (S97)', () {
    final CourseSpine spine = buildCourseSpine(loadEn());
    expect(spine.units.length, greaterThanOrEqualTo(2));
    final CourseUnit u2 = spine.units[1];
    expect(u2.section, 'SECTION 1 · FOUNDATIONS');
    expect(u2.title, 'About You');
    expect(u2.guideText, isNotNull);
    expect(u2.lessons.map((CourseLesson l) => l.id).toList(), <String>[
      'skill_en_a1_s1u2_l1',
      'skill_en_a1_s1u2_l2',
      'skill_en_a1_s1u2_l3',
      'skill_en_a1_s1u2_l4',
    ]);
    for (final CourseLesson l in u2.lessons) {
      expect(l.exercises.length, 7, reason: l.id);
      expect(l.exercises.any((CourseExercise e) => e.exerciseType == 'listen'),
          true, reason: '${l.id} needs a listen exercise');
    }
  });

  test('item-level explanations key by the ITEM id (plan §2) and project', () {
    final CourseSpine spine = buildCourseSpine(loadEn());
    final List<CourseExercise> all = pathExercises(spine);
    expect(all, isNotEmpty);
    expect(
        all.every((CourseExercise e) => (e.explain ?? '').isNotEmpty), true,
        reason: 'every EN path exercise carries its authored explanation '
            '(S97 re-key: gloss content_id == item_id)');
    // The legacy ES course authored neither options nor explanations — the
    // projection must stay empty/null there (typed path, byte-identical).
    final CourseSpine es = buildCourseSpine(loader.loadString(
        File('assets/content/es/course.batch.json').readAsStringSync()));
    for (final CourseExercise e in pathExercises(es)) {
      expect(e.options, isEmpty, reason: '${e.id} (ES) has no authored bank');
      expect(e.explain, isNull, reason: '${e.id} (ES) has no explanation');
    }
  });
}
