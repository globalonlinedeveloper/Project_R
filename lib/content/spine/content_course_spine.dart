import 'package:ratel/features/learning_path/course_spine.dart';

import '../loader/content_loader.dart';
import '../models/models.dart';

/// CI-ONLY content seam: the pure projection from a freezed [ContentBatch] to
/// the codegen-free [CourseSpine] the feature layer renders. This is the ONE
/// file Home's path data flows through that imports the build_runner content
/// models, so it (and only it) is CI-authoritative. Injected at app root via
/// `initContentOverrides()`.
///
/// Mapping (HONEST — derived only from authored rows, never invented):
///  • each `grammar_point` becomes a lesson node (title = its `name`);
///  • its exercises = the `item` rows whose `skill_ids` include that grammar id;
///  • an item's prompt = its `prompt_ref` resolved through the `gloss` rows
///    (preferring an English UI gloss), accepted answers = `answer_spec.accepted`;
///  • lessons group into units by CEFR band (A1 < A2 < … < C2), authored order
///    preserved within a band.
/// [R-B3 · R-A7 · R-B8] batch→path projection over the authored CEFR content.
CourseSpine buildCourseSpine(ContentBatch batch) {
  // content_id -> prompt/sense text, preferring an 'en' UI-locale gloss.
  final Map<String, String> glossText = <String, String>{};
  for (final Gloss g in batch.glosses) {
    final bool prefer = g.uiLocale == 'en';
    if (prefer || !glossText.containsKey(g.contentId)) {
      glossText[g.contentId] = g.text;
    }
  }

  CourseExercise toExercise(Item it) {
    final AnswerSpec? spec = it.answerSpec;
    final NormalizationFlags? nf = spec?.normalizationFlags;
    return CourseExercise(
      id: it.itemId,
      exerciseType: it.exerciseType.name,
      prompt: glossText[it.promptRef] ?? '',
      accepted: spec?.accepted ?? const <String>[],
      irtB: it.irtB,
      foldCase: nf?.foldCase ?? true,
      stripDiacritics: nf?.stripDiacritics ?? false,
    );
  }

  // grammar_id -> its items, preserving authored item order.
  List<CourseExercise> exercisesFor(String grammarId) => <CourseExercise>[
        for (final Item it in batch.items)
          if (it.skillIds.contains(grammarId)) toExercise(it),
      ];

  final List<CourseLesson> lessons = <CourseLesson>[
    for (final GrammarPoint gp in batch.grammar)
      CourseLesson(
        id: gp.grammarId,
        title: gp.name,
        cefr: gp.cefrLevel.name.toUpperCase(),
        exercises: exercisesFor(gp.grammarId),
      ),
  ];

  // Group lessons into units by CEFR band, first-seen band order preserved.
  final List<String> bandOrder = <String>[];
  final Map<String, List<CourseLesson>> byBand = <String, List<CourseLesson>>{};
  for (final CourseLesson l in lessons) {
    (byBand[l.cefr] ??= <CourseLesson>[]).add(l);
    if (!bandOrder.contains(l.cefr)) bandOrder.add(l.cefr);
  }
  bandOrder.sort(); // 'A1' < 'A2' < 'B1' < … lexicographically == CEFR order

  final List<CourseUnit> units = <CourseUnit>[
    for (int i = 0; i < bandOrder.length; i++)
      CourseUnit(
        section: 'SECTION ${i + 1} · LEVEL ${bandOrder[i]}',
        title: 'Level ${bandOrder[i]}',
        lessons: byBand[bandOrder[i]]!,
      ),
  ];

  return CourseSpine(courseCode: batch.locale ?? '', units: units);
}
