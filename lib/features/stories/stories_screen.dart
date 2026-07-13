import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// Read & Listen — the un-gated Stories library (INF-6). Lists the graded
/// stories the current course authors (content `passage`, kind=story), grouped
/// by CEFR level in data order, each opening the [StoryReaderScreen]. A course
/// with no stories yet shows an HONEST empty state — never a fabricated list.
/// Real audio/video (podcasts / watch) stays the owner-gated media piece. [R-B3]
class StoriesScreen extends ConsumerWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CourseStory> stories = ref.watch(courseSpineProvider).stories;
    // CEFR order (A1<A2<B1<B2<C1<C2 sorts lexicographically), then data order.
    final List<String> levels = <String>[];
    final Map<String, List<CourseStory>> byLevel = <String, List<CourseStory>>{};
    for (final CourseStory s in stories) {
      (byLevel[s.cefr] ??= <CourseStory>[]).add(s);
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
        title: Text(
          context.l10n.storiesTitle,
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            color: context.palette.ink,
            fontSize: RatelType.cardTitle,
          ),
        ),
      ),
      body: stories.isEmpty
          ? _empty(context)
          : ListView(
              padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                  RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
              children: <Widget>[
                Text(
                  context.l10n.storiesSub,
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      color: context.palette.muted),
                ),
                const SizedBox(height: RatelSpace.lg),
                for (final String level in levels) ...<Widget>[
                  RatelSectionHeader(label: level),
                  const SizedBox(height: RatelSpace.sm),
                  for (final CourseStory s in byLevel[level]!) ...<Widget>[
                    RatelListRow(
                      key: ValueKey<String>('story-row-${s.id}'),
                      leadingEmoji: '📖',
                      leadingColor: RatelColors.teal,
                      title: s.title,
                      subtitle: s.theme == null || s.theme!.isEmpty
                          ? context.l10n.mediaChecksCount(s.checkCount)
                          : s.theme!,
                      onTap: () => context.push(
                          '/story?passage=${Uri.encodeComponent(s.id)}'),
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
              const Text('📖', style: TextStyle(fontSize: 56)),
              const SizedBox(height: RatelSpace.md),
              Text(
                context.l10n.storiesEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.bodyLg,
                    color: context.palette.muted),
              ),
            ],
          ),
        ),
      );
}
