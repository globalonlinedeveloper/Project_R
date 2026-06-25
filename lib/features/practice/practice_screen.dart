import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/repository/content_providers.dart';
import '../../core/design_system/design_system.dart';
import '../../services/learning/learning.dart';
import 'practice_controller.dart';

/// Practice ("Smart review", R-G5/R-G7): a real FSRS-driven review queue over the
/// seed vocab, replacing the Stage-1 placeholder. Local-now (in-memory FSRS); the
/// live persisted due-queue binds through the #7 store once authEnabled.
class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seed = ref.watch(seedBatchProvider);
    return RatelScreen(
      title: 'Practice your mistakes',
      child: KeyedSubtree(
        key: const Key('practice-screen'),
        child: seed.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              Center(child: Text('Could not load reviews', style: RatelType.body)),
          data: (_) {
            final PracticeState state = ref.watch(practiceControllerProvider);
            if (state.isComplete) {
              return _PracticeDone(reviewed: state.reviewed);
            }
            final PracticeController ctrl =
                ref.read(practiceControllerProvider.notifier);
            return _ReviewCardView(
              state: state,
              onReveal: ctrl.reveal,
              onGrade: ctrl.grade,
            );
          },
        ),
      ),
    );
  }
}

class _ReviewCardView extends StatelessWidget {
  const _ReviewCardView({
    required this.state,
    required this.onReveal,
    required this.onGrade,
  });

  final PracticeState state;
  final VoidCallback onReveal;
  final void Function(FsrsRating rating) onGrade;

  @override
  Widget build(BuildContext context) {
    final ReviewCard card = state.current!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: RatelSpacing.sm),
        Text('${state.dueCount} due · ${state.reviewed} done',
            style: RatelType.caption),
        const SizedBox(height: RatelSpacing.md),
        Expanded(
          child: RatelCard(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(card.front, style: RatelType.display),
                  if (state.revealed && card.back != null) ...<Widget>[
                    const SizedBox(height: RatelSpacing.sm),
                    Text(card.back!, style: RatelType.body),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: RatelSpacing.lg),
        if (!state.revealed)
          RatelButton(label: 'Reveal', onPressed: onReveal, expand: true)
        else
          Row(
            children: <Widget>[
              Expanded(
                child: RatelButton(
                  label: 'Again',
                  kind: RatelButtonKind.secondary,
                  onPressed: () => onGrade(FsrsRating.again),
                ),
              ),
              const SizedBox(width: RatelSpacing.sm),
              Expanded(
                child: RatelButton(
                  label: 'Good',
                  onPressed: () => onGrade(FsrsRating.good),
                ),
              ),
              const SizedBox(width: RatelSpacing.sm),
              Expanded(
                child: RatelButton(
                  label: 'Easy',
                  kind: RatelButtonKind.secondary,
                  onPressed: () => onGrade(FsrsRating.easy),
                ),
              ),
            ],
          ),
        const SizedBox(height: RatelSpacing.md),
      ],
    );
  }
}

class _PracticeDone extends StatelessWidget {
  const _PracticeDone({required this.reviewed});

  final int reviewed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('All caught up', style: RatelType.headline),
          const SizedBox(height: RatelSpacing.sm),
          Text('You reviewed $reviewed ${reviewed == 1 ? 'card' : 'cards'}.',
              style: RatelType.body),
        ],
      ),
    );
  }
}
