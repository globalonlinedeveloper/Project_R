import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Portability seam (R-H7): AI-vendor adapter. ALL runtime AI calls route through
/// this; Stage 3 supplies a concrete (e.g. Gemini) implementation behind it, with
/// server-side cost guardrails (R-M8) + moderation. No network in this layer.
abstract interface class AiRelay {
  bool get isAvailable;
  Future<String> complete(String prompt);
}

/// Default (local / Stage 1–2): no AI configured — fails closed.
class UnconfiguredAiRelay implements AiRelay {
  const UnconfiguredAiRelay();
  @override
  bool get isAvailable => false;
  @override
  Future<String> complete(String prompt) async =>
      throw StateError('AiRelay is not configured (enabled in Stage 3).');
}

final aiRelayProvider = Provider<AiRelay>((ref) => const UnconfiguredAiRelay());
