import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/learning/learning.dart';

/// The lesson runner (design spec §4.7 "Lesson exercises").
///
/// A REAL adaptive lesson: each exercise is chosen by Maximum-Fisher-Information
/// ([CatModel.selectNext]) from a hand-authored Spanish item bank at the
/// learner's CURRENT global ability θ, and every graded answer is folded into
/// the real ability engine via [LearnerController.recordReview] (so θ / CEFR
/// level genuinely move with practice). Finishing awards real XP
/// ([LearnerController.recordLessonComplete]) and intakes the practised words
/// through the real dedup engine ([SavedWordsController.save]).
/// [R-L3 · R-D13 · R-G2 · R-I1 · R-G9 · R-L19]
///
/// HONESTY (design spec §6 / charter "don't fake depth"): the engine OUTPUT is
/// real (selection, θ fold, XP, saved-words). The item-bank CONTENT is
/// hand-authored starter content (same basis as the §4.11 placement quiz); the
/// calibrated production item-bank + the codegen `ContentBatch` macro-spine is
/// the go-live wiring step. The mockup's sample stats (412 words, 88 lessons,
/// "−1 ⚡ energy") are NOT reproduced — energy has no engine (§6) so the lesson
/// never spends it, and FSRS spaced-review *scheduling* (persisting each item's
/// next-due interval) is the next wiring step (the answer already folds into the
/// θ ability engine; the durable due-queue + clock land with persistence).
class LessonRunnerScreen extends ConsumerStatefulWidget {
  const LessonRunnerScreen({super.key});

  @override
  ConsumerState<LessonRunnerScreen> createState() => _LessonRunnerScreenState();
}

enum _ExType { pick, wordBank }

/// One pick-the-picture option (emoji + label).
class _Opt {
  const _Opt(this.emoji, this.label);
  final String emoji;
  final String label;
}

/// A hand-authored lesson item carrying its IRT difficulty [b] so the real CAT
/// engine can select it. For [_ExType.pick] the correct option is index 0
/// (authored-bank convention — the production bank shuffles + calibrates).
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
        pool = const <String>[];

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
        saveWord = null;

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
}

const int _kLessonXp = 20;

/// Hand-authored A1→A2 starter bank (content), scored + selected by the real
/// engine. Low-difficulty pick items first (served first at the A1 cold-start);
/// higher-b translate items surface as θ rises.
const List<_Item> _kItems = <_Item>[
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

class _LessonRunnerScreenState extends ConsumerState<LessonRunnerScreen> {
  final CatModel _cat = const CatModel();

  late final List<CatItem> _bank = <CatItem>[
    for (final _Item it in _kItems) CatItem(id: it.id, params: IrtItem(b: it.b)),
  ];
  late final Map<String, _Item> _byId = <String, _Item>{
    for (final _Item it in _kItems) it.id: it,
  };

  final Set<String> _seen = <String>{};
  final List<String> _savedWords = <String>[];
  int _correct = 0;

  CatItem? _current;
  int? _picked; // pick-the-picture selected option index
  final List<int> _answer = <int>[]; // word-bank assembled pool indices
  bool _checked = false;
  bool _wasCorrect = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    final double theta = ref.read(learnerControllerProvider).theta;
    _current = _cat.selectNext(_bank, theta, _seen);
  }

  _Item get _item => _byId[_current!.id]!;

  void _resetItemState() {
    _picked = null;
    _answer.clear();
    _checked = false;
    _wasCorrect = false;
  }

  bool get _canCheck =>
      _item.type == _ExType.pick ? _picked != null : _answer.isNotEmpty;

  /// Grade the current item and fold the answer into the REAL ability engine.
  void _check() {
    final _Item it = _item;
    final bool correct = it.type == _ExType.pick
        ? _picked == 0
        : _seqEq(<String>[for (final int i in _answer) it.pool[i]], it.target);

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
    _seen.add(it.id);
    if (correct) {
      _correct += 1;
      if (it.saveWord != null) {
        _savedWords.add(it.saveWord!);
      }
    }
    setState(() {
      _checked = true;
      _wasCorrect = correct;
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
    final words = ref.read(savedWordsControllerProvider.notifier);
    for (final String w in _savedWords) {
      words.save(w);
    }
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('screen-lesson'),
      backgroundColor: RatelColors.cream,
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
                icon: const Icon(Icons.close, color: RatelColors.ink),
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(width: RatelSpace.md),
              Expanded(
                child: RatelProgressBar(
                  value: _seen.length / _kItems.length,
                  color: RatelColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: RatelSpace.lg),
          Text(
            it.prompt,
            style: const TextStyle(
              fontFamily: RatelFont.display,
              fontWeight: RatelType.extraBold,
              fontSize: RatelType.screenTitle,
              color: RatelColors.ink,
            ),
          ),
          const SizedBox(height: RatelSpace.lg),
          Expanded(
            child: SingleChildScrollView(
              child: it.type == _ExType.pick ? _pick(it) : _wordBank(it),
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
                  color: RatelColors.white,
                  borderRadius: BorderRadius.circular(RatelRadius.card),
                  border: Border.all(color: RatelColors.border),
                ),
                child: Text(
                  it.source!,
                  style: const TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: RatelColors.ink,
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
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: RatelColors.border)),
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

  Widget _bottom(_Item it) {
    if (_checked) {
      final Color tint = _wasCorrect ? RatelColors.green : RatelColors.coral;
      final String answerText = it.type == _ExType.pick
          ? '${it.options[0].emoji}  ${it.options[0].label}'
          : it.target.join(' ');
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
                if (!_wasCorrect) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    'Answer: $answerText',
                    style: const TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.body,
                      color: RatelColors.ink,
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
          const Text(
            'Lesson complete!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: RatelFont.display,
              fontWeight: RatelType.extraBold,
              fontSize: RatelType.screenTitle,
              color: RatelColors.ink,
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
            '$_correct of ${_kItems.length} correct · now '
            '${snap.level.name.toUpperCase()}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: RatelFont.body,
              fontSize: RatelType.body,
              color: RatelColors.muted,
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
