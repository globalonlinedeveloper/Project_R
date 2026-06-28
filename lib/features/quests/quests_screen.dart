import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/preferences/app_settings.dart';

/// Quests tab (🎯) — design spec §4.4. PARTIALLY real: the DAILY GOAL (today's
/// XP toward the persisted goal) is REAL engine state; DAILY REFRESH routes to
/// the (pending) lesson runner; quest tracking, rewards and friend quests have
/// NO engine (§6) and are an honest stub — never faked progress.
class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
    final AppSettings settings = ref.watch(appSettingsControllerProvider);
    final int goal = settings.dailyGoal <= 0 ? 1 : settings.dailyGoal;
    final double goalVal = (snap.xpToday / goal).clamp(0.0, 1.0);
    return Container(
      key: const ValueKey<String>('tab-quests'),
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
                  const RatelSectionHeader(label: 'Daily goal'),
                  const SizedBox(height: RatelSpace.sm),
                  RatelCard(
                    color: RatelColors.amber,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Reach $goal XP today',
                            style: const TextStyle(
                                fontFamily: RatelFont.display,
                                fontWeight: RatelType.extraBold,
                                fontSize: RatelType.cardTitle,
                                color: RatelColors.onColor)),
                        const SizedBox(height: 2),
                        Text('${snap.xpToday}/$goal XP today',
                            style: const TextStyle(
                                fontFamily: RatelFont.body,
                                fontSize: RatelType.small,
                                color: RatelColors.onColor)),
                        const SizedBox(height: RatelSpace.sm),
                        RatelProgressBar(
                            value: goalVal, color: RatelColors.onColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpace.lg),
                  const RatelSectionHeader(label: 'Daily refresh'),
                  const SizedBox(height: RatelSpace.sm),
                  RatelCard(
                    gradient: const LinearGradient(
                        colors: <Color>[RatelColors.teal, RatelColors.tealDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('A fresh 5-question mix',
                            style: TextStyle(
                                fontFamily: RatelFont.display,
                                fontWeight: RatelType.extraBold,
                                fontSize: RatelType.cardTitle,
                                color: RatelColors.onColor)),
                        const SizedBox(height: 2),
                        const Text(
                            'Served from your real review queue — earns real XP.',
                            style: TextStyle(
                                fontFamily: RatelFont.body,
                                fontSize: RatelType.small,
                                color: RatelColors.onColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: RatelSpace.sm),
                  RatelButton(
                      label: 'Start the daily refresh',
                      onPressed: () => context.push('/daily-quiz')),
                  const SizedBox(height: RatelSpace.lg),
                  const RatelSectionHeader(label: 'Daily quests'),
                  const SizedBox(height: RatelSpace.sm),
                  RatelCard(
                    color: RatelColors.cream2,
                    child: Row(
                      children: <Widget>[
                        const Text('🎯', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: RatelSpace.md),
                        const Expanded(
                            child: Text(
                                'Quest tracking, rewards and friend quests have '
                                'no backend engine yet — an owner decision. No '
                                'fake progress is shown.',
                                style: TextStyle(
                                    fontFamily: RatelFont.body,
                                    fontSize: RatelType.body,
                                    color: RatelColors.muted))),
                        const RatelChip(
                            label: 'Soon', tone: RatelChipTone.neutral),
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
