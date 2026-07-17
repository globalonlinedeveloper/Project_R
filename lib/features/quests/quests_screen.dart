import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/notifications/notifications_controller.dart';
import 'package:ratel/features/quests/quests_controller.dart';
import 'package:ratel/features/home/diamonds_sheet.dart';
import 'package:ratel/features/home/economy_glyph.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/quests/quests.dart';

/// Pure, clockless helper (design §4.4, finding D-2): time until the DAILY
/// REFRESH resets at the next LOCAL midnight — the honest day boundary (the
/// reset itself stays an owner decision, see `DailyGoalStatus` doc). Rendered
/// "Resets in Xh Ym". Computed once at build from `DateTime.now()` — NOT a
/// periodic Timer, which would hang widget `pumpAndSettle` (§11).
String refreshResetsLabel(DateTime now) {
  final ({int h, int m}) p = refreshResetsParts(now);
  return 'Resets in ${p.h}h ${p.m}m';
}

/// The countdown parts — pure, so the widget can compose a LOCALIZED label
/// (L-2) while [refreshResetsLabel] stays the test-pinned English form.
({int h, int m}) refreshResetsParts(DateTime now) {
  final DateTime nextMidnight =
      DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  Duration left = nextMidnight.difference(now);
  if (left.isNegative) left = Duration.zero;
  return (h: left.inHours, m: left.inMinutes % 60);
}

String _localizedResetsLabel(BuildContext context) {
  final ({int h, int m}) p = refreshResetsParts(DateTime.now());
  return context.l10n.questsResetsIn(p.h, p.m);
}

/// Quests tab (🎯) — design spec §4.4 [R-I7]. REAL: the DAILY GOAL (today's XP
/// toward the persisted goal) and the DAILY QUEST board are pure-engine state
/// (`QuestsEngine`), measured from the learner's real XP-today / streak — a
/// fresh day honestly shows the quests open with real progress, never faked.
/// DAILY REFRESH routes to the real review runner (earns real XP). Reward
/// chests, friend quests and a weekly leaderboard have NO engine (§6) and are an
/// honest note — no fake rewards.
class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final int unread = ref.watch(unreadNotificationsCountProvider);
    final CourseSpine spine = ref.watch(courseSpineProvider);
    final DailyGoalStatus goalStatus = ref.watch(dailyGoalProvider);
    final int goal = goalStatus.goal;
    final double goalVal = goalStatus.fraction;
    final int remaining =
        (goal - snap.xpToday) < 0 ? 0 : (goal - snap.xpToday);
    final List<QuestProgress> quests = ref.watch(questsProvider);
    final int questsDone =
        quests.where((QuestProgress p) => p.done).length;
    // E3 (INC-10): reveal the app-wide animated WorldBackdrop behind this tab for
    // every backdrop world — mirrors Home's E1 fix. Derived exactly as ratel_app.dart;
    // Daylight (backdrop `none`) keeps its solid cream. The translucent scaffold
    // (theme.dart, 80% tint) is the readability floor, so no scrim is needed.
    final bool hasBackdrop =
        kBackdropPainters.containsKey(ref.watch(activeWorldProvider).backdrop);
    return Container(
      key: const ValueKey<String>('tab-quests'),
      color: hasBackdrop ? Colors.transparent : context.palette.cream,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // R-L11 inbox surface: the top-bar bell + unread badge open the
            // in-app notifications feed (a real, learner-derived count).
            RatelTopBar(
                flagEmoji: courseFlagEmoji(spine.courseCode),
                langCode: courseLangCode(spine.courseCode),
                onLanguageTap: () => context.push('/courses'),
                streak: snap.streakDays,
                energy: snap.energy,
                diamonds: formatCount(snap.diamonds),
                streakFreeze: snap.streakFreezes > 0 ? snap.streakFreezes : null,
                unreadNotifications: unread,
                onDiamondsTap: () => showDiamondsSheet(context, snap.diamonds),
                onNotificationsTap: () => context.push('/notifications')),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                    RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
                children: <Widget>[
                  // D-1: DAILY REFRESH first (design order Refresh → Goal).
                  RatelSectionHeader(label: context.l10n.questsDailyRefresh),
                  const SizedBox(height: RatelSpace.sm),
                  RatelCard(
                    gradient: const LinearGradient(
                        colors: <Color>[RatelColors.teal, RatelColors.tealDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(context.l10n.questsFreshMix,
                                      style: TextStyle(
                                          fontFamily: RatelFont.display,
                                          fontWeight: RatelType.extraBold,
                                          fontSize: RatelType.cardTitle,
                                          color: RatelColors.onColor)),
                                  SizedBox(height: 2),
                                  Text(
                                      context.l10n.questsServedFromQueue,
                                      style: TextStyle(
                                          fontFamily: RatelFont.body,
                                          fontSize: RatelType.small,
                                          color: RatelColors.onColor)),
                                ],
                              ),
                            ),
                            const SizedBox(width: RatelSpace.md),
                            // D-3: Start CTA inline-right (white pill on teal).
                            _StartPill(onTap: () => context.push('/daily-quiz')),
                          ],
                        ),
                        const SizedBox(height: RatelSpace.sm),
                        // D-2: real day-boundary reset countdown.
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text('⏳', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 6),
                            // Flexible: long locales (ar at 360px) wrap
                            // instead of overflowing the min-sized Row
                            // (caught by the S130b RTL deep-audit).
                            Flexible(
                              child: Text(_localizedResetsLabel(context),
                                  style: const TextStyle(
                                      fontFamily: RatelFont.body,
                                      fontSize: RatelType.small,
                                      color: RatelColors.onColor)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpace.lg),
                  // D-1: DAILY GOAL second.
                  RatelSectionHeader(label: context.l10n.settingsDailyGoal),
                  const SizedBox(height: RatelSpace.sm),
                  RatelCard(
                    // D-4: amber gradient (was a solid amber fill).
                    gradient: const LinearGradient(
                        colors: <Color>[
                          RatelColors.amber,
                          RatelColors.amberDark
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            goalStatus.met
                                ? context.l10n.questsGoalReached
                                : context.l10n.questsReachGoal(goal),
                            style: const TextStyle(
                                fontFamily: RatelFont.display,
                                fontWeight: RatelType.extraBold,
                                fontSize: RatelType.cardTitle,
                                color: RatelColors.onColor)),
                        const SizedBox(height: RatelSpace.sm),
                        RatelProgressBar(
                            value: goalVal, color: RatelColors.onColor),
                        const SizedBox(height: RatelSpace.sm),
                        // D-5: honest remaining fragment. Design shows "· N
                        // lesson to go", but per-lesson XP is VARIABLE (no fixed
                        // award), so a lessons count can't be honest — we show
                        // the real remaining XP instead (anti-goal §E).
                        Text(
                            goalStatus.met
                                ? context.l10n.questsGoalLine(snap.xpToday, goal)
                                : context.l10n.questsGoalRemaining(
                                    snap.xpToday, goal, remaining),
                            style: const TextStyle(
                                fontFamily: RatelFont.body,
                                fontSize: RatelType.small,
                                color: RatelColors.onColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpace.lg),
                  RatelSectionHeader(
                      label: context.l10n.questsDailyQuests(
                          questsDone, quests.length)),
                  const SizedBox(height: RatelSpace.sm),
                  for (final QuestProgress q in quests) ...<Widget>[
                    _QuestTile(progress: q),
                    const SizedBox(height: RatelSpace.sm),
                  ],
                  RatelCard(
                    color: context.palette.cream2,
                    child: Row(
                      children: <Widget>[
                        const Text('🎁', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: RatelSpace.md),
                        Expanded(
                            child: Text(
                                context.l10n.questsInfoNote,
                                style: TextStyle(
                                    fontFamily: RatelFont.body,
                                    fontSize: RatelType.small,
                                    color: context.palette.muted))),
                      ],
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
}

/// D-3: the inline "Start" pill on the DAILY REFRESH card — a white pill with a
/// teal label (design §4.4), replacing the old full-width button below the card.
class _StartPill extends StatelessWidget {
  const _StartPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.questsStartRefresh,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(RatelRadius.pill),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: RatelSpace.lg, vertical: RatelSpace.sm),
            decoration: BoxDecoration(
              color: RatelColors.onColor,
              borderRadius: BorderRadius.circular(RatelRadius.pill),
            ),
            child: Text(context.l10n.questsStart,
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.bodyLg,
                    color: RatelColors.teal)),
          ),
        ),
      ),
    );
  }
}

