import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'edge_tts_relay.dart';
export 'tts_size_guard.dart';
export 'audio_handle.dart';

/// Portability seam (mirrors [AiRelay]): a text/SSML synthesis request -> playable
/// audio bytes. ALL Listen audio synthesis routes through this; a fail-closed
/// local default keeps an un-wired build silent (Listen degrades to typed). No
/// network in this layer — the concrete [EdgeTtsRelay] injects the transport.
///
/// The GCP_TTS key is NEVER referenced here (nor in any client layer) — it lives
/// only in the server-side `tts-relay` edge function, exactly as GEMINI_API_KEY
/// backs `ai-relay`.
abstract interface class TtsRelay {
  /// When false the UI must NOT offer Listen (it degrades to typed).
  bool get isAvailable;

  /// Synthesize [req] to audio bytes. Throws (never a partial result) on any
  /// error; callers treat a throw as "no audio" and degrade honestly.
  Future<AudioBytes> synthesize(TtsRequest req);
}

/// Default (local / un-wired): no TTS configured — fails closed. Parity with
/// `UnconfiguredAiRelay`.
class UnconfiguredTtsRelay implements TtsRelay {
  const UnconfiguredTtsRelay();
  @override
  bool get isAvailable => false;
  @override
  Future<AudioBytes> synthesize(TtsRequest req) async =>
      throw const TtsUnavailable('not configured (enabled at go-live).');
}

/// The seam the app reads through. Default = fail-closed [UnconfiguredTtsRelay];
/// the real [EdgeTtsRelay] is injected at go-live in `backend_wiring` behind the
/// `RATEL_TTS` flag (mirrors `aiRelayProvider`).
final ttsRelayProvider = Provider<TtsRelay>((ref) => const UnconfiguredTtsRelay());

/// A synthesis request: [text] OR [ssml] (ssml wins when present), an optional
/// [voiceId], and a plain-string quality [tier] hint (kept a String so this
/// services layer stays decoupled from the content `TtsTier` enum). Pure value.
@immutable
class TtsRequest {
  const TtsRequest({
    this.text = '',
    this.ssml = '',
    this.voiceId = '',
    this.tier = '',
  });
  final String text;
  final String ssml;
  final String voiceId;
  final String tier;

  /// The synthesis payload a size guard caps (ssml preferred over text).
  String get payload => ssml.isNotEmpty ? ssml : text;
}

/// Opaque decoded audio (bytes + mime). NOT a markup sink — rendered by an audio
/// decoder — so unlike `RelayText` it needs no HTML/markdown escaping box.
@immutable
class AudioBytes {
  const AudioBytes(this.bytes, this.mime);
  final Uint8List bytes;
  final String mime;
  int get length => bytes.length;
}

/// Synthesis could not be completed (unconfigured / non-2xx / transport error).
class TtsUnavailable implements Exception {
  const TtsUnavailable(this.reason);
  final String reason;
  @override
  String toString() => 'TtsUnavailable: $reason';
}

/// Upstream returned 2xx but the payload was malformed / no usable audio.
class TtsBadResponse implements Exception {
  const TtsBadResponse(this.reason);
  final String reason;
  @override
  String toString() => 'TtsBadResponse: $reason';
}
