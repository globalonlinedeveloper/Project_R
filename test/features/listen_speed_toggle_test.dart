import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/lesson/renderers/listen_audio_controls.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart';

// Q-6 (screen review 2026-07 §2): the Listen controls carry a playback-speed
// cycle (1x -> 1.25x -> 0.75x) applied through the OPTIONAL
// RateControlledAudio capability — rate-aware handles receive playAt(rate),
// plain AudioHandles keep the unchanged play() path (never broken by the
// toggle), and the turtle keeps its dedicated slow replay.

class _RateAwareFake implements AudioHandle, RateControlledAudio {
  final List<double> playAtRates = <double>[];
  int playCount = 0;
  int playSlowCount = 0;
  @override
  bool get isPlaying => false;
  @override
  Future<void> play() async => playCount++;
  @override
  Future<void> playSlow() async => playSlowCount++;
  @override
  Future<void> playAt(double rate) async => playAtRates.add(rate);
  @override
  Future<void> dispose() async {}
}

class _PlainFake implements AudioHandle {
  int playCount = 0;
  @override
  bool get isPlaying => false;
  @override
  Future<void> play() async => playCount++;
  @override
  Future<void> playSlow() async {}
  @override
  Future<void> dispose() async {}
}

Future<void> _pump(WidgetTester tester, AudioHandle audio) async {
  await tester.pumpWidget(MaterialApp(
    // reduceMotion: no pulse timer scheduled — keeps testWidgets timer-clean
    // (the pulse path is covered by lesson_listen_controls_test).
    home: Scaffold(body: ListenAudioControls(audio: audio, reduceMotion: true)),
  ));
}

final Finder _toggle = find.byKey(const ValueKey<String>('listen-speed-toggle'));

void main() {
  testWidgets('cycle 1x -> 1.25x -> 0.75x -> 1x; playAt gets the rate',
      (WidgetTester tester) async {
    final _RateAwareFake audio = _RateAwareFake();
    await _pump(tester, audio);

    expect(find.text('1×'), findsOneWidget);
    await tester.tap(find.text('🔊'));
    await tester.pump();
    expect(audio.playCount, 1); // 1x rides the plain play() path
    expect(audio.playAtRates, isEmpty);

    await tester.tap(_toggle);
    await tester.pump();
    expect(find.text('1.25×'), findsOneWidget);
    await tester.tap(find.text('🔊'));
    await tester.pump();
    expect(audio.playAtRates, <double>[1.25]);

    await tester.tap(_toggle);
    await tester.pump();
    expect(find.text('0.75×'), findsOneWidget);
    await tester.tap(find.text('🔊'));
    await tester.pump();
    expect(audio.playAtRates, <double>[1.25, 0.75]);

    await tester.tap(_toggle);
    await tester.pump();
    expect(find.text('1×'), findsOneWidget);

    // The turtle stays the dedicated slow replay, rate-independent.
    await tester.tap(find.text('🐢'));
    await tester.pump();
    expect(audio.playSlowCount, 1);
    expect(audio.playCount, 1);
  });

  testWidgets('plain AudioHandle: non-1x falls back to play(), never throws',
      (WidgetTester tester) async {
    final _PlainFake audio = _PlainFake();
    await _pump(tester, audio);
    await tester.tap(_toggle);
    await tester.pump();
    expect(find.text('1.25×'), findsOneWidget);
    await tester.tap(find.text('🔊'));
    await tester.pump();
    expect(audio.playCount, 1); // degraded honestly to normal play
    expect(find.text('Audio unavailable — read the prompt.'), findsNothing);
  });

  testWidgets('speed chip announces as a button', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pump(tester, _RateAwareFake());
    expect(
      tester.getSemantics(_toggle),
      isSemantics(isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });

  testWidgets('gauntlet: controls row overflows nowhere @360/430',
      (WidgetTester tester) async {
    for (final double w in <double>[360, 430]) {
      tester.view.physicalSize = Size(w, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        key: ValueKey<double>(w),
        home: Scaffold(
            body:
                ListenAudioControls(audio: _RateAwareFake(), reduceMotion: true)),
      ));
      expect(find.text('1×'), findsOneWidget, reason: 'chip missing @$w');
    }
  });
}
