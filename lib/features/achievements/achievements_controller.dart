import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/services/achievements/achievements.dart';

/// Bridges the REAL learner + saved-words state to the pure [AchievementsEngine]
/// (design spec §4.5 / §6 [R-I7]). Recomputes whenever the underlying engine
/// state changes, so badges unlock LIVE as the learner actually progresses — a
/// fresh account is all-locked with honest progress, never a fabricated grid.
final achievementsProvider = Provider<List<AchievementProgress>>((ref) {
  final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
  final int words = ref.watch(savedWordsControllerProvider).count;
  final AchievementStats stats = AchievementStats(
    lessonsCompleted: snap.lessonsCompleted,
    xpTotal: snap.xpTotal,
    streakDays: snap.streakDays,
    savedWords: words,
    cefrOrdinal: snap.level.index,
  );
  return const AchievementsEngine().evaluate(stats);
});

/// Count of genuinely-unlocked milestones (for the Profile section header).
final unlockedAchievementsCountProvider = Provider<int>((ref) => ref
    .watch(achievementsProvider)
    .where((AchievementProgress p) => p.unlocked)
    .length);
