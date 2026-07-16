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
///  * the M–S week grid (✓/flame/empty) needs a per-day activity log that
///    does not exist → omitted, with an on-screen note explaining why;
///  * "14 Longest streak" needs a longest-streak column that is not on the
///    snapshot → omitted rather than invented;
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
    final bool hasStreak = days > 0;

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
                  _freezeTile(context, freezes),
                  const SizedBox(height: RatelSpace.md),
                  _deadlineCard(context, hasStreak),
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
            const Text('🔥', style: TextStyle(fontSize: 64)),
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

  Widget _freezeTile(BuildContext context, int freezes) {
    return RatelCard(
      color: context.palette.white,
      child: Row(
        children: <Widget>[
          const Text('❄️', style: TextStyle(fontSize: 28)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      '$freezes',
                      style: TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.extraBold,
                        fontSize: RatelType.cardTitle,
                        color: context.palette.ink,
                      ),
                    ),
                    const SizedBox(width: RatelSpace.sm),
                    Text(
                      context.l10n.streakFreezesLabel,
                      style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontWeight: RatelType.semiBold,
                        fontSize: RatelType.body,
                        color: context.palette.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.streakFreezesTileSub,
                  style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    height: 1.3,
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

  Widget _deadlineCard(BuildContext context, bool hasStreak) {
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
                  hasStreak
                      ? context.l10n.streakDeadlineTitle
                      : context.l10n.streakZeroTitle,
                  style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.body,
                    color: context.palette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasStreak
                      ? context.l10n.streakDeadlineBody
                      : context.l10n.streakZeroBody,
                  style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    height: 1.3,
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
