import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/quests/quests_controller.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/quests/quests.dart';

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
    final AppSettings settings = ref.watch(appSettingsControllerProvider);
    final int goal = settings.dailyGoal <= 0 ? 1 : settings.dailyGoal;
    final double goalVal = (snap.xpToday / goal).clamp(0.0, 1.0);
    final List<QuestProgress> quests = ref.watch(questsProvider);
    final int questsDone =
        quests.where((QuestProgress p) => p.done).length;
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
                  RatelSectionHeader(
                      label: 'Daily quests · $questsDone/${quests.length}'),
                  const SizedBox(height: RatelSpace.sm),
                  for (final QuestProgress q in quests) ...<Widget>[
                    _QuestTile(progress: q),
                    const SizedBox(height: RatelSpace.sm),
                  ],
                  const RatelCard(
                    color: RatelColors.cream2,
                    child: Row(
                      children: <Widget>[
                        Text('🎁', style: TextStyle(fontSize: 22)),
                        SizedBox(width: RatelSpace.md),
                        Expanded(
                            child: Text(
                                'Quests track your real daily progress. Reward '
                                'chests, friend quests and a weekly leaderboard '
                                'need a backend economy — an owner decision (§6). '
                                'No fake rewards are shown.',
                                style: TextStyle(
                                    fontFamily: RatelFont.body,
                                    fontSize: RatelType.small,
                                    color: RatelColors.muted))),
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

/// One real daily quest: emoji, title, honest progress bar + current/target.
class _QuestTile extends StatelessWidget {
  const _QuestTile({required this.progress});

  final QuestProgress progress;

  @override
  Widget build(BuildContext context) {
    final bool done = progress.done;
    final Quest q = progress.quest;
    final String detail = q.metric == QuestMetric.practicedToday
        ? (done ? 'Practised today — streak safe' : 'Earn any XP today')
        : '${progress.current}/${progress.target} XP today';
    return RatelCard(
      child: Row(
        children: <Widget>[
          Text(q.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(q.title,
                    style: const TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.semiBold,
                        fontSize: RatelType.bodyLg,
                        color: RatelColors.ink)),
                Text(q.description,
                    style: const TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.small,
                        color: RatelColors.muted)),
                const SizedBox(height: RatelSpace.sm),
                RatelProgressBar(
                    value: progress.fraction,
                    color: done ? RatelColors.green : RatelColors.teal),
                const SizedBox(height: 4),
                Text(detail,
                    style: const TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.caption,
                        color: RatelColors.muted)),
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
}
