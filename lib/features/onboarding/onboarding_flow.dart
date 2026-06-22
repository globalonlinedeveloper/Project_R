import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_flags.dart';
import '../../content/loader/content_loader.dart';
import '../../content/models/models.dart';
import '../../content/repository/content_providers.dart';
import '../../core/design_system/design_system.dart';

/// Guest-first onboarding (R-L2): language -> motivation -> goal -> first win.
/// The first win renders a real item off the local ContentBatch (no stubs) and
/// reuses the R-L19 celebration kit.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  static const int _stepCount = 4;
  int _step = 0;
  String _language = 'English';
  String? _motivation;
  String? _goal;

  void _next() => setState(() => _step = (_step + 1).clamp(0, _stepCount - 1));

  void _finish() {
    onboardingComplete.value = true;
    if (mounted) context.go('/learn');
  }

  @override
  Widget build(BuildContext context) {
    return RatelScreen(
      child: Column(
        key: const Key('onboarding'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepDots(step: _step, total: _stepCount),
          const SizedBox(height: RatelSpacing.xl),
          Expanded(
            child: RatelFadeThrough(
              child: KeyedSubtree(
                key: ValueKey<int>(_step),
                child: _step == 0
                    ? _LanguageStep(
                        selected: _language,
                        onSelect: (v) => setState(() => _language = v),
                        onContinue: _next,
                      )
                    : _step == 1
                        ? _ChoiceStep(
                            title: 'Why are you learning?',
                            options: const [
                              'Travel',
                              'Work',
                              'Family',
                              'Brain training'
                            ],
                            selected: _motivation,
                            onSelect: (v) => setState(() => _motivation = v),
                            onContinue: _motivation == null ? null : _next,
                          )
                        : _step == 2
                            ? _ChoiceStep(
                                title: 'Pick a daily goal',
                                options: const [
                                  'Casual - 5 min',
                                  'Regular - 10 min',
                                  'Serious - 15 min'
                                ],
                                selected: _goal,
                                onSelect: (v) => setState(() => _goal = v),
                                onContinue: _goal == null ? null : _next,
                              )
                            : _FirstWinStep(onDone: _finish),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.step, required this.total});
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        for (int i = 0; i < total; i++)
          Expanded(
            child: Container(
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: RatelSpacing.xs),
              decoration: BoxDecoration(
                color: i <= step ? t.primary : t.surfaceVariant,
                borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
              ),
            ),
          ),
      ],
    );
  }
}

class _LanguageStep extends StatelessWidget {
  const _LanguageStep({
    required this.selected,
    required this.onSelect,
    required this.onContinue,
  });
  final String selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    const langs = ['English', 'Spanish', 'Tamil'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('I want to learn...', style: RatelType.headline),
        const SizedBox(height: RatelSpacing.lg),
        for (final l in langs)
          Padding(
            padding: const EdgeInsets.only(bottom: RatelSpacing.sm),
            child: RatelCard(
              selected: l == selected,
              onTap: () => onSelect(l),
              child: Text(l, style: RatelType.title),
            ),
          ),
        const Spacer(),
        RatelButton(label: 'Continue', expand: true, onPressed: onContinue),
      ],
    );
  }
}

class _ChoiceStep extends StatelessWidget {
  const _ChoiceStep({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.onContinue,
  });
  final String title;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: RatelType.headline),
        const SizedBox(height: RatelSpacing.lg),
        for (final o in options)
          Padding(
            padding: const EdgeInsets.only(bottom: RatelSpacing.sm),
            child: RatelCard(
              selected: o == selected,
              onTap: () => onSelect(o),
              child: Text(o, style: RatelType.title),
            ),
          ),
        const Spacer(),
        RatelButton(label: 'Continue', expand: true, onPressed: onContinue),
      ],
    );
  }
}

class _FirstWinStep extends ConsumerStatefulWidget {
  const _FirstWinStep({required this.onDone});
  final VoidCallback onDone;

  @override
  ConsumerState<_FirstWinStep> createState() => _FirstWinStepState();
}

class _FirstWinStepState extends ConsumerState<_FirstWinStep> {
  String? _picked;
  bool _won = false;

  void _pick(String option, String answer) {
    setState(() {
      _picked = option;
      if (option.toLowerCase() == answer.toLowerCase()) _won = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final async = ref.watch(seedBatchProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('Could not load content', style: RatelType.body)),
      data: (batch) {
        final mcq = batch.items.firstWhere(
          (i) => i.exerciseType == ExerciseType.mcq,
          orElse: () => batch.items.first,
        );
        final answer = (mcq.answerSpec?.accepted.isNotEmpty ?? false)
            ? mcq.answerSpec!.accepted.first
            : '';
        final prompt = _promptFor(batch, answer);
        final options = _optionsFor(batch, answer);
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Your first win!', style: RatelType.headline),
                const SizedBox(height: RatelSpacing.lg),
                RatelCard(child: Text(prompt, style: RatelType.title)),
                const SizedBox(height: RatelSpacing.xl),
                if (!_won)
                  for (final o in options)
                    Padding(
                      padding: const EdgeInsets.only(bottom: RatelSpacing.sm),
                      child: RatelButton(
                        label: o,
                        kind: RatelButtonKind.secondary,
                        expand: true,
                        onPressed: () => _pick(o, answer),
                      ),
                    ),
                if (!_won && _picked != null)
                  Padding(
                    padding: const EdgeInsets.only(top: RatelSpacing.sm),
                    child: Text('Not quite — try again',
                        style: RatelType.body.copyWith(color: t.danger)),
                  ),
                if (_won) _WinPanel(onContinue: widget.onDone),
              ],
            ),
            if (_won)
              const Positioned.fill(
                child: IgnorePointer(
                  child: RatelCelebration(level: CelebrationLevel.lessonComplete),
                ),
              ),
          ],
        );
      },
    );
  }

  String _promptFor(ContentBatch batch, String answer) {
    if (batch.sentences.isEmpty || answer.isEmpty) return 'Tap the correct word';
    final s = batch.sentences.firstWhere(
      (s) => s.targetText.toLowerCase().contains(answer.toLowerCase()),
      orElse: () => batch.sentences.first,
    );
    final idx = s.targetText.toLowerCase().indexOf(answer.toLowerCase());
    if (idx < 0) return s.targetText;
    return s.targetText.replaceRange(idx, idx + answer.length, '___');
  }

  List<String> _optionsFor(ContentBatch batch, String answer) {
    final pool = <String>{};
    for (final s in batch.sentences) {
      for (final tok in s.tokens) {
        final w = tok.surface.toLowerCase();
        if (w.length >= 3 && w != answer.toLowerCase()) pool.add(w);
      }
    }
    final opts = <String>{answer.toLowerCase(), ...pool.take(2)}.toList()..sort();
    return opts;
  }
}

class _WinPanel extends StatelessWidget {
  const _WinPanel({required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: RatelCountUp(
            value: 10,
            prefix: '+',
            suffix: ' XP',
            style: RatelType.display,
          ),
        ),
        const SizedBox(height: RatelSpacing.sm),
        Center(child: Text('Nice! Your first XP.', style: RatelType.body)),
        const SizedBox(height: RatelSpacing.xl),
        RatelButton(label: 'Continue', expand: true, onPressed: onContinue),
      ],
    );
  }
}
