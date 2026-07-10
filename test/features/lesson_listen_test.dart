import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/lesson/renderers/listen_exercise.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart' show AudioHandle;

// Widget tests for the CONTROLLED Listen renderer (C-7). The widget is PURE
// presentation: audio is injected as an AudioHandle and the picked-order state
// lives in the PARENT (the runner's `_answer`), so there is NO Check button
// here — the runner's FIXED footer Check grades (see
// lesson_listen_bank_runner_test.dart). Proves: play/slow route to the handle,
// bank/tray taps report via onPlace/onRemove, `checked` locks the bank,
// reduce-motion schedules no pulse timer, no overflow at 360px, and a handle
// throw degrades to a non-blocking hint while the bank stays usable.
// [R-D5 / SPEC §2/§5]

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
  testWidgets('renders play + slow + bank; no in-widget Check (C-7); taps route '
      'to the handle', (WidgetTester tester) async {
    final FakeAudioHandle fake = FakeAudioHandle();
    await _pump(
      tester,
      ListenExercise(
        audio: fake,
        tokens: const <String>['yo', 'como', 'estas'],
        picked: const <int>[],
        checked: false,
        onPlace: (_) {},
        onRemove: (_) {},
      ),
    );
    expect(find.text('🔊'), findsOneWidget);
    expect(find.text('🐢'), findsOneWidget);
    expect(find.text('yo'), findsOneWidget);
    // The Check lives in the runner's fixed footer now, not this widget.
    expect(find.text('Check'), findsNothing);

    await tester.tap(find.text('🔊'));
    await tester.pumpAndSettle();
    expect(fake.playCount, 1);

    await tester.tap(find.text('🐢'));
    await tester.pumpAndSettle();
    expect(fake.slowCount, 1);
  });

  testWidgets('tapping a bank chip reports onPlace(index)',
      (WidgetTester tester) async {
    final List<int> placed = <int>[];
    await _pump(
      tester,
      ListenExercise(
        audio: FakeAudioHandle(),
        tokens: const <String>['alpha', 'bravo', 'charlie'],
        picked: const <int>[],
        checked: false,
        onPlace: placed.add,
        onRemove: (_) {},
      ),
    );
    await tester.tap(find.text('bravo'));
    await tester.pump();
    expect(placed, <int>[1]);
  });

  testWidgets('tapping a tray chip reports onRemove(index)',
      (WidgetTester tester) async {
    final List<int> removed = <int>[];
    await _pump(
      tester,
      ListenExercise(
        audio: FakeAudioHandle(),
        tokens: const <String>['alpha', 'bravo', 'charlie'],
        picked: const <int>[0],
        checked: false,
        onPlace: (_) {},
        onRemove: removed.add,
      ),
    );
    // The tray tile (index 0) renders before the bank; tap it to remove.
    await tester.tap(find.text('alpha').first);
    await tester.pump();
    expect(removed, <int>[0]);
  });

  testWidgets('checked:true locks the bank (no onPlace)',
      (WidgetTester tester) async {
    final List<int> placed = <int>[];
    await _pump(
      tester,
      ListenExercise(
        audio: FakeAudioHandle(),
        tokens: const <String>['alpha', 'bravo'],
        picked: const <int>[],
        checked: true,
        onPlace: placed.add,
        onRemove: (_) {},
      ),
    );
    await tester.tap(find.text('alpha'));
    await tester.pump();
    expect(placed, isEmpty);
  });

  testWidgets('reduceMotion: tapping play schedules NO pending pulse timer',
      (WidgetTester tester) async {
    final FakeAudioHandle fake = FakeAudioHandle();
    await _pump(
      tester,
      ListenExercise(
        audio: fake,
        tokens: const <String>['a', 'b'],
        picked: const <int>[],
        checked: false,
        onPlace: (_) {},
        onRemove: (_) {},
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
        picked: const <int>[],
        checked: false,
        onPlace: (_) {},
        onRemove: (_) {},
      ),
      size: const Size(360, 1400),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('audio error is non-blocking: hint shows, bank still reports taps',
      (WidgetTester tester) async {
    final List<int> placed = <int>[];
    final FakeAudioHandle fake = FakeAudioHandle(throwOnPlay: true);
    await _pump(
      tester,
      ListenExercise(
        audio: fake,
        tokens: const <String>['alpha', 'bravo'],
        picked: const <int>[],
        checked: false,
        onPlace: placed.add,
        onRemove: (_) {},
      ),
    );
    await tester.tap(find.text('🔊'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Audio unavailable'), findsOneWidget);

    await tester.tap(find.text('alpha'));
    await tester.pump();
    expect(placed, <int>[0]);
  });
}
