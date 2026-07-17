import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/library/last_read_controller.dart';
import 'package:ratel/features/notifications/notifications_controller.dart';

/// Library tab (📚) — design spec §4.2 + owner-bundle `scraps/b-lib.png`
/// (UXA S115-L5 dense rebuild). Everything here is REAL: the Featured Story and
/// the inline Graded-Stories / Podcasts / Watch rows read the authored course
/// (`courseSpineProvider`), the PRO badge is the real billing entitlement
/// (`isProProvider`), and every row opens its real reader/player. HONEST DELTAS
/// (anti-goal §E — never fake): CourseStory has no AUTHORED duration, so the
/// mock's "· N min" is rendered as a COMPUTED "· ~N min" READING-TIME ESTIMATE
/// (from the resolved sentence count — the '~' marks it an estimate, not an
/// authored fact; CEFR-only when a story has no sentences). The mock's
/// CONTINUE card (s163 INC-C3) is now REAL: it appears as the FIRST item under
/// READ & LISTEN, but ONLY once the learner has actually opened a story on this
/// device (`lastReadControllerProvider`) AND that story still resolves in the
/// current spine — nothing is shown otherwise (honest empty state), and no
/// progress %/time-left is ever fabricated (a resume pointer is not a claim
/// about completion);
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
    // s163 INC-C3 — the device-local resume pointer. Resolved against the LIVE
    // spine below (spine wins on display); a pointer that no longer resolves is
    // pruned post-frame via clearIfStale, so a course switch/content pull never
    // leaves a dead CONTINUE card.
    final LastReadRef? lastRead = ref.watch(lastReadControllerProvider);
    final CourseStory? resumeStory = _resolveResume(lastRead, spine);
    if (lastRead != null && resumeStory == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(lastReadControllerProvider.notifier).clearIfStale(spine);
      });
    }
    // E3 (INC-10): reveal the app-wide animated WorldBackdrop behind this tab for
    // every backdrop world — mirrors Home's E1 fix. Derived exactly as ratel_app.dart;
    // Daylight (backdrop `none`) keeps its solid cream. The translucent scaffold
    // (theme.dart, 80% tint) is the readability floor, so no scrim is needed.
    final bool hasBackdrop =
        kBackdropPainters.containsKey(ref.watch(activeWorldProvider).backdrop);
    return Container(
      key: const ValueKey<String>('tab-library'),
      color: hasBackdrop ? Colors.transparent : context.palette.cream,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RatelTopBar(
                flagEmoji: courseFlagEmoji(spine.courseCode),
                langCode: courseLangCode(spine.courseCode),
                onLanguageTap: () => context.push('/courses'),
                streak: snap.streakDays,
                energy: snap.energy,
                unreadNotifications: unread,
                onNotificationsTap: () => context.push('/notifications')),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                    RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
                children: <Widget>[
                  Text(context.l10n.navLibrary,
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
                    // L-3: design ships the AI-Tutor card as a flat navy panel
                    // (#15324a == RatelColors.navy), not the teal gradient.
                    color: RatelColors.navy,
                    emoji: '🦡',
                    title: context.l10n.libraryAiTutor,
                    subtitle: context.l10n.libraryAiTutorSub,
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
                    title: context.l10n.libraryRoleplay,
                    subtitle: context.l10n.libraryRoleplaySub,
                    badge: RatelChip.free(context.l10n.adventuresFreeChip),
                    route: '/roleplay',
                  ),
                  const SizedBox(height: RatelSpace.lg),
                  RatelSectionHeader(label: context.l10n.librarySectionPractice),
                  const SizedBox(height: RatelSpace.sm),
                  RatelListRow(
                    leadingEmoji: '🎯',
                    leadingColor: RatelColors.green,
                    title: context.l10n.libraryPracticeHub,
                    subtitle: context.l10n.libraryPracticeHubSub,
                    onTap: () => context.push('/practice'),
                  ),
                  const SizedBox(height: RatelSpace.lg),
                  RatelSectionHeader(label: context.l10n.librarySectionReadListen),
                  const SizedBox(height: RatelSpace.md),
                  // s163 INC-C3 CONTINUE — the FIRST item under READ & LISTEN when a
                  // real resume pointer resolves in the current spine (else omitted).
                  if (resumeStory != null) ...<Widget>[
                    _continueCard(context, lastRead!, resumeStory),
                    const SizedBox(height: RatelSpace.md),
                  ],
                  // B-3 dense inline rows from the REAL authored course. The
                  // Featured card is stories.first, so Graded stories skips it.
                  ..._mediaSection(
                    context,
                    label: context.l10n.libraryGradedStories,
                    items: spine.stories.length > 1
                        ? spine.stories.sublist(1)
                        : const <CourseStory>[],
                    kindLabel: context.l10n.libraryKindStory,
                    emoji: '📖',
                    color: RatelColors.teal,
                    rowRoute: '/story',
                    allRoute: '/stories',
                    allLabel: context.l10n.libraryAllStories,
                    play: false,
                  ),
                  ..._mediaSection(
                    context,
                    label: context.l10n.libraryPodcasts,
                    items: spine.podcasts,
                    kindLabel: context.l10n.libraryKindPodcast,
                    emoji: '🎧',
                    color: RatelColors.purple,
                    rowRoute: '/podcast',
                    allRoute: '/podcasts',
                    allLabel: context.l10n.libraryAllPodcasts,
                    play: true,
                  ),
                  ..._mediaSection(
                    context,
                    label: context.l10n.libraryWatch,
                    items: spine.watch,
                    kindLabel: context.l10n.libraryKindVideo,
                    emoji: '🎬',
                    color: RatelColors.coral,
                    rowRoute: '/watch-play',
                    allRoute: '/watch',
                    allLabel: context.l10n.libraryAllVideos,
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

  /// s163 INC-C3 — resolve the resume pointer to the LIVE spine story it points
  /// at (spine wins on display: title/level always come from the current spine,
  /// never the stored copy). Returns null when there is no pointer, the pointer
  /// belongs to a different course, or its id no longer exists in the spine —
  /// each case means NO CONTINUE card (honest, no dead pointer). Stories-first
  /// scope for v1; the pointer supports podcasts/watch for a follow-up.
  CourseStory? _resolveResume(LastReadRef? ref, CourseSpine spine) {
    if (ref == null || ref.courseCode != spine.courseCode) return null;
    final List<CourseStory> pool = ref.kind == 'podcast'
        ? spine.podcasts
        : ref.kind == 'watch'
            ? spine.watch
            : spine.stories;
    for (final CourseStory s in pool) {
      if (s.id == ref.passageId) return s;
    }
    return null;
  }

  /// The route that reopens a resume pointer of [kind] (mirrors the row routes
  /// used elsewhere on this screen). Stories-first; podcast/watch are wired for
  /// a follow-up that also records those kinds.
  static String _routeForKind(String kind) {
    switch (kind) {
      case 'podcast':
        return '/podcast';
      case 'watch':
        return '/watch-play';
      default:
        return '/story';
    }
  }

  // s163 INC-C3 CONTINUE card — the design's resume slot: a "CONTINUE" eyebrow +
  // the LIVE story title + level (· ~N min only when it has sentences, same rule
  // as the Featured/row subtitles) + an orange ▶. Tap reopens the story. It is
  // an HONEST resume pointer (the device recorded that the user opened this
  // story) — never a progress %, never a "N min left".
  Widget _continueCard(
          BuildContext context, LastReadRef ref, CourseStory story) =>
      RatelCard(
        key: const ValueKey<String>('lib-continue'),
        color: context.palette.white,
        onTap: () => context.push(
            '${_routeForKind(ref.kind)}?passage=${Uri.encodeComponent(story.id)}'),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(context.l10n.lessonContinue.toUpperCase(),
                      style: const TextStyle(
                          fontFamily: RatelFont.body,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.caption,
                          letterSpacing: 1.3,
                          color: RatelColors.amber)),
                  const SizedBox(height: RatelSpace.xs),
                  Text(story.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.cardTitle,
                          color: context.palette.ink)),
                  const SizedBox(height: RatelSpace.xs),
                  Text(
                      story.sentences.isNotEmpty
                          ? '${context.l10n.commonLevel(story.cefr)} · '
                              '${context.l10n.libraryEstMinutes(story.estMinutes)}'
                          : context.l10n.commonLevel(story.cefr),
                      style: TextStyle(
                          fontFamily: RatelFont.body,
                          fontSize: RatelType.small,
                          color: context.palette.muted)),
                ],
              ),
            ),
            const SizedBox(width: RatelSpace.md),
            const Text('▶',
                style: TextStyle(fontSize: 22, color: RatelColors.amber)),
          ],
        ),
      );

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
                child: Text(context.l10n.librarySearchHint,
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
  // The level line appends a COMPUTED "· ~N min" reading-time estimate (from the
  // story's sentence count) when it has sentences — the '~' marks it an estimate,
  // not an authored duration (§E); CEFR-only when the story has no sentences.
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
                  Text(context.l10n.libraryFeaturedStory,
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
                  Text(
                      story.sentences.isNotEmpty
                          ? '${context.l10n.commonLevel(story.cefr)} · '
                              '${context.l10n.libraryEstMinutes(story.estMinutes)}'
                          : context.l10n.commonLevel(story.cefr),
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
                    child: Text(context.l10n.libraryReadNow,
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
                Expanded(
                  child: Text(context.l10n.libraryNewExplore,
                      style: TextStyle(
                          fontFamily: RatelFont.body,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.caption,
                          letterSpacing: 1.3,
                          color: RatelColors.onColor)),
                ),
                const SizedBox(width: RatelSpace.sm),
                RatelChip.free(context.l10n.adventuresFreeChip),
              ],
            ),
            const SizedBox(height: RatelSpace.sm),
            Text(context.l10n.libraryAdventures,
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.cardTitle,
                    color: RatelColors.onColor)),
            const SizedBox(height: RatelSpace.xs),
            Text(
                context.l10n.libraryAdventuresSub,
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
              child: Text(context.l10n.libraryStartExploring,
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
          subtitle: s.sentences.isNotEmpty
              ? '$kindLabel · ${s.cefr} · ${context.l10n.libraryEstMinutes(s.estMinutes)}'
              : '$kindLabel · ${s.cefr}',
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
    Gradient? gradient,
    Color? color,
    required String emoji,
    required String title,
    required String subtitle,
    required String route,
    Widget? badge,
  }) =>
      RatelCard(
        gradient: gradient,
        color: color,
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
