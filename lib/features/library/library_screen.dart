import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/notifications/notifications_controller.dart';

/// Library tab (📚) — design spec §4.2. REAL where an engine exists: the PRO
/// badges are driven by the actual billing entitlement (`isProProvider`, free by
/// default), and Practice routes to the real review queue. Stories, Podcasts
/// and Watch are REAL surfaces: text + browser read-aloud (stories), streamed R2
/// audio (podcasts) and streamed R2 video (watch) on the web, degrading honestly
/// off-web. Nothing here is a faked player.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final int unread = ref.watch(unreadNotificationsCountProvider);
    final bool isPro = ref.watch(isProProvider);
    return Container(
      key: const ValueKey<String>('tab-library'),
      color: context.palette.cream,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // R-L11 inbox surface: the top-bar bell + unread badge open the
            // in-app notifications feed (a real, learner-derived count).
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
                  const SizedBox(height: RatelSpace.cardGap),
                  _featureCard(
                    context,
                    gradient: const LinearGradient(
                        colors: <Color>[RatelColors.blue, RatelColors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    emoji: '🗺️',
                    title: 'Adventures',
                    subtitle: 'Real conversations — always free',
                    badge: RatelChip.free(),
                    route: '/adventures',
                  ),
                  const SizedBox(height: RatelSpace.cardGap),
                  _featureCard(
                    context,
                    gradient: const LinearGradient(
                        colors: <Color>[RatelColors.purple, RatelColors.coral],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    emoji: '🎭',
                    title: 'Roleplay',
                    subtitle: 'Practice replies -- graded, always free',
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
                  const SizedBox(height: RatelSpace.sm),
                  _featureCard(
                    context,
                    gradient: const LinearGradient(
                        colors: <Color>[RatelColors.teal, RatelColors.tealDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    emoji: '📖',
                    title: 'Stories',
                    subtitle: 'Graded stories — read & listen aloud',
                    badge: RatelChip.free(),
                    route: '/stories',
                  ),
                  const SizedBox(height: RatelSpace.cardGap),
                  _featureCard(
                    context,
                    gradient: const LinearGradient(
                        colors: <Color>[RatelColors.purple, RatelColors.tealDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    emoji: '🎧',
                    title: 'Podcasts',
                    subtitle: 'Graded audio episodes -- listen with transcript',
                    badge: RatelChip.free(),
                    route: '/podcasts',
                  ),
                  const SizedBox(height: RatelSpace.cardGap),
                  _featureCard(
                    context,
                    gradient: const LinearGradient(
                        colors: <Color>[RatelColors.coral, RatelColors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    emoji: '🎬',
                    title: 'Watch',
                    subtitle: 'Short video clips -- watch with a transcript',
                    badge: RatelChip.free(),
                    route: '/watch',
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
              Text('🔍', style: TextStyle(fontSize: 16)),
              SizedBox(width: RatelSpace.sm),
              // S113: Expanded + ellipsis — the fixed label overflowed the
              // pill at narrow widths (caught by the L-4 460px router tour;
              // layout gauntlet rule: overflow = red).
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
