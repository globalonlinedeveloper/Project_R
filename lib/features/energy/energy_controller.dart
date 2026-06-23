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
    state = s.copyWith(
      energy: energy,
      dailyFreeUsed: dailyFreeUsed,
      lessonsCompleted: completed,
    );
    return EnergyCommitOutcome(
      energySpent: spent,
      showInterstitial: interstitial,
      energy: energy,
      wasFree: free,
    );
  }

  /// Ad-reward / manual refill, capped at the max tank.
  void refill([int amount = 1]) => state = state.copyWith(
      energy: (state.energy + amount).clamp(0, state.config.maxEnergy));

  void setPro(bool value) => state = state.copyWith(isPro: value);

  /// New day -> the first daily lesson is free again.
  void resetDaily() => state = state.copyWith(dailyFreeUsed: false);
}

final energyControllerProvider =
    StateNotifierProvider<EnergyController, EnergyState>(
        (ref) => EnergyController());
