import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel;
import 'package:ratel/core/core.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/preferences/app_settings.dart';

/// Profile tab (🦡) — design spec §4.5, built HONESTLY. Surfaces the REAL
/// learner snapshot (CEFR level from θ via cold_start, XP, lessons completed,
/// streak, saved words) and the REAL identity: a fresh install is a GUEST —
/// never the mockup's "Alex Rivera · Level A2 · 1,240 XP". Design elements with
/// no engine (achievements, leagues, "Top 3", friends) are honest "coming soon"
/// rows, never fabricated (§6).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final int words = ref.watch(savedWordsControllerProvider);
    final Identity identity = ref.watch(identityProvider);
    final AppSettings settings = ref.watch(appSettingsControllerProvider);
    final String level = snap.level.name.toUpperCase();

    return Container(
      key: const ValueKey<String>('tab-profile'),
      color: RatelColors.cream,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(RatelSpace.screen, RatelSpace.lg,
              RatelSpace.screen, RatelSpace.xl),
          children: <Widget>[
            _header(context, identity, level),
            const SizedBox(height: RatelSpace.cardGap),
            _stats(snap, words),
            const SizedBox(height: RatelSpace.cardGap),
            _progressBanner(context, level, snap, settings),
            const SizedBox(height: RatelSpace.lg),
            const RatelSectionHeader(label: 'Achievements'),
            const SizedBox(height: RatelSpace.sm),
            _comingSoonCard(
                '🏅', 'Achievements unlock as you learn — coming soon.'),
            const SizedBox(height: RatelSpace.lg),
            const RatelSectionHeader(label: 'Account'),
            const SizedBox(height: RatelSpace.sm),
            RatelListRow(
                leadingEmoji: '⚙️',
                leadingColor: RatelColors.muted,
                title: 'Settings',
                onTap: () => context.push('/settings')),
            const SizedBox(height: RatelSpace.sm),
            RatelListRow(
                leadingEmoji: '💎',
                leadingColor: RatelColors.amber,
                title: 'Shop',
                onTap: () => context.push('/shop')),
            const SizedBox(height: RatelSpace.sm),
            RatelListRow(
                leadingEmoji: '🔔',
                leadingColor: RatelColors.blue,
                title: 'Notifications',
                onTap: () => context.push('/notifications')),
            const SizedBox(height: RatelSpace.sm),
            RatelListRow(
                leadingEmoji: '👥',
                leadingColor: RatelColors.purple,
                title: 'Friends',
                onTap: () => context.push('/friends')),
            const SizedBox(height: RatelSpace.lg),
            RatelButton(
                label: 'See onboarding flow ↗',
                variant: RatelButtonVariant.secondary,
                onPressed: () => context.push('/onboarding')),
            const SizedBox(height: RatelSpace.md),
            const Center(
              child: Text(
                'Level, XP, lessons, streak and saved words are real engine '
                'state — they start at zero on a fresh account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    color: RatelColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, Identity identity, String level) {
    final bool authed = identity.isAuthenticated;
    final String name = authed ? 'Learner' : 'Guest';
    final String sub =
        authed ? '🇪🇸 Spanish · Level $level' : 'Not signed in · 🇪🇸 Spanish';
    return RatelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    color: RatelColors.cream3, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('🦡', style: TextStyle(fontSize: 34)),
              ),
              const SizedBox(width: RatelSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: RatelFont.display,
                            fontWeight: RatelType.extraBold,
                            fontSize: RatelType.screenTitle,
                            color: RatelColors.ink)),
                    const SizedBox(height: 2),
                    Text(sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: RatelFont.body,
                            fontSize: RatelType.small,
                            color: RatelColors.muted)),
                  ],
                ),
              ),
              RatelChip.level(level),
            ],
          ),
          if (!authed) ...<Widget>[
            const SizedBox(height: RatelSpace.md),
            RatelButton(
                label: 'Create a free account',
                onPressed: () => context.push('/onboarding')),
            const SizedBox(height: RatelSpace.xs),
            const Center(
              child: Text('Save your progress across devices',
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      color: RatelColors.muted)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stats(LearnerSnapshot snap, int words) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
                child: _statCard('🔥', '${snap.streakDays}', 'Day streak')),
            const SizedBox(width: RatelSpace.cardGap),
            Expanded(child: _statCard('⚡', '${snap.xpTotal}', 'Total XP')),
          ],
        ),
        const SizedBox(height: RatelSpace.cardGap),
        Row(
          children: <Widget>[
            Expanded(
                child:
                    _statCard('📘', '${snap.lessonsCompleted}', 'Lessons')),
            const SizedBox(width: RatelSpace.cardGap),
            Expanded(child: _statCard('🔖', '$words', 'Saved words')),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String emoji, String value, String label) => RatelCard(
        child: Row(
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: RatelSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.cardTitle,
                          color: RatelColors.ink)),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: RatelFont.body,
                          fontSize: RatelType.small,
                          color: RatelColors.muted)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _progressBanner(BuildContext context, String level,
      LearnerSnapshot snap, AppSettings settings) {
    final int goal = settings.dailyGoal <= 0 ? 1 : settings.dailyGoal;
    final double ringVal = (snap.xpToday / goal).clamp(0.0, 1.0);
    return RatelCard(
      gradient: const LinearGradient(
        colors: <Color>[RatelColors.blue, RatelColors.navy],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onTap: () => context.push('/progress'),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Level $level · ${_levelName(snap.level)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.extraBold,
                        fontSize: RatelType.cardTitle,
                        color: RatelColors.onColor)),
                const SizedBox(height: 2),
                Text("Today's goal · ${snap.xpToday}/$goal XP",
                    style: const TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.small,
                        color: RatelColors.onColor)),
                const SizedBox(height: RatelSpace.sm),
                const Text('View progress →',
                    style: TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.semiBold,
                        fontSize: RatelType.small,
                        color: RatelColors.onColor)),
              ],
            ),
          ),
          const SizedBox(width: RatelSpace.md),
          RatelProgressRing(
            value: ringVal,
            size: 64,
            stroke: 8,
            color: RatelColors.onColor,
            center: Text('${snap.xpToday}/$goal',
                style: const TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.small,
                    color: RatelColors.onColor)),
          ),
        ],
      ),
    );
  }

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

  String _levelName(CefrLevel l) {
    switch (l) {
      case CefrLevel.a1:
        return 'Beginner';
      case CefrLevel.a2:
        return 'Elementary';
      case CefrLevel.b1:
        return 'Intermediate';
      case CefrLevel.b2:
        return 'Upper intermediate';
      case CefrLevel.c1:
        return 'Advanced';
      case CefrLevel.c2:
        return 'Proficient';
    }
  }
}
