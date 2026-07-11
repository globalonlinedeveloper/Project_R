import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/podcasts/podcast_player_screen.dart';
import 'package:ratel/services/audio_relay/audio_player.dart';

// M-2 (screen review 2026-07 §2): podcast seekbar + elapsed time.
// The scrubber renders ONLY when the handle really exposes position/duration
// (SeekablePodcastHandle — the web MP3 element); it tracks the REAL position
// via the 500ms ticker, seeks through the handle, and plain handles keep the
// plain play/pause UI (honest degrade — never a fake scrubber).
// §11: the ticker is a periodic Timer — tests advance with pump(Duration),
// NEVER pumpAndSettle while playing.

class _SeekableFakeHandle implements PodcastHandle, SeekablePodcastHandle {
  double pos = 0;
  double? dur = 180;
  bool playing = false;
  final List<double> seeks = <double>[];
  @override
  bool get isPlaying => playing;
  @override
  Future<void> play() async => playing = true;
  @override
  Future<void> pause() async => playing = false;
  @override
  Future<void> dispose() async {}
  @override
  double get positionSeconds => pos;
  @override
  double? get durationSeconds => dur;
  @override
  void seekTo(double seconds) {
    seeks.add(seconds);
    pos = seconds;
  }
}

class _PlainFakeHandle implements PodcastHandle {
  @override
  bool get isPlaying => false;
  @override
  Future<void> play() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> dispose() async {}
}

class _FakeAudio implements PodcastAudio {
  _FakeAudio(this.handle);
  final PodcastHandle handle;
  @override
  bool get isAvailable => true;
  @override
  PodcastHandle handleFor(String url) => handle;
}

CourseSpine _spine() => const CourseSpine(
      courseCode: 'en',
      units: <CourseUnit>[],
      podcasts: <CourseStory>[
        CourseStory(
          id: 'p1',
          title: 'My Morning',
          cefr: 'A1',
          audioUrl: 'https://cdn.example/p1.mp3',
          sentences: <String>['I wake up at seven.'],
          checkExercises: <CourseExercise>[],
        ),
      ],
    );

Future<void> _pump(WidgetTester tester, PodcastHandle handle) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final ProviderContainer c = ProviderContainer(overrides: <Override>[
    courseSpineProvider.overrideWithValue(_spine()),
    podcastAudioProvider.overrideWithValue(_FakeAudio(handle)),
  ]);
  addTearDown(c.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: const MaterialApp(home: PodcastPlayerScreen(passageId: 'p1')),
  ));
  await tester.pumpAndSettle(); // safe: no ticker before the first play
}

Finder get _seekbar => find.byKey(const ValueKey<String>('podcast-seekbar'));
Finder get _time => find.byKey(const ValueKey<String>('podcast-time'));

void main() {
  testWidgets('seekbar + m:ss / m:ss appear on play and track the real position',
      (WidgetTester tester) async {
    final _SeekableFakeHandle h = _SeekableFakeHandle();
    await _pump(tester, h);
    expect(_seekbar, findsNothing); // nothing before play

    await tester.tap(find.byKey(const ValueKey<String>('podcast-play-toggle')));
    await tester.pump(); // pendingPlay frame
    await tester.pump(); // play resolved -> ticker started + first sync
    expect(_seekbar, findsOneWidget);
    expect(find.text('0:00 / 3:00'), findsOneWidget);

    h.pos = 65; // the element advanced
    await tester.pump(const Duration(milliseconds: 600)); // one tick
    expect(find.text('1:05 / 3:00'), findsOneWidget);
  });

  testWidgets('dragging the slider seeks through the handle',
      (WidgetTester tester) async {
    final _SeekableFakeHandle h = _SeekableFakeHandle();
    await _pump(tester, h);
    await tester.tap(find.byKey(const ValueKey<String>('podcast-play-toggle')));
    await tester.pump();
    await tester.pump();

    await tester.drag(_seekbar, const Offset(120, 0));
    await tester.pump();
    expect(h.seeks, isNotEmpty, reason: 'seekTo must hit the real handle');
    expect(h.pos, greaterThan(0));

    // Pause freezes the bar at the real paused position (ticker stopped).
    await tester.tap(find.byKey(const ValueKey<String>('podcast-play-toggle')));
    await tester.pump();
    expect(_seekbar, findsOneWidget);
  });

  testWidgets('duration unknown until metadata -> scrubber appears when known',
      (WidgetTester tester) async {
    final _SeekableFakeHandle h = _SeekableFakeHandle()..dur = null;
    await _pump(tester, h);
    await tester.tap(find.byKey(const ValueKey<String>('podcast-play-toggle')));
    await tester.pump();
    await tester.pump();
    expect(_seekbar, findsNothing); // no duration -> no scrubber (honest)

    h.dur = 120; // metadata arrived
    await tester.pump(const Duration(milliseconds: 600)); // one tick
    expect(_seekbar, findsOneWidget);
    expect(find.text('0:00 / 2:00'), findsOneWidget);
  });

  testWidgets('plain handle (no capability) keeps the plain play/pause UI',
      (WidgetTester tester) async {
    await _pump(tester, _PlainFakeHandle());
    await tester.tap(find.byKey(const ValueKey<String>('podcast-play-toggle')));
    await tester.pump();
    await tester.pump();
    expect(find.text('Pause'), findsOneWidget); // playing
    expect(_seekbar, findsNothing); // honest degrade: no fake scrubber
    expect(_time, findsNothing);
  });
}
