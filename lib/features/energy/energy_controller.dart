import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'energy_state.dart';

/// Holds the in-memory energy economy and applies its rules (R-J* / R-L3).
class EnergyController extends StateNotifier<EnergyState> {
  EnergyController([EnergyState? initial])
      : super(initial ?? const EnergyState());

  bool canStart({bool isReview = false}) => state.canStart(isReview: isReview);

  /// Apply the commit rules for a COMPLETED lesson. A quit never calls this, so
  /// quitting commits nothing and costs no energy. Mistakes never reach here.
  EnergyCommitOutcome commit({bool isReview = false}) {
    final s = state;
    final free = s.isPro || isReview || !s.dailyFreeUsed;
    var energy = s.energy;
    var dailyFreeUsed = s.dailyFreeUsed;
    var spent = 0;
    if (!free) {
      spent = s.config.lessonCost;
      energy = (energy - spent).clamp(0, s.config.maxEnergy);
    } else if (!s.isPro && !isReview && !s.dailyFreeUsed) {
      dailyFreeUsed = true; // consume the always-free first daily lesson
    }
    final completed = s.lessonsCompleted + 1;
    final interstitial = !s.isPro &&
        s.config.interstitialEvery > 0 &&
        completed % s.config.interstitialEvery == 0;
    // Daily-goal XP credits real lessons only (reviews are free practice).
    final xpToday = s.xpToday + (isReview ? 0 : s.config.lessonXp);
    var next = s.copyWith(
      energy: energy,
      dailyFreeUsed: dailyFreeUsed,
      lessonsCompleted: completed,
      xpToday: xpToday,
    );
    // The tank dropped below full -> start the real regen clock (if idle).
    if (!next.isPro &&
        next.energy < next.config.maxEnergy &&
        next.refillAtMs == null) {
      next = next.copyWith(
        refillAtMs: DateTime.now().millisecondsSinceEpoch +
            next.config.regenSeconds * 1000,
      );
    }
    state = next;
    return EnergyCommitOutcome(
      energySpent: spent,
      showInterstitial: interstitial,
      energy: energy,
      wasFree: free,
    );
  }

  /// Credit any energy that has regenerated in real time. Driven by the daily
  /// strip's per-second tick; [nowMs] is injectable for tests.
  void applyRegen({int? nowMs}) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final next = state.regenerated(now);
    if (!identical(next, state)) state = next;
  }

  /// Ad-reward / manual refill, capped at the max tank.
  void refill([int amount = 1]) {
    var next = state.copyWith(
        energy: (state.energy + amount).clamp(0, state.config.maxEnergy));
    if (next.energy >= next.config.maxEnergy) {
      next = next.copyWith(clearRefill: true);
    } else if (next.refillAtMs == null) {
      next = next.copyWith(
          refillAtMs: DateTime.now().millisecondsSinceEpoch +
              next.config.regenSeconds * 1000);
    }
    state = next;
  }

  void setPro(bool value) {
    var next = state.copyWith(isPro: value);
    if (value) next = next.copyWith(clearRefill: true);
    state = next;
  }

  /// New day -> the first daily lesson is free again.
  void resetDaily() => state = state.copyWith(dailyFreeUsed: false);
}

final energyControllerProvider =
    StateNotifierProvider<EnergyController, EnergyState>(
        (ref) => EnergyController());
