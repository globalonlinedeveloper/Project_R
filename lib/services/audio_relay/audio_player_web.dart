import 'dart:js_interop';

import 'audio_player.dart';

/// Web factory: the browser HTMLAudioElement (`new Audio(url)` -- built into
/// every modern browser, no dependency, no key, no server). Only compiled on the
/// web target (guarded by the `dart.library.js_interop` conditional import in
/// audio_player.dart).
PodcastAudio createPodcastAudio() => WebPodcastAudio();

/// The global `Audio` constructor (null only on a non-browser JS host); mirrors
/// the `speechSynthesis` availability probe in speech_tts_web.dart.
@JS('Audio')
external JSAny? get _audioCtor;

@JS('Audio')
extension type _Audio._(JSObject _) implements JSObject {
  external factory _Audio(String src);
  external JSPromise<JSAny?> play();
  external void pause();
  external bool get paused;
  external set preload(String value);
}

/// Plays a pre-generated MP3 via the browser. [isAvailable] is true when the
/// global `Audio` constructor exists (all modern browsers).
class WebPodcastAudio implements PodcastAudio {
  @override
  bool get isAvailable => _audioCtor != null;

  @override
  PodcastHandle handleFor(String url) => _WebPodcastHandle(url);
}

class _WebPodcastHandle implements PodcastHandle {
  _WebPodcastHandle(String url) : _el = _Audio(url) {
    _el.preload = 'none';
  }

  final _Audio _el;

  @override
  bool get isPlaying => !_el.paused;

  @override
  Future<void> play() async {
    try {
      await _el.play().toDart;
    } catch (_) {
      // A blocked/failed play (autoplay policy, decode error) is honest "no
      // audio" -- the player degrades to the transcript.
      throw const PodcastAudioUnavailable('playback failed');
    }
  }

  @override
  Future<void> pause() async => _el.pause();

  @override
  Future<void> dispose() async => _el.pause();
}
