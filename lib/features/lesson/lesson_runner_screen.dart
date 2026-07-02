import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/lesson/renderers/match_exercise.dart';
import 'package:ratel/features/lesson/renderers/listen_audio_controls.dart';
import 'package:ratel/services/learning/learning.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart';

/// The lesson runner (design spec §4.7 "Lesson exercises").
///
/// (H2) CONTENT-DRIVEN: when launched with a [lessonId] (Home's §4.6 preview
/// passes the tapped lesson's content id), the runner serves THAT lesson's REAL
/// authored exercises from the projected [CourseSpine] — prompt + accepted
/// answers + IRT difficulty straight from the authored `ContentBatch`. Each
/// exercise is still chosen by Maximum-Fisher-Information ([CatModel.selectNext])
/// at the learner's CURRENT global ability θ, and every graded answer is folded
/// into the real ability engine via [LearnerController.recordReview] (so θ /
/// CEFR level genuinely move with practice). Finishing awards real XP
/// ([LearnerController.recordLessonComplete]) and intakes the practised words
/// through the real dedup engine ([SavedWordsController.save]).
/// [R-L3 · R-D7 · R-D13 · R-G2 · R-I1 · R-G9 · R-L19 · R-B8]
///
/// HONEST RENDERER CHOICE: authored items carry NO distractor pool / picture
/// options (the `answer_spec` is `accepted` + normalization flags only), so the
/// honest renderer for real content is a TYPED answer graded by the authored
/// normalization flags (fold-case / strip-diacritics / collapse-whitespace) —
/// never a fabricated multiple-choice or word-bank. When NO lesson is supplied
/// (the Quests "Daily Refresh" and the Practice hub still open `/daily-quiz`
/// cold) the runner falls back to the hand-authored adaptive starter bank
/// (pick-the-picture + word-bank) — honest starter content, the same basis as
/// the §4.11 placement quiz.
///
/// HONESTY (design spec §6 / charter "don't fake depth"): the engine OUTPUT is
/// real (selection, θ fold, XP, saved-words). On the content path the item
/// CONTENT is the authored ContentBatch — no invented prompts, options, or
/// answers. The mockup's sample stats (412 words, 88 lessons, "−1 ⚡ energy")
/// are NOT reproduced — energy has no engine (§6) so the lesson never spends it,
/// and the durable FSRS spaced-review store is the §4.2 Practice hub's wiring.
class LessonRunnerScreen extends ConsumerStatefulWidget {
  const LessonRunnerScreen({super.key, this.lessonId});

  /// The content lesson (grammar-point) id to serve, threaded from Home's §4.6
  /// preview. Null ⇒ the hand-authored adaptive fallback bank.
  final String? lessonId;

  @override
  ConsumerState<LessonRunnerScreen> createState() => _LessonRunnerScreenState();
}

enum _ExType { pick, wordBank, typed, match, listen }

/// One pick-the-picture option (emoji + label).
class _Opt {
  const _Opt(this.emoji, this.label);
  final String emoji;
  final String label;
}

/// A lesson item carrying its IRT difficulty [b] so the real CAT engine can
/// select it. Three honest renderers: [_ExType.pick] (correct = option index 0,
/// hand-authored bank), [_ExType.wordBank] (assemble the target, hand-authored
/// bank), and [_ExType.typed] (free-text graded against [accepted] under the
/// authored normalization flags — the content-driven renderer).
class _Item {
  const _Item.pick({
    required this.id,
    required this.skill,
    required this.b,
    required this.prompt,
    required this.options,
    required this.saveWord,
  })  : type = _ExType.pick,
        source = null,
        target = const <String>[],
        pool = const <String>[],
        accepted = const <String>[],
        foldCase = true,
        stripDiacritics = false,
        pairs = const <MatchPair>[],
        phrase = '',
        lang = '';

  const _Item.wordBank({
    required this.id,
    required this.skill,
    required this.b,
    required this.prompt,
    required this.source,
    required this.target,
    required this.pool,
  })  : type = _ExType.wordBank,
        options = const <_Opt>[],
        saveWord = null,
        accepted = const <String>[],
        foldCase = true,
        stripDiacritics = false,
        pairs = const <MatchPair>[],
        phrase = '',
        lang = '';

