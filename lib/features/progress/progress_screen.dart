import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
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
/// 86%").
///
/// D1: the **Last 7 days** chart is now REAL — driven by the device-local
/// [last7DaysXpProvider] recorder hooked to every completed lesson; inactive
/// days are honest zeros, never invented. **Share milestone** copies a real
/// level/XP/streak card to the clipboard. Stats with NO engine yet — accuracy,
/// study time, retention % — stay honest empty states (D2 / §6 "don't fake
/// depth").
///
/// Surfaces UI for: [R-G2] ability θ · [R-G6] learner-state + 7-day history ·
/// [R-G9] saved-words count · [R-I1] XP · [R-I2] streak · [R-I7] daily goal ·
/// [R-L14] honest empty / no-data UI states.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final int words = ref.watch(savedWordsControllerProvider).count;
    final DailyGoalStatus goalStatus = ref.watch(dailyGoalProvider);
    final List<DayXp> last7 = ref.watch(last7DaysXpProvider);
    final int weekTotal = last7.fold<int>(0, (int a, DayXp d) => a + d.xp);

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
            const SizedBox(height: RatelSpace.cardGap),
            RatelButton(
              label: 'Share milestone',
              variant: RatelButtonVariant.secondary,
              leading: const Text('📤', style: TextStyle(fontSize: 18)),
              onPressed: () => _shareMilestone(context, snap, level),
            ),
            const SizedBox(height: RatelSpace.lg),
            const RatelSectionHeader(label: 'Last 7 days'),
            const SizedBox(height: RatelSpace.sm),
            _HistoryChart(days: last7, weekTotal: weekTotal),
            const SizedBox(height: RatelSpace.lg),
            const RatelSectionHeader(label: 'Accuracy & retention'),
            const SizedBox(height: RatelSpace.sm),
            _noEngineCard(context),
            const SizedBox(height: RatelSpace.lg),
            Center(
              child: Text(
                'Level, ability, saved words, XP, lessons, streak and your '
                '7-day history are real recorded state — they start at zero on a '
                'fresh account. Accuracy, study time and retention arrive as you '
                'complete graded lessons; nothing here is invented.',
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

  /// Copy a REAL level/XP/streak milestone card to the clipboard (D1 "Share
  /// milestone"). No `share_plus` dependency — a clipboard copy works on every
  /// platform incl. web, and is honest about what it does (the SnackBar says so).
  void _shareMilestone(BuildContext context, LearnerSnapshot snap, String level) {
    final String text = '🦡 RATEL · Level $level (${_levelName(snap.level)})\n'
        '🔥 ${snap.streakDays}-day streak · ⚡ ${snap.xpTotal} XP · '
        '📘 ${snap.lessonsCompleted} lessons\n'
        'Learning at learnwithratel.com';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Milestone copied to clipboard — share it anywhere!'),
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

/// A real 7-bar daily-XP chart (D1). Bars scale to the busiest day; inactive
/// days show a faint baseline stub (honest zero, never a gap). When no XP has
/// been recorded in the window the header reads "No XP recorded yet" with a
/// "No data yet" chip + an honest caption — the frame is shown but nothing is
/// invented.
class _HistoryChart extends StatelessWidget {
  const _HistoryChart({required this.days, required this.weekTotal});

  final List<DayXp> days;
  final int weekTotal;

  static const List<String> _dow = <String>[
    '', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su',
  ];

  @override
  Widget build(BuildContext context) {
    final int maxXp =
        days.fold<int>(0, (int m, DayXp d) => d.xp > m ? d.xp : m);
    const double trackH = 84;
    return RatelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('📊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: RatelSpace.sm),
              Expanded(
                child: Text(
                  weekTotal > 0
                      ? '$weekTotal XP · last 7 days'
                      : 'No XP recorded yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: RatelFont.display,
                      fontWeight: RatelType.extraBold,
                      fontSize: RatelType.cardTitle,
                      color: context.palette.ink),
                ),
              ),
              if (weekTotal == 0)
                const RatelChip(
                    label: 'No data yet', tone: RatelChipTone.neutral),
            ],
          ),
          const SizedBox(height: RatelSpace.md),
          SizedBox(
            height: trackH + 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                for (final DayXp d in days)
                  Expanded(child: _bar(context, d, maxXp, trackH)),
              ],
            ),
          ),
          if (weekTotal == 0) ...<Widget>[
            const SizedBox(height: RatelSpace.sm),
            Text(
              'Finish a lesson to start your 7-day history — inactive days stay '
              'at zero, nothing is invented.',
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: context.palette.muted,
                  height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bar(BuildContext context, DayXp d, int maxXp, double trackH) {
    final double frac = maxXp <= 0 ? 0 : d.xp / maxXp;
    final double h = d.xp <= 0 ? 4 : (8 + frac * (trackH - 8));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: trackH,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: h,
                decoration: BoxDecoration(
                  color: d.xp > 0 ? RatelColors.teal : context.palette.cream3,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _dow[d.date.weekday],
          maxLines: 1,
          style: TextStyle(
              fontFamily: RatelFont.body,
              fontSize: RatelType.small,
              color: context.palette.muted),
        ),
      ],
    );
  }
}
