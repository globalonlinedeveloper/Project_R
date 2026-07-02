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
///    (preferring an English UI gloss), accepted answers = `answer_spec.accepted`.
///
/// S96 (content-build plan §3.2 — Level→Section→Unit→Lesson): when the batch
/// carries authored `unit` rows, the path projects the REAL curriculum —
/// units ordered purely by DATA (`section_order`, `unit_order`), lessons within
/// a unit by `lesson_order` (authored order as tiebreak), section/unit titles +
/// the 📖 Guide resolved through the gloss layer. Grammar points with NO
/// `unit_id` (or one no unit row matches) keep the historic CEFR-band grouping,
/// appended AFTER the authored sections with continuing section numbers — so a
/// legacy batch (the live ES course) projects byte-identically to before.
/// NO hardcoded structure counts anywhere: the spine renders whatever rows
/// exist (plan §4, dynamic/data-driven).
/// [R-B3 · R-A7 · R-B8] batch→path projection over the authored content.
CourseSpine buildCourseSpine(ContentBatch batch) {
  // content_id -> prompt/sense/title/guide text, preferring an 'en' UI gloss.
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

  CourseLesson lessonOf(GrammarPoint gp) => CourseLesson(
        id: gp.grammarId,
        title: gp.name,
        cefr: gp.cefrLevel.name.toUpperCase(),
        exercises: exercisesFor(gp.grammarId),
      );

  final List<CourseUnit> units = <CourseUnit>[];
  final Set<String> placed = <String>{};

  // (1) Authored curriculum: project `unit` rows in pure data order.
  if (batch.units.isNotEmpty) {
    final Map<String, int> unitIdx = <String, int>{
      for (int i = 0; i < batch.units.length; i++) batch.units[i].unitId: i,
    };
    final Map<String, int> gpIdx = <String, int>{
      for (int i = 0; i < batch.grammar.length; i++)
        batch.grammar[i].grammarId: i,
    };
    final List<Unit> ordered = <Unit>[...batch.units]
      ..sort((Unit a, Unit b) {
        final int s = a.sectionOrder.compareTo(b.sectionOrder);
        if (s != 0) return s;
        final int u = a.unitOrder.compareTo(b.unitOrder);
        if (u != 0) return u;
        return unitIdx[a.unitId]!.compareTo(unitIdx[b.unitId]!);
      });
    for (final Unit u in ordered) {
      final List<GrammarPoint> wired = <GrammarPoint>[
        for (final GrammarPoint gp in batch.grammar)
          if (gp.unitId == u.unitId) gp,
      ]..sort((GrammarPoint a, GrammarPoint b) {
          final int la = a.lessonOrder ?? 1 << 30;
          final int lb = b.lessonOrder ?? 1 << 30;
          if (la != lb) return la.compareTo(lb);
          return gpIdx[a.grammarId]!.compareTo(gpIdx[b.grammarId]!);
        });
      if (wired.isEmpty) continue; // a unit with no lessons yet renders nothing
      final String? guideRef = u.guideRef;
      units.add(CourseUnit(
        section: glossText[u.sectionTitleRef] ?? 'SECTION ${u.sectionOrder}',
        title: glossText[u.titleRef] ?? u.unitId,
        guideText: guideRef == null ? null : glossText[guideRef],
        lessons: <CourseLesson>[
          for (final GrammarPoint gp in wired) lessonOf(gp)
        ],
      ));
      for (final GrammarPoint gp in wired) {
        placed.add(gp.grammarId);
      }
    }
  }

  // (2) CEFR-band fallback for everything not placed (legacy / null unit_id) —
  // byte-identical to the historic projection when the batch has no units.
  final List<CourseLesson> leftovers = <CourseLesson>[
    for (final GrammarPoint gp in batch.grammar)
      if (!placed.contains(gp.grammarId)) lessonOf(gp),
  ];
  final List<String> bandOrder = <String>[];
  final Map<String, List<CourseLesson>> byBand = <String, List<CourseLesson>>{};
  for (final CourseLesson l in leftovers) {
    (byBand[l.cefr] ??= <CourseLesson>[]).add(l);
    if (!bandOrder.contains(l.cefr)) bandOrder.add(l.cefr);
  }
  bandOrder.sort(); // 'A1' < 'A2' < 'B1' < … lexicographically == CEFR order
  for (final String band in bandOrder) {
    units.add(CourseUnit(
      section: 'SECTION ${units.length + 1} · LEVEL $band',
      title: 'Level $band',
      lessons: byBand[band]!,
    ));
  }

  return CourseSpine(courseCode: batch.locale ?? '', units: units);
}
