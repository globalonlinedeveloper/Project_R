import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/loader/content_loader.dart';
import 'package:ratel/content/spine/content_course_spine.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// INF-8 (CI-only, needs build_runner content models): the batch->spine scenario
/// projection (Roleplay + Adventures) over the REAL authored EN course, incl. the
/// non-leak invariant (a scenario turn item never appears as a path exercise).
void main() {
  const ContentLoader loader = ContentLoader();
  ContentBatch en() => loader.loadString(
      File('assets/content/en/course.batch.json').readAsStringSync());

  test('EN scenarios project into roleplays + adventures (kind split)', () {
    final CourseSpine spine = buildCourseSpine(en());
    expect(spine.roleplays.isNotEmpty, true, reason: 'at least one roleplay');
    expect(spine.adventures.isNotEmpty, true, reason: 'at least one adventure');
    expect(spine.roleplays.every((CourseScenario s) => s.isRoleplay), true);
    expect(spine.adventures.every((CourseScenario s) => s.kind == 'adventure'),
        true);
    final CourseScenario rp = spine.roleplays.first;
    expect(rp.scenes.isNotEmpty, true);
    expect(rp.scenes.first.line.isNotEmpty, true); // sentence_ref resolved
    expect(rp.title.isNotEmpty, true); // title_ref gloss resolved
    // a roleplay carries a graded decision (a choice with is_correct)
    final bool hasGraded = spine.roleplays.any((CourseScenario s) =>
        s.scenes.any((CourseScene sc) =>
            sc.choices.any((CourseChoice c) => c.isCorrect == true)));
    expect(hasGraded, true);
    // an adventure branches (a choice carries next_scene_id)
    final bool branches = spine.adventures.any((CourseScenario s) => s.scenes
        .any((CourseScene sc) =>
            sc.choices.any((CourseChoice c) => c.nextSceneId != null)));
    expect(branches, true);
  });

  test('non-leak: a scenario turn item never appears as a path exercise', () {
    final CourseSpine spine = buildCourseSpine(en());
    final Set<String> pathItemIds = <String>{
      for (final CourseUnit u in spine.units)
        for (final CourseLesson l in u.lessons)
          for (final CourseExercise e in l.exercises) e.id,
    };
    // the A1 roleplay sample's graded turn item stays OFF the path
    expect(pathItemIds.contains('item_en_a1_s1u1_meet_1'), false);
  });
}
