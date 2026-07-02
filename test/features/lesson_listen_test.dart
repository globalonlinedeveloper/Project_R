import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/lesson/renderers/listen_exercise.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart' show AudioHandle;

// Widget tests for the Listen renderer (mirror lesson_match_test.dart). The
// widget is PURE: audio is injected as an AudioHandle, so a FakeAudioHandle
// backs every test — no audio plugin, no network. Proves the honest posture:
// play/slow route to the handle, grading is ordered token-join, reduce-motion
// schedules no pulse timer, no overflow at 360px, and a handle throw degrades
// to a non-blocking hint while the bank + Check stay usable. [R-H7 / SPEC §2/§5]

class FakeAudioHandle implements AudioHandle {
  FakeAudioHandle({this.throwOnPlay = false});
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

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 1200),
}) async {
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
  testWidgets('renders play + slow + bank; taps route to the handle',
      (WidgetTester tester) async {
    final FakeAudioHandle fake = FakeAudioHandle();
    await _pump(
      tester,
      ListenExercise(
        audio: fake,
        tokens: const <String>['yo', 'como', 'estas'],
        target: const <String>['yo', 'como', 'estas'],
        onGraded: (_) {},
      ),
    );
    expect(find.text('🔊'), findsOneWidget);
    expect(find.text('🐢'), findsOneWidget);
    expect(find.text('yo'), findsOneWidget);

    await tester.tap(find.text('🔊'));
    await tester.pumpAndSettle();
    expect(fake.playCount, 1);

    await tester.tap(find.text('🐢'));
    await tester.pumpAndSettle();
    expect(fake.slowCount, 1);
  });

  testWidgets('correct order -> onGraded(true)', (WidgetTester tester) async {
    bool? result;
    await _pump(
      tester,
      ListenExercise(
        audio: FakeAudioHandle(),
        tokens: const <String>['alpha', 'bravo', 'charlie'],
        target: const <String>['alpha', 'bravo', 'charlie'],
        onGraded: (bool ok) => result = ok,
      ),
    );
    for (final String w in const <String>['alpha', 'bravo', 'charlie']) {
      await tester.tap(find.text(w));
      await tester.pump();
    }
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('wrong order -> onGraded(false)', (WidgetTester tester) async {
    bool? result;
    await _pump(
      tester,
      ListenExercise(
        audio: FakeAudioHandle(),
        tokens: const <String>['alpha', 'bravo', 'charlie'],
        target: const <String>['alpha', 'bravo', 'charlie'],
        onGraded: (bool ok) => result = ok,
      ),
    );
    for (final String w in const <String>['charlie', 'bravo', 'alpha']) {
      await tester.tap(find.text(w));
      await tester.pump();
    }
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('reduceMotion: tapping play schedules NO pending pulse timer',
      (WidgetTester tester) async {
    final FakeAudioHandle fake = FakeAudioHandle();
    await _pump(
      tester,
      ListenExercise(
        audio: fake,
        tokens: const <String>['a', 'b'],
        target: const <String>['a', 'b'],
        onGraded: (_) {},
        reduceMotion: true,
      ),
    );
    await tester.tap(find.text('🔊'));
    // Completes with no pending timers (no pulse scheduled under reduce-motion).
    await tester.pumpAndSettle();
    expect(fake.playCount, 1);
  });

  testWidgets('no overflow at 360px width', (WidgetTester tester) async {
    await _pump(
      tester,
      ListenExercise(
        audio: FakeAudioHandle(),
        tokens: const <String>['uno', 'dos', 'tres', 'cuatro', 'cinco'],
        target: const <String>['uno', 'dos', 'tres', 'cuatro', 'cinco'],
        onGraded: (_) {},
      ),
      size: const Size(360, 1400),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('audio error is non-blocking: hint shows, bank + Check still work',
      (WidgetTester tester) async {
    bool? result;
    final FakeAudioHandle fake = FakeAudioHandle(throwOnPlay: true);
    await _pump(
      tester,
      ListenExercise(
        audio: fake,
        tokens: const <String>['alpha', 'bravo'],
        target: const <String>['alpha', 'bravo'],
        onGraded: (bool ok) => result = ok,
      ),
    );
    await tester.tap(find.text('🔊'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Audio unavailable'), findsOneWidget);

    for (final String w in const <String>['alpha', 'bravo']) {
      await tester.tap(find.text(w));
      await tester.pump();
    }
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
