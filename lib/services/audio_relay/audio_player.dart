import 'package:flutter_riverpod/flutter_riverpod.dart';

// Compile-time platform split: web => browser HTMLAudioElement; else Unavailable.
import 'audio_player_stub.dart'
    if (dart.library.js_interop) 'audio_player_web.dart';

/// Podcast audio-playback seam (INF-7) -- mirrors [SpeechTts]. A podcast passage
/// carries a REAL pre-generated MP3 (its `audio_ref` -> a `media_asset` uri on
/// R2); this seam plays that URL directly via the browser's built-in
/// HTMLAudioElement (no plugin, no key, no `tts-relay` edge fn). It is
/// INDEPENDENT of the browser SpeechSynthesis path ([SpeechTts]): a podcast's
/// primary audio is the authored MP3, while the transcript read-aloud stays the
/// SpeechTts fallback.
///
/// Honesty: [isAvailable] is false on every non-web build and in all tests (the
/// stub factory), so the player degrades to the transcript there -- it never
/// offers audio it cannot play.
// R-D5 (listen) - R-B3: pre-generated podcast audio delivery on web.
abstract interface class PodcastAudio {
  /// False => the UI must NOT offer the audio player (it shows the transcript).
  bool get isAvailable;

  /// A playable handle for the MP3 at [url]. Only meaningful when [isAvailable].
  PodcastHandle handleFor(String url);
}

/// A play/pause handle over one podcast audio URL. Parallels the Listen
/// `AudioHandle` but adds pause (a podcast is a long track the learner starts
/// and stops, not a one-shot phrase).
abstract interface class PodcastHandle {
  /// Start (or resume) playback. Throws if no real audio backend is wired.
  Future<void> play();

  /// Pause playback (position retained). No-op when nothing is playing.
  Future<void> pause();

  /// Whether audio is currently playing (best-effort; false when unknown).
  bool get isPlaying;

  /// Release the underlying element.
  Future<void> dispose();
}

/// Default (non-web / tests): never available => the player shows the transcript.
/// Parity with `UnavailableSpeechTts`.
class UnavailablePodcastAudio implements PodcastAudio {
  const UnavailablePodcastAudio();
  @override
  bool get isAvailable => false;
  @override
  PodcastHandle handleFor(String url) => const SilentPodcastHandle();
}

/// Fail-closed handle: [play] throws so the player degrades honestly -- it NEVER
/// pretends to stream silence.
class SilentPodcastHandle implements PodcastHandle {
  const SilentPodcastHandle();
  @override
  bool get isPlaying => false;
  @override
  Future<void> play() async =>
      throw const PodcastAudioUnavailable('no audio player wired (web-only).');
  @override
  Future<void> pause() async {}
  @override
  Future<void> dispose() async {}
}

/// Thrown by [SilentPodcastHandle] (or a real handle on a decode/URL failure).
class PodcastAudioUnavailable implements Exception {
  const PodcastAudioUnavailable(this.reason);
  final String reason;
  @override
  String toString() => 'PodcastAudioUnavailable: $reason';
}

/// Resolved at compile time by [createPodcastAudio] (web vs stub). Tests may
/// override with a fake available impl to exercise the live player path.
final podcastAudioProvider =
    Provider<PodcastAudio>((ref) => createPodcastAudio());
