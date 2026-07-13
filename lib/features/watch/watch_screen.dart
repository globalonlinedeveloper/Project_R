import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

/// Watch (INF-9) -- the un-gated video library. Lists the Watch lessons the
/// current course authors (content `passage`, kind=video, each carrying a REAL
/// `video_ref` -> `media_asset` MP4 on R2), grouped by CEFR level in data order,
/// each opening the [WatchPlayerScreen]. A course with no Watch lessons yet shows
/// an HONEST empty state -- never a fabricated list. [R-B3]
class WatchScreen extends ConsumerWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CourseStory> watch = ref.watch(courseSpineProvider).watch;
    // CEFR order (A1<A2<B1<B2<C1<C2 sorts lexicographically), then data order.
    final List<String> levels = <String>[];
    final Map<String, List<CourseStory>> byLevel =
        <String, List<CourseStory>>{};
    for (final CourseStory p in watch) {
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
          context.l10n.libraryWatch,
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            color: context.palette.ink,
            fontSize: RatelType.cardTitle,
          ),
        ),
      ),
      body: watch.isEmpty
          ? _empty(context)
          : ListView(
              padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                  RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
              children: <Widget>[
                Text(
                  context.l10n.watchSub,
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
                      key: ValueKey<String>('watch-row-${p.id}'),
                      leadingEmoji: '🎬',
                      leadingColor: RatelColors.coral,
                      title: p.title,
                      subtitle: p.theme == null || p.theme!.isEmpty
                          ? context.l10n.mediaChecksCount(p.checkCount)
                          : p.theme!,
                      onTap: () => context.push(
                          '/watch-play?passage=${Uri.encodeComponent(p.id)}'),
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
              const Text('🎬', style: TextStyle(fontSize: 56)),
              const SizedBox(height: RatelSpace.md),
              Text(
                context.l10n.watchEmpty,
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
