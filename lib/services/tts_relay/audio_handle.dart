import 'dart:async';

/// Portability seam for audio playback (the owner-gated §3d dependency). The
/// Listen renderer consumes an [AudioHandle] and NEVER imports an audio plugin
/// directly, so widget tests inject a fake and no third-party package is
/// required until go-live.
///
/// Owner decision (this increment): NO audio-player package is added — the
/// concrete runtime handle is the fail-closed [SilentAudioHandle]. In practice
/// the runner only builds a Listen item when a real player AND a real audio
/// source are wired, so this stub is never reached live today; if it ever were,
/// [play] throws and the renderer degrades honestly (a non-blocking hint), never
/// pretending to play.
abstract interface class AudioHandle {
  /// Play at normal speed. Throws if no real audio backend is wired.
  Future<void> play();

  /// Play slowly (turtle replay). Throws if no real audio backend is wired.
  Future<void> playSlow();

  /// Whether audio is currently playing (best-effort; false when unknown).
  bool get isPlaying;

  /// Release any resources.
  Future<void> dispose();
}

/// Fail-closed default: no audio-player dependency is wired (owner Option B).
/// Every play call throws so a renderer degrades honestly — it NEVER pretends to
/// play silence.
class SilentAudioHandle implements AudioHandle {
  const SilentAudioHandle();

  @override
  bool get isPlaying => false;

  @override
  Future<void> play() async =>
      throw const AudioUnavailable('no audio player wired (enabled at go-live).');

  @override
  Future<void> playSlow() async =>
      throw const AudioUnavailable('no audio player wired (enabled at go-live).');

  @override
  Future<void> dispose() async {}
}

/// Thrown by [SilentAudioHandle] (or a real handle on a decode/URL failure).
class AudioUnavailable implements Exception {
  const AudioUnavailable(this.reason);
  final String reason;
  @override
  String toString() => 'AudioUnavailable: $reason';
}
