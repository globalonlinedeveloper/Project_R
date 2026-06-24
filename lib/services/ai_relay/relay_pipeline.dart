// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// COST-1 [R-M8 · R-H7] — cost-safe relay composition (the S26 review's open cost finding).
//
// The paid model call is the cost event. M1's [BudgetedAiRelay] books spend right AFTER its
// inner relay returns; M2's [ModeratedAiRelay] classifies the OUTPUT *after* the model has
// already produced it. So if the budget layer sits OUTSIDE moderation —
// `BudgetedAiRelay(ModeratedAiRelay(model))`, the order the old comments documented — an
// OUTPUT-moderation block throws straight past recordSpend: the attempt hit the (paid) model
// yet is NEVER charged. That is a per-user / global cap BYPASS an abuser can farm by crafting
// prompts whose outputs get blocked (R-M8 cost ceiling · R-H7 relay abuse).
//
// Fix = composition order: put the budget / meter layer DIRECTLY around the model, INSIDE
// moderation -> `ModeratedAiRelay(BudgetedAiRelay(model))`. Spend is then booked the instant
// the model call returns, BEFORE output moderation runs, so an output block (which throws
// after) STILL counts against the ceiling. INPUT-moderation blocks and over-cap denials
// short-circuit BEFORE the model, so they are correctly never charged. This file makes that
// order canonical + tested instead of a comment that can drift (it already had).
//
// PRODUCT NOTE (go-live / owner): counting a policy-BLOCKED output against the cap is the
// anti-abuse default (R-M8) — it stops farming expensive generations whose output is blocked.
// Whether a *false-positive* block earns a goodwill credit refund is an owner / UX call,
// applied downstream against the M4 ledger; this layer only ensures the spend is metered,
// never silently bypassed.
//
// GO-LIVE STOP: inject the real model adapter (M3 Gemini), the real moderation provider, and
// the server-side ledger-backed spend readers / recorder; then override `aiRelayProvider`
// with this stack.

import 'ai_relay.dart';
import 'cost_guard.dart';
import 'moderation.dart';

/// Builds the runtime relay stack in the COST-SAFE order (innermost -> outermost):
///
///   [model] -> [BudgetedAiRelay] (meter + cap gate) -> [ModeratedAiRelay] (input/output safety)
///
/// i.e. `ModeratedAiRelay(BudgetedAiRelay(model))`. See the file header for why this order is
/// the R-M8 cost-bypass fix. Every collaborator is injected; the safe local defaults
/// ([CostGuard], [NoopModerationAuditSink]) keep an un-wired build inert.
AiRelay buildModeratedBudgetedRelay({
  required AiRelay model,
  required ModerationProvider moderationProvider,
  required SpendReader userSpentToday,
  required SpendReader globalSpentToday,
  required SpendRecorder recordSpend,
  CostGuard guard = const CostGuard(),
  ModerationAuditSink moderationAudit = const NoopModerationAuditSink(),
  Duration moderationTimeout = const Duration(seconds: 10),
}) {
  // Meter wraps the model DIRECTLY: spend is recorded as soon as the paid call returns,
  // so nothing layered ABOVE can throw past the charge.
  final metered = BudgetedAiRelay(
    model,
    userSpentToday: userSpentToday,
    globalSpentToday: globalSpentToday,
    recordSpend: recordSpend,
    guard: guard,
  );
  // Moderation wraps the meter: an input block short-circuits BEFORE the meter (never
  // charged); an output block throws AFTER the meter already booked the spend (still charged).
  return ModeratedAiRelay(
    metered,
    provider: moderationProvider,
    audit: moderationAudit,
    timeout: moderationTimeout,
  );
}
