import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Compile-time platform split (the 3x-proven seam pattern: speech_tts,
// audio_relay, video_relay): web => Gemini Live WSS transport; else Unavailable.
import 'live_session_stub.dart'
    if (dart.library.js_interop) 'live_session_web.dart';
// Re-export the platform factory so `backend_wiring` can arm it with a token
// fetcher (the conditional import above is library-local, never re-exported).
export 'live_session_stub.dart'
    if (dart.library.js_interop) 'live_session_web.dart'
    show createLiveSessionEngine;

/// LIVE-AI voice session seam (L-2, S112 — plan `RATEL_LIVE_AI_PLAN.md` §B).
///
/// A live session is a bidirectional voice conversation with the Gemini Live
/// tutor: mic PCM16@16k up, tutor PCM16@24k down, with live transcript turns.
/// The server-side contract keeps every secret out of the client: the
/// `live-token` edge function (L-1, ACTIVE in prod) verifies the JWT, checks
/// the Pro entitlement + budgets, and mints a SINGLE-USE ephemeral token whose
/// `liveConnectConstraints` LOCK the model + system prompt server-side — the
/// client only ever holds that short-lived token, never an API key.
///
/// DORMANT by default (R-H7 / plan §D): [kEnableLiveAi] is a build-dark
/// dart-define; without `--dart-define=RATEL_LIVE_AI=true` (and the Supabase
/// config + a token fetcher wired in `backend_wiring`), the provider resolves
/// to the honest fail-closed [UnavailableLiveSessionEngine] and the app is
/// byte-identical — the existing Tutor two-signal gate stays false.
// R-H2 realtime voice (Pro) · R-H6 live roleplay · R-H7 cost guardrails.

/// Opt-in (build-dark until L-5): turn the LIVE-AI seam on at build time.
const bool kEnableLiveAi = bool.fromEnvironment('RATEL_LIVE_AI');

/// The server-side token-mint endpoint, derived from the Supabase project URL
/// (mirrors `aiRelayUrl`/`ttsRelayUrl` — no separate URL define needed).
String liveTokenUrl(String supabaseUrl) =>
    '$supabaseUrl/functions/v1/live-token';

/// A minted ephemeral grant (the `live-token` response): the single-use token
/// name plus the WSS host it authorizes. Never persisted, never logged.
class LiveTokenGrant {
  const LiveTokenGrant({required this.token, this.wssHost});
  final String token;
  final String? wssHost;
}

/// Injected by `backend_wiring` (Supabase functions invoke, which attaches the
/// user JWT). The seam itself never imports a backend type (R-K6 portability).
/// L-3 (S113): [payload] is an OPAQUE scenario-scaffold body forwarded to the
/// `live-token` mint — the server clamps every field and builds the system
/// prompt there (plan §B/§E); null => free-form practice. No prompt text is
/// ever composed client-side.
typedef LiveTokenFetcher = Future<LiveTokenGrant> Function(
    {Map<String, Object?>? payload});

/// Session phases (plan §B): idle -> connecting -> listening <-> speaking ->
/// closed. `listening` = the learner may talk (mic streaming); `speaking` =
/// the tutor's audio is playing (barge-in flips straight back to listening).
enum LiveSessionPhase { idle, connecting, listening, speaking, closed }

/// Events that drive [LiveSessionStateMachine] (fired by the web transport;
/// fired by fakes in tests — the machine itself is pure Dart, no platform).
enum LiveSessionEvent {
  connectRequested,
  setupComplete,
  tutorSpeaking,
  tutorDone,
  interrupted,
  closeRequested,
  failed,
}

/// Who said a transcript line.
enum LiveSpeaker { you, tutor }

/// One live-transcript line (input or output transcription).
class LiveTurn {
  const LiveTurn({required this.speaker, required this.text});
  final LiveSpeaker speaker;
  final String text;
}

/// PURE session state machine — the single source of truth for phase
/// transitions, unit-testable without a socket or a browser. Illegal events
/// are REJECTED (return false, no phase change) so a late socket callback can
/// never resurrect a closed session.
class LiveSessionStateMachine {
  LiveSessionPhase _phase = LiveSessionPhase.idle;
  final StreamController<LiveSessionPhase> _phases =
      StreamController<LiveSessionPhase>.broadcast();

  LiveSessionPhase get phase => _phase;
  Stream<LiveSessionPhase> get phases => _phases.stream;

  /// Applies [event]; returns true when it produced a legal transition.
  bool advance(LiveSessionEvent event) {
    final LiveSessionPhase? next = nextPhase(_phase, event);
    if (next == null || next == _phase) return false;
    _phase = next;
    _phases.add(next);
    return true;
  }

  /// The pure transition table (static so tests can probe it exhaustively).
  static LiveSessionPhase? nextPhase(
      LiveSessionPhase phase, LiveSessionEvent event) {
    // Terminal: nothing leaves `closed`.
    if (phase == LiveSessionPhase.closed) return null;
    switch (event) {
      case LiveSessionEvent.closeRequested:
      case LiveSessionEvent.failed:
        return LiveSessionPhase.closed;
      case LiveSessionEvent.connectRequested:
        return phase == LiveSessionPhase.idle
            ? LiveSessionPhase.connecting
            : null;
      case LiveSessionEvent.setupComplete:
        return phase == LiveSessionPhase.connecting
            ? LiveSessionPhase.listening
            : null;
      case LiveSessionEvent.tutorSpeaking:
        return phase == LiveSessionPhase.listening
            ? LiveSessionPhase.speaking
            : null;
      case LiveSessionEvent.tutorDone:
      case LiveSessionEvent.interrupted:
        return phase == LiveSessionPhase.speaking
            ? LiveSessionPhase.listening
            : null;
    }
  }

  void dispose() {
    _phases.close();
  }
}

/// A running (or finished) live session.
abstract interface class LiveSession {
  /// Phase stream (seeded by the transport; see [LiveSessionStateMachine]).
  Stream<LiveSessionPhase> get phases;

  /// Live transcript turns (input + output transcription as configured
  /// server-side by the token's locked config).
  Stream<LiveTurn> get transcript;

  /// Current phase snapshot.
  LiveSessionPhase get phase;

  /// Mute/unmute the mic WITHOUT tearing the session down.
  void setMicMuted(bool muted);

  /// End the session and release the mic + socket + audio pipeline.
  Future<void> close();
}

/// The engine seam the UI reads (L-3 Roleplay / L-4 Tutor Talk).
abstract interface class LiveSessionEngine {
  /// False => the UI must not offer live voice at all (free build, non-web,
  /// flag off, or no token fetcher wired). Two-signal honesty: the Tutor
  /// surface ALSO checks the Pro entitlement before showing the card.
  bool get isAvailable;

  /// Mint a token (server enforces Pro + budgets; 403/429 surface as
  /// [LiveSessionUnavailable] with the server's honest reason) and open the
  /// session. Only meaningful when [isAvailable]. [payload] = the optional
  /// scenario scaffold forwarded to the mint (see [LiveTokenFetcher]).
  Future<LiveSession> start({Map<String, Object?>? payload});
}

/// Default (non-web / flag off / unwired): honest fail-closed engine.
class UnavailableLiveSessionEngine implements LiveSessionEngine {
  const UnavailableLiveSessionEngine();
  @override
  bool get isAvailable => false;
  @override
  Future<LiveSession> start({Map<String, Object?>? payload}) async =>
      throw const LiveSessionUnavailable('live AI is not enabled in this build.');
}

/// Thrown on start/transport failure — carries an honest, user-presentable
/// reason (quota exhausted, not Pro, offline). Never a fake session (§6).
class LiveSessionUnavailable implements Exception {
  const LiveSessionUnavailable(this.reason);
  final String reason;
  @override
  String toString() => 'LiveSessionUnavailable: $reason';
}

/// ---- PCM16 wire codec (pure; unit-tested off-web) --------------------------
/// Gemini Live speaks PCM16 little-endian: 16 kHz up, 24 kHz down.

/// Float32 [-1,1] samples -> PCM16LE bytes (clamped, round-to-nearest).
Uint8List pcm16FromFloat32(List<double> samples) {
  final Uint8List out = Uint8List(samples.length * 2);
  final ByteData bd = ByteData.view(out.buffer);
  for (int i = 0; i < samples.length; i++) {
    final double c = samples[i].clamp(-1.0, 1.0);
    bd.setInt16(i * 2, (c * 32767).round(), Endian.little);
  }
  return out;
}

/// PCM16LE bytes -> Float32 [-1,1] samples (odd trailing byte ignored).
Float32List float32FromPcm16(Uint8List bytes) {
  final int n = bytes.lengthInBytes ~/ 2;
  final ByteData bd =
      ByteData.view(bytes.buffer, bytes.offsetInBytes, n * 2);
  final Float32List out = Float32List(n);
  for (int i = 0; i < n; i++) {
    out[i] = bd.getInt16(i * 2, Endian.little) / 32768.0;
  }
  return out;
}

/// Resolved at compile time (web vs stub). `backend_wiring` overrides it with
/// a token-fetcher-armed engine when the build is configured + flag on; tests
/// override with fakes. Default = the honest Unavailable engine.
final liveSessionEngineProvider =
    Provider<LiveSessionEngine>((ref) => createLiveSessionEngine());
