// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// M2 [P0-7b · TS-10] — AI-relay input + output moderation that FAILS CLOSED.
//
// A moderation state machine wrapping every relay round-trip on BOTH sides.
// Order of operations:
//   1. sanitize input (strip prompt-injection / tool-call markers);
//   2. classify input  — blocked => deny, relay NEVER called;
//   3. call the inner relay;
//   4. classify output — blocked => deny, raw text NEVER returned.
// A provider error / timeout / unknown verdict at EITHER step FAILS CLOSED
// ([ModerationUnavailable], candidate discarded). Allowed output stays a
// [RelayText] (TS-13). Every classification is logged to a [ModerationAuditSink]
// (TS-7; no-op locally, durable store at go-live).
//
// Composition at go-live: BudgetedAiRelay(ModeratedAiRelay(GeminiAiRelay(...))).
// Because the budget decorator records spend only AFTER inner.complete returns,
// a moderation deny (which throws out of inner.complete) prevents the charge.
import 'ai_relay.dart';

/// Provider verdict. Anything other than [allowed] stops the round-trip.
enum ModerationVerdict { allowed, blocked, unknown }

/// Moderation classifier seam. Go-live supplies OpenAI/Gemini moderation behind
/// this; the local default is a deterministic fake.
abstract interface class ModerationProvider {
  Future<ModerationVerdict> classify(String text);
}

/// Audit seam (TS-7). No-op locally; a durable, append-only store at go-live.
abstract interface class ModerationAuditSink {
  void record({required String stage, required ModerationVerdict verdict});
}

/// Default audit sink — discards (local only).
class NoopModerationAuditSink implements ModerationAuditSink {
  const NoopModerationAuditSink();
  @override
  void record({required String stage, required ModerationVerdict verdict}) {}
}

/// Deterministic local default provider: blocks on any configured keyword,
/// otherwise allows. Real moderation replaces this at go-live.
class KeywordModerationProvider implements ModerationProvider {
  const KeywordModerationProvider(this.blocked);
  final Set<String> blocked;
  @override
  Future<ModerationVerdict> classify(String text) async {
    final lower = text.toLowerCase();
    for (final b in blocked) {
      if (lower.contains(b.toLowerCase())) return ModerationVerdict.blocked;
    }
    return ModerationVerdict.allowed;
  }
}

/// Content was disallowed by policy at [stage] ('input' | 'output').
class ModerationBlocked implements Exception {
  const ModerationBlocked(this.stage);
  final String stage;
  // Deliberately does NOT echo the offending text (no leak path).
  @override
  String toString() => 'ModerationBlocked(stage: $stage)';
}

/// Moderation could not be completed (provider error/timeout/unknown verdict)
/// at [stage] — FAIL CLOSED, candidate discarded.
class ModerationUnavailable implements Exception {
  const ModerationUnavailable(this.stage, {this.cause});
  final String stage;
  final Object? cause;
  @override
  String toString() => 'ModerationUnavailable(stage: $stage)';
}

/// [AiRelay] decorator gating both sides of the relay call through moderation.
class ModeratedAiRelay implements AiRelay {
  ModeratedAiRelay(
    this.inner, {
    required this.provider,
    this.audit = const NoopModerationAuditSink(),
    this.timeout = const Duration(seconds: 10),
  });

  final AiRelay inner;
  final ModerationProvider provider;
  final ModerationAuditSink audit;
  final Duration timeout;

  @override
  bool get isAvailable => inner.isAvailable;

  /// Prompt-injection / tool-call markers stripped before anything sees the input,
  /// so an embedded system/instruction frame can't steer the model.
  static String sanitizeInput(String input) {
    var out = input;
    for (final p in _injectionPatterns) {
      out = out.replaceAll(p, '');
    }
    return out;
  }

  static final List<RegExp> _injectionPatterns = <String>[
    '<|system|>', '<|user|>', '<|assistant|>',
    '<|im_start|>', '<|im_end|>',
    '[INST]', '[/INST]', '<<SYS>>', '<</SYS>>',
    '### System:', '### Instruction:',
  ].map((m) => RegExp(RegExp.escape(m), caseSensitive: false)).toList();

  @override
  Future<RelayText> complete(String prompt) async {
    final cleaned = sanitizeInput(prompt);

    // (2) input moderation — throws Blocked/Unavailable; relay not yet reached.
    await _moderate(cleaned, stage: 'input');

    // (3) relay call on the sanitized prompt.
    final candidate = await inner.complete(cleaned);

    // (4) output moderation on the raw candidate text; on any non-allow the
    // candidate is discarded by throwing, so raw text never returns.
    await _moderate(candidate.plain, stage: 'output');

    return candidate; // already RelayText (TS-13)
  }

  Future<void> _moderate(String text, {required String stage}) async {
    ModerationVerdict verdict;
    try {
      verdict = await provider.classify(text).timeout(timeout);
    } catch (e) {
      // Provider error OR timeout => fail closed.
      audit.record(stage: stage, verdict: ModerationVerdict.unknown);
      throw ModerationUnavailable(stage, cause: e);
    }
    audit.record(stage: stage, verdict: verdict);
    switch (verdict) {
      case ModerationVerdict.allowed:
        return;
      case ModerationVerdict.blocked:
        throw ModerationBlocked(stage);
      case ModerationVerdict.unknown:
        throw ModerationUnavailable(stage, cause: 'unknown verdict');
    }
  }
}
