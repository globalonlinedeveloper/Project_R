// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// CAPS-1 [R-M8 · R-H7] — relay request-size / input hard cap.
//
// R-M8 calls for "per-IP/per-user rate + request-size limits" in the relay and
// R-H7 for "size limits, burst detection". The M1 [CostGuard] only SCALES the
// cost ESTIMATE with prompt length; there is no HARD per-request input ceiling.
// Worse, in the cost-safe stack ModeratedAiRelay(BudgetedAiRelay(model)) the
// INPUT-moderation classify runs BEFORE the budget gate, so an oversized prompt
// already drives a moderation call (an external/paid round-trip at go-live, and
// work proportional to size) before anything denies it — and a single very large
// in-cap prompt can still drive a big per-message cost.
//
// This is a fail-closed, deterministic, ZERO-I/O size gate that rejects an
// over-size prompt UP FRONT. Slotted OUTERMOST (see relay_pipeline.dart), it
// short-circuits BEFORE moderation + the meter + the paid model. It mirrors the
// [CostGuard] / [BudgetedAiRelay] / [RelayBudgetExceeded] shape (pure checker +
// AiRelay decorator + typed exception). It NEVER truncates — an over-size prompt
// is rejected, not silently trimmed (truncation would change the user's meaning).
//
// Seam notes (go-live wiring):
//  - the per-feature char/token ceilings replace [RequestSizeLimits] defaults at
//    go-live; the defaults are a conservative FINITE ceiling so an un-tuned build
//    still rejects an abusive oversized prompt rather than passing it through.
//  - this cap is INDEPENDENT of (and outside) the R-M8 spend cap: it is a
//    per-request abuse ceiling, defense-in-depth above the daily/global meter.
//
// GO-LIVE STOP: tune [RequestSizeLimits] (maxChars / optional maxTokens) to the
// real per-feature ceiling and pass it as `sizeGuard:` to buildModeratedBudgetedRelay.
import 'ai_relay.dart';

/// Outcome of a request-size check. Every non-[allow] value is a fail-closed DENY.
enum RequestSizeDecision {
  allow,

  /// Prompt exceeded the character ceiling.
  denyChars,

  /// Prompt exceeded the (optional) estimated-token ceiling.
  denyTokens;

  bool get isAllow => this == RequestSizeDecision.allow;
}

/// Injected request-size policy (R-M8 "request-size limits" / R-H7 "size limits").
/// Defaults are intentionally a conservative, finite per-request ceiling so an
/// un-tuned deployment still rejects an abusive oversized prompt up front.
class RequestSizeLimits {
  const RequestSizeLimits({
    this.maxChars = 8000,
    this.maxTokens,
    this.charsPerToken = 4,
  })  : assert(maxChars > 0),
        // null => the token axis is disabled (characters only).
        assert((maxTokens ?? 1) > 0),
        assert(charsPerToken > 0);

  /// Hard ceiling on prompt length in characters (UTF-16 code units, matching
  /// `String.length` used by [CostGuard]). A prompt longer than this is rejected.
  final int maxChars;

  /// Optional hard ceiling on the ESTIMATED token count. `null` disables this
  /// axis (the char ceiling alone applies).
  final int? maxTokens;

  /// Deterministic chars-per-token heuristic used for the token estimate. The
  /// real tokenizer is a model detail; this conservative ratio is enough to cap
  /// abuse and is refined at go-live.
  final int charsPerToken;
}

/// Pure (no I/O) request-size gate. Deterministic; mirrors [CostGuard]'s style.
class RequestSizeGuard {
  const RequestSizeGuard([this.limits = const RequestSizeLimits()]);

  final RequestSizeLimits limits;

  /// Deterministic token estimate: `ceil(chars / charsPerToken)`. No randomness.
  int estimateTokens(String prompt) =>
      (prompt.length + limits.charsPerToken - 1) ~/ limits.charsPerToken;

  /// Gate a prompt by size. A prompt AT a limit passes; only a prompt strictly
  /// OVER a limit is denied. The char ceiling is checked first.
  RequestSizeDecision check(String prompt) {
    if (prompt.length > limits.maxChars) {
      return RequestSizeDecision.denyChars;
    }
    final maxTokens = limits.maxTokens;
    if (maxTokens != null && estimateTokens(prompt) > maxTokens) {
      return RequestSizeDecision.denyTokens;
    }
    return RequestSizeDecision.allow;
  }
}

/// Thrown by [RequestSizeLimitedAiRelay.complete] when a prompt exceeds the
/// injected size limit. The inner relay (moderation + meter + model) is NEVER
/// invoked when this is thrown, so an oversized prompt costs nothing — no
/// moderation classify, no paid model round-trip, no spend recorded. The prompt
/// is REJECTED, never truncated (fail-closed).
class RequestTooLarge implements Exception {
  const RequestTooLarge(
    this.decision, {
    required this.chars,
    required this.limit,
  });

  final RequestSizeDecision decision;

  /// Actual prompt length in characters.
  final int chars;

  /// The breached ceiling (maxChars, or maxTokens for a token denial).
  final int limit;

  @override
  String toString() =>
      'RequestTooLarge(decision: $decision, chars: $chars, limit: $limit)';
}

/// [AiRelay] decorator enforcing [RequestSizeGuard] BEFORE delegating to [inner].
/// Slots OUTERMOST in the relay stack (outside moderation + the meter) so an
/// oversized prompt is rejected up front — before any moderation classify call
/// or paid model round-trip. Pure, no I/O; never truncates.
class RequestSizeLimitedAiRelay implements AiRelay {
  const RequestSizeLimitedAiRelay(
    this.inner, {
    this.guard = const RequestSizeGuard(),
  });

  final AiRelay inner;
  final RequestSizeGuard guard;

  @override
  bool get isAvailable => inner.isAvailable;

  @override
  Future<RelayText> complete(String prompt) async {
    final decision = guard.check(prompt);
    if (decision.isAllow) {
      return inner.complete(prompt);
    }
    final limits = guard.limits;
    final limit = decision == RequestSizeDecision.denyTokens
        ? (limits.maxTokens ?? limits.maxChars)
        : limits.maxChars;
    // Inner relay is NEVER reached on a deny: no moderation classify, no paid
    // model round-trip, no spend. Reject (never truncate) — fail closed.
    throw RequestTooLarge(decision, chars: prompt.length, limit: limit);
  }
}
