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
///  • an item's authored `options[]` (text / is_correct) + its "Explain this"
///    texts (per-option `explain_ref` glosses + the item-level
///    `content_id == item_id` gloss, `content_kind: explanation`) project
///    onto [CourseOption]s (INF-2.5).
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

  // content_id -> authored "Explain this" text (content_kind: explanation),
  // 'en' preferred: item-level texts key by the ITEM id (plan §2) and
  // per-option texts by the option's `explain_ref` (INF-2.5).
  final Map<String, String> explainOf = <String, String>{};
  for (final Gloss g in batch.glosses) {
    if (g.contentKind != ContentKind.explanation) continue;
    final bool prefer = g.uiLocale == 'en';
    if (prefer || !explainOf.containsKey(g.contentId)) {
      explainOf[g.contentId] = g.text;
    }
  }

  // content_id -> Guided-Writing display rubric (content_kind: rubric), keyed
  // by the ITEM id (parallel to the explanation layer, INF-5). 'en' preferred.
  final Map<String, String> rubricOf = <String, String>{};
  for (final Gloss g in batch.glosses) {
    if (g.contentKind != ContentKind.rubric) continue;
    final bool prefer = g.uiLocale == 'en';
    if (prefer || !rubricOf.containsKey(g.contentId)) {
      rubricOf[g.contentId] = g.text;
    }
  }
  // vocab_id -> lemma: resolves a write item's rubric_spec.required_vocab_refs
  // into the surface words the answer must contain (deterministic, un-gated).
  final Map<String, String> vocabLemmaOf = <String, String>{
    for (final VocabEntry v in batch.vocab) v.vocabId: v.lemma,
  };

  CourseExercise toExercise(Item it) {
    final AnswerSpec? spec = it.answerSpec;
    final NormalizationFlags? nf = spec?.normalizationFlags;
    // Guided-Writing (INF-5): project the machine `rubric_spec` into the
    // un-gated deterministic checks (no live AI) + the display rubric gloss.
    final Map<String, Object?> rspec =
        it.rubricSpec ?? const <String, Object?>{};
    final Object? minTok = rspec['min_tokens'];
    final List<String> reqWords = <String>[
      for (final Object? r
          in (rspec['required_vocab_refs'] as List<Object?>? ??
              const <Object?>[]))
        if (r is String && vocabLemmaOf[r] != null) vocabLemmaOf[r]!,
    ];
    return CourseExercise(
      id: it.itemId,
      exerciseType: it.exerciseType.name,
      prompt: glossText[it.promptRef] ?? '',
      accepted: spec?.accepted ?? const <String>[],
      irtB: it.irtB,
      foldCase: nf?.foldCase ?? true,
      stripDiacritics: nf?.stripDiacritics ?? false,
      options: <CourseOption>[
        for (final Map<String, Object?> m
            in it.options ?? const <Map<String, Object?>>[])
          if (m['text'] is String && (m['text']! as String).isNotEmpty)
            CourseOption(
              text: m['text']! as String,
              isCorrect: m['is_correct'] == true,
              explain: m['explain_ref'] is String
                  ? explainOf[m['explain_ref']! as String]
                  : null,
            ),
      ],
      explain: explainOf[it.itemId],
      rubric: rubricOf[it.itemId],
      minTokens:
          minTok is int ? minTok : (minTok is num ? minTok.toInt() : null),
      requiredWords: reqWords,
      requireTerminalPunct: rspec['require_terminal_punct'] == true,
    );
  }

  // Items OWNED by another surface never appear as path exercises: passage
  // comprehension checks render with their passage, scenario turn items inside
  // their roleplay (R-D10). Pure data — derived from the refs, no type lists.
  final Set<String> surfaceOwned = <String>{
    for (final Passage p in batch.passages) ...?p.checkItemRefs,
    for (final Scenario sc in batch.scenarios)
      for (final Map<String, Object?> m in sc.scenes)
        if (m['turn_item_ref'] is String) m['turn_item_ref']! as String,
  };

  // grammar_id -> its PATH items, preserving authored item order. Data-driven
  // gradability rule: only items carrying an answer_spec are servable on the
  // path today (write items are rubric-graded — they surface via their own
  // renderer increment, never as a broken typed exercise).
  List<CourseExercise> exercisesFor(String grammarId) => <CourseExercise>[
        for (final Item it in batch.items)
          if (it.skillIds.contains(grammarId) &&
              (it.answerSpec != null ||
                  (it.exerciseType == ExerciseType.write &&
                      it.rubricSpec != null)) &&
              !surfaceOwned.contains(it.itemId))
            toExercise(it),
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
