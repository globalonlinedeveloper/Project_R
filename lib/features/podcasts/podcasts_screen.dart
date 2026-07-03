import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// Podcasts (INF-7) -- the un-gated audio library. Lists the graded podcasts the
/// current course authors (content `passage`, kind=podcast, each carrying a REAL
/// `audio_ref` -> `media_asset` MP3), grouped by CEFR level in data order, each
/// opening the [PodcastPlayerScreen]. A course with no podcasts yet shows an
/// HONEST empty state -- never a fabricated list. [R-B3]
class PodcastsScreen extends ConsumerWidget {
  const PodcastsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CourseStory> podcasts = ref.watch(courseSpineProvider).podcasts;
    // CEFR order (A1<A2<B1<B2<C1<C2 sorts lexicographically), then data order.
    final List<String> levels = <String>[];
    final Map<String, List<CourseStory>> byLevel =
        <String, List<CourseStory>>{};
    for (final CourseStory p in podcasts) {
      (byLevel[p.cefr] ??= <CourseStory>[]).add(p);
      if (!levels.contains(p.cefr)) levels.add(p.cefr);
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
          'Podcasts',
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            color: context.palette.ink,
            fontSize: RatelType.cardTitle,
          ),
        ),
      ),
      body: podcasts.isEmpty
          ? _empty(context)
          : ListView(
              padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                  RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
              children: <Widget>[
                Text(
                  'Listen -- graded podcasts with real audio and a transcript.',
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      color: context.palette.muted),
                ),
                const SizedBox(height: RatelSpace.lg),
                for (final String level in levels) ...<Widget>[
                  RatelSectionHeader(label: level),
                  const SizedBox(height: RatelSpace.sm),
                  for (final CourseStory p in byLevel[level]!) ...<Widget>[
                    RatelListRow(
                      key: ValueKey<String>('podcast-row-${p.id}'),
                      leadingEmoji: '🎧',
                      leadingColor: RatelColors.teal,
                      title: p.title,
                      subtitle: p.theme == null || p.theme!.isEmpty
                          ? '${p.checkCount} comprehension check'
                              '${p.checkCount == 1 ? '' : 's'}'
                          : p.theme!,
                      onTap: () => context.push(
                          '/podcast?passage=${Uri.encodeComponent(p.id)}'),
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
              const Text('🎧', style: TextStyle(fontSize: 56)),
              const SizedBox(height: RatelSpace.md),
              Text(
                'No podcasts in this course yet.',
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
