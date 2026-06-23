import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../content/models/models.dart' show ExerciseType;
import '../../core/design_system/design_system.dart';
import 'engine/exercise.dart';
import 'lesson_controller.dart';
import '../energy/energy_controller.dart';
import '../streak/streak_controller.dart';

/// Immersive lesson runner (R-L3 / R-L17). Loads exercises off the local seed,
/// runs the engine via [lessonControllerProvider], and renders question ->
/// feedback (free why-card) -> celebratory complete. Quitting confirms and
/// discards (no commit / no energy). All colour + motion via design tokens.
class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, this.onClose, this.isReview = false});

  /// Injected so tests drive exit without a real router; defaults to a pop.
  final VoidCallback? onClose;

  /// Reviews are always free (no energy) — R-J*/R-L8.
  final bool isReview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(lessonExercisesProvider);
    return async.when(
      loading: () => const _LessonScaffold(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _LessonScaffold(
        child: Center(child: Text('Could not load the lesson', style: RatelType.body)),
      ),
      data: (exercises) {
        if (exercises.isEmpty) {
          return _LessonScaffold(
            child: Center(child: Text('No lesson available yet', style: RatelType.body)),
          );
        }
        return _LessonRun(
          onClose: onClose ?? () => _defaultClose(context),
          isReview: isReview,
        );
      },
    );
  }

  static void _defaultClose(BuildContext context) {
    if (context.canPop()) context.pop();
  }
}

class _LessonScaffold extends StatelessWidget {
  const _LessonScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: RatelSpacing.maxContentWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _LessonRun extends ConsumerStatefulWidget {
  const _LessonRun({required this.onClose, this.isReview = false});
  final VoidCallback onClose;
  final bool isReview;

  @override
  ConsumerState<_LessonRun> createState() => _LessonRunState();
}

class _LessonRunState extends ConsumerState<_LessonRun> {
  String? _selected;
  bool _committed = false;

  Future<void> _confirmQuit() async {
    final t = context.tokens;
    final quit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surface,
        title: Text('Quit lesson?', style: RatelType.title),
        content: Text(
          "Your progress in this lesson won't be saved.",
          style: RatelType.body,
        ),
        actions: [
          RatelButton(
            label: 'Keep going',
            kind: RatelButtonKind.text,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          RatelButton(label: 'Quit', onPressed: () => Navigator.of(ctx).pop(true)),
        ],
      ),
    );
    if (quit == true) widget.onClose();
  }

  void _showInterstitial() {
    final t = context.tokens;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.surface,
        title: Text('Quick break', style: RatelType.title),
        content: Text(
          'A short ad would play here on the free tier. Mistakes never cost energy.',
          style: RatelType.body,
        ),
        actions: [
          RatelButton(
              label: 'Continue', onPressed: () => Navigator.of(ctx).pop()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonControllerProvider);
    final controller = ref.read(lessonControllerProvider.notifier);
    final isPro = ref.watch(energyControllerProvider).isPro;

    // Charge energy exactly once when the lesson reaches complete (R-J*); a quit
    // never reaches here, so quitting commits nothing.
    ref.listen<LessonState>(lessonControllerProvider, (prev, next) {
      if (!_committed && next.phase == LessonPhase.complete) {
        _committed = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final outcome = ref
              .read(energyControllerProvider.notifier)
              .commit(isReview: widget.isReview);
          ref.read(streakControllerProvider.notifier).recordActivity();
          if (outcome.showInterstitial) _showInterstitial();
        });
      }
    });

    if (state.phase == LessonPhase.complete) {
      return _LessonScaffold(
        child: _CompletePanel(result: state.result!, onDone: widget.onClose),
      );
    }

