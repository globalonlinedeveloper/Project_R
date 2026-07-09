/// Remote-text fetch seam for CONTENT (C-1, plan §B). Compile-time split like
/// `speech_tts` / `audio_relay`: web = browser `fetch`, everywhere else = an
/// honest null (bundled fallback). Injectable via [RemoteTextFetch] in tests.
library;

export 'remote_fetch_stub.dart'
    if (dart.library.js_interop) 'remote_fetch_web.dart';

/// Injectable fetch signature: body text, or null on any failure.
typedef RemoteTextFetch = Future<String?> Function(Uri url);
