// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// M1 [R-H7 / R-M8 · TS-4] — AI-relay cost guardrail + per-user caps.
//
// A deterministic, fail-closed cost/quota estimator + budget gate that ANY
// future relay adapter (e.g. the M3 Gemini adapter) must pass before a paid
// round-trip. Pure Dart, ZERO network, ZERO I/O in [CostGuard] itself.
//
// Seam notes (go-live wiring):
//  - `userSpentToday` / `globalSpentToday` are read SERVER-SIDE from the credit
//    ledger (M4 `post_credit_entry` / a balance view) — NEVER client-asserted.
//    Here they are injected async providers with safe fakes in tests.
//  - the real per-model price table replaces [CostConfig] defaults at go-live;
//    the defaults are deliberately HIGH so an unconfigured estimate fails closed
//    (denies sooner) rather than under-charging.
import 'ai_relay.dart';

/// Outcome of a budget check. Every non-[allow] value is a DENY (fail-closed).
enum CostDecision {
  allow,
  denyPerUserCap,
  denyGlobalCeiling,

  /// Inputs were missing/null/negative (or a spend provider errored) — deny.
  denyInvalid;

  bool get isAllow => this == CostDecision.allow;
}

/// Injected cost/quota policy. Defaults are intentionally conservative (HIGH
/// cost, modest caps) so that an un-tuned deployment errs toward denying spend.
class CostConfig {
  const CostConfig({
    this.perUserDailyCap = 50,
    this.globalDailyCeiling = 100000,
    this.unitFloor = 1,
    this.charsPerUnit = 200,
    this.unitPrice = 4,
  })  : assert(perUserDailyCap >= 0),
        assert(globalDailyCeiling >= 0),
        assert(unitFloor >= 0),
        assert(charsPerUnit > 0),
        assert(unitPrice > 0);

  /// Max credit units a single user may spend per day.
  final int perUserDailyCap;

  /// Max credit units across ALL users per day (global circuit-breaker).
  final int globalDailyCeiling;

  /// Minimum estimate for any non-empty request (floor; also the empty-prompt
  /// cost). Guarantees `estimateCost >= unitFloor` always.
  final int unitFloor;

  /// Heuristic: characters of prompt per billable unit.
  final int charsPerUnit;

  /// Credits charged per billable unit.
  final int unitPrice;
}

/// Pure (no I/O) cost estimator + budget gate.
class CostGuard {
  const CostGuard([this.config = const CostConfig()]);

  final CostConfig config;

  /// Deterministic, monotonic-non-decreasing estimate in whole credit units.
  /// Always `>= config.unitFloor`. No randomness, no I/O.
  int estimateCost(String prompt) {
    final units = (prompt.length + config.charsPerUnit - 1) ~/ config.charsPerUnit;
    final raw = units * config.unitPrice;
    return raw < config.unitFloor ? config.unitFloor : raw;
  }

  /// Gate a prospective spend. Fails closed on any null/negative input or on a
  /// projected total exceeding the per-user cap or the global ceiling.
  CostDecision check({
    required int? userSpentToday,
    required int? globalSpentToday,
    required int? estimate,
  }) {
    if (userSpentToday == null || globalSpentToday == null || estimate == null) {
      return CostDecision.denyInvalid;
    }
    if (userSpentToday < 0 || globalSpentToday < 0 || estimate < 0) {
      return CostDecision.denyInvalid;
    }
    if (userSpentToday + estimate > config.perUserDailyCap) {
      return CostDecision.denyPerUserCap;
    }
    if (globalSpentToday + estimate > config.globalDailyCeiling) {
      return CostDecision.denyGlobalCeiling;
    }
    return CostDecision.allow;
  }
}

/// Thrown by [BudgetedAiRelay.complete] when the budget gate denies the call.
/// The inner relay is NEVER invoked when this is thrown.
class RelayBudgetExceeded implements Exception {
  const RelayBudgetExceeded(this.decision, {required this.estimate});

  final CostDecision decision;
  final int estimate;

  @override
  String toString() =>
      'RelayBudgetExceeded(decision: $decision, estimate: $estimate credits)';
}

/// Reads today's credit spend (per-user and global). At go-live this is backed
/// by the M4 ledger, read server-side; in tests it is a fake. A provider that
/// throws or returns null causes [BudgetedAiRelay] to fail closed.
typedef SpendReader = Future<int?> Function();

/// Records `credits` of spend after an allowed completion. At go-live this posts
/// to the M4 ledger; in tests it is a counting fake.
typedef SpendRecorder = Future<void> Function(int credits);

/// [AiRelay] decorator enforcing [CostGuard] BEFORE delegating to [inner].
/// Composition order at go-live: `BudgetedAiRelay(ModeratedAiRelay(GeminiAiRelay(...)))`.
class BudgetedAiRelay implements AiRelay {
  const BudgetedAiRelay(
    this.inner, {
    required this.userSpentToday,
    required this.globalSpentToday,
    required this.recordSpend,
    this.guard = const CostGuard(),
  });

  final AiRelay inner;
  final CostGuard guard;

  /// Reads the user's credit spend today (M4 ledger at go-live; fake in tests).
  final SpendReader userSpentToday;

  /// Reads global credit spend today (M4 ledger at go-live; fake in tests).
  final SpendReader globalSpentToday;

  /// Posts spend after an allowed completion (M4 ledger at go-live).
  final SpendRecorder recordSpend;

  @override
  bool get isAvailable => inner.isAvailable;

  @override
  Future<RelayText> complete(String prompt) async {
    final estimate = guard.estimateCost(prompt);

    // Fail closed if a spend provider is unavailable/errors -> treat as null.
    int? user;
    int? global;
    try {
      user = await userSpentToday();
    } catch (_) {
      user = null;
    }
    try {
      global = await globalSpentToday();
    } catch (_) {
      global = null;
    }

    final decision = guard.check(
      userSpentToday: user,
      globalSpentToday: global,
      estimate: estimate,
    );
    if (!decision.isAllow) {
      // Inner relay is NEVER reached on a deny; no spend is recorded.
      throw RelayBudgetExceeded(decision, estimate: estimate);
    }

    final result = await inner.complete(prompt);
    // Record spend ONLY after a successful, in-budget completion.
    await recordSpend(estimate);
    return result;
  }
}
