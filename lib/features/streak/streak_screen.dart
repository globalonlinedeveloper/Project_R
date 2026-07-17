import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';

/// Streak screen (🔥) — design #11 / lane A-S (`/streak`).
///
/// HONEST BUILD. The flame hero (day count + "DAY STREAK") and the
/// freeze tile show REAL [LearnerSnapshot] state (`streakDays`,
/// `streakFreezes`) — the same numbers the top-bar 🔥/💪 chips read, wired
/// from the real streak engine (`services/learning/streak.dart`). What the
/// design shows but has NO real backing store is deliberately NOT faked:
///
///  * the M–S week grid renders REAL activity from `xp_history`
///    (`last7DaysXpProvider`): a day is "active" when the learner earned XP
///    that day (`DayXp.xp > 0`) — honest zeros for inactive days, no
///    fabricated flame / goal-met per day;
///  * "Longest streak" reads the REAL persisted max (`snap.longestStreak`,
///    monotonic on the `__global__` `user_course` row) beside the freeze
///    tile as a 2-up stat; a learner who has never met a goal (0) sees the
///    honest muted zero-state, never a fabricated "14";
///  * "5h 12m left today" implies a precise deadline countdown → replaced by
///    an honest generic "meet your goal before midnight" note (no fake timer);
///  * "Streak Society" (friend streaks / societies / perks) has no social
///    backend → shown as an honest not-built note, exactly like Leagues.
///
/// Reached from the Home top-bar 🔥 chip (A-S1 wiring).
class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final int days = snap.streakDays;
    final int freezes = snap.streakFreezes;
    final int longest = snap.longestStreak;
    final bool hasStreak = days > 0;
    // REAL "goal met today" signal (dailyGoalProvider.met == xpToday >= goal):
    // when a streak is live and today's goal is already met, the deadline card
    // reads "your streak is safe" instead of the generic before-midnight note.
    final bool goalMetToday = ref.watch(dailyGoalProvider).met;
    // REAL 7-day activity, oldest -> newest, zero-filled for inactive days
    // (services/progress/xp_history.dart). "Active" = earned XP that day.
    final List<DayXp> week = ref.watch(last7DaysXpProvider);
    final DateTime nowLocal = ref.watch(clockProvider)();
    final DateTime today =
        DateTime(nowLocal.year, nowLocal.month, nowLocal.day);

    return Scaffold(
      backgroundColor: context.palette.cream,
      body: SafeArea(
        top: false,
        child: ListView(
          key: const ValueKey<String>('screen-streak'),
          padding: EdgeInsets.zero,
          children: <Widget>[
            _hero(context, days, hasStreak),
            Padding(
              padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                  RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _statTiles(context, longest, freezes),
                  const SizedBox(height: RatelSpace.md),
                  _weekGrid(context, week, today),
                  const SizedBox(height: RatelSpace.md),
                  _deadlineCard(context, hasStreak, goalMetToday),
                  const SizedBox(height: RatelSpace.md),
                  _societyCard(context),
                  const SizedBox(height: RatelSpace.lg),
                  Text(
                    context.l10n.streakHonestNote,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      height: 1.4,
                      color: context.palette.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context, int days, bool hasStreak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          RatelSpace.screen, RatelSpace.xl, RatelSpace.screen, RatelSpace.xl),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[RatelColors.ink, RatelColors.tealDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GestureDetector(
                key: const ValueKey<String>('streak-back'),
                onTap: () => context.pop(),
                child: Icon(RatelIcons.arrowBack,
                    color: RatelColors.onColor, size: 26),
              ),
            ),
            const SizedBox(height: RatelSpace.lg),
            const Text('🔥',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 64)),
            const SizedBox(height: RatelSpace.sm),
            Text(
              '$days',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                fontSize: RatelType.hero,
                height: 1.0,
                color: RatelColors.onColor,
              ),
            ),
            const SizedBox(height: RatelSpace.xs),
            Text(
              context.l10n.streakDayLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                fontSize: RatelType.small,
                letterSpacing: 1.5,
                color: RatelColors.gold,
              ),
            ),
            if (!hasStreak) ...<Widget>[
              const SizedBox(height: RatelSpace.md),
              Text(
                context.l10n.streakZeroTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: RatelFont.display,
                  fontWeight: RatelType.extraBold,
                  fontSize: RatelType.cardTitle,
                  color: RatelColors.onColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

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

  /// A real 7-day activity grid (D1) — reads the same honest [DayXp] series the
  /// Progress chart uses (`last7DaysXpProvider`), oldest -> newest, zero-filled.
  /// An "active" day is one the learner earned XP (`DayXp.xp > 0`): filled teal.
  /// Inactive days show a faint `cream3` dot (honest zero, never a gap). The
  /// last cell is marked as today only when its date is genuinely the clock's
  /// today. No per-day flame / goal-met is fabricated.
  Widget _weekGrid(BuildContext context, List<DayXp> week, DateTime today) {
    return RatelCard(
      color: context.palette.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          for (final DayXp d in week)
            Expanded(child: _weekCell(context, d, today)),
        ],
      ),
    );
  }

  Widget _weekCell(BuildContext context, DayXp d, DateTime today) {
    final bool active = d.xp > 0;
    final bool isToday = d.date == today;
    const double dot = 28;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          key: ValueKey<String>('streak-day-'
              '${d.date.year.toString().padLeft(4, '0')}-'
              '${d.date.month.toString().padLeft(2, '0')}-'
              '${d.date.day.toString().padLeft(2, '0')}'
              '-${active ? 'active' : 'empty'}${isToday ? '-today' : ''}'),
          width: dot,
          height: dot,
          decoration: BoxDecoration(
            color: active ? RatelColors.teal : context.palette.cream3,
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: RatelColors.teal, width: 2)
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _dowLabel(context, d.date.weekday),
          maxLines: 1,
          style: TextStyle(
            fontFamily: RatelFont.body,
            fontSize: RatelType.small,
            color: context.palette.muted,
          ),
        ),
      ],
    );
  }

  /// The 2-up stat row (design #11): the REAL persisted longest streak beside
  /// the REAL freeze count. Both cells share [_statTile] and sit in an
  /// [IntrinsicHeight] so they stay equal-height at any width; a narrow screen
  /// wraps the label text rather than overflowing.
  Widget _statTiles(BuildContext context, int longest, int freezes) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _statTile(
              context,
              key: 'streak-longest-tile',
              emoji: '🏆',
              // Honest zero-state: never a fabricated peak. Below 1 the tile
              // shows a muted "No streak yet" instead of a big "0".
              value: longest > 0 ? '$longest' : null,
              valueLabel: context.l10n.streakLongestLabel,
              emptyLabel: context.l10n.streakLongestNone,
            ),
          ),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: _statTile(
              context,
              key: 'streak-freezes-tile',
              emoji: '❄️',
              value: '$freezes',
              valueLabel: context.l10n.streakFreezesLabel,
              emptyLabel: context.l10n.streakFreezesLabel,
            ),
          ),
        ],
      ),
    );
  }

  /// A compact white stat cell: emoji, a big REAL number + its label, or — when
  /// [value] is null (an honest empty state) — a single muted [emptyLabel] and
  /// no fabricated number.
  Widget _statTile(
    BuildContext context, {
    required String key,
    required String emoji,
    required String? value,
    required String valueLabel,
    required String emptyLabel,
  }) {
    final bool hasValue = value != null;
    return RatelCard(
      key: ValueKey<String>(key),
      color: context.palette.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: RatelSpace.sm),
          if (hasValue) ...<Widget>[
            Text(
              value,
              style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                fontSize: RatelType.cardTitle,
                color: context.palette.ink,
              ),
            ),
            Text(
              valueLabel,
              style: TextStyle(
                fontFamily: RatelFont.body,
                fontWeight: RatelType.semiBold,
                fontSize: RatelType.small,
                height: 1.3,
                color: context.palette.muted,
              ),
            ),
          ] else
            Text(
              emptyLabel,
              style: TextStyle(
                fontFamily: RatelFont.body,
                fontWeight: RatelType.semiBold,
                fontSize: RatelType.body,
                height: 1.3,
                color: context.palette.muted,
              ),
            ),
        ],
      ),
    );
  }


  /// Amber 🛡️ card, three honest states:
  ///  * no streak yet        -> start-your-streak title + body;
  ///  * streak live, goal met -> the shipped [streakTodayDone] safe line
  ///    (a complete sentence, so no body is shown);
  ///  * streak live, not met  -> generic before-midnight deadline note.
  Widget _deadlineCard(
      BuildContext context, bool hasStreak, bool goalMetToday) {
    final bool safeToday = hasStreak && goalMetToday;
    final String title;
    final String? body; // null -> self-contained title, no second line.
    if (safeToday) {
      title = context.l10n.streakTodayDone;
      body = null;
    } else if (hasStreak) {
      title = context.l10n.streakDeadlineTitle;
      body = context.l10n.streakDeadlineBody;
    } else {
      title = context.l10n.streakZeroTitle;
      body = context.l10n.streakZeroBody;
    }
    return Container(
      padding: const EdgeInsets.all(RatelSpace.cardPad),
      decoration: BoxDecoration(
        color: RatelColors.amber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(RatelRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('🛡️', style: TextStyle(fontSize: 22)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.body,
                    color: context.palette.ink,
                  ),
                ),
                if (body != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      height: 1.3,
                      color: context.palette.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _societyCard(BuildContext context) {
    return RatelCard(
      color: context.palette.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('🔥', style: TextStyle(fontSize: 24)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.streakSocietyTitle,
                  style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.body,
                    color: context.palette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.streakSocietySub,
                  style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    color: context.palette.muted,
                  ),
                ),
                const SizedBox(height: RatelSpace.sm),
                Text(
                  context.l10n.streakSocietyHonest,
                  style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    height: 1.35,
                    color: context.palette.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
