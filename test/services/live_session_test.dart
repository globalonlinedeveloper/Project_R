import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/live_session/live_session.dart';

// L-2 (S112): the live_session seam is DORMANT — these tests pin (1) the pure
// state machine, (2) the PCM16 wire codec, and (3) the fail-closed defaults
// that keep every flag-off build byte-identical (the lane-2 trap: existing
// surfaces assert live AI is unavailable — that MUST stay true here).

void main() {
  group('LiveSessionStateMachine (plan §B: idle→connecting→listening⇄speaking→closed)', () {
    test('happy path walks every phase in order', () async {
      final LiveSessionStateMachine m = LiveSessionStateMachine();
      final List<LiveSessionPhase> seen = <LiveSessionPhase>[];
      final sub = m.phases.listen(seen.add);
      expect(m.phase, LiveSessionPhase.idle);
      expect(m.advance(LiveSessionEvent.connectRequested), isTrue);
      expect(m.advance(LiveSessionEvent.setupComplete), isTrue);
      expect(m.advance(LiveSessionEvent.tutorSpeaking), isTrue);
      expect(m.advance(LiveSessionEvent.tutorDone), isTrue);
      expect(m.advance(LiveSessionEvent.tutorSpeaking), isTrue);
      expect(m.advance(LiveSessionEvent.interrupted), isTrue,
          reason: 'barge-in flips speaking straight back to listening');
      expect(m.advance(LiveSessionEvent.closeRequested), isTrue);
      expect(m.phase, LiveSessionPhase.closed);
      await Future<void>.delayed(Duration.zero);
      expect(seen, const <LiveSessionPhase>[
        LiveSessionPhase.connecting,
        LiveSessionPhase.listening,
        LiveSessionPhase.speaking,
        LiveSessionPhase.listening,
        LiveSessionPhase.speaking,
        LiveSessionPhase.listening,
        LiveSessionPhase.closed,
      ]);
      await sub.cancel();
      m.dispose();
    });

    test('illegal events are rejected without a phase change', () {
      final LiveSessionStateMachine m = LiveSessionStateMachine();
      expect(m.advance(LiveSessionEvent.setupComplete), isFalse);
      expect(m.advance(LiveSessionEvent.tutorSpeaking), isFalse);
      expect(m.advance(LiveSessionEvent.tutorDone), isFalse);
      expect(m.phase, LiveSessionPhase.idle);
      m.advance(LiveSessionEvent.connectRequested);
      expect(m.advance(LiveSessionEvent.tutorSpeaking), isFalse,
          reason: 'no tutor audio before setupComplete');
      expect(m.phase, LiveSessionPhase.connecting);
      m.dispose();
    });

    test('failure closes from any live phase', () {
      final LiveSessionStateMachine m = LiveSessionStateMachine();
      m.advance(LiveSessionEvent.connectRequested);
      expect(m.advance(LiveSessionEvent.failed), isTrue);
      expect(m.phase, LiveSessionPhase.closed);
      m.dispose();
    });

    test('closed is terminal — a late socket callback cannot resurrect it',
        () {
      final LiveSessionStateMachine m = LiveSessionStateMachine();
      m.advance(LiveSessionEvent.connectRequested);
      m.advance(LiveSessionEvent.closeRequested);
      for (final LiveSessionEvent e in LiveSessionEvent.values) {
        expect(m.advance(e), isFalse, reason: 'closed must swallow $e');
      }
      expect(m.phase, LiveSessionPhase.closed);
      m.dispose();
    });
  });

  group('PCM16 wire codec (16k up / 24k down)', () {
    test('round-trips within quantization error and clamps overdrive', () {
      const List<double> samples = <double>[-1.0, -0.5, 0.0, 0.5, 1.0];
      final Uint8List bytes = pcm16FromFloat32(samples);
      expect(bytes.length, samples.length * 2);
      final Float32List back = float32FromPcm16(bytes);
      for (int i = 0; i < samples.length; i++) {
        expect((back[i] - samples[i]).abs(), lessThan(1.5 / 32768.0),
            reason: 'sample $i');
      }
      // Overdrive clamps instead of wrapping.
      final Float32List hot =
          float32FromPcm16(pcm16FromFloat32(const <double>[2.0, -2.0]));
      expect(hot[0], closeTo(1.0, 0.001));
      expect(hot[1], closeTo(-1.0, 0.001));
    });

    test('an odd trailing byte is ignored, empty stays empty', () {
      expect(float32FromPcm16(Uint8List.fromList(<int>[1])), isEmpty);
      expect(float32FromPcm16(Uint8List(0)), isEmpty);
      expect(pcm16FromFloat32(const <double>[]), isEmpty);
    });
  });

  group('dormant defaults (flag off => byte-identical build)', () {
    test('kEnableLiveAi defaults false; provider is the Unavailable engine',
        () {
      expect(kEnableLiveAi, isFalse);
      final ProviderContainer c = ProviderContainer();
      addTearDown(c.dispose);
      final LiveSessionEngine engine = c.read(liveSessionEngineProvider);
      expect(engine, isA<UnavailableLiveSessionEngine>());
      expect(engine.isAvailable, isFalse);
    });

    test('the Unavailable engine fail-closes with an honest reason', () {
      const UnavailableLiveSessionEngine e = UnavailableLiveSessionEngine();
      expect(e.start(), throwsA(isA<LiveSessionUnavailable>()));
    });

    test('liveTokenUrl derives from the project URL (mirrors aiRelayUrl)', () {
      expect(liveTokenUrl('https://x.supabase.co'),
          'https://x.supabase.co/functions/v1/live-token');
    });
  });
}
