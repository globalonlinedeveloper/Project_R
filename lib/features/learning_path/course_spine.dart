import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One authored MCQ option (a content `item.options[]` entry) resolved for
/// the codegen-free feature layer: display [text], authored [isCorrect], and
/// the per-option "Explain this" [explain] text (its `explain_ref` gloss),
/// when authored. [INF-2.5]
class CourseOption {
  const CourseOption({
    required this.text,
    required this.isCorrect,
    this.explain,
  });

  final String text;
  final bool isCorrect;
  final String? explain;
}

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
    this.options = const <CourseOption>[],
    this.explain,
    this.rubric,
    this.minTokens,
    this.requiredWords = const <String>[],
    this.requireTerminalPunct = false,
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

  /// Authored MCQ options (content `item.options[]`) in AUTHORED order,
  /// resolved for the codegen-free feature layer: display text, authored
  /// correctness, and the per-option "Explain this" text. Empty for items
  /// without an authored bank (the legacy ES course) -- those keep the typed
  /// renderer, byte-identical. [INF-2.5]
  final List<CourseOption> options;

  /// Item-level authored explanation (gloss `content_id == item_id`,
  /// `content_kind: explanation`) -- the "why this answer is right" text
  /// behind the "Explain this" button. Null when not authored.
  final String? explain;

  /// Guided-Writing display rubric (gloss `content_id == item_id`,
  /// `content_kind: rubric`) -- the human-readable "what full marks looks
  /// like". Null for non-write items. [INF-5]
  final String? rubric;

  /// Deterministic, UN-GATED rubric checks projected from `item.rubric_spec`
  /// (no live AI): [minTokens] = minimum word count, [requiredWords] = the
  /// resolved vocab lemmas the answer must contain, [requireTerminalPunct] =
  /// whether a terminal `.`/`!`/`?` is required. Null/empty for non-write
  /// items. [INF-5]
  final int? minTokens;
  final List<String> requiredWords;
  final bool requireTerminalPunct;
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

/// A graded reading passage (content `passage`, kind=story) projected for the
/// un-gated Read&Listen surface (INF-6): the gloss-resolved [title] + per-
/// passage [explain], the resolved [sentences] (its `sentence_refs` ->
/// `sentence.target_text`, in order), and the comprehension [checkExercises]
/// (its `check_item_refs` -> the SAME [CourseExercise] projection the runner
/// grades). TEXT-FIRST: `audio_ref` is null today, so the reader renders text +
/// optional browser read-aloud; real pre-generated audio/video stays owner-gated.
class CourseStory {
  const CourseStory({
    required this.id,
    required this.title,
    required this.cefr,
    required this.sentences,
    this.theme,
    this.explain,
    this.audioUrl,
    this.checkExercises = const <CourseExercise>[],
  });

  final String id; // content passage_id
  final String title;
  final String cefr; // 'A1'..'C2'
  final List<String> sentences; // resolved sentence.target_text, in order
  final String? theme;
  final String? explain; // per-passage explain gloss, when authored

  /// For a PODCAST (kind=podcast) the resolved audio URL: its `audio_ref` ->
  /// `media_asset.uri` (a real pre-generated MP3 on R2). Null for a text-first
  /// story (kind=story). [INF-7]
  final String? audioUrl;
  final List<CourseExercise> checkExercises;

  int get checkCount => checkExercises.length;
}

/// The whole authored course, projected for the path UI.
class CourseSpine {
  const CourseSpine({
    required this.courseCode,
    required this.units,
    this.stories = const <CourseStory>[],
    this.podcasts = const <CourseStory>[],
  });

  final String courseCode; // batch locale, e.g. 'es'
  final List<CourseUnit> units;

  /// Graded Read&Listen stories (content `passage`, kind=story) projected for
  /// the un-gated reading surface (INF-6). Empty when the batch authors none.
  final List<CourseStory> stories;

  /// Graded Podcasts (content `passage`, kind=podcast, with a real `audio_ref`)
  /// projected for the un-gated audio surface (INF-7). Same [CourseStory] shape
  /// as [stories] but each carries a non-null [CourseStory.audioUrl]. Empty when
  /// the batch authors none.
  final List<CourseStory> podcasts;

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
