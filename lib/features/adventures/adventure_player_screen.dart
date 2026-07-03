import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// Adventure player (INF-8) -- a branching pre-generated story (content
/// `scenario`, kind=adventure). Plays scene by scene: the authored line, then the
/// authored choices, each of which BRANCHES to its authored `next_scene_id`. No
/// wrong answers, no grading -- a scene with no choices is an ENDING. Pure
/// authored DATA, NO live AI, no fabricated dialogue. [R-D10 - R-B3 - R-J1]
class AdventurePlayerScreen extends ConsumerStatefulWidget {
  const AdventurePlayerScreen({super.key, required this.scenarioId});

  final String? scenarioId;

  @override
  ConsumerState<AdventurePlayerScreen> createState() =>
      _AdventurePlayerScreenState();
}

class _AdventurePlayerScreenState extends ConsumerState<AdventurePlayerScreen> {
  String? _sceneId;

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
        title: Text(s?.title ?? 'Adventure',
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
            Text('🏁 The End',
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.bodyLg,
                    color: context.palette.ink)),
            const SizedBox(height: RatelSpace.sm),
            Row(children: <Widget>[
              RatelButton(
                  label: 'Start over',
                  variant: RatelButtonVariant.secondary,
                  expand: false,
                  onPressed: () =>
                      setState(() => _sceneId = s.scenes.first.sceneId)),
              const SizedBox(width: RatelSpace.sm),
              RatelButton(
                  label: 'Done', expand: false, onPressed: () => context.pop()),
            ]),
          ],
        ),
      );

  Widget _notFound(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(RatelSpace.xl),
          child: Text('This adventure is not available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.bodyLg,
                  color: context.palette.muted)),
        ),
      );
}
