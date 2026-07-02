import 'dart:js_interop';

import 'speech_tts.dart';

/// Web factory: the browser SpeechSynthesis API (built into every modern
/// browser — no dependency, no key, no server). Only compiled on the web target
/// (guarded by the `dart.library.js_interop` conditional import in speech_tts.dart).
SpeechTts createSpeechTts() => WebSpeechTts();

@JS('speechSynthesis')
external _SpeechSynthesis? get _speechSynthesis;

extension type _SpeechSynthesis._(JSObject _) implements JSObject {
  external void speak(_Utterance utterance);
  external void cancel();
  external bool get speaking;
}

@JS('SpeechSynthesisUtterance')
extension type _Utterance._(JSObject _) implements JSObject {
  external factory _Utterance(String text);
  external set rate(double value);
  external set lang(String value);
}

/// Speaks a phrase via the browser. [isAvailable] is true when the global
/// `speechSynthesis` object exists (all modern browsers).
class WebSpeechTts implements SpeechTts {
  @override
  bool get isAvailable => _speechSynthesis != null;

  @override
  AudioHandle handleFor(String text, {String lang = ''}) =>
      _WebSpeechAudioHandle(text, lang);
}

class _WebSpeechAudioHandle implements AudioHandle {
  _WebSpeechAudioHandle(this.text, this.lang);
  final String text;
  final String lang;

  @override
  bool get isPlaying => _speechSynthesis?.speaking ?? false;

  @override
  Future<void> play() async => _speak(1.0);

  @override
  Future<void> playSlow() async => _speak(0.6);

  void _speak(double rate) {
    final _SpeechSynthesis? synth = _speechSynthesis;
    if (synth == null) {
      throw const AudioUnavailable('speechSynthesis unavailable');
    }
    // Cancel any in-flight utterance so rapid taps don't queue up.
    synth.cancel();
    final _Utterance u = _Utterance(text)..rate = rate;
    if (lang.isNotEmpty) u.lang = lang;
    synth.speak(u);
  }

  @override
  Future<void> dispose() async => _speechSynthesis?.cancel();
}
