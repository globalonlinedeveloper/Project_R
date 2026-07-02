import 'speech_tts.dart';

/// Non-web / VM / test factory: speech synthesis is unavailable, so Listen
/// degrades honestly to the typed renderer.
SpeechTts createSpeechTts() => const UnavailableSpeechTts();