  const _Item.typed({
    required this.id,
    required this.skill,
    required this.b,
    required this.prompt,
    required this.accepted,
    required this.foldCase,
    required this.stripDiacritics,
    required this.saveWord,
  })  : type = _ExType.typed,
        options = const <_Opt>[],
        source = null,
        target = const <String>[],
        pool = const <String>[],
        pairs = const <MatchPair>[],
        phrase = '',
        lang = '';

  /// A text-Match over >=3 REAL authored (prompt -> answer) pairs.
  const _Item.match({
    required this.id,
    required this.skill,
    required this.b,
    required this.pairs,
  })  : type = _ExType.match,
        prompt = 'Match the pairs',
        options = const <_Opt>[],
        saveWord = null,
        source = null,
        target = const <String>[],
        pool = const <String>[],
        accepted = const <String>[],
        foldCase = true,
        stripDiacritics = false,
        phrase = '',
        lang = '';

  /// Type-what-you-hear Listen: play [phrase] (browser TTS) + a typed answer
  /// graded against [accepted] (identical grading to [_ExType.typed]).
  const _Item.listen({
    required this.id,
    required this.skill,
    required this.b,
    required this.phrase,
    required this.lang,
    required this.accepted,
    required this.foldCase,
    required this.stripDiacritics,
  })  : type = _ExType.listen,
        prompt = 'Type what you hear',
        options = const <_Opt>[],
        saveWord = null,
        source = null,
        target = const <String>[],
        pool = const <String>[],
        pairs = const <MatchPair>[];

  final _ExType type;
  final String id;
  final String skill;
  final double b;
  final String prompt;
  // pick-the-picture
  final List<_Opt> options;
  final String? saveWord;
  // translate / word-bank
  final String? source;
  final List<String> target;
  final List<String> pool;
  // typed (content-driven)
  final List<String> accepted;
  final bool foldCase;
  final bool stripDiacritics;
  // text-Match
  final List<MatchPair> pairs;
  // listen (type-what-you-hear): the phrase to speak + its BCP-47 lang.
  final String phrase;
  final String lang;
}

const int _kLessonXp = 20;

/// Hand-authored A1→A2 starter bank (content), scored + selected by the real
/// engine — the FALLBACK when the runner is opened with no content lesson. Low-
/// difficulty pick items first (served first at the A1 cold-start); higher-b
/// translate items surface as θ rises.
const List<_Item> _kFallbackItems = <_Item>[
  _Item.pick(
    id: 'm1',
    skill: 'vocab',
    b: -2.4,
    prompt: 'Which one is "la manzana"?',
    options: <_Opt>[
      _Opt('🍎', 'manzana'),
      _Opt('🍌', 'el plátano'),
      _Opt('🍞', 'el pan'),
      _Opt('🧀', 'el queso'),
    ],
    saveWord: 'manzana',
  ),
  _Item.pick(
    id: 'm2',
    skill: 'vocab',
    b: -2.1,
    prompt: 'Which one is "el pan"?',
    options: <_Opt>[
      _Opt('🍞', 'el pan'),
      _Opt('🧀', 'el queso'),
      _Opt('🍎', 'la manzana'),
      _Opt('🥛', 'la leche'),
    ],
    saveWord: 'pan',
  ),
  _Item.pick(
    id: 'm3',
    skill: 'vocab',
    b: -1.8,
    prompt: 'Which one is "el gato"?',
    options: <_Opt>[
      _Opt('🐱', 'el gato'),
      _Opt('🐶', 'el perro'),
      _Opt('🐦', 'el pájaro'),
      _Opt('🐟', 'el pez'),
    ],
    saveWord: 'gato',
  ),
  _Item.pick(
    id: 'm4',
    skill: 'vocab',
    b: -1.4,
    prompt: 'Which one is "el agua"?',
    options: <_Opt>[
      _Opt('💧', 'el agua'),
      _Opt('☕', 'el café'),
      _Opt('🍷', 'el vino'),
      _Opt('🥛', 'la leche'),
    ],
    saveWord: 'agua',
  ),
  _Item.pick(
    id: 'm5',
    skill: 'vocab',
    b: -1.0,
    prompt: 'Which one is "la casa"?',
    options: <_Opt>[
      _Opt('🏠', 'la casa'),
      _Opt('🏫', 'la escuela'),
      _Opt('🏪', 'la tienda'),
      _Opt('⛪', 'la iglesia'),
    ],
    saveWord: 'casa',
  ),
  _Item.wordBank(
    id: 't1',
    skill: 'grammar',
    b: -0.5,
    prompt: 'Translate this sentence',
    source: 'The girl eats an apple',
    target: <String>['La', 'niña', 'come', 'una', 'manzana'],
    pool: <String>['niña', 'La', 'manzana', 'come', 'una', 'El', 'bebe', 'agua'],
  ),
  _Item.wordBank(
    id: 't2',
    skill: 'grammar',
    b: -0.1,
    prompt: 'Translate this sentence',
    source: 'I drink water',
    target: <String>['Yo', 'bebo', 'agua'],
    pool: <String>['bebo', 'agua', 'Yo', 'come', 'leche', 'niño'],
  ),
  _Item.wordBank(
    id: 't3',
    skill: 'grammar',
    b: 0.4,
    prompt: 'Translate this sentence',
    source: 'The cat is in the house',
    target: <String>['El', 'gato', 'está', 'en', 'la', 'casa'],
    pool: <String>['gato', 'El', 'casa', 'en', 'está', 'la', 'perro', 'calle'],
  ),
];

