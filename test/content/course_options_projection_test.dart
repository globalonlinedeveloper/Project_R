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

  test('A1+A2+B1+B2+C1+C2: 72 authored units project in data order (S100)',
      () {
    final CourseSpine spine = buildCourseSpine(loadEn());
    expect(spine.units.length, 72);
    expect(spine.units.map((CourseUnit u) => u.title).toList(), <String>[
      'First Words',
      'About You',
      'Family & Friends',
      'Everyday Things',
      'Food & Drink',
      'Days & Time',
      'My Day',
      'At Home',
      'Places in Town',
      'Clothes & Shopping',
      'Weather & Seasons',
      'I Can Swim',
      'Yesterday',
      'Shopping',
      'At the Restaurant',
      'Getting Around',
      'Health',
      'Free Time',
      'Plans',
      'Comparisons',
      'Work & Jobs',
      'Travel',
      'My Town',
      'Feelings & Opinions',
      'Telling Stories',
      'Life Experiences',
      'Future Predictions',
      'If...',
      'Describing People',
      'Making Plans',
      'Growing Up',
      "How It's Made",
      'Pass It On',
      'Keeping At It',
      'Rules & Guesses',
      'Getting Things Done',
      'Before That',
      'This Time Tomorrow',
      'What If',
      'It Must Have Been',
      'It Is Said',
      'To Do or Doing',
      'Which and Who',
      'So They Say',
      'A, The, or Nothing',
      'More and More',
      'On the Other Hand',
      "Isn't It?",
      'Never Have I...',
      'Had I Known',
      'Having Said That',
      "It's Essential That",
      'It Was Then That',
      "You Needn't Have",
      'In Other Words',
      'Less Is More',
      'Furthermore',
      'It Would Seem',
      "Much As I'd Like",
      'It Depends On',
      'Front and Centre',
      'No Sooner Said',
      'Be That As It May',
      'By and Large',
      'To Put It Mildly',
      'A Case in Point',
      'Come What May',
      'Were It Not',
      'Not That It Matters',
      'Mind You',
      'Splitting Hairs',
      'All Things Considered',
    ]);
    for (int i = 0; i < spine.units.length; i++) {
      final CourseUnit u = spine.units[i];
      expect(
          u.section,
          i < 6
              ? 'SECTION 1 · FOUNDATIONS'
              : i < 12
                  ? 'SECTION 2 · EVERYDAY LIFE'
                  : i < 18
                      ? 'SECTION 3 · A2 · EVERYDAY SITUATIONS'
                      : i < 24
                          ? 'SECTION 4 · A2 · PEOPLE & PLANS'
                          : i < 30
                              ? 'SECTION 5 · B1 · EXPERIENCES & STORIES'
                              : i < 36
                                  ? 'SECTION 6 · B1 · THE WIDER WORLD'
                                  : i < 42
                                      ? 'SECTION 7 · B2 · SHADES OF MEANING'
                                      : i < 48
                                          ? 'SECTION 8 · B2 · PUTTING IT TOGETHER'
                                          : i < 54
                                              ? 'SECTION 9 · C1 · THE FINER POINTS'
                                              : i < 60
                                                  ? 'SECTION 10 · C1 · STYLE & COHESION'
                                                  : i < 66
                                                      ? 'SECTION 11 · C2 · MASTERY & NUANCE'
                                                      : 'SECTION 12 · C2 · THE NATIVE TOUCH',
          reason: u.title);
      expect(u.guideText, isNotNull, reason: '${u.title} needs a 📖 Guide');
      expect(u.lessons.length, 4, reason: u.title);
      for (final CourseLesson l in u.lessons) {
        expect(l.exercises.length, inInclusiveRange(6, 7), reason: l.id);
        expect(
            l.exercises.any((CourseExercise e) => e.exerciseType == 'listen'),
            true,
            reason: '${l.id} needs a listen exercise');
        expect(
            l.exercises.every((CourseExercise e) =>
                e.exerciseType == 'listen' || e.prompt.isNotEmpty),
            true,
            reason: '${l.id} has an unresolved prompt_ref');
      }
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