/// One real daily quest: emoji, title, honest progress bar + current/target.
class _QuestTile extends StatelessWidget {
  const _QuestTile({required this.progress});

  final QuestProgress progress;

  @override
  Widget build(BuildContext context) {
    final bool done = progress.done;
    final Quest q = progress.quest;
    final String detail = q.metric == QuestMetric.practicedToday
        ? (done
            ? context.l10n.questsPractisedToday
            : context.l10n.questsEarnAnyXp)
        : context.l10n.questsXpToday(progress.current, progress.target);
    return RatelCard(
      child: Row(
        children: <Widget>[
          _iconTile(context, q.emoji),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(ratelQuestTitle(context, q.id, q.title),
                    style: TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.semiBold,
                        fontSize: RatelType.bodyLg,
                        color: context.palette.ink)),
                Text(ratelQuestDescription(context, q.id, q.description),
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.small,
                        color: context.palette.muted)),
                const SizedBox(height: RatelSpace.sm),
                RatelProgressBar(
                    value: progress.fraction,
                    color: done ? RatelColors.green : RatelColors.teal),
                const SizedBox(height: 4),
                Text(detail,
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.caption,
                        color: context.palette.muted)),
              ],
            ),
          ),
          if (done) ...<Widget>[
            const SizedBox(width: RatelSpace.sm),
            const Text('✅', style: TextStyle(fontSize: 18)),
          ],
        ],
      ),
    );
  }

  /// The design's soft rounded-square icon TILE (D-Q6, design #34): the quest's
  /// emoji centred on a tinted rounded square — the square counterpart of the
  /// circular RatelListRow medallion. A stable teal accent tint (tokens only,
  /// no raw hex), matching the other list medallions across the app.
  Widget _iconTile(BuildContext context, String emoji) {
    return Container(
      key: const ValueKey<String>('quest-icon-tile'),
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: RatelColors.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RatelRadius.chip),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 22)),
    );
  }
}
