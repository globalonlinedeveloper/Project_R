// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// CAPS-2 [R-M8 · R-H7] — TTS synthesis request-size hard cap. Synthesis is a
// PAID GCP call, so reject an oversized text/ssml payload UP FRONT (before the
// transport round-trip + the paid model). Mirrors `request_size_guard.dart`:
// pure checker + [TtsRelay] decorator + typed exception. NEVER truncates — an
// over-size payload is rejected, not silently trimmed.
//
// GO-LIVE STOP: tune [TtsSizeLimits.maxChars] to the real per-locale ceiling
// and pass it as `guard:` when constructing [TtsSizeLimitedTtsRelay].
import 'tts_relay.dart';

/// Injected request-size policy. The default is a conservative finite ceiling
/// (a Listen prompt is short) so an un-tuned deployment still rejects abuse.
class TtsSizeLimits {
  const TtsSizeLimits({this.maxChars = 2000}) : assert(maxChars > 0);

  /// Hard ceiling on the synthesis payload length in characters.
  final int maxChars;
}

/// Pure (no I/O) size gate. Deterministic; mirrors `RequestSizeGuard`'s style.
class TtsSizeGuard {
  const TtsSizeGuard([this.limits = const TtsSizeLimits()]);

  final TtsSizeLimits limits;

  /// A payload AT the limit passes; only strictly OVER is denied.
  bool withinLimit(TtsRequest req) => req.payload.length <= limits.maxChars;
}

/// Thrown by [TtsSizeLimitedTtsRelay.synthesize] when a payload exceeds the
/// injected limit. The inner relay is NEVER reached, so an oversized request
/// costs nothing (no transport call, no paid synthesis). Rejected, not trimmed.
class TtsRequestTooLarge implements Exception {
  const TtsRequestTooLarge({required this.chars, required this.limit});
  final int chars;
  final int limit;
  @override
  String toString() => 'TtsRequestTooLarge(chars: $chars, limit: $limit)';
}

/// [TtsRelay] decorator enforcing [TtsSizeGuard] BEFORE delegating to [inner].
/// Slots OUTERMOST so an oversized payload is rejected up front. Pure, no I/O.
class TtsSizeLimitedTtsRelay implements TtsRelay {
  const TtsSizeLimitedTtsRelay(this.inner, {this.guard = const TtsSizeGuard()});

  final TtsRelay inner;
  final TtsSizeGuard guard;

  @override
  bool get isAvailable => inner.isAvailable;

  @override
  Future<AudioBytes> synthesize(TtsRequest req) async {
    if (!guard.withinLimit(req)) {
      throw TtsRequestTooLarge(
        chars: req.payload.length,
        limit: guard.limits.maxChars,
      );
    }
    return inner.synthesize(req);
  }
}
