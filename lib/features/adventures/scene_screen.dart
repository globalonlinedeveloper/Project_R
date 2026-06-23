import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import 'adventure_model.dart';
import 'scene_player.dart';
import '../mascot/mascot_view.dart';

/// Immersive scripted-roleplay player (R-L4a). NPC line -> learner choice ->
/// NPC reply -> next, ending in a small celebration. All token-driven; runs on
/// rails (no live AI). [onClose] is injected so tests need no real router.
class SceneScreen extends ConsumerWidget {
  const SceneScreen({super.key, required this.sceneId, this.onClose});
  final String sceneId;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final scene = findScene(sceneId);
    final close = onClose ?? () { if (context.canPop()) context.pop(); };

    if (scene == null) {
      return Scaffold(
        backgroundColor: t.surface,
        body: SafeArea(
          child: Center(child: Text('Scene not found', style: RatelType.body)),
        ),
      );
    }

    final state = ref.watch(scenePlayerProvider(sceneId));
    final player = ref.read(scenePlayerProvider(sceneId).notifier);

    return Scaffold(
      backgroundColor: t.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: RatelSpacing.maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.all(RatelSpacing.lg),
              child: state.isComplete
                  ? _SceneComplete(title: scene.title, onDone: close)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TopBar(progress: state.progress, onClose: close),
                        const SizedBox(height: RatelSpacing.lg),
                        Expanded(child: _SceneBody(player: player, state: state)),
                      ],
                    ),
            ),
          ),
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
          tooltip: 'Leave scene',
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

class _SceneBody extends StatelessWidget {
  const _SceneBody({required this.player, required this.state});
  final ScenePlayer player;
  final ScenePlayerState state;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final step = player.currentStep;
    final replying = state.phase == ScenePhase.replying;
    return ListView(
      children: [
        Text(step.speaker, style: RatelType.label.copyWith(color: t.onSurfaceVariant)),
        const SizedBox(height: RatelSpacing.xs),
        _Bubble(text: step.line, fg: t.onSurface, bg: t.surfaceVariant, fromNpc: true),
        const SizedBox(height: RatelSpacing.lg),
        if (!replying)
          for (var i = 0; i < step.choices.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: RatelSpacing.sm),
              child: RatelCard(
                onTap: () => player.choose(i),
                child: Text(step.choices[i], style: RatelType.title),
              ),
            ),
        if (replying) ...[
          _Bubble(
            text: step.choices[state.lastChoice!],
            fg: t.onPrimary,
            bg: t.primary,
            fromNpc: false,
          ),
          const SizedBox(height: RatelSpacing.md),
          Text(
            state.lastWasBest
                ? 'Great — that fits the moment.'
                : 'That works — here is a natural reply.',
            style: RatelType.caption.copyWith(color: t.onSurfaceVariant),
          ),
          const SizedBox(height: RatelSpacing.md),
          Text(step.speaker, style: RatelType.label.copyWith(color: t.onSurfaceVariant)),
          const SizedBox(height: RatelSpacing.xs),
          _Bubble(text: step.reply, fg: t.onSurface, bg: t.surfaceVariant, fromNpc: true),
          const SizedBox(height: RatelSpacing.lg),
          RatelButton(label: 'Continue', expand: true, onPressed: player.advance),
        ],
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.fg,
    required this.bg,
    required this.fromNpc,
  });
  final String text;
  final Color fg;
  final Color bg;
  final bool fromNpc;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromNpc ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(RatelSpacing.lg),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(RatelSpacing.radiusLg),
        ),
        child: Text(text, style: RatelType.body.copyWith(color: fg)),
      ),
    );
  }
}

class _SceneComplete extends StatelessWidget {
  const _SceneComplete({required this.title, required this.onDone});
  final String title;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: MascotView(size: 96, mood: MascotMood.cheer)),
            const SizedBox(height: RatelSpacing.lg),
            Text('Scene complete!',
                style: RatelType.display, textAlign: TextAlign.center),
            const SizedBox(height: RatelSpacing.sm),
            Text('You finished "$title".',
                style: RatelType.body, textAlign: TextAlign.center),
            const SizedBox(height: RatelSpacing.xxl),
            RatelButton(label: 'Done', expand: true, onPressed: onDone),
          ],
        ),
        const Positioned.fill(
          child: IgnorePointer(
            child: RatelCelebration(level: CelebrationLevel.flourish),
          ),
        ),
      ],
    );
  }
}
