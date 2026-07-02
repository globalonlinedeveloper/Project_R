import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A plain-Dart, codegen-FREE projection of the content layer's `ContentBatch`
/// into the learning-path shape the Home tab (design spec §4.1) renders.
///
/// WHY IT LIVES HERE (feature layer), not in `lib/content`: the content models
/// are freezed/json_serializable and need `build_runner` (CI-authoritative — they
/// do not compile under the local 45s gate). Keeping this projection free of any
/// `lib/content` import lets Home AND its widget tests build + run in the local
/// gate. The single CI-only seam is the batch→spine MAPPER
/// (`lib/content/spine/content_course_spine.dart`), injected at app root through
/// [courseSpineProvider] — exactly mirroring how `backend_wiring` injects the
/// Supabase seams behind an honest local default.
/// [R-B3] path-rendering view-model. [R-B8] carries per-exercise IRT difficulty.
class CourseExercise {
  const CourseExercise({
    required this.id,
    required this.exerciseType,
    required this.prompt,
    required this.accepted,
    this.irtB,
    this.foldCase = true,
    this.stripDiacritics = false,
  });

  /// Content `item_id`.
  final String id;

  /// Content `exercise_type` token (mcq / cloze / translate / listen / …),
  /// carried verbatim so the runner can pick an honest renderer.
  final String exerciseType;

  /// Resolved prompt text (the item's `prompt_ref` → `gloss.text`).
  final String prompt;

  /// `answer_spec.accepted` — the authored acceptable answers.
  final List<String> accepted;

  /// `irt_b` difficulty so the REAL CAT engine can select this exercise.
  final double? irtB;

  final bool foldCase;
  final bool stripDiacritics;
}

/// One lesson node on the path (a content `skill` / grammar point).
class CourseLesson {
  const CourseLesson({
    required this.id,
    required this.title,
    required this.cefr,
    this.exercises = const <CourseExercise>[],
  });

  final String id;
  final String title;
  final String cefr; // 'A1'..'C2'
  final List<CourseExercise> exercises;

  int get exerciseCount => exercises.length;
}

/// A unit groups lessons under a section banner (here: by CEFR band).
class CourseUnit {
  const CourseUnit({
    required this.section,
    required this.title,
    required this.lessons,
    this.guideText,
  });

  final String section; // e.g. 'SECTION 1 · LEVEL A1'
  final String title; // e.g. 'Level A1'
  final List<CourseLesson> lessons;

  /// Authored 📖 Guide text for this unit (`unit.guide_ref` → gloss), when the
  /// curriculum carries one. Null on legacy CEFR-band units.
  final String? guideText;
}

/// The whole authored course, projected for the path UI.
class CourseSpine {
  const CourseSpine({required this.courseCode, required this.units});

  final String courseCode; // batch locale, e.g. 'es'
  final List<CourseUnit> units;

  bool get isEmpty => units.isEmpty;

  /// Lessons flattened in path order.
  List<CourseLesson> get lessons =>
      <CourseLesson>[for (final CourseUnit u in units) ...u.lessons];

  int get lessonCount => lessons.length;

  /// Honest "no content wired" fallback (the bundled course batch is loaded +
  /// injected in `main`; a build without it shows an honest empty path, never a
  /// fabricated curriculum).
  static const CourseSpine empty =
      CourseSpine(courseCode: '', units: <CourseUnit>[]);
}

/// The course spine the feature layer reads. Default = [CourseSpine.empty]
/// (honest unconfigured). `main` overrides it with the bundled-batch projection
/// via `initContentOverrides()` (the CI-only content seam).
final courseSpineProvider = Provider<CourseSpine>((ref) => CourseSpine.empty);
