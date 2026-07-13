import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel;
import 'package:ratel/core/core.dart';
import 'package:ratel/services/learning/learning.dart';

/// The adaptive placement test (design spec §4.11 "Take a placement test").
///
/// A REAL computerised-adaptive quiz: each question is selected by
/// Maximum-Fisher-Information from a hand-authored English item bank
/// ([CatModel.selectNext]), the running ability is re-estimated by EAP after
/// every answer ([CatModel.eap]), and the variable-length stop rule
/// ([CatModel.shouldStop]) ends it. The final θ (same IRT logit scale as the
/// learner engine) seeds the learner via [LearnerController.seedFromPlacement],
/// so Home opens at the placed level. Nothing here is faked — the items are
/// authored content scored by the real IRT / CAT / EAP engine. [R-G4 · R-G7]
///
/// The bank is a small hand-authored English set spanning A1→C1; the calibrated
/// production item-bank is a go-live wiring step (engine contract).
class PlacementQuizScreen extends ConsumerStatefulWidget {
  const PlacementQuizScreen({super.key});

  @override
  ConsumerState<PlacementQuizScreen> createState() =>
      _PlacementQuizScreenState();
}

class _QItem {
  const _QItem(this.id, this.prompt, this.options, this.correct, this.b);
  final String id;
  final String prompt;
  final List<String> options;
  final int correct;
  final double b; // IRT difficulty on the logit scale (A1 ≈ -2.5 … C1 ≈ +2)
}

const List<_QItem> _kBank = <_QItem>[
  _QItem('p1', "Complete: 'I ___ a student.'",
      <String>['am', 'is', 'are', 'be'], 0, -2.5),
  _QItem('p2', 'Which word is a greeting?',
      <String>['Hello', 'Table', 'Fast', 'Blue'], 0, -2.3),
  _QItem('p3', "What is the plural of 'book'?",
      <String>['books', 'book', 'bookes', 'bookies'], 0, -2.1),
  _QItem('p4', "Complete: 'She ___ tea every morning.'",
      <String>['drinks', 'drink', 'drinking', 'drunk'], 0, -1.8),
  _QItem('p5', "Past tense: 'Yesterday I ___ home.'",
      <String>['went', 'go', 'goes', 'going'], 0, -1.5),
  _QItem('p6', "Choose the preposition: 'The book is ___ the table.'",
      <String>['on', 'in', 'of', 'since'], 0, -1.1),
  _QItem('p7', "Complete: 'They have ___ finished.'",
      <String>['already', 'yet', 'ago', 'during'], 0, -0.8),
  _QItem('p8', "First conditional: 'If it rains, we ___ stay in.'",
      <String>['will', 'would', 'are', 'did'], 0, -0.5),
  _QItem('p9', "Closest in meaning to 'purchase'",
      <String>['buy', 'sell', 'lose', 'borrow'], 0, -0.1),
  _QItem('p10', "Reported speech: 'She said she ___ tired.'",
      <String>['was', 'is', 'being', 'be'], 0, 0.3),
  _QItem('p11', 'Which sentence is correct?',
      <String>[
        'I wish I had known earlier.',
        'I wish I have known earlier.',
        'I wish I know earlier.',
        'I wish I knowing earlier.'
      ], 0, 0.9),
  _QItem('p12', "Closest in meaning to 'meticulous'",
      <String>['thorough', 'careless', 'sudden', 'rough'], 0, 1.9),
];

class _PlacementQuizScreenState extends ConsumerState<PlacementQuizScreen> {
  final CatModel _cat = const CatModel();

  late final List<CatItem> _bank = <CatItem>[
    for (final _QItem q in _kBank) CatItem(id: q.id, params: IrtItem(b: q.b)),
  ];
  late final Map<String, _QItem> _byId = <String, _QItem>{
    for (final _QItem q in _kBank) q.id: q,
  };

  final List<CatResponse> _responses = <CatResponse>[];
  final Set<String> _seen = <String>{};

  double _theta = 0.0; // neutral start; EAP re-estimates from responses
  CatItem? _current;
  bool _done = false;
  CefrLevel _level = CefrLevel.a1;

  @override
  void initState() {
    super.initState();
    _current = _cat.selectNext(_bank, _theta, _seen);
  }

  void _answer(int index) {
    final CatItem item = _current!;
    final _QItem q = _byId[item.id]!;
    _responses.add(CatResponse(item: item, correct: index == q.correct));
    _seen.add(item.id);

    final EapEstimate est = _cat.eap(_responses);
    _theta = est.theta;

    final CatItem? next = _cat.selectNext(_bank, _theta, _seen);
    final bool finished =
        next == null || _cat.shouldStop(_responses.length, est.se);

    if (finished) {
      _level = const ColdStartModel().bandFor(_theta) ?? CefrLevel.a1;
      // Seed the learner with the placement θ (real engine handoff).
      ref.read(learnerControllerProvider.notifier).seedFromPlacement(_theta);
      setState(() => _done = true);
    } else {
      setState(() => _current = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.cream,
      appBar: AppBar(
        backgroundColor: context.palette.cream,
        surfaceTintColor: context.palette.cream,
        elevation: 0,
        leading: IconButton(
          icon: Icon(RatelIcons.close, color: context.palette.ink),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Placement test',
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            fontSize: RatelType.cardTitle,
            color: context.palette.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: RatelSpace.screen),
          child: _done ? _result() : _question(),
        ),
      ),
    );
  }

  Widget _question() {
    final _QItem q = _byId[_current!.id]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: RatelSpace.sm),
        RatelProgressBar(
          value: _responses.length / _kBank.length,
          color: RatelColors.teal,
        ),
        const SizedBox(height: RatelSpace.sm),
        Text(
          'Question ${_responses.length + 1}',
          style: TextStyle(
            fontFamily: RatelFont.body,
            fontSize: RatelType.small,
            color: context.palette.muted,
          ),
        ),
        const SizedBox(height: RatelSpace.lg),
        Text(
          q.prompt,
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            fontSize: RatelType.screenTitle,
            color: context.palette.ink,
          ),
        ),
        const SizedBox(height: RatelSpace.lg),
        Expanded(
          child: ListView(
            children: <Widget>[
              for (int i = 0; i < q.options.length; i++) ...<Widget>[
                RatelOptionCard(
                  label: q.options[i],
                  onTap: () => _answer(i),
                ),
                const SizedBox(height: RatelSpace.cardGap),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _result() {
    return Column(
      children: <Widget>[
        const SizedBox(height: RatelSpace.xl),
        const Text('🧭', style: TextStyle(fontSize: 72)),
        const SizedBox(height: RatelSpace.lg),
        Text(
          'Your starting point',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            fontSize: RatelType.screenTitle,
            color: context.palette.ink,
          ),
        ),
        const SizedBox(height: RatelSpace.md),
        RatelChip.level(_level.name.toUpperCase()),
        const SizedBox(height: RatelSpace.md),
        Text(
          'Based on ${_responses.length} questions, we placed you at '
          '${_level.name.toUpperCase()}. You can always adjust later.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: RatelFont.body,
            fontSize: RatelType.body,
            color: context.palette.muted,
          ),
        ),
        const Spacer(),
        RatelButton(
          label: 'Start learning',
          onPressed: () => context.go('/home'),
        ),
        const SizedBox(height: RatelSpace.lg),
      ],
    );
  }
}
