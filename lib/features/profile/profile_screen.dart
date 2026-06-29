import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel;
import 'package:ratel/core/core.dart';
import 'package:ratel/features/achievements/achievements_controller.dart';
import 'package:ratel/services/achievements/achievements.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/preferences/app_settings.dart';

/// Profile tab (🦡) — design spec §4.5, built HONESTLY. Surfaces the REAL
/// learner snapshot (CEFR level from θ via cold_start, XP, lessons completed,
/// streak, saved words) and the REAL identity: a fresh install is a GUEST —
/// never the mockup's "Alex Rivera · Level A2 · 1,240 XP". Design elements with
/// the achievements grid is REAL (each badge unlocks from live learner
/// state, §4.5); the remaining no-engine elements (leagues, "Top 3",
/// friends) stay honest "coming soon" rows, never fabricated (§6).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final int words = ref.watch(savedWordsControllerProvider).count;
    final Identity identity = ref.watch(identityProvider);
    final AppSettings settings = ref.watch(appSettingsControllerProvider);
    final String level = snap.level.name.toUpperCase();
    final List<AchievementProgress> achievements =
        ref.watch(achievementsProvider);
    final int unlockedAch =
        achievements.where((AchievementProgress p) => p.unlocked).length;

    return Container(
      key: const ValueKey<String>('tab-profile'),
      color: context.palette.cream,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(RatelSpace.screen, RatelSpace.lg,
              RatelSpace.screen, RatelSpace.xl),
          children: <Widget>[
            _header(context, identity, level),
            const SizedBox(height: RatelSpace.cardGap),
            _stats(context, snap, words),
            const SizedBox(height: RatelSpace.cardGap),
            _progressBanner(context, level, snap, settings),
            const SizedBox(height: RatelSpace.lg),
            const RatelSectionHeader(label: 'Achievements'),
            const SizedBox(height: RatelSpace.xs),
            Text(
              '$unlockedAch of ${achievements.length} unlocked · real progress',
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: context.palette.muted),
            ),
            const SizedBox(height: RatelSpace.sm),
            _achievementsGrid(context, achievements),
            const SizedBox(height: RatelSpace.lg),
            const RatelSectionHeader(label: 'Account'),
            const SizedBox(height: RatelSpace.sm),
            RatelListRow(
                leadingEmoji: '⚙️',
                leadingColor: context.palette.muted,
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
            Center(
              child: Text(
                'Level, XP, lessons, streak and saved words are real engine '
                'state — they start at zero on a fresh account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    color: context.palette.muted),
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
                decoration: BoxDecoration(
                    color: context.palette.cream3, shape: BoxShape.circle),
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
                        style: TextStyle(
                            fontFamily: RatelFont.display,
                            fontWeight: RatelType.extraBold,
                            fontSize: RatelType.screenTitle,
                            color: context.palette.ink)),
                    const SizedBox(height: 2),
                    Text(sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: RatelFont.body,
                            fontSize: RatelType.small,
                            color: context.palette.muted)),
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
            Center(
              child: Text('Save your progress across devices',
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      color: context.palette.muted)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stats(BuildContext context, LearnerSnapshot snap, int words) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
                child: _statCard(context, '🔥', '${snap.streakDays}', 'Day streak')),
            const SizedBox(width: RatelSpace.cardGap),
            Expanded(child: _statCard(context, '⚡', '${snap.xpTotal}', 'Total XP')),
          ],
        ),
        const SizedBox(height: RatelSpace.cardGap),
        Row(
          children: <Widget>[
            Expanded(
                child:
                    _statCard(context, '📘', '${snap.lessonsCompleted}', 'Lessons')),
            const SizedBox(width: RatelSpace.cardGap),
            Expanded(child: _statCard(context, '🔖', '$words', 'Saved words')),
          ],
        ),
      ],
    );
  }

  Widget _statCard(BuildContext context, String emoji, String value, String label) => RatelCard(
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
                      style: TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.cardTitle,
                          color: context.palette.ink)),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: RatelFont.body,
                          fontSize: RatelType.small,
                          color: context.palette.muted)),
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

  /// The REAL §4.5 achievements grid — 3-up rows of badge tiles, each unlocked
  /// state + progress computed live from the learner snapshot (never faked).
  Widget _achievementsGrid(BuildContext context, List<AchievementProgress> items) {
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < items.length; i += 3) {
      final List<AchievementProgress> chunk = items.skip(i).take(3).toList();
      rows.add(Row(
        children: <Widget>[
          for (int j = 0; j < 3; j++) ...<Widget>[
            if (j > 0) const SizedBox(width: RatelSpace.cardGap),
            if (j < chunk.length)
              Expanded(child: _achievementTile(context, chunk[j]))
            else
              const Expanded(child: SizedBox()),
          ],
        ],
      ));
      if (i + 3 < items.length) {
        rows.add(const SizedBox(height: RatelSpace.cardGap));
      }
    }
    return Column(children: rows);
  }

  Widget _achievementTile(BuildContext context, AchievementProgress p) {
    final bool on = p.unlocked;
    return RatelCard(
      key: ValueKey<String>('achievement-${p.achievement.id}'),
      color: on ? context.palette.white : context.palette.cream2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Opacity(
            opacity: on ? 1 : 0.35,
            child: Text(p.achievement.emoji,
                style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(height: RatelSpace.xs),
          Text(p.achievement.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: RatelFont.display,
                  fontWeight: RatelType.semiBold,
                  fontSize: RatelType.small,
                  color: on ? context.palette.ink : context.palette.muted)),
          const SizedBox(height: 2),
          Text(on ? 'Unlocked' : '${p.current}/${p.target}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.caption,
                  fontWeight: on ? RatelType.semiBold : RatelType.regular,
                  color: on ? RatelColors.green : context.palette.muted)),
        ],
      ),
    );
  }

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
