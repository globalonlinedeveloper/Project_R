import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/loader/content_loader.dart';
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
}
