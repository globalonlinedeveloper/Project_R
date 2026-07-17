import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

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

    final CourseSpine spine = ref.watch(courseSpineProvider);
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
          context.l10n.progressTitle,
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
            _hero(context, snap, goal, ringVal, goalStatus.met,
                spine.courseCode, spine.lessonCount),
            const SizedBox(height: RatelSpace.cardGap),
            _stats(context, snap, words, goal),
            const SizedBox(height: RatelSpace.cardGap),
            RatelButton(
              label: context.l10n.progressShareMilestone,
              variant: RatelButtonVariant.secondary,
              leading: const Text('📤', style: TextStyle(fontSize: 18)),
              onPressed: () => _shareMilestone(context, snap),
            ),
            const SizedBox(height: RatelSpace.lg),
            RatelSectionHeader(label: context.l10n.progressLast7Days),
            const SizedBox(height: RatelSpace.sm),
            _HistoryChart(days: last7, weekTotal: weekTotal),
            const SizedBox(height: RatelSpace.lg),
            RatelSectionHeader(label: context.l10n.progressAccuracyRetention),
            const SizedBox(height: RatelSpace.sm),
            _statsCard(context, stats, retention, reviewed),
            const SizedBox(height: RatelSpace.lg),
            Center(
              child: Text(
                context.l10n.progressHonestyNote,
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
  void _shareMilestone(BuildContext context, LearnerSnapshot snap) {
    final String text = context.l10n.progressShareText(
        snap.streakDays, snap.xpTotal, snap.lessonsCompleted);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.progressShareCopied),
      ),
    );
  }

  Widget _hero(BuildContext context, LearnerSnapshot snap,
      int goal, double ringVal, bool met, String courseCode, int totalLessons) {
    // D-R1: the hero ring shows COURSE COMPLETION (lessons done / total
    // authored lessons) matching the design's N/160 — not today's XP. Real
    // learner state only; empty until a course spine loads (totalLessons == 0).
    final double completionVal = totalLessons <= 0
        ? 0.0
        : (snap.lessonsCompleted / totalLessons).clamp(0.0, 1.0);
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
                    // D-R1 (S161 INC-P2): course-language title, no CEFR band.
                    Text(
                        ratelCourseLanguageName(context, courseCode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: RatelFont.display,
                            fontWeight: RatelType.extraBold,
                            fontSize: RatelType.screenTitle,
                            color: RatelColors.onColor)),
                    const SizedBox(height: 4),
                    Text(
                        context.l10n.progressAbilityLine(
                            snap.theta.toStringAsFixed(2)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: RatelFont.body,
                            fontSize: RatelType.small,
                            color: RatelColors.onColor)),
                    const SizedBox(height: RatelSpace.sm),
                    Text(
                        '${context.l10n.profileTodaysGoal(snap.xpToday, goal)}${met ? ' ✓' : ''}',
                        style: const TextStyle(
                            fontFamily: RatelFont.body,
                            fontSize: RatelType.small,
                            color: RatelColors.onColor)),
                  ],
                ),
              ),
              const SizedBox(width: RatelSpace.md),
              RatelProgressRing(
                value: completionVal,
                size: 76,
                stroke: 9,
                color: RatelColors.onColor,
                center: Text('${snap.lessonsCompleted}/$totalLessons',
                    style: const TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.extraBold,
                        fontSize: RatelType.small,
                        color: RatelColors.onColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _stats(BuildContext context, LearnerSnapshot snap, int words, int goal) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _statCard(context, '🔖', '$words', context.l10n.progressStatSavedWords)),
            const SizedBox(width: RatelSpace.cardGap),
            Expanded(
                child: _statCard(context, '📘', '${snap.lessonsCompleted}',
                    context.l10n.progressStatLessons)),
          ],
        ),
        const SizedBox(height: RatelSpace.cardGap),
        Row(
          children: <Widget>[
            Expanded(
                child: _statCard(context, '🔥', '${snap.streakDays}',
                    context.l10n.progressStatDayStreak)),
            const SizedBox(width: RatelSpace.cardGap),
            Expanded(child: _statCard(context, '⚡', '${snap.xpTotal}', context.l10n.progressStatTotalXp)),
          ],
        ),
        const SizedBox(height: RatelSpace.cardGap),
        Row(
          children: <Widget>[
            Expanded(
                child: _statCard(context, '🎯', '${snap.xpToday}/$goal',
                    context.l10n.progressStatTodaysXp)),
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
            context.l10n.progressAccuracy,
            acc == null ? null : '${(acc * 100).round()}%',
            acc == null
                ? context.l10n.progressAccuracyEmpty
                : context.l10n
                    .progressAccuracyDetail(stats.correct, stats.total),
          ),
          Divider(height: RatelSpace.lg, color: context.palette.border),
          _metric(
            context,
            '⏱️',
            context.l10n.progressStudyTime,
            stats.studySeconds == 0
                ? null
                : _fmtDuration(context, stats.studySeconds),
            stats.studySeconds == 0
                ? context.l10n.progressTimeEmpty
                : context.l10n.progressTimeDetail,
          ),
          Divider(height: RatelSpace.lg, color: context.palette.border),
          _metric(
            context,
            '🧠',
            context.l10n.progressRetention,
            retention == null ? null : '${(retention * 100).round()}%',
            retention == null
                ? context.l10n.progressRetentionEmpty
                : context.l10n.progressRetentionDetail(reviewed),
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
            RatelChip(
                label: context.l10n.progressNoData, tone: RatelChipTone.neutral)
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
  String _fmtDuration(BuildContext context, int seconds) {
    if (seconds < 60) return context.l10n.commonDurSeconds(seconds);
    final int m = seconds ~/ 60;
    if (m < 60) return context.l10n.commonDurMinutes(m);
    final int h = m ~/ 60;
    final int rem = m % 60;
    return rem == 0
        ? context.l10n.commonDurHours(h)
        : context.l10n.commonDurHoursMinutes(h, rem);
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

  static String _dowLabel(BuildContext context, int weekday) =>
      switch (weekday) {
        DateTime.monday => context.l10n.commonDowMon,
        DateTime.tuesday => context.l10n.commonDowTue,
        DateTime.wednesday => context.l10n.commonDowWed,
        DateTime.thursday => context.l10n.commonDowThu,
        DateTime.friday => context.l10n.commonDowFri,
        DateTime.saturday => context.l10n.commonDowSat,
        _ => context.l10n.commonDowSun,
      };

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
                      ? context.l10n.progressWeekTotal(weekTotal)
                      : context.l10n.progressNoXpYet,
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
                RatelChip(
                    label: context.l10n.progressNoData,
                    tone: RatelChipTone.neutral),
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
              context.l10n.progressChartEmptyNote,
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
          _dowLabel(context, d.date.weekday),
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
