import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/podcasts/podcast_player_screen.dart';
import 'package:ratel/features/stories/story_reader_screen.dart';
import 'package:ratel/features/watch/watch_player_screen.dart';
import 'package:ratel/services/audio_relay/audio_player.dart';

// Q-2 (screen review 2026-07 §2): every content player shows the explicit
// "Content unavailable" guidance card (honest copy naming BOTH causes:
// missing content or an offline/CDN-fallback boot) with a Go back action —
// and the podcast play button surfaces the REAL remote MP3 wait as a
// disabled Loading state while play() is in flight.

const CourseSpine _spine = CourseSpine(
  courseCode: 'en',
  units: <CourseUnit>[],
  podcasts: <CourseStory>[
    CourseStory(
      id: 'p1',
      title: 'My Morning',
      cefr: 'A1',
      audioUrl: 'https://cdn.example/p1.mp3',
      sentences: <String>['I wake up at seven.'],
    ),
  ],
);

/// play() blocks until [gate] is completed — models the remote MP3 buffer.
class _GatedHandle implements PodcastHandle {
  Completer<void>? gate;
  bool _playing = false;
  @override
  bool get isPlaying => _playing;
  @override
  Future<void> play() async {
    gate = Completer<void>();
    await gate!.future;
    _playing = true;
  }

  @override
  Future<void> pause() async => _playing = false;
  @override
  Future<void> dispose() async {}
}

class _GatedAudio implements PodcastAudio {
  _GatedAudio(this.handle);
  final _GatedHandle handle;
  @override
  bool get isAvailable => true;
  @override
  PodcastHandle handleFor(String url) => handle;
}

Future<ProviderContainer> _pump(
  WidgetTester tester,
  Widget home, {
  List<Override> extra = const <Override>[],
}) async {
  tester.view.physicalSize = const Size(430, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final ProviderContainer c = ProviderContainer(overrides: <Override>[
    courseSpineProvider.overrideWithValue(_spine),
    ...extra,
  ]);
  addTearDown(c.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(home: home),
  ));
  await tester.pumpAndSettle();
  return c;
}

void main() {
  testWidgets('story: unavailable card carries guidance + Go back',
      (WidgetTester tester) async {
    await _pump(tester, const StoryReaderScreen(passageId: 'missing'));
    expect(find.text('Content unavailable'), findsOneWidget);
    expect(
        find.textContaining('If you are offline, check your connection'),
        findsOneWidget);
    expect(find.textContaining('This story'), findsOneWidget);
    expect(find.text('Go back'), findsOneWidget);
  });

  testWidgets('podcast: unavailable card names the podcast noun',
      (WidgetTester tester) async {
    await _pump(tester, const PodcastPlayerScreen(passageId: 'missing'));
    expect(find.text('Content unavailable'), findsOneWidget);
    expect(find.textContaining('This podcast'), findsOneWidget);
    expect(find.text('Go back'), findsOneWidget);
  });

  testWidgets('watch: unavailable card names the video noun',
      (WidgetTester tester) async {
    await _pump(tester, const WatchPlayerScreen(passageId: 'missing'));
    expect(find.text('Content unavailable'), findsOneWidget);
    expect(find.textContaining('This video'), findsOneWidget);
    expect(find.text('Go back'), findsOneWidget);
  });

  testWidgets('podcast play surfaces the in-flight remote wait, then Pause',
      (WidgetTester tester) async {
    final _GatedHandle handle = _GatedHandle();
    await _pump(tester, const PodcastPlayerScreen(passageId: 'p1'),
        extra: <Override>[
          podcastAudioProvider.overrideWithValue(_GatedAudio(handle)),
        ]);
    expect(find.text('Play episode'), findsOneWidget);
    await tester.tap(find.text('Play episode'));
    await tester.pump();
    expect(find.text('Loading…'), findsOneWidget); // honest wait
    handle.gate!.complete(); // the MP3 buffered
    await tester.pumpAndSettle();
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Loading…'), findsNothing);
  });

  testWidgets('gauntlet: unavailable card overflows nowhere @360',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spine),
    ]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: StoryReaderScreen(passageId: 'nope')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Content unavailable'), findsOneWidget);
  });
}
