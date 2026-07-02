import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/services/tts_relay/tts_relay.dart';

// The browser-speech seam. On the VM (all tests) the compile-time factory is the
// stub, so speech is unavailable and the runner degrades Listen to typed. The
// fail-closed SilentAudioHandle never pretends to play. [SPEC_LISTEN_TTS §3d/§5]
void main() {
  test('default speechTtsProvider is fail-closed on the VM (Listen degrades)',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final SpeechTts s = container.read(speechTtsProvider);
    expect(s, isA<UnavailableSpeechTts>());
    expect(s.isAvailable, isFalse);
  });

  test('UnavailableSpeechTts.handleFor is a SilentAudioHandle that never fakes',
      () async {
    const SpeechTts s = UnavailableSpeechTts();
    final AudioHandle h = s.handleFor('hola', lang: 'es');
    expect(h, isA<SilentAudioHandle>());
    expect(h.isPlaying, isFalse);
    await expectLater(h.play(), throwsA(isA<AudioUnavailable>()));
    await expectLater(h.playSlow(), throwsA(isA<AudioUnavailable>()));
  });
}
