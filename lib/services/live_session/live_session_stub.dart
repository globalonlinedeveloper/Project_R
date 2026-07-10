import 'live_session.dart';

/// Non-web factory: live voice is web-first (O-L1); every other target gets
/// the honest fail-closed engine (parity with speech_tts/audio_relay stubs).
LiveSessionEngine createLiveSessionEngine({LiveTokenFetcher? tokenFetcher}) =>
    const UnavailableLiveSessionEngine();
