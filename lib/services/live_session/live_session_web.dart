import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'live_session.dart';

/// Web factory (only compiled under `dart.library.js_interop`): the Gemini
/// Live bidirectional WSS transport. Available ONLY when the build flag is on
/// AND `backend_wiring` armed a token fetcher — otherwise honest Unavailable.
LiveSessionEngine createLiveSessionEngine({LiveTokenFetcher? tokenFetcher}) =>
    kEnableLiveAi && tokenFetcher != null
    ? WebLiveSessionEngine(tokenFetcher)
    : const UnavailableLiveSessionEngine();

/// Gemini Live over the browser: single-use ephemeral token (minted by the
/// `live-token` edge function — model + system prompt LOCKED server-side, no
/// key ever reaches this code) → client-direct WSS → mic PCM16@16k up via an
/// AudioWorklet (`web/ratel_mic_worklet.js`, served as a plain asset — it can
/// NOT be bundled into main.dart.js) → tutor PCM16@24k scheduled back out.
///
/// MUST be started from the mic-button tap handler: both AudioContexts are
/// created (and resumed) inside [start] so the browser's user-gesture rules
/// are satisfied (plan §A landscape caveat).
class WebLiveSessionEngine implements LiveSessionEngine {
  WebLiveSessionEngine(this._mintToken);
  final LiveTokenFetcher _mintToken;

  @override
  bool get isAvailable => true;

  @override
  Future<LiveSession> start({Map<String, Object?>? payload}) async {
    final LiveTokenGrant grant;
    try {
      grant = await _mintToken(payload: payload);
    } on LiveSessionUnavailable {
      rethrow;
    } catch (_) {
      throw const LiveSessionUnavailable(
        'could not start a live session — please try again.',
        code: LiveUnavailableCode.startFailed,
      );
    }
    final _WebLiveSession session = _WebLiveSession();
    await session.open(grant);
    return session;
  }
}

/// Default Live API host (v1alpha — ephemeral tokens are a v1alpha feature;
/// the token server may override via `wss_host`). Kept in ONE place so L-5
/// QA can tune the endpoint without hunting.
const String _kLiveHost = 'generativelanguage.googleapis.com';
const String _kLivePath =
    // S114 QA fix: ephemeral tokens authenticate ONLY on the *Constrained*
    // bidi method (SDK live.ts: auth_tokens/ => BidiGenerateContentConstrained
    // + ?access_token=); plain BidiGenerateContent accepts API keys only
    // ("unregistered callers" close 1008 otherwise — sandbox-probed).
    '/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContentConstrained';

class _WebLiveSession implements LiveSession {
  final LiveSessionStateMachine _machine = LiveSessionStateMachine();
  final StreamController<LiveTurn> _transcript =
      StreamController<LiveTurn>.broadcast();

  web.WebSocket? _ws;
  web.AudioContext? _ctxIn;
  web.AudioContext? _ctxOut;
  web.MediaStream? _mic;
  web.AudioWorkletNode? _tap;
  final List<web.AudioBufferSourceNode> _scheduled =
      <web.AudioBufferSourceNode>[];
  double _playhead = 0;
  bool _muted = false;
  bool _closed = false;

  @override
  Stream<LiveSessionPhase> get phases => _machine.phases;
  @override
  LiveSessionPhase get phase => _machine.phase;
  @override
  Stream<LiveTurn> get transcript => _transcript.stream;
  @override
  void setMicMuted(bool muted) => _muted = muted;

  Future<void> open(LiveTokenGrant grant) async {
    _machine.advance(LiveSessionEvent.connectRequested);
    // 1) Audio pipeline FIRST (inside the user gesture): contexts + mic.
    try {
      final web.AudioContext ctxIn = web.AudioContext(
        web.AudioContextOptions(sampleRate: 16000),
      );
      final web.AudioContext ctxOut = web.AudioContext(
        web.AudioContextOptions(sampleRate: 24000),
      );
      _ctxIn = ctxIn;
      _ctxOut = ctxOut;
      await ctxIn.resume().toDart;
      await ctxOut.resume().toDart;
      _mic = (await web.window.navigator.mediaDevices
          .getUserMedia(web.MediaStreamConstraints(audio: true.toJS))
          .toDart);
      await ctxIn.audioWorklet.addModule('ratel_mic_worklet.js').toDart;
      final web.AudioWorkletNode tap = web.AudioWorkletNode(ctxIn, 'ratel-mic');
      _tap = tap;
      ctxIn.createMediaStreamSource(_mic!).connect(tap);
      tap.port.onmessage = ((web.MessageEvent e) {
        final JSAny? data = e.data;
        if (data == null || _muted || _ws == null) return;
        final LiveSessionPhase p = _machine.phase;
        if (p != LiveSessionPhase.listening && p != LiveSessionPhase.speaking) {
          return; // not streaming before setupComplete / after close
        }
        final Float32List samples = (data as JSFloat32Array).toDart;
        _send(<String, Object?>{
          'realtimeInput': <String, Object?>{
            'audio': <String, Object?>{
              'mimeType': 'audio/pcm;rate=16000',
              'data': base64Encode(pcm16FromFloat32(samples)),
            },
          },
        });
      }).toJS;
    } catch (_) {
      await close();
      throw const LiveSessionUnavailable(
        'microphone unavailable — allow mic access to talk with the tutor.',
        code: LiveUnavailableCode.micUnavailable,
      );
    }
    // 2) Socket: single-use token rides the query (v1alpha ephemeral tokens).
    final String host = grant.wssHost ?? _kLiveHost;
    final web.WebSocket ws = web.WebSocket(
      'wss://$host$_kLivePath?access_token=${Uri.encodeComponent(grant.token)}',
    );
    _ws = ws;
    ws.onopen = ((web.Event _) {
      // Model/system-prompt/modality are LOCKED into the token's
      // liveConnectConstraints (L-1) — the setup frame stays minimal.
      _send(const <String, Object?>{'setup': <String, Object?>{}});
    }).toJS;
    ws.onmessage = ((web.MessageEvent e) {
      final JSAny? data = e.data;
      if (data == null) return;
      if (data.typeofEquals('string')) {
        _handleFrame((data as JSString).toDart);
      } else {
        // Live API frames may arrive as Blobs — read then handle.
        (data as web.Blob).text().toDart.then(
          (JSString s) => _handleFrame(s.toDart),
          onError: (Object _) {},
        );
      }
    }).toJS;
    ws.onerror = ((web.Event _) => _fail()).toJS;
    ws.onclose = ((web.Event _) {
      if (!_closed) _fail();
    }).toJS;
  }

