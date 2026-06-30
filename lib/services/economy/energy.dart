/// Pure, clockless ENERGY model (R-I3 — energy: lesson cost, time-regen, cap).
///
/// DISPLAY-ONLY / NON-BLOCKING (owner decision, S60): energy depletes by one
/// per completed lesson and regenerates over REAL time toward a cap, surfaced in
/// the top-bar ⚡ counter — but it NEVER gates a lesson. (The design's `energygate`
/// is deliberately not built; flipping to gating once a 💎 refill / IAP path
/// exists is a one-line change.) Like the other economy models this holds no
/// clock and no balance: the [LearnerController] passes the current energy + the
/// elapsed time and gets back the regenerated / post-lesson value, and owns the
/// (go-live durable) state. PRO "unlimited" (the design's ∞) is a billing
/// surface the controller decides, not a block computed here.
///
/// HONESTY (design spec §6 / R-I3): the depletion + time-regen + cap are REAL
/// and deterministic. Energy is session-local until the durable store lands
/// (the same go-live wiring as every other R-O1 counter) — never faked.
class EnergyModel {
  const EnergyModel();

  /// Full energy cap (design spec: `energyMax = 5`).
  static const int cap = 5;

  /// Energy spent per completed lesson (design: −1 ⚡).
  static const int lessonCost = 1;

  /// Real time to regenerate one energy (tunable; design hint ≈30 min).
  static const Duration regenInterval = Duration(minutes: 30);

  int _clamp(int energy) => energy < 0 ? 0 : (energy > cap ? cap : energy);

  /// [energy] after [elapsed] of regeneration, capped at [cap]. Partial
  /// intervals do NOT grant energy (floor); malformed input clamps into
  /// [0, cap]; an already-full or non-positive elapsed returns unchanged.
  int regenerated({required int energy, required Duration elapsed}) {
    final int base = _clamp(energy);
    if (base >= cap || elapsed <= Duration.zero) {
      return base;
    }
    final int gained = elapsed.inMinutes ~/ regenInterval.inMinutes;
    final int total = base + gained;
    return total > cap ? cap : total;
  }

  /// [energy] after completing a lesson: spends [lessonCost], floored at 0.
  /// NON-BLOCKING — energy may reach 0 and the lesson still proceeds.
  int afterLesson({required int energy}) {
    final int next = _clamp(energy) - lessonCost;
    return next < 0 ? 0 : next;
  }
}