bool _seqEq(List<String> a, List<String> b) {
  if (a.length != b.length) {
    return false;
  }
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

/// Lowercase Latin accents → base letter, for the authored `strip_diacritics`
/// normalization flag (Spanish: á é í ó ú ü ñ, plus the broader Latin set).
const Map<String, String> _kDiacritics = <String, String>{
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ñ': 'n', 'ç': 'c',
};

/// Normalize a typed answer the SAME way both sides are compared, applying the
/// item's authored normalization flags. Whitespace is always trimmed/collapsed.
String _normalize(String s, {required bool foldCase, required bool stripDiacritics}) {
  String out = s.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (foldCase) {
    out = out.toLowerCase();
  }
  if (stripDiacritics) {
    final StringBuffer buf = StringBuffer();
    for (final int rune in out.runes) {
      final String ch = String.fromCharCode(rune);
      buf.write(_kDiacritics[ch] ?? ch);
    }
    out = buf.toString();
  }
  return out;
}

/// True iff [input] matches any authored accepted answer once both are
/// normalized under the item's flags (the honest content-driven grader).
bool _gradeTyped(_Item it, String input) {
  final String got =
      _normalize(input, foldCase: it.foldCase, stripDiacritics: it.stripDiacritics);
  if (got.isEmpty) {
    return false;
  }
  for (final String a in it.accepted) {
    if (_normalize(a, foldCase: it.foldCase, stripDiacritics: it.stripDiacritics) ==
        got) {
      return true;
    }
  }
  return false;
}

class _LessonRunnerScreenState extends ConsumerState<LessonRunnerScreen> {
  final CatModel _cat = const CatModel();

  late final List<_Item> _items;
  late final List<CatItem> _bank;
  late final Map<String, _Item> _byId;

  final Set<String> _seen = <String>{};
  final List<({String word, String? glyph})> _savedWords =
      <({String word, String? glyph})>[];
  int _correct = 0;
  int _graded = 0; // graded answers this session (accuracy denominator)
  late final DateTime _sessionStart; // D2 study-time clock anchor

  CatItem? _current;
  int? _picked; // pick-the-picture selected option index
  final List<int> _answer = <int>[]; // word-bank assembled pool indices
  final TextEditingController _typedCtrl = TextEditingController(); // typed
  bool _checked = false;
  bool _wasCorrect = false;
  AudioHandle? _audio; // browser-TTS handle for the current Listen item
  String? _audioItemId;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _sessionStart = ref.read(clockProvider)();
    _items = _resolveItems();
    _bank = <CatItem>[
      for (final _Item it in _items) CatItem(id: it.id, params: IrtItem(b: it.b)),
    ];
    _byId = <String, _Item>{for (final _Item it in _items) it.id: it};
    final double theta = ref.read(learnerControllerProvider).theta;
    _current = _cat.selectNext(_bank, theta, _seen);
  }

  @override
  void dispose() {
    _typedCtrl.dispose();
    _audio?.dispose();
    super.dispose();
  }

  /// The lesson bank: the selected content lesson's REAL authored exercises when
  /// a [LessonRunnerScreen.lessonId] resolves in the projected spine, else the
  /// hand-authored fallback bank.
  List<_Item> _resolveItems() {
    final String? id = widget.lessonId;
    if (id != null) {
      final CourseSpine spine = ref.read(courseSpineProvider);
      for (final CourseLesson l in spine.lessons) {
        if (l.id == id && l.exercises.isNotEmpty) {
          final List<_Item> items = <_Item>[
            for (final CourseExercise e in l.exercises) _fromExercise(id, e),
          ];
          // Append a text-Match over REAL authored pairs (a mixed vocabulary
          // review) when the spine carries enough distinct content; else omit.
          final _Item? match = _buildMatchItem(spine, id);
          if (match != null) items.add(match);
          final _Item? listen = _buildListenItem(spine, id);
          if (listen != null) items.add(listen);
          return items;
        }
      }
    }
    return _kFallbackItems;
  }

  /// The design's text-Match shows 3-5 tiles per side.
  static const int _kMatchMin = 3;
  static const int _kMatchMax = 5;

  /// Build ONE text-Match item from the course spine's REAL authored
  /// (prompt -> first-accepted-answer) pairs, gathered in path order,
  /// de-duplicated by prompt, capped at [_kMatchMax]. Returns null when fewer
  /// than [_kMatchMin] distinct pairs exist so Match is only ever served over
  /// genuine content -- never dummy data.
  _Item? _buildMatchItem(CourseSpine spine, String lessonId) {
    final List<MatchPair> pairs = <MatchPair>[];
    final Set<String> seenPrompts = <String>{};
    double bSum = 0;
    int bN = 0;
    outer:
    for (final CourseLesson l in spine.lessons) {
      for (final CourseExercise e in l.exercises) {
        final String pr = e.prompt.trim();
        final String an = e.accepted.isNotEmpty ? e.accepted.first.trim() : '';
        if (pr.isEmpty || an.isEmpty || !seenPrompts.add(pr)) continue;
        pairs.add(MatchPair(pr, an));
        bSum += e.irtB ?? 0.0;
        bN += 1;
        if (pairs.length >= _kMatchMax) break outer;
      }
    }
    if (pairs.length < _kMatchMin) return null;
    return _Item.match(
      id: 'match::$lessonId',
      skill: lessonId,
      b: bN > 0 ? bSum / bN : 0.0,
      pairs: pairs,
    );
  }

  /// Append ONE type-what-you-hear Listen review built from a REAL authored
  /// phrase (mirrors [_buildMatchItem]) -- surfaced only when browser speech
  /// is available (web); omitted everywhere else so Listen degrades to typed.
  /// Uses already-authored content, never dummy data.
  // R-D8 (dictation / type-what-you-hear), R-D5 (listen).
  _Item? _buildListenItem(CourseSpine spine, String lessonId) {
    if (!ref.read(speechTtsProvider).isAvailable) return null;
    // Prefer a phrase from the CURRENT lesson (relevant + varies per lesson);
    // fall back to any authored phrase course-wide. Never dummy data.
    final List<CourseLesson> ordered = <CourseLesson>[
      for (final CourseLesson l in spine.lessons) if (l.id == lessonId) l,
      for (final CourseLesson l in spine.lessons) if (l.id != lessonId) l,
    ];
    for (final CourseLesson l in ordered) {
      for (final CourseExercise e in l.exercises) {
        final String phrase =
            e.accepted.isNotEmpty ? e.accepted.first.trim() : '';
        if (phrase.isEmpty) continue;
        return _Item.listen(
          id: 'listen::\$lessonId',
          skill: lessonId,
          b: e.irtB ?? 0.0,
          phrase: phrase,
          lang: spine.courseCode,
          accepted: e.accepted,
          foldCase: e.foldCase,
          stripDiacritics: e.stripDiacritics,
        );
      }
    }
    return null;
  }

  /// Target-language BCP-47 code for browser TTS voice selection.
  String get _courseLang => ref.read(courseSpineProvider).courseCode;

  /// Project one authored [CourseExercise] into a typed runner item. Only a
  /// single-token accepted answer (no spaces) is saved to the practice hub — a
  /// whole-sentence translation never masquerades as a vocabulary "word".
  _Item _fromExercise(String skill, CourseExercise e) {
    // Listen/dictation -> the type-what-you-hear renderer, but ONLY when
    // browser speech is available (web); otherwise fall through to typed.
    final String listenPhrase =
        e.accepted.isNotEmpty ? e.accepted.first.trim() : '';
    if ((e.exerciseType == 'listen' || e.exerciseType == 'dictation') &&
        listenPhrase.isNotEmpty &&
        ref.read(speechTtsProvider).isAvailable) {
      return _Item.listen(
        id: e.id,
        skill: skill,
        b: e.irtB ?? 0.0,
        phrase: listenPhrase,
        lang: _courseLang,
        accepted: e.accepted,
        foldCase: e.foldCase,
        stripDiacritics: e.stripDiacritics,
      );
    }
    String? saveWord;
    for (final String a in e.accepted) {
      final String w = a.trim();
      if (w.isNotEmpty && !w.contains(' ')) {
        saveWord = w;
        break;
      }
    }
    return _Item.typed(
      id: e.id,
      skill: skill,
      b: e.irtB ?? 0.0,
      prompt: e.prompt,
      accepted: e.accepted,
      foldCase: e.foldCase,
      stripDiacritics: e.stripDiacritics,
      saveWord: saveWord,
    );
  }

  _Item get _item => _byId[_current!.id]!;

  void _resetItemState() {
    _audio?.dispose();
    _audio = null;
    _audioItemId = null;
    _picked = null;
    _answer.clear();
    _typedCtrl.clear();
    _checked = false;
    _wasCorrect = false;
  }

  bool get _canCheck => switch (_item.type) {
        _ExType.pick => _picked != null,
        _ExType.wordBank => _answer.isNotEmpty,
        _ExType.typed => _typedCtrl.text.trim().isNotEmpty,
        _ExType.listen => _typedCtrl.text.trim().isNotEmpty,
        _ExType.match => false,
      };

  /// Grade the current item and fold the answer into the REAL ability engine.
  void _check() {
    final _Item it = _item;
    final bool correct = switch (it.type) {
      _ExType.pick => _picked == 0,
      _ExType.wordBank =>
        _seqEq(<String>[for (final int i in _answer) it.pool[i]], it.target),
      _ExType.typed => _gradeTyped(it, _typedCtrl.text),
      _ExType.listen => _gradeTyped(it, _typedCtrl.text),
      _ExType.match => false,
    };

    final double thetaBefore = ref.read(learnerControllerProvider).theta;
    ref.read(learnerControllerProvider.notifier).recordReview(
          ReviewLogEntry(
            itemId: it.id,
            skill: it.skill,
            grade: correct ? FsrsRating.good : FsrsRating.again,
            correct: correct,
            elapsedMs: 0,
            thetaBefore: thetaBefore,
            irtBAtReview: it.b,
            source: 'lesson',
          ),
        );
    _graded += 1;
    _seen.add(it.id);
    if (correct) {
      _correct += 1;
      if (it.saveWord != null) {
        _savedWords.add((
          word: it.saveWord!,
          glyph: it.options.isNotEmpty ? it.options.first.emoji : null,
        ));
      }
    }
    setState(() {
      _checked = true;
      _wasCorrect = correct;
    });
  }

  /// Fold a completed Match into the REAL ability engine -- one review at the
  /// match's difficulty, correct iff every pair matched with zero mismatches
  /// (MatchExercise fires [onGraded] exactly once). Mirrors [_check].
  void _gradeMatch(_Item it, bool allCorrect) {
    if (_checked) return;
    final double thetaBefore = ref.read(learnerControllerProvider).theta;
    ref.read(learnerControllerProvider.notifier).recordReview(
          ReviewLogEntry(
            itemId: it.id,
            skill: it.skill,
            grade: allCorrect ? FsrsRating.good : FsrsRating.again,
            correct: allCorrect,
            elapsedMs: 0,
            thetaBefore: thetaBefore,
            irtBAtReview: it.b,
            source: 'lesson',
          ),
        );
    _graded += 1;
    _seen.add(it.id);
    if (allCorrect) _correct += 1;
    setState(() {
      _checked = true;
      _wasCorrect = allCorrect;
    });
  }

  void _skip() {
    _seen.add(_item.id);
    _next();
  }

  void _next() {
    final double theta = ref.read(learnerControllerProvider).theta;
    final CatItem? next = _cat.selectNext(_bank, theta, _seen);
    if (next == null) {
      _finish();
    } else {
      setState(() {
        _current = next;
        _resetItemState();
      });
    }
  }

  void _finish() {
    ref
        .read(learnerControllerProvider.notifier)
        .recordLessonComplete(xp: _kLessonXp);
    // D2: record graded accuracy + the real lesson session duration.
    final Duration session =
        ref.read(clockProvider)().difference(_sessionStart);
    ref.read(studyStatsControllerProvider.notifier).recordLesson(
          correct: _correct,
          total: _graded,
          session: session,
        );
    final words = ref.read(savedWordsControllerProvider.notifier);
    for (final ({String word, String? glyph}) w in _savedWords) {
      words.save(w.word, glyph: w.glyph);
    }
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('screen-lesson'),
      backgroundColor: context.palette.cream,
      body: SafeArea(child: _done ? _result(context) : _runner(context)),
    );
  }

  Widget _runner(BuildContext context) {
    final _Item it = _item;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RatelSpace.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: RatelSpace.sm),
          Row(
            children: <Widget>[
              IconButton(
                key: const ValueKey<String>('lesson-close'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(RatelIcons.close, color: context.palette.ink),
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(width: RatelSpace.md),
              Expanded(
                child: RatelProgressBar(
                  value: _seen.length / _items.length,
                  color: RatelColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: RatelSpace.lg),
          Text(
            it.prompt,
            style: TextStyle(
              fontFamily: RatelFont.display,
              fontWeight: RatelType.extraBold,
              fontSize: RatelType.screenTitle,
              color: context.palette.ink,
            ),
          ),
          const SizedBox(height: RatelSpace.lg),
          Expanded(
            child: SingleChildScrollView(
              child: switch (it.type) {
                _ExType.pick => _pick(it),
                _ExType.wordBank => _wordBank(it),
                _ExType.typed => _typed(it),
                _ExType.listen => _listen(it),
                _ExType.match => _match(it),
              },
            ),
          ),
          _bottom(it),
          const SizedBox(height: RatelSpace.md),
        ],
      ),
    );
  }

  Widget _pick(_Item it) {
    RatelOptionState stateFor(int i) {
      if (!_checked) {
        return i == _picked ? RatelOptionState.selected : RatelOptionState.idle;
      }
      if (i == 0) {
        return RatelOptionState.correct;
      }
      if (i == _picked) {
        return RatelOptionState.wrong;
      }
      return RatelOptionState.idle;
    }

    Widget card(int i) => Expanded(
          child: RatelOptionCard(
            key: ValueKey<String>('lesson-opt-$i'),
            emoji: it.options[i].emoji,
            label: it.options[i].label,
            state: stateFor(i),
            onTap: _checked ? null : () => setState(() => _picked = i),
          ),
        );

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            card(0),
            const SizedBox(width: RatelSpace.cardGap),
            card(1),
          ],
        ),
        const SizedBox(height: RatelSpace.cardGap),
        Row(
          children: <Widget>[
            card(2),
            const SizedBox(width: RatelSpace.cardGap),
            card(3),
          ],
        ),
      ],
    );
  }

  Widget _wordBank(_Item it) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('🦡', style: TextStyle(fontSize: 28)),
            const SizedBox(width: RatelSpace.sm),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(RatelSpace.md),
                decoration: BoxDecoration(
                  color: context.palette.white,
                  borderRadius: BorderRadius.circular(RatelRadius.card),
                  border: Border.all(color: context.palette.border),
                ),
                child: Text(
                  it.source!,
                  style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: context.palette.ink,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: RatelSpace.lg),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(vertical: RatelSpace.sm),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.palette.border)),
          ),
          child: Wrap(
            spacing: RatelSpace.sm,
            runSpacing: RatelSpace.sm,
            children: <Widget>[
              for (final int i in _answer)
                RatelWordTile(
                  word: it.pool[i],
                  onTap:
                      _checked ? null : () => setState(() => _answer.remove(i)),
                ),
            ],
          ),
        ),
        const SizedBox(height: RatelSpace.lg),
        Wrap(
          spacing: RatelSpace.sm,
          runSpacing: RatelSpace.sm,
          children: <Widget>[
            for (int i = 0; i < it.pool.length; i++)
              RatelWordTile(
                word: it.pool[i],
                used: _answer.contains(i),
                onTap: _checked
                    ? null
                    : () => setState(() {
                          if (!_answer.contains(i)) {
                            _answer.add(i);
                          }
                        }),
              ),
          ],
        ),
      ],
    );
  }

  Widget _typed(_Item it) {
    final Color borderColor = _checked
        ? (_wasCorrect ? RatelColors.green : RatelColors.coral)
        : context.palette.border;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('🦡', style: TextStyle(fontSize: 28)),
            const SizedBox(width: RatelSpace.sm),
            Expanded(
              child: Text(
                'Type your answer in the target language.',
                style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: context.palette.muted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: RatelSpace.lg),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: RatelSpace.lg, vertical: RatelSpace.xs),
          decoration: BoxDecoration(
            color: context.palette.white,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(RatelRadius.card),
          ),
          child: TextField(
            key: const ValueKey<String>('lesson-input'),
            controller: _typedCtrl,
            enabled: !_checked,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (_canCheck && !_checked) {
                _check();
              }
            },
            style: TextStyle(
              fontFamily: RatelFont.body,
              fontWeight: RatelType.medium,
              fontSize: RatelType.body,
              color: context.palette.ink,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: RatelSpace.md),
              hintText: 'Type your answer…',
              hintStyle: TextStyle(
                fontFamily: RatelFont.body,
                fontWeight: RatelType.medium,
                fontSize: RatelType.body,
                color: context.palette.muted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _listen(_Item it) {
    if (_audioItemId != it.id) {
      _audio?.dispose();
      _audio = ref.read(speechTtsProvider).handleFor(it.phrase, lang: it.lang);
      _audioItemId = it.id;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListenAudioControls(
          key: ValueKey<String>('lesson-listen-\${it.id}'),
          audio: _audio!,
          reduceMotion: ref.watch(reduceMotionProvider),
        ),
        const SizedBox(height: RatelSpace.lg),
        _typed(it),
      ],
    );
  }

  Widget _match(_Item it) {
    return MatchExercise(
      key: ValueKey<String>('lesson-match-${it.id}'),
      pairs: it.pairs,
      reduceMotion: ref.watch(reduceMotionProvider),
      onGraded: (bool ok) => _gradeMatch(it, ok),
    );
  }

  Widget _bottom(_Item it) {
    if (_checked) {
      final Color tint = _wasCorrect ? RatelColors.green : RatelColors.coral;
      final String answerText = switch (it.type) {
        _ExType.pick => '${it.options[0].emoji}  ${it.options[0].label}',
        _ExType.wordBank => it.target.join(' '),
        _ExType.typed => it.accepted.isNotEmpty ? it.accepted.first : '',
        _ExType.listen => it.accepted.isNotEmpty ? it.accepted.first : '',
        _ExType.match => '',
      };
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(RatelSpace.md),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(RatelRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _wasCorrect ? '✓ Correct!' : '✕ Not quite',
                  style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.cardTitle,
                    color: tint,
                  ),
                ),
                if (!_wasCorrect && answerText.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    'Answer: $answerText',
                    style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.body,
                      color: context.palette.ink,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: RatelSpace.md),
          RatelButton(
            label: 'Continue',
            variant: _wasCorrect
                ? RatelButtonVariant.success
                : RatelButtonVariant.danger,
            onPressed: _next,
          ),
        ],
      );
    }
    if (it.type == _ExType.match) {
      // Match auto-grades once every pair resolves; only Skip is offered
      // (no Check button -- mirrors the design's Match footer).
      return RatelButton(
        label: 'Skip',
        variant: RatelButtonVariant.secondary,
        onPressed: _skip,
      );
    }
    return Row(
      children: <Widget>[
        RatelButton(
          label: 'Skip',
          variant: RatelButtonVariant.secondary,
          expand: false,
          onPressed: _skip,
        ),
        const SizedBox(width: RatelSpace.md),
        Expanded(
          child: RatelButton(
            label: 'Check',
            onPressed: _canCheck ? _check : null,
          ),
        ),
      ],
    );
  }

  Widget _result(BuildContext context) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RatelSpace.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Spacer(),
          const Text('🎉', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 72)),
          const SizedBox(height: RatelSpace.lg),
          Text(
            'Lesson complete!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: RatelFont.display,
              fontWeight: RatelType.extraBold,
              fontSize: RatelType.screenTitle,
              color: context.palette.ink,
            ),
          ),
          const SizedBox(height: RatelSpace.lg),
          Center(
            child: RatelChip(
              label: '+$_kLessonXp XP',
              tone: RatelChipTone.green,
              filled: true,
            ),
          ),
          const SizedBox(height: RatelSpace.md),
          Text(
            '$_correct of ${_items.length} correct · now '
            '${snap.level.name.toUpperCase()}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: RatelFont.body,
              fontSize: RatelType.body,
              color: context.palette.muted,
            ),
          ),
          const Spacer(),
          RatelButton(label: 'Continue', onPressed: () => context.go('/home')),
          const SizedBox(height: RatelSpace.lg),
        ],
      ),
    );
  }
}