    final exercise = state.current!;
    return _LessonScaffold(
      child: Padding(
        padding: const EdgeInsets.all(RatelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopBar(progress: state.progress, onClose: _confirmQuit),
            const SizedBox(height: RatelSpacing.xl),
            Expanded(
              child: state.phase == LessonPhase.feedback
                  ? _FeedbackPanel(
                      feedback: state.feedback!,
                      proLocked: !isPro,
                      onContinue: () {
                        setState(() => _selected = null);
                        controller.proceed();
                      },
                    )
                  : _QuestionPanel(
                      exercise: exercise,
                      selected: _selected,
                      onSelect: (o) => setState(() => _selected = o),
                      onCheck: _selected == null
                          ? null
                          : () => controller.submit(_selected!),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.progress, required this.onClose});
  final double progress;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close),
          color: t.onSurfaceVariant,
          tooltip: 'Quit lesson',
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: t.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(t.primary),
            ),
          ),
        ),
        const SizedBox(width: RatelSpacing.sm),
      ],
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({
    required this.exercise,
    required this.selected,
    required this.onSelect,
    required this.onCheck,
  });
  final Exercise exercise;
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback? onCheck;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _typeLabel(exercise.type),
          style: RatelType.label.copyWith(color: t.onSurfaceVariant),
        ),
        const SizedBox(height: RatelSpacing.sm),
        RatelCard(child: Text(exercise.prompt, style: RatelType.headline)),
        const SizedBox(height: RatelSpacing.xl),
        Expanded(
          child: ListView(
            children: [
              for (final o in exercise.options)
                Padding(
                  padding: const EdgeInsets.only(bottom: RatelSpacing.sm),
                  child: RatelCard(
                    selected: o == selected,
                    onTap: () => onSelect(o),
                    child: Text(o, style: RatelType.title),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: RatelSpacing.sm),
        RatelButton(label: 'Check', expand: true, onPressed: onCheck),
      ],
    );
  }

  String _typeLabel(ExerciseType type) => switch (type) {
        ExerciseType.cloze => 'Fill in the blank',
        _ => 'Choose the answer',
      };
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.feedback,
    required this.proLocked,
    required this.onContinue,
  });
  final LessonFeedback feedback;
  final bool proLocked;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final correct = feedback.correct;
    final bg = correct ? t.success : t.danger;
    final fg = correct ? t.onSuccess : t.onDanger;
    final headline = correct
        ? 'Correct!'
        : (feedback.revealed ? 'Answer: ${feedback.correctAnswer}' : 'Not quite');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(RatelSpacing.lg),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(RatelSpacing.radiusLg),
                  ),
                  child: Row(
                    children: [
                      Icon(correct ? Icons.check_circle : Icons.cancel, color: fg),
                      const SizedBox(width: RatelSpacing.sm),
                      Expanded(
                        child: Text(headline,
                            style: RatelType.title.copyWith(color: fg)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: RatelSpacing.lg),
                RatelCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Why',
                          style: RatelType.label.copyWith(color: t.primary)),
                      const SizedBox(height: RatelSpacing.xs),
                      Text(feedback.whyCard, style: RatelType.body),
                    ],
                  ),
                ),
                if (proLocked) ...[
                  const SizedBox(height: RatelSpacing.sm),
                  const _ProExplainLock(),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: RatelSpacing.lg),
        RatelButton(label: 'Continue', expand: true, onPressed: onContinue),
      ],
    );
  }
}

class _CompletePanel extends StatelessWidget {
  const _CompletePanel({required this.result, required this.onDone});
  final LessonResult result;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final pct = (result.accuracy * 100).round();
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(RatelSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Lesson complete!',
                  style: RatelType.display, textAlign: TextAlign.center),
              const SizedBox(height: RatelSpacing.xl),
              Center(
                child: RatelCountUp(
                  value: result.xp,
                  prefix: '+',
                  suffix: ' XP',
                  style: RatelType.display,
                ),
              ),
              const SizedBox(height: RatelSpacing.sm),
              Center(child: Text('$pct% accuracy', style: RatelType.title)),
              const SizedBox(height: RatelSpacing.xxl),
              RatelButton(label: 'Done', expand: true, onPressed: onDone),
            ],
          ),
        ),
        const Positioned.fill(
          child: IgnorePointer(
            child: RatelCelebration(level: CelebrationLevel.lessonComplete),
          ),
        ),
      ],
    );
  }
}

/// Pre-tap Pro lock for the deeper "Explain my answer" (R-J6 / §H honesty): the
/// free tier sees it is a Pro feature BEFORE tapping; the why-card above is free.
class _ProExplainLock extends StatelessWidget {
  const _ProExplainLock();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: 'Explain my answer, Pro feature',
      child: Container(
        padding: const EdgeInsets.all(RatelSpacing.md),
        decoration: BoxDecoration(
          color: t.surfaceVariant,
          borderRadius: BorderRadius.circular(RatelSpacing.radiusMd),
          border: Border.all(color: t.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_outline, size: 18, color: t.onSurfaceVariant),
            const SizedBox(width: RatelSpacing.sm),
            Expanded(
              child: Text('Explain my answer', style: RatelType.label),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: RatelSpacing.sm, vertical: RatelSpacing.xs),
              decoration: BoxDecoration(
                color: t.accent,
                borderRadius: BorderRadius.circular(RatelSpacing.radiusPill),
              ),
              child: Text('PRO', style: RatelType.caption.copyWith(color: t.onAccent)),
            ),
          ],
        ),
      ),
    );
  }
}
