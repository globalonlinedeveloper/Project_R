import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// Adventures (🗺️, INF-8) -- the FREE branching-dialogue library. Lists the
/// pre-generated adventures the current course authors (content `scenario`,
/// kind=adventure), grouped by CEFR level in data order, each opening the
/// branching [AdventurePlayerScreen]. Pure authored content (choose-your-path, no
/// wrong answers) -- NO live AI, no fabricated conversation. A course with none
/// yet shows an HONEST empty state. [R-D10 - R-B3 - R-J1]
class AdventuresScreen extends ConsumerWidget {
  const AdventuresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CourseScenario> items =
        ref.watch(courseSpineProvider).adventures;
    final List<String> levels = <String>[];
    final Map<String, List<CourseScenario>> byLevel =
        <String, List<CourseScenario>>{};
    for (final CourseScenario s in items) {
      (byLevel[s.cefr] ??= <CourseScenario>[]).add(s);
      if (!levels.contains(s.cefr)) levels.add(s.cefr);
    }
    levels.sort();

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
        title: Text('Adventures',
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                color: context.palette.ink,
                fontSize: RatelType.cardTitle)),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: RatelSpace.lg),
            child:
                Center(child: RatelChip(label: 'FREE', tone: RatelChipTone.green)),
          ),
        ],
      ),
      body: items.isEmpty
          ? _empty(context)
          : ListView(
              key: const ValueKey<String>('screen-adventures'),
              padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                  RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
              children: <Widget>[
                Text(
                  'Choose your path -- every choice branches the story. No wrong answers, always free.',
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.body,
                      color: context.palette.muted),
                ),
                const SizedBox(height: RatelSpace.lg),
                for (final String level in levels) ...<Widget>[
                  RatelSectionHeader(label: level),
                  const SizedBox(height: RatelSpace.sm),
                  for (final CourseScenario s in byLevel[level]!) ...<Widget>[
                    RatelListRow(
                      key: ValueKey<String>('adventure-row-${s.id}'),
                      leadingEmoji: '🗺️',
                      leadingColor: RatelColors.blue,
                      title: s.title,
                      subtitle: s.goal == null || s.goal!.isEmpty
                          ? (s.world ?? 'Adventure')
                          : s.goal!,
                      onTap: () => context.push(
                          '/adventure?scenario=${Uri.encodeComponent(s.id)}'),
                      // M-3: long-press opens the REAL scene-script preview
                      // (mirrors the lesson preview sheet).
                      onLongPress: () => _showScenePreview(context, s),
                    ),
                    const SizedBox(height: RatelSpace.sm),
                  ],
                  const SizedBox(height: RatelSpace.md),
                ],
              ],
            ),
    );
  }

  /// M-3 (screen review §2): the scene-script preview sheet — the SAME sheet
  /// grammar as the Home lesson preview (kicker / title / meta / primary CTA),
  /// filled with the REAL authored opening scene: speaker + line + the actual
  /// branching choices. Pure data off [CourseScenario.scenes]; nothing invented.
  void _showScenePreview(BuildContext context, CourseScenario s) {
    final int decisions =
        s.scenes.where((CourseScene sc) => sc.isDecision).length;
    final CourseScene? opening = s.scenes.isEmpty ? null : s.scenes.first;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(RatelRadius.featureLg))),
      builder: (BuildContext sheetContext) => Padding(
        padding: const EdgeInsets.all(RatelSpace.xl),
        child: Column(
          key: const ValueKey<String>('adventure-preview-sheet'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('🗺️ ADVENTURE · ${s.cefr}',
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.caption,
                    fontWeight: RatelType.semiBold,
                    color: sheetContext.palette.muted)),
            const SizedBox(height: 4),
            Text(s.title,
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.screenTitle,
                    color: sheetContext.palette.ink)),
            const SizedBox(height: 4),
            Text(
                '${s.scenes.length} scenes · '
                '$decisions choice ${decisions == 1 ? 'point' : 'points'}'
                '${s.goal != null && s.goal!.isNotEmpty ? ' · ${s.goal!}' : ''}',
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: sheetContext.palette.muted)),
            if (opening != null) ...<Widget>[
              const SizedBox(height: RatelSpace.md),
              Text('OPENING SCENE',
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.caption,
                      fontWeight: RatelType.semiBold,
                      color: sheetContext.palette.muted)),
              const SizedBox(height: RatelSpace.sm),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    key: const ValueKey<String>('adventure-preview-script'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${opening.speaker}: ${opening.line}',
                          style: TextStyle(
                              fontFamily: RatelFont.body,
                              fontSize: RatelType.body,
                              height: 1.45,
                              color: sheetContext.palette.ink)),
                      for (final CourseChoice ch in opening.choices)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: RatelSpace.sm, left: RatelSpace.md),
                          child: Text('› ${ch.label}',
                              style: TextStyle(
                                  fontFamily: RatelFont.body,
                                  fontSize: RatelType.body,
                                  height: 1.3,
                                  color: sheetContext.palette.muted)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: RatelSpace.lg),
            RatelButton(
              key: const ValueKey<String>('adventure-preview-start'),
              label: 'Start adventure',
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.push(
                    '/adventure?scenario=${Uri.encodeComponent(s.id)}');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(RatelSpace.xl),
          child: Column(
            key: const ValueKey<String>('screen-adventures'),
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('🗺️', style: TextStyle(fontSize: 56)),
              const SizedBox(height: RatelSpace.md),
              Text('No adventures in this course yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.bodyLg,
                      color: context.palette.muted)),
            ],
          ),
        ),
      );
}
