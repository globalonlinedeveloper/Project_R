import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_handle.dart';
// Compile-time platform split: web => browser SpeechSynthesis; else Unavailable.
import 'speech_tts_stub.dart'
    if (dart.library.js_interop) 'speech_tts_web.dart';

export 'audio_handle.dart';

/// Client-side speech-synthesis seam — the ZERO-COST web path that speaks a
/// phrase directly via the browser's built-in SpeechSynthesis (no GCP key, no
/// `tts-relay` edge fn, no audio-player package). This is INDEPENDENT of
/// [TtsRelay] (the GCP byte path): Listen has two possible audio sources and
/// this is the one wired live on web.
///
/// Honesty: [isAvailable] is false on every non-web build and in all tests
/// (the stub factory), so the lesson runner degrades Listen to the typed
/// renderer there — it never offers audio it cannot play.
// R-D5 (listen) · R-D8 (dictation): browser-speech delivery on web.
abstract interface class SpeechTts {
  /// False => the UI must NOT offer Listen (runner degrades to typed).
  bool get isAvailable;

  /// A playable handle that speaks [text] (normal + slow). [lang] (e.g. `es`)
  /// hints the browser voice. Only meaningful when [isAvailable].
  AudioHandle handleFor(String text, {String lang});
}

/// Default (non-web / tests): never available => Listen degrades to typed.
class UnavailableSpeechTts implements SpeechTts {
  const UnavailableSpeechTts();
  @override
  bool get isAvailable => false;
  @override
  AudioHandle handleFor(String text, {String lang = ''}) =>
      const SilentAudioHandle();
}

/// Resolved at compile time by [createSpeechTts] (web vs stub). Tests may
/// override with a fake available impl to exercise the live Listen path.
final speechTtsProvider = Provider<SpeechTts>((ref) => createSpeechTts());
