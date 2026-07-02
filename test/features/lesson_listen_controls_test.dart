import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/lesson/renderers/listen_audio_controls.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart' show AudioHandle;

class _FakeAudioHandle implements AudioHandle {
  _FakeAudioHandle({this.throwOnPlay = false});
  final bool throwOnPlay;
  int playCount = 0;
  int slowCount = 0;
  @override
  bool get isPlaying => false;
  @override
  Future<void> play() async {
    playCount++;
    if (throwOnPlay) throw Exception('decode fail');
  }

  @override
  Future<void> playSlow() async {
    slowCount++;
    if (throwOnPlay) throw Exception('decode fail');
  }

  @override
  Future<void> dispose() async {}
}

Future<void> _pump(WidgetTester tester, Widget child,
    {Size size = const Size(390, 600)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders play + slow; routes taps to the handle',
      (WidgetTester tester) async {
    final _FakeAudioHandle fake = _FakeAudioHandle();
    await _pump(tester, ListenAudioControls(audio: fake));
    expect(find.text('🔊'), findsOneWidget);
    expect(find.text('🐢'), findsOneWidget);
    await tester.tap(find.text('🔊'));
    await tester.pumpAndSettle();
    expect(fake.playCount, 1);
    await tester.tap(find.text('🐢'));
    await tester.pumpAndSettle();
    expect(fake.slowCount, 1);
  });

  testWidgets('reduceMotion: tapping play schedules NO pending pulse timer',
      (WidgetTester tester) async {
    final _FakeAudioHandle fake = _FakeAudioHandle();
    await _pump(tester,
        ListenAudioControls(audio: fake, reduceMotion: true));
    await tester.tap(find.text('🔊'));
    await tester.pumpAndSettle();
    expect(fake.playCount, 1);
  });

  testWidgets('audio error surfaces a non-blocking hint',
      (WidgetTester tester) async {
    final _FakeAudioHandle fake = _FakeAudioHandle(throwOnPlay: true);
    await _pump(tester, ListenAudioControls(audio: fake));
    await tester.tap(find.text('🔊'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Audio unavailable'), findsOneWidget);
  });
}
