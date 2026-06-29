import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/services/quests/quests.dart';

/// Bridges the REAL learner state + the chosen daily goal to the pure
/// [QuestsEngine] (design spec §4.4 [R-I7]). Recomputes whenever the learner's
/// XP / streak or the daily-goal setting changes, so the quest board reflects
/// genuine daily progress — a fresh day shows the quests open with real
/// progress, never a fabricated board. Read-only over the existing learner +
/// settings providers (it never mutates them).
final questsProvider = Provider<List<QuestProgress>>((ref) {
  final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
  final int goal = ref.watch(appSettingsControllerProvider).dailyGoal;
  final QuestStats stats = QuestStats(
    xpToday: snap.xpToday,
    streakDays: snap.streakDays,
    dailyGoal: goal <= 0 ? 1 : goal,
  );
  return const QuestsEngine().evaluate(stats);
});

/// Count of genuinely-completed quests (for the section header).
final completedQuestsCountProvider = Provider<int>((ref) =>
    ref.watch(questsProvider).where((QuestProgress p) => p.done).length);
