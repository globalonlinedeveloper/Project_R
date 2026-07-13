import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/common/content_unavailable_card.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// Roleplay player (INF-8) -- a graded pre-generated dialogue (content
/// `scenario`, kind=roleplay). Plays scene by scene: the other speaker's authored
/// lines, and at a "you" turn the authored choices -- tap one, graded by
/// `is_correct`, with an optional "Explain this" (its choice gloss). Advancement
/// is pure authored DATA (`next_scene_id`, else the next scene in order); NO live
/// AI, no faked dialogue. [R-D10 - R-B3]
class RoleplayPlayerScreen extends ConsumerStatefulWidget {
  const RoleplayPlayerScreen({super.key, required this.scenarioId});

  final String? scenarioId;

  @override
  ConsumerState<RoleplayPlayerScreen> createState() =>
      _RoleplayPlayerScreenState();
}

class _RoleplayPlayerScreenState extends ConsumerState<RoleplayPlayerScreen> {
  String? _sceneId; // current scene id (null => the first scene)
  int? _picked; // chosen choice index at the current decision
  bool _showExplain = false;
  bool _done = false;

  CourseScenario? _find(CourseSpine spine) {
    for (final CourseScenario s in spine.roleplays) {
      if (s.id == widget.scenarioId) return s;
    }
    return null;
  }

  void _advance(CourseScenario s, CourseScene scene) {
    final CourseChoice? picked =
        (_picked != null && _picked! < scene.choices.length)
            ? scene.choices[_picked!]
            : null;
    String? next = picked?.nextSceneId;
    if (next == null || s.indexOf(next) < 0) {
      final int i = s.indexOf(scene.sceneId);
      next = (i >= 0 && i + 1 < s.scenes.length) ? s.scenes[i + 1].sceneId : null;
    }
    setState(() {
      if (next == null) {
        _done = true;
      } else {
        _sceneId = next;
        _picked = null;
        _showExplain = false;
      }
    });
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
        title: Text(s?.title ?? context.l10n.libraryRoleplay,
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
    final bool youTurn = scene.isDecision;
    final bool decided = _picked != null;
    return ListView(
      key: const ValueKey<String>('screen-roleplay-player'),
      padding: const EdgeInsets.fromLTRB(
          RatelSpace.screen, RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
      children: <Widget>[
        if (s.goal != null && s.goal!.isNotEmpty) ...<Widget>[
          RatelCard(
            color: context.palette.cream2,
            child: Row(children: <Widget>[
              const Text('🎯', style: TextStyle(fontSize: 20)),
              const SizedBox(width: RatelSpace.sm),
              Expanded(
                child: Text(s.goal!,
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.small,
                        color: context.palette.muted)),
              ),
            ]),
          ),
          const SizedBox(height: RatelSpace.md),
        ],
        if (_done)
          _finished(context)
        else ...<Widget>[
          _speakerLine(context, scene),
          if (youTurn) ...<Widget>[
            const SizedBox(height: RatelSpace.md),
            Text(context.l10n.roleplayYourReply,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.small,
                    color: context.palette.muted)),
            const SizedBox(height: RatelSpace.sm),
            for (int i = 0; i < scene.choices.length; i++)
              _choice(context, scene, i),
            if (decided) ...<Widget>[
              const SizedBox(height: RatelSpace.sm),
              _feedback(context, scene.choices[_picked!]),
              const SizedBox(height: RatelSpace.md),
              RatelButton(
                key: const ValueKey<String>('roleplay-continue'),
                label: context.l10n.lessonContinue,
                expand: false,
                onPressed: () => _advance(s, scene),
              ),
            ],
          ] else ...<Widget>[
            const SizedBox(height: RatelSpace.md),
            RatelButton(
              key: const ValueKey<String>('roleplay-continue'),
              label: context.l10n.lessonContinue,
              expand: false,
              onPressed: () => _advance(s, scene),
            ),
          ],
        ],
      ],
    );
  }

  Widget _speakerLine(BuildContext context, CourseScene scene) => RatelCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(scene.speaker,
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.small,
                    color: RatelColors.purple)),
            const SizedBox(height: RatelSpace.xs),
            Text(scene.line,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.bodyLg,
                    height: 1.5,
                    color: context.palette.ink)),
          ],
        ),
      );

  Widget _choice(BuildContext context, CourseScene scene, int i) {
    final CourseChoice c = scene.choices[i];
    final bool decided = _picked != null;
    final bool isPick = _picked == i;
    final bool correct = c.isCorrect == true;
    Color bg = context.palette.cream2;
    Color line = context.palette.border;
    if (decided && (isPick || correct)) {
      final Color col = correct ? RatelColors.green : RatelColors.coral;
      bg = col.withValues(alpha: 0.12);
      line = col;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: RatelSpace.xs),
      child: GestureDetector(
        key: ValueKey<String>('roleplay-opt-$i'),
        onTap: decided ? null : () => setState(() => _picked = i),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(RatelSpace.md),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(RatelRadius.chip),
            border: Border.all(color: line),
          ),
          child: Text(c.label,
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.bodyLg,
                  color: context.palette.ink)),
        ),
      ),
    );
  }

  Widget _feedback(BuildContext context, CourseChoice c) {
    final bool correct = c.isCorrect == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(correct ? context.l10n.lessonNicelyDone : context.l10n.lessonNotQuite,
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                fontSize: RatelType.bodyLg,
                color: correct ? RatelColors.green : RatelColors.coral)),
        if (c.explain != null && c.explain!.isNotEmpty) ...<Widget>[
          const SizedBox(height: RatelSpace.xs),
          GestureDetector(
            key: const ValueKey<String>('roleplay-explain-toggle'),
            onTap: () => setState(() => _showExplain = !_showExplain),
            child: Text(context.l10n.lessonExplainThis,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.small,
                    color: RatelColors.teal)),
          ),
          if (_showExplain) ...<Widget>[
            const SizedBox(height: RatelSpace.xs),
            Text(c.explain!,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    height: 1.4,
                    color: context.palette.muted)),
          ],
        ],
      ],
    );
  }

  Widget _finished(BuildContext context) => RatelCard(
        child: Column(
          key: const ValueKey<String>('roleplay-done'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(context.l10n.roleplaySceneComplete,
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.bodyLg,
                    color: context.palette.ink)),
            const SizedBox(height: RatelSpace.sm),
            RatelButton(
                label: context.l10n.roleplayBack,
                expand: false,
                onPressed: () => context.pop()),
          ],
        ),
      );

  // M-3 fold-in: the shared honest unavailable card (Q-2) replaces the old
  // plain not-available text — same degrade as story/podcast/watch.
  Widget _notFound(BuildContext context) =>
      const ContentUnavailableCard(noun: 'roleplay');
}
