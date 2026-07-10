import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/notifications/notifications_controller.dart';

/// Library tab (📚) — design spec §4.2 + owner-bundle `scraps/b-lib.png`
/// (UXA S115-L5 dense rebuild). Everything here is REAL: the Featured Story and
/// the inline Graded-Stories / Podcasts / Watch rows read the authored course
/// (`courseSpineProvider`), the PRO badge is the real billing entitlement
/// (`isProProvider`), and every row opens its real reader/player. HONEST DELTAS
/// (anti-goal §E — never fake): no per-passage duration ⇒ the mock's "· N min"
/// is OMITTED; no resume engine ⇒ the mock's CONTINUE card is OMITTED;
/// `CourseStory` carries no per-item Pro tier ⇒ the mock's per-podcast PRO badge
/// is OMITTED (the app-level Pro gate stays on AI Tutor). A course that authors
/// no media shows each section's honest "all …" browse entry, never a
/// fabricated item list.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  /// Max REAL items shown inline per Read&Listen section; the rest live on the
  /// dedicated screen, reached via the honest "all …" row.
  static const int _inlineCap = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final int unread = ref.watch(unreadNotificationsCountProvider);
    final bool isPro = ref.watch(isProProvider);
    final CourseSpine spine = ref.watch(courseSpineProvider);
    return Container(
      key: const ValueKey<String>('tab-library'),
      color: context.palette.cream,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RatelTopBar(
                flagEmoji: '🇪🇸',
                langCode: 'ES',
                streak: snap.streakDays,
                energy: snap.energy,
                unreadNotifications: unread,
                onNotificationsTap: () => context.push('/notifications')),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                    RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
                children: <Widget>[
                  Text('Library',
                      style: TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.screenTitle,
                          color: context.palette.ink)),
                  const SizedBox(height: RatelSpace.md),
                  _searchBar(context),
                  const SizedBox(height: RatelSpace.lg),
                  // AI Tutor — the app-level Pro gate lives here (real entitlement).
                  _featureCard(
                    context,
                    gradient: const LinearGradient(
                        colors: <Color>[RatelColors.teal, RatelColors.tealDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    emoji: '🦡',
                    title: 'AI Tutor',
                    subtitle: 'Talk, chat & roleplay — writing feedback',
                    badge: isPro ? null : RatelChip.pro(),
                    route: '/tutor',
                  ),
                  // B-1 Featured Story — the first authored story (REAL). Omitted
                  // (never faked) when the course authors none.
                  if (spine.stories.isNotEmpty) ...<Widget>[
                    const SizedBox(height: RatelSpace.cardGap),
                    _featuredStory(context, spine.stories.first),
                  ],
                  const SizedBox(height: RatelSpace.cardGap),
                  // B-6 Adventures — "NEW · EXPLORE" eyebrow + "Start exploring →".
                  _adventuresCard(context),
                  const SizedBox(height: RatelSpace.cardGap),
                  _featureCard(
                    context,
                    gradient: const LinearGradient(
                        colors: <Color>[RatelColors.purple, RatelColors.coral],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    emoji: '🎭',
                    title: 'Roleplay',
                    subtitle: 'Practice replies — graded, always free',
                    badge: RatelChip.free(),
                    route: '/roleplay',
                  ),
                  const SizedBox(height: RatelSpace.lg),
                  const RatelSectionHeader(label: 'Practice'),
                  const SizedBox(height: RatelSpace.sm),
                  RatelListRow(
                    leadingEmoji: '🎯',
                    leadingColor: RatelColors.green,
                    title: 'Practice hub',
                    subtitle: 'Mistakes, weak words & drills · FREE',
                    onTap: () => context.push('/practice'),
                  ),
                  const SizedBox(height: RatelSpace.lg),
                  const RatelSectionHeader(label: 'Read & listen'),
                  const SizedBox(height: RatelSpace.md),
                  // B-3 dense inline rows from the REAL authored course. The
                  // Featured card is stories.first, so Graded stories skips it.
                  ..._mediaSection(
                    context,
                    label: 'Graded stories',
                    items: spine.stories.length > 1
                        ? spine.stories.sublist(1)
                        : const <CourseStory>[],
                    kindLabel: 'Story',
                    emoji: '📖',
                    color: RatelColors.teal,
                    rowRoute: '/story',
                    allRoute: '/stories',
                    allLabel: 'All stories',
                    play: false,
                  ),
                  ..._mediaSection(
                    context,
                    label: 'Podcasts',
                    items: spine.podcasts,
                    kindLabel: 'Podcast',
                    emoji: '🎧',
                    color: RatelColors.purple,
                    rowRoute: '/podcast',
                    allRoute: '/podcasts',
                    allLabel: 'All podcasts',
                    play: true,
                  ),
                  ..._mediaSection(
                    context,
                    label: 'Watch',
                    items: spine.watch,
                    kindLabel: 'Video',
                    emoji: '🎬',
                    color: RatelColors.coral,
                    rowRoute: '/watch-play',
                    allRoute: '/watch',
                    allLabel: 'All videos',
                    play: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) => GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: RatelSpace.lg, vertical: RatelSpace.md),
          decoration: BoxDecoration(
            color: context.palette.white,
            borderRadius: BorderRadius.circular(RatelRadius.pill),
            border: Border.all(color: context.palette.border),
          ),
          child: Row(
            children: <Widget>[
              const Text('🔍', style: TextStyle(fontSize: 16)),
              const SizedBox(width: RatelSpace.sm),
              Expanded(
                child: Text('Search lessons, words, stories…',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.body,
                        color: context.palette.muted)),
              ),
            ],
          ),
        ),
      );

  // B-1 Featured Story — real title + CEFR + "Read now" (opens the real reader).
  // No "· N min": CourseStory carries no duration, so it stays omitted (§E).
  Widget _featuredStory(BuildContext context, CourseStory story) => RatelCard(
        gradient: const LinearGradient(
            colors: <Color>[RatelColors.green, RatelColors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        onTap: () =>
            context.push('/story?passage=${Uri.encodeComponent(story.id)}'),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('FEATURED · STORY',
                      style: TextStyle(
                          fontFamily: RatelFont.body,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.caption,
                          letterSpacing: 1.3,
                          color: RatelColors.onColor)),
                  const SizedBox(height: RatelSpace.sm),
                  Text(story.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.cardTitle,
                          color: RatelColors.onColor)),
                  const SizedBox(height: RatelSpace.xs),
                  Text('Level ${story.cefr}',
                      style: const TextStyle(
                          fontFamily: RatelFont.body,
                          fontSize: RatelType.small,
                          color: RatelColors.onColor)),
                  const SizedBox(height: RatelSpace.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: RatelSpace.lg, vertical: RatelSpace.sm),
                    decoration: BoxDecoration(
                      color: RatelColors.onColor,
                      borderRadius: BorderRadius.circular(RatelRadius.pill),
                    ),
                    child: const Text('Read now',
                        style: TextStyle(
                            fontFamily: RatelFont.body,
                            fontWeight: RatelType.extraBold,
                            fontSize: RatelType.small,
                            color: RatelColors.tealDark)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: RatelSpace.md),
            const Text('📖', style: TextStyle(fontSize: 44)),
          ],
        ),
      );

  // B-6 Adventures — eyebrow "NEW · EXPLORE" + FREE + copy + "Start exploring →".
  Widget _adventuresCard(BuildContext context) => RatelCard(
        gradient: const LinearGradient(
            colors: <Color>[RatelColors.blue, RatelColors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        onTap: () => context.push('/adventures'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text('NEW · EXPLORE',
                      style: TextStyle(
                          fontFamily: RatelFont.body,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.caption,
                          letterSpacing: 1.3,
                          color: RatelColors.onColor)),
                ),
                const SizedBox(width: RatelSpace.sm),
                RatelChip.free(),
              ],
            ),
            const SizedBox(height: RatelSpace.sm),
            const Text('Adventures',
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.cardTitle,
                    color: RatelColors.onColor)),
            const SizedBox(height: RatelSpace.xs),
            const Text(
                'Walk a living world and talk your way through real scenes.',
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    color: RatelColors.onColor)),
            const SizedBox(height: RatelSpace.md),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: RatelSpace.lg, vertical: RatelSpace.sm),
              decoration: BoxDecoration(
                color: RatelColors.onColor,
                borderRadius: BorderRadius.circular(RatelRadius.pill),
              ),
              child: const Text('Start exploring →',
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontWeight: RatelType.extraBold,
                      fontSize: RatelType.small,
                      color: RatelColors.blue)),
            ),
          ],
        ),
      );

  // B-3 — one Read&Listen section: header + up to [_inlineCap] REAL rows + an
  // honest "all …" browse row (always present ⇒ navigable even when empty).
  List<Widget> _mediaSection(
    BuildContext context, {
    required String label,
    required List<CourseStory> items,
    required String kindLabel,
    required String emoji,
    required Color color,
    required String rowRoute,
    required String allRoute,
    required String allLabel,
    required bool play,
  }) {
    return <Widget>[
      RatelSectionHeader(label: label),
      const SizedBox(height: RatelSpace.sm),
      for (final CourseStory s in items.take(_inlineCap)) ...<Widget>[
        RatelListRow(
          key: ValueKey<String>('lib-row-${s.id}'),
          leadingEmoji: emoji,
          leadingColor: color,
          title: s.title,
          subtitle: '$kindLabel · ${s.cefr}',
          trailing: play
              ? Text('▶', style: TextStyle(fontSize: 18, color: color))
              : null,
          onTap: () =>
              context.push('$rowRoute?passage=${Uri.encodeComponent(s.id)}'),
        ),
      ],
      RatelListRow(
        key: ValueKey<String>('lib-all-$allRoute'),
        title: allLabel,
        onTap: () => context.push(allRoute),
      ),
      const SizedBox(height: RatelSpace.md),
    ];
  }

  Widget _featureCard(
    BuildContext context, {
    required Gradient gradient,
    required String emoji,
    required String title,
    required String subtitle,
    required String route,
    Widget? badge,
  }) =>
      RatelCard(
        gradient: gradient,
        onTap: () => context.push(route),
        child: Row(
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: const TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.cardTitle,
                          color: RatelColors.onColor)),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: RatelFont.body,
                          fontSize: RatelType.small,
                          color: RatelColors.onColor)),
                ],
              ),
            ),
            if (badge != null) ...<Widget>[
              const SizedBox(width: RatelSpace.sm),
              badge,
            ],
          ],
        ),
      );
}
