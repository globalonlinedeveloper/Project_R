import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'relay_text.dart';

export 'relay_text.dart';
export 'cost_guard.dart';
export 'moderation.dart';
export 'gemini_relay.dart';
export 'relay_pipeline.dart';

/// Portability seam (R-H7): AI-vendor adapter. ALL runtime AI calls route through
/// this; Stage 3 supplies a concrete (e.g. Gemini) implementation behind it, with
/// server-side cost guardrails (R-M8) + moderation. No network in this layer.
///
/// TS-13: relay output is UNTRUSTED, so [complete] returns a [RelayText] box —
/// callers MUST escape it (`toHtml` / `toMarkdown`) before any HTML/markdown sink.
abstract interface class AiRelay {
  bool get isAvailable;
  Future<RelayText> complete(String prompt);
}

/// Default (local / Stage 1–2): no AI configured — fails closed.
class UnconfiguredAiRelay implements AiRelay {
  const UnconfiguredAiRelay();
  @override
  bool get isAvailable => false;
  @override
  Future<RelayText> complete(String prompt) async =>
      throw StateError('AiRelay is not configured (enabled in Stage 3).');
}

final aiRelayProvider = Provider<AiRelay>((ref) => const UnconfiguredAiRelay());
