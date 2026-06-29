import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel;
import 'package:ratel/core/core.dart';

/// Progress dashboard (📊) — design spec §4.13, reached from the Profile
/// "View progress →" banner (`/progress`). Built HONESTLY from the REAL learner
/// snapshot ONLY: CEFR level + ability θ (the `learner_state` ability fold
/// seeded by the `cold_start` anchor), the saved-words count (real per-course
/// dedup) and the in-memory R-O1 gameplay counters (XP, lessons, streak — they
/// start at ZERO on a freshly-wiped account, never the mockup's "412 / 88 /
/// 86%"). Stats with NO engine in this foundation — accuracy, study time,
/// retention %, and the per-day history chart — are shown as honest empty
/// states, never fabricated (design spec §6 "don't fake depth").
///
/// Surfaces UI for: [R-G2] ability θ · [R-G6] learner-state stats · [R-G9]
/// saved-words count · [R-I1] XP · [R-I2] streak · [R-I7] daily goal ·
/// [R-L14] honest empty / no-data UI states.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final int words = ref.watch(savedWordsControllerProvider).count;
    final DailyGoalStatus goalStatus = ref.watch(dailyGoalProvider);

    final String level = snap.level.name.toUpperCase();
    final int goal = goalStatus.goal;
    final double ringVal = goalStatus.fraction;

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
          'Progress',
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            color: context.palette.ink,
            fontSize: RatelType.cardTitle,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          key: const ValueKey<String>('screen-progress'),
          padding: const EdgeInsets.fromLTRB(
              RatelSpace.screen, RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
          children: <Widget>[
            _hero(level, snap, goal, ringVal, goalStatus.met),
            const SizedBox(height: RatelSpace.cardGap),
            _stats(context, snap, words, goal, level),
            const SizedBox(height: RatelSpace.lg),
            const RatelSectionHeader(label: 'Last 7 days'),
            const SizedBox(height: RatelSpace.sm),
            _noHistoryCard(context),
            const SizedBox(height: RatelSpace.lg),
            const RatelSectionHeader(label: 'Accuracy & retention'),
            const SizedBox(height: RatelSpace.sm),
            _noEngineCard(context),
            const SizedBox(height: RatelSpace.lg),
            Center(
              child: Text(
                'Level, ability, saved words, XP, lessons and streak are real '
                'engine state — they start at zero on a fresh account. Accuracy, '
                'study time, retention and daily history need recorded review '
                'history (arriving with the lesson runner); nothing here is '
                'invented.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    color: context.palette.muted,
                    height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(String level, LearnerSnapshot snap, int goal, double ringVal, bool met) {
    return RatelCard(
      gradient: const LinearGradient(
        colors: <Color>[RatelColors.blue, RatelColors.navy],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
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
                        fontSize: RatelType.screenTitle,
                        color: RatelColors.onColor)),
                const SizedBox(height: 4),
                Text('Ability θ ${snap.theta.toStringAsFixed(2)} · real estimate',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.small,
                        color: RatelColors.onColor)),
                const SizedBox(height: RatelSpace.sm),
                Text("Today's goal · ${snap.xpToday}/$goal XP${met ? ' ✓' : ''}",
                    style: const TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.small,
                        color: RatelColors.onColor)),
              ],
            ),
          ),
          const SizedBox(width: RatelSpace.md),
          RatelProgressRing(
            value: ringVal,
            size: 76,
            stroke: 9,
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

  Widget _stats(BuildContext context, LearnerSnapshot snap, int words, int goal, String level) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _statCard(context, '🔖', '$words', 'Saved words')),
            const SizedBox(width: RatelSpace.cardGap),
            Expanded(
                child: _statCard(context, '📘', '${snap.lessonsCompleted}', 'Lessons')),
          ],
        ),
        const SizedBox(height: RatelSpace.cardGap),
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
                child: _statCard(context, '🎯', '${snap.xpToday}/$goal', "Today's XP")),
            const SizedBox(width: RatelSpace.cardGap),
            Expanded(child: _statCard(context, '📈', level, 'CEFR level')),
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

  Widget _noHistoryCard(BuildContext context) => RatelCard(
        color: context.palette.cream2,
        child: Row(
          children: <Widget>[
            const Text('📊', style: TextStyle(fontSize: 22)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Text(
                'Your daily activity chart fills in as you learn — there is no '
                'recorded history yet, so nothing is shown.',
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: context.palette.muted),
              ),
            ),
            const RatelChip(label: 'No data yet', tone: RatelChipTone.neutral),
          ],
        ),
      );

  Widget _noEngineCard(BuildContext context) => RatelCard(
        color: context.palette.cream2,
        child: Row(
          children: <Widget>[
            const Text('🎯', style: TextStyle(fontSize: 22)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Text(
                'Accuracy, study time and retention appear once the lesson '
                'runner records graded reviews — they are never estimated or '
                'faked.',
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: context.palette.muted),
              ),
            ),
            const RatelChip(label: 'Soon', tone: RatelChipTone.amber),
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
