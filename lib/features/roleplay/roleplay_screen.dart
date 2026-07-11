import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// Roleplay (INF-8) -- the un-gated pre-generated roleplay library. Lists the
/// graded roleplay drills the current course authors (content `scenario`,
/// kind=roleplay), grouped by CEFR level in data order, each opening the
/// [RoleplayPlayerScreen]. A course with none yet shows an HONEST empty state --
/// never a fabricated list. [R-D10 - R-B3]
class RoleplayScreen extends ConsumerWidget {
  const RoleplayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CourseScenario> items = ref.watch(courseSpineProvider).roleplays;
    final bool isPro = ref.watch(isProProvider);
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
        title: Text('Roleplay',
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                color: context.palette.ink,
                fontSize: RatelType.cardTitle)),
      ),
      body: items.isEmpty
          ? _empty(context)
          : ListView(
              key: const ValueKey<String>('screen-roleplay'),
              padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                  RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
              children: <Widget>[
                Text(
                  'Practice real conversations -- pick the right reply, get instant feedback.',
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      color: context.palette.muted),
                ),
                const SizedBox(height: RatelSpace.lg),
                // L-3 (S113): the LIVE variant entry — ADDITIVE beside the
                // pre-generated list (plan §B; anti-goal §D: this screen's
                // authored surface is untouched). Two-signal honesty lives on
                // the LiveRoleplayScreen itself. [R-H6 · R-J1]
                RatelCard(
                  key: const ValueKey<String>('live-roleplay-entry'),
                  gradient: const LinearGradient(
                      colors: <Color>[RatelColors.teal, RatelColors.tealDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  onTap: () => context.push('/roleplay-live'),
                  child: Row(
                    children: <Widget>[
                      const Text('🎙️', style: TextStyle(fontSize: 30)),
                      const SizedBox(width: RatelSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('Live Roleplay',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: RatelFont.display,
                                    fontWeight: RatelType.extraBold,
                                    fontSize: RatelType.cardTitle,
                                    color: RatelColors.onColor)),
                            Text('Talk it out with Ratel — real voice',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: RatelFont.body,
                                    fontSize: RatelType.small,
                                    color: RatelColors.onColor)),
                          ],
                        ),
                      ),
                      if (!isPro) ...<Widget>[
                        const SizedBox(width: RatelSpace.sm),
                        RatelChip.pro(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: RatelSpace.lg),
                for (final String level in levels) ...<Widget>[
                  RatelSectionHeader(label: level),
                  const SizedBox(height: RatelSpace.sm),
                  for (final CourseScenario s in byLevel[level]!) ...<Widget>[
                    RatelListRow(
                      key: ValueKey<String>('roleplay-row-${s.id}'),
                      leadingEmoji: '🎭',
                      leadingColor: RatelColors.purple,
                      title: s.title,
                      subtitle: s.goal == null || s.goal!.isEmpty
                          ? (s.world ?? 'Roleplay')
                          : s.goal!,
                      onTap: () => context.push(
                          '/roleplay-play?scenario=${Uri.encodeComponent(s.id)}'),
                    ),
                    const SizedBox(height: RatelSpace.sm),
                  ],
                  const SizedBox(height: RatelSpace.md),
                ],
              ],
            ),
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(RatelSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('🎭', style: TextStyle(fontSize: 56)),
              const SizedBox(height: RatelSpace.md),
              Text('No roleplays in this course yet.',
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
