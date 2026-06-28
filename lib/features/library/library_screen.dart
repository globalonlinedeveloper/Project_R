import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';

/// Library tab (📚) — design spec §4.2. REAL where an engine exists: the PRO
/// badges are driven by the actual billing entitlement (`isProProvider`, free by
/// default), and Practice routes to the real review queue. Story / podcast /
/// video players have NO media engine (§6) and are honest "coming soon" stubs —
/// never a faked player.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final bool isPro = ref.watch(isProProvider);
    return Container(
      key: const ValueKey<String>('tab-library'),
      color: RatelColors.cream,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RatelTopBar(
                flagEmoji: '🇪🇸', langCode: 'ES', streak: snap.streakDays),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                    RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
                children: <Widget>[
                  const Text('Library',
                      style: TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.screenTitle,
                          color: RatelColors.ink)),
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
                  const SizedBox(height: RatelSpace.lg),
                  const RatelSectionHeader(label: 'Practice'),
                  const SizedBox(height: RatelSpace.sm),
                  RatelListRow(
                    leadingEmoji: '🎯',
                    leadingColor: RatelColors.green,
                    title: 'Practice hub',
                    subtitle: 'Mistakes, weak words & drills · FREE',
                    onTap: () => context.push('/daily-quiz'),
                  ),
                  const SizedBox(height: RatelSpace.lg),
                  const RatelSectionHeader(label: 'Read & listen'),
                  const SizedBox(height: RatelSpace.sm),
                  _comingSoonCard('🎧',
                      'Graded stories, podcasts and video need a media / audio engine — coming as an owner decision (§6). Nothing here is faked.'),
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
            color: RatelColors.white,
            borderRadius: BorderRadius.circular(RatelRadius.pill),
            border: Border.all(color: RatelColors.border),
          ),
          child: const Row(
            children: <Widget>[
              Text('🔍', style: TextStyle(fontSize: 16)),
              SizedBox(width: RatelSpace.sm),
              Text('Search lessons, words, stories…',
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.body,
                      color: RatelColors.muted)),
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

  Widget _comingSoonCard(String emoji, String text) => RatelCard(
        color: RatelColors.cream2,
        child: Row(
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.body,
                      color: RatelColors.muted)),
            ),
            const RatelChip(label: 'Soon', tone: RatelChipTone.neutral),
          ],
        ),
      );
}
