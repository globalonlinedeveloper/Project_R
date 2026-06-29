import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/features/learner/learner_controller.dart';
import 'package:ratel/features/settings/settings_controller.dart';

/// Derived daily-goal status — the REAL meaning of the persisted daily XP goal.
///
/// The daily goal (chosen in Settings / Onboarding, persisted by the
/// `preferences` engine) used to be DISPLAY-ONLY: Quests, Progress and Profile
/// each recomputed `goal <= 0 ? 1 : goal` plus a clamped ring fraction, and
/// reaching the goal had no acknowledged state. This collapses that duplicated
/// math into one pure, testable derive and adds [met] so "goal reached today"
/// can be shown honestly.
///
/// Pure + clockless: [met] is just `xpToday >= goal`. The day-boundary reset of
/// today's XP and any streak-gating on the goal stay owner decisions (design
/// spec §6 — they need a clock / a product call); this holds neither.
///
/// Requirements: R-I7 (daily goal) — turns the persisted setting into real,
/// acknowledged met-state instead of a display-only ring.
class DailyGoalStatus {
  const DailyGoalStatus({required this.xpToday, required this.goal});

  /// Real XP earned today (from the learner snapshot; 0 on a fresh account).
  final int xpToday;

  /// Effective goal — the persisted setting, floored at 1 so the ring math can
  /// never divide by zero.
  final int goal;

  /// True once today's XP reaches the goal.
  bool get met => xpToday >= goal;

  /// Ring / bar fill in [0, 1].
  double get fraction => (xpToday / goal).clamp(0.0, 1.0);

  @override
  bool operator ==(Object other) =>
      other is DailyGoalStatus &&
      other.xpToday == xpToday &&
      other.goal == goal;

  @override
  int get hashCode => Object.hash(xpToday, goal);
}

/// Single source of truth for every daily-goal ring: watches the learner
/// snapshot + settings and yields the derived [DailyGoalStatus].
final dailyGoalProvider = Provider<DailyGoalStatus>((ref) {
  final int xpToday = ref.watch(learnerControllerProvider).xpToday;
  final int rawGoal = ref.watch(appSettingsControllerProvider).dailyGoal;
  return DailyGoalStatus(xpToday: xpToday, goal: rawGoal <= 0 ? 1 : rawGoal);
});
