import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/common/content_unavailable_card.dart';
import 'package:ratel/features/adventures/adventure_progress_controller.dart';
import 'package:ratel/features/learner/learner_controller.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// Adventure player (INF-8) -- a branching pre-generated story (content
/// `scenario`, kind=adventure). Plays scene by scene: the authored line, then the
/// authored choices, each of which BRANCHES to its authored `next_scene_id`. No
/// wrong answers, no grading -- a scene with no choices is an ENDING. Pure
/// authored DATA, NO live AI, no fabricated dialogue. Reaching an ending marks
/// the adventure EXPLORED (device-local, L-4 design 4.12); the FIRST
/// exploration awards +15 XP / +5 diamonds with the ADVENTURE COMPLETE dialog
/// (owner-approved S131) -- re-plays never re-award. [R-D10 - R-B3 - R-J1]
class AdventurePlayerScreen extends ConsumerStatefulWidget {
  const AdventurePlayerScreen({super.key, required this.scenarioId});

  final String? scenarioId;

  @override
  ConsumerState<AdventurePlayerScreen> createState() =>
      _AdventurePlayerScreenState();
}

class _AdventurePlayerScreenState extends ConsumerState<AdventurePlayerScreen> {
  String? _sceneId;

  /// Scenario ids whose ending has already been handled THIS visit — guards
  /// the post-frame explored/reward hook against rebuilds and 'Start over'
  /// round-trips (the store itself guards re-plays across visits).
  final Set<String> _endingHandled = <String>{};

  CourseScenario? _find(CourseSpine spine) {
    for (final CourseScenario s in spine.adventures) {
      if (s.id == widget.scenarioId) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final CourseSpine spine = ref.watch(courseSpineProvider);
    final CourseScenario? s = _find(spine);
    return Scaffold(
      backgroundColor: context.palette.cream,
      appBar: AppBar(
        backgroundColor: context.palette.cream,
        surfaceTintColor: context.palette.cream,
        elevation: 0,
        leading: IconButton(
          icon: Icon(RatelIcons.arrowBack, color: context.palette.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(s?.title ?? context.l10n.adventurePlayerFallbackTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                color: context.palette.ink,
                fontSize: RatelType.cardTitle)),
      ),
      body: s == null || s.scenes.isEmpty
          ? _notFound(context)
          : _play(context, s),
    );
  }

  Widget _play(BuildContext context, CourseScenario s) {
    final int idx = _sceneId == null || s.indexOf(_sceneId!) < 0
        ? 0
        : s.indexOf(_sceneId!);
    final CourseScene scene = s.scenes[idx];
    return ListView(
      key: const ValueKey<String>('screen-adventure-player'),
      padding: const EdgeInsets.fromLTRB(
          RatelSpace.screen, RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
      children: <Widget>[
        RatelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(scene.speaker,
                  style: TextStyle(
                      fontFamily: RatelFont.display,
                      fontWeight: RatelType.extraBold,
                      fontSize: RatelType.small,
                      color: RatelColors.blue)),
              const SizedBox(height: RatelSpace.xs),
              Text(scene.line,
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.bodyLg,
                      height: 1.5,
                      color: context.palette.ink)),
            ],
          ),
        ),
        const SizedBox(height: RatelSpace.md),
        if (!scene.isDecision) _scheduleEndingReached(s),
        if (scene.isDecision)
          for (int i = 0; i < scene.choices.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: RatelSpace.sm),
              child: RatelListRow(
                key: ValueKey<String>('adventure-choice-$i'),
                leadingEmoji: '➡️',
                leadingColor: RatelColors.blue,
                title: scene.choices[i].label,
                onTap: () {
                  final String? next = scene.choices[i].nextSceneId;
                  if (next != null && s.indexOf(next) >= 0) {
                    setState(() => _sceneId = next);
                  }
                },
              ),
            )
        else
          _ending(context, s),
      ],
    );
  }

  Widget _ending(BuildContext context, CourseScenario s) => RatelCard(
        color: context.palette.cream2,
        child: Column(
          key: const ValueKey<String>('adventure-ending'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(context.l10n.adventureTheEnd,
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.bodyLg,
                    color: context.palette.ink)),
            const SizedBox(height: RatelSpace.sm),
            Wrap(
              spacing: RatelSpace.sm,
              runSpacing: RatelSpace.sm,
              children: <Widget>[
                RatelButton(
                    label: context.l10n.adventureStartOver,
                    variant: RatelButtonVariant.secondary,
                    expand: false,
                    onPressed: () =>
                        setState(() => _sceneId = s.scenes.first.sceneId)),
                RatelButton(
                    label: context.l10n.adventureDone,
                    expand: false,
                    onPressed: () => context.pop()),
              ],
            ),
          ],
        ),
      );

  /// Ending reached (a choice-less scene rendered): schedule the explored
  /// mark + first-time reward AFTER this frame (never a build-time side
  /// effect). Renders as an empty box so it can sit in the scene column.
  Widget _scheduleEndingReached(CourseScenario s) {
    if (!_endingHandled.contains(s.id)) {
      _endingHandled.add(s.id);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onEndingReached(s);
      });
    }
    return const SizedBox.shrink();
  }

  void _onEndingReached(CourseScenario s) {
    final bool newlyExplored = ref
        .read(adventureProgressControllerProvider.notifier)
        .markExplored(s.id);
    if (!newlyExplored) return;
    // FIRST exploration: the once-per-adventure design reward (+15 XP - +5
    // diamonds, S131 owner-approved) + the ADVENTURE COMPLETE dialog.
    ref.read(learnerControllerProvider.notifier).recordAdventureExplored();
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        key: const ValueKey<String>('adventure-complete-dialog'),
        backgroundColor: dialogContext.palette.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RatelRadius.featureLg)),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(dialogContext.l10n.adventureCompleteKicker,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.caption,
                    fontWeight: RatelType.extraBold,
                    letterSpacing: 2,
                    color: RatelColors.amber)),
            const SizedBox(height: RatelSpace.xs),
            Text(dialogContext.l10n.adventureCompleteTitle(s.title),
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.screenTitle,
                    color: dialogContext.palette.ink)),
          ],
        ),
        content: Text(dialogContext.l10n.adventureCompleteBody,
            style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.body,
                height: 1.45,
                color: dialogContext.palette.muted)),
        actions: <Widget>[
          RatelButton(
            key: const ValueKey<String>('adventure-complete-continue'),
            label: dialogContext.l10n.lessonContinue,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }

  // M-3 fold-in: the shared honest unavailable card (Q-2) replaces the old
  // plain not-available text — same degrade as story/podcast/watch.
  Widget _notFound(BuildContext context) =>
      const ContentUnavailableCard(noun: 'adventure');
}