  void _send(Map<String, Object?> frame) {
    try {
      _ws?.send(jsonEncode(frame).toJS);
    } catch (_) {
      /* socket teardown race: the close/fail path owns state */
    }
  }

  void _handleFrame(String raw) {
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return; // tolerate non-JSON keepalives
    }
    if (decoded is! Map<String, dynamic>) return;
    if (decoded.containsKey('setupComplete')) {
      _machine.advance(LiveSessionEvent.setupComplete);
      return;
    }
    final Object? sc = decoded['serverContent'];
    if (sc is! Map<String, dynamic>) return;
    if (sc['interrupted'] == true) {
      _flushPlayback();
      _machine.advance(LiveSessionEvent.interrupted);
    }
    final Object? it = sc['inputTranscription'];
    if (it is Map<String, dynamic> && it['text'] is String) {
      _transcript.add(
        LiveTurn(speaker: LiveSpeaker.you, text: it['text'] as String),
      );
    }
    final Object? ot = sc['outputTranscription'];
    if (ot is Map<String, dynamic> && ot['text'] is String) {
      _transcript.add(
        LiveTurn(speaker: LiveSpeaker.tutor, text: ot['text'] as String),
      );
    }
    final Object? mt = sc['modelTurn'];
    if (mt is Map<String, dynamic>) {
      final Object? parts = mt['parts'];
      if (parts is List) {
        for (final Object? part in parts) {
          if (part is! Map<String, dynamic>) continue;
          final Object? inline = part['inlineData'];
          if (inline is! Map<String, dynamic>) continue;
          final Object? b64 = inline['data'];
          if (b64 is! String || b64.isEmpty) continue;
          _machine.advance(LiveSessionEvent.tutorSpeaking);
          try {
            _enqueuePcm(base64Decode(b64));
          } catch (_) {
            /* skip an undecodable chunk, keep the session */
          }
        }
      }
    }
    if (sc['turnComplete'] == true) {
      _machine.advance(LiveSessionEvent.tutorDone);
    }
  }

  void _enqueuePcm(Uint8List bytes) {
    final web.AudioContext? ctx = _ctxOut;
    if (ctx == null) return;
    final Float32List f = float32FromPcm16(bytes);
    if (f.isEmpty) return;
    final web.AudioBuffer buf = ctx.createBuffer(1, f.length, 24000);
    buf.copyToChannel(f.toJS, 0);
    final web.AudioBufferSourceNode src = ctx.createBufferSource();
    src.buffer = buf;
    src.connect(ctx.destination);
    final double now = ctx.currentTime;
    if (_playhead < now) _playhead = now;
    src.start(_playhead);
    _playhead += f.length / 24000.0;
    _scheduled.add(src);
    if (_scheduled.length > 64) {
      _scheduled.removeRange(0, _scheduled.length - 64);
    }
  }

  void _flushPlayback() {
    for (final web.AudioBufferSourceNode s in _scheduled) {
      try {
        s.stop();
      } catch (_) {
        /* never started / already ended */
      }
    }
    _scheduled.clear();
    _playhead = 0;
  }

  void _fail() {
    if (_machine.advance(LiveSessionEvent.failed)) {
      _teardown();
    }
  }

  @override
  Future<void> close() async {
    _machine.advance(LiveSessionEvent.closeRequested);
    _teardown();
  }

  void _teardown() {
    if (_closed) return;
    _closed = true;
    _flushPlayback();
    try {
      _ws?.close();
    } catch (_) {}
    _ws = null;
    final web.MediaStream? mic = _mic;
    if (mic != null) {
      final JSArray<web.MediaStreamTrack> tracks = mic.getTracks();
      for (int i = 0; i < tracks.length; i++) {
        tracks[i].stop();
      }
    }
    _mic = null;
    try {
      _tap?.disconnect();
    } catch (_) {}
    _tap = null;
    try {
      _ctxIn?.close();
    } catch (_) {}
    try {
      _ctxOut?.close();
    } catch (_) {}
    _ctxIn = null;
    _ctxOut = null;
  }
}
