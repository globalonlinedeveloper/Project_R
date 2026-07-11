import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/podcasts/podcast_player_screen.dart';
import 'package:ratel/services/audio_relay/audio_player.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart';

// INF-7: the un-gated Podcasts player streams a podcast's REAL MP3 where the
// platform can play it (web), always renders the transcript, degrades honestly
// to browser read-aloud / transcript otherwise, and grades the comprehension
// checks deterministically.

class _FakePodcastHandle implements PodcastHandle {
  int playCount = 0;
  int pauseCount = 0;
  @override
  bool get isPlaying => false;
  @override
  Future<void> play() async => playCount++;
  @override
  Future<void> pause() async => pauseCount++;
  @override
  Future<void> dispose() async {}
}

class _FakeAvailablePodcastAudio implements PodcastAudio {
  _FakeAvailablePodcastAudio(this.handle);
  final _FakePodcastHandle handle;
  @override
  bool get isAvailable => true;
  @override
  PodcastHandle handleFor(String url) => handle;
}

class _FakeVoiceHandle implements AudioHandle {
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

class _FakeAvailableSpeechTts implements SpeechTts {
  _FakeAvailableSpeechTts(this.handle);
  final _FakeVoiceHandle handle;
  @override
  bool get isAvailable => true;
  @override
  AudioHandle handleFor(String text, {String lang = ''}) => handle;
}

CourseSpine _spineWithPodcast() => const CourseSpine(
      courseCode: 'en',
      units: <CourseUnit>[],
      podcasts: <CourseStory>[
        CourseStory(
          id: 'p1',
          title: 'My Morning',
          cefr: 'A1',
          theme: 'a daily routine',
          audioUrl: 'https://cdn.example/p1.mp3',
          sentences: <String>[
            'I wake up at seven.',
            'I drink coffee.',
          ],
          checkExercises: <CourseExercise>[
            CourseExercise(
              id: 'chk1',
              exerciseType: 'mcq',
              prompt: 'When does she wake up?',
              accepted: <String>[],
              options: <CourseOption>[
                CourseOption(
                    text: 'Seven',
                    isCorrect: true,
                    explain: 'The podcast says she wakes at seven.'),
                CourseOption(text: 'Nine', isCorrect: false),
              ],
            ),
          ],
        ),
      ],
    );

Future<void> _pump(WidgetTester tester, ProviderContainer c,
    {String passageId = 'p1'}) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(home: PodcastPlayerScreen(passageId: passageId)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders title + transcript sentences',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithPodcast()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);
    expect(find.text('My Morning'), findsWidgets);
    expect(find.text('I wake up at seven.'), findsOneWidget);
    expect(find.text('I drink coffee.'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('podcast-body')), findsOneWidget);
  });

  testWidgets('no player + no read-aloud when neither backend is available',
      (WidgetTester tester) async {
    // Defaults in tests: podcastAudio = Unavailable, speechTts = Unavailable.
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithPodcast()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);
    expect(
        find.byKey(const ValueKey<String>('podcast-play-toggle')), findsNothing);
    expect(
        find.byKey(const ValueKey<String>('podcast-read-aloud')), findsNothing);
    // ...but the transcript is always readable (honest degrade).
    expect(find.byKey(const ValueKey<String>('podcast-body')), findsOneWidget);
  });

  testWidgets('plays + pauses the real MP3 when the player is available',
      (WidgetTester tester) async {
    final _FakePodcastHandle handle = _FakePodcastHandle();
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithPodcast()),
      podcastAudioProvider
          .overrideWithValue(_FakeAvailablePodcastAudio(handle)),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    final Finder btn =
        find.byKey(const ValueKey<String>('podcast-play-toggle'));
    expect(btn, findsOneWidget);
    // the read-aloud fallback is NOT shown when the real player is available.
    expect(
        find.byKey(const ValueKey<String>('podcast-read-aloud')), findsNothing);
    await tester.tap(btn);
    await tester.pumpAndSettle();
    expect(handle.playCount, 1);
    expect(find.text('Pause'), findsOneWidget);
    await tester.tap(btn);
    await tester.pumpAndSettle();
    expect(handle.pauseCount, 1);
  });

  testWidgets('degrades to browser read-aloud when only speech is available',
      (WidgetTester tester) async {
    final _FakeVoiceHandle voice = _FakeVoiceHandle();
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithPodcast()),
      speechTtsProvider.overrideWithValue(_FakeAvailableSpeechTts(voice)),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);
    // No MP3 player (podcastAudio unavailable), but read-aloud fallback shows.
    expect(
        find.byKey(const ValueKey<String>('podcast-play-toggle')), findsNothing);
    final Finder btn =
        find.byKey(const ValueKey<String>('podcast-read-aloud'));
    expect(btn, findsOneWidget);
    await tester.tap(btn);
    await tester.pumpAndSettle();
    expect(voice.playCount, 1);
  });

  testWidgets('comprehension MCQ grades a correct pick',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithPodcast()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);
    await tester.tap(find.byKey(const ValueKey<String>('podcast-opt-chk1-0')));
    await tester.pumpAndSettle();
    expect(find.text('✓ Nicely done!'), findsOneWidget);
  });

  testWidgets('comprehension MCQ marks a wrong pick',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithPodcast()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);
    await tester.tap(find.byKey(const ValueKey<String>('podcast-opt-chk1-1')));
    await tester.pumpAndSettle();
    expect(find.text('✕ Not quite'), findsOneWidget);
  });

  testWidgets('unknown passage shows an honest not-available message',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithPodcast()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c, passageId: 'nope');
    expect(find.text('Content unavailable'), findsOneWidget);
    expect(find.text('Go back'), findsOneWidget);
  });
}
