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
    final StudyStats stats = ref.watch(studyStatsControllerProvider);
    final double? retention = ref.watch(retentionEstimateProvider);
    final int reviewed = ref.watch(reviewedItemCountProvider);

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
            _statsCard(context, stats, retention, reviewed),
            const SizedBox(height: RatelSpace.lg),
            Center(
              child: Text(
                'Everything here is real recorded state — level, ability, saved '
                'words, XP, lessons, streak, your 7-day history, accuracy and '
                'study time all start at zero and grow as you learn. Retention is '
                "this session's predicted recall (the durable cross-session "
                'scheduler is go-live wiring); nothing is invented.',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
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
          const SizedBox(height: RatelSpace.md),
          // D-11: CEFR ladder strip (A1…C2) — highlights the learner's REAL
          // current level; an honest position on the scale, no invented data.
          _cefrLadder(snap.level),
        ],
      ),
    );
  }

  /// D-11: horizontal CEFR ladder (A1 A2 B1 B2 C1 C2). The learner's current
  /// level is filled bright; the rest are dimmed. Theme tokens only (onColor
  /// with alpha over the blue hero gradient) — token_lint stays green.
  Widget _cefrLadder(CefrLevel current) {
    final List<Widget> pills = <Widget>[];
    for (int i = 0; i < CefrLevel.values.length; i++) {
      final CefrLevel l = CefrLevel.values[i];
      final bool active = l == current;
      pills.add(Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? RatelColors.onColor
                : RatelColors.onColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(RatelRadius.chip),
          ),
          child: Text(l.name.toUpperCase(),
              style: TextStyle(
                  fontFamily: RatelFont.display,
                  fontWeight: active ? RatelType.extraBold : RatelType.semiBold,
                  fontSize: RatelType.caption,
                  color: active ? RatelColors.navy : RatelColors.onColor)),
        ),
      ));
      if (i != CefrLevel.values.length - 1) {
        pills.add(const SizedBox(width: 6));
      }
    }
    return Row(children: pills);
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

  /// Real accuracy / study-time / retention (D2). Accuracy + study time are the
  /// cumulative device-local [StudyStats]; retention is the live FSRS 1-day
  /// recall over this session's reviewed items. Each surfaces an honest "No data
  /// yet" until it has something real — never an estimate.
  Widget _statsCard(
      BuildContext context, StudyStats stats, double? retention, int reviewed) {
    final double? acc = stats.accuracy;
    return RatelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _metric(
            context,
            '🎯',
            'Accuracy',
            acc == null ? null : '${(acc * 100).round()}%',
            acc == null
                ? 'Answer graded exercises to start'
                : '${stats.correct} of ${stats.total} correct',
          ),
          Divider(height: RatelSpace.lg, color: context.palette.border),
          _metric(
            context,
            '⏱️',
            'Study time',
            stats.studySeconds == 0 ? null : _fmtDuration(stats.studySeconds),
            stats.studySeconds == 0
                ? 'Time in lessons adds up here'
                : 'across all your lessons',
          ),
          Divider(height: RatelSpace.lg, color: context.palette.border),
          _metric(
            context,
            '🧠',
            'Retention',
            retention == null ? null : '${(retention * 100).round()}%',
            retention == null
                ? 'Review items to see predicted recall'
                : 'predicted 1-day recall · $reviewed '
                    'item${reviewed == 1 ? '' : 's'} this session',
          ),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String emoji, String label,
          String? value, String subtitle) =>
      Row(
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.extraBold,
                        fontSize: RatelType.body,
                        color: context.palette.ink)),
                Text(subtitle,
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.small,
                        color: context.palette.muted,
                        height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: RatelSpace.sm),
          if (value == null)
            const RatelChip(label: 'No data yet', tone: RatelChipTone.neutral)
          else
            Text(value,
                maxLines: 1,
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.cardTitle,
                    color: context.palette.ink)),
        ],
      );

  /// Compact human duration: `45s` / `12m` / `2h` / `1h 23m`.
  String _fmtDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final int m = seconds ~/ 60;
    if (m < 60) return '${m}m';
    final int h = m ~/ 60;
    final int rem = m % 60;
    return rem == 0 ? '${h}h' : '${h}h ${rem}m';
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
