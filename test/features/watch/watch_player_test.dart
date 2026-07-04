import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/watch/watch_player_screen.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart';
import 'package:ratel/services/video_relay/video_player.dart';

// INF-9: the un-gated Watch player embeds a lesson's REAL R2 MP4 where the
// platform can render it (web), always renders the transcript, degrades honestly
// to a poster (+ optional browser read-aloud) otherwise, and grades the
// comprehension checks deterministically.

class _FakeAvailableVideoRelay implements VideoRelay {
  @override
  bool get isAvailable => true;
  @override
  Widget viewFor(String url) => Container(
        key: const ValueKey<String>('fake-video-view'),
        alignment: Alignment.center,
        child: Text(url),
      );
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

CourseSpine _spineWithWatch() => const CourseSpine(
      courseCode: 'en',
      units: <CourseUnit>[],
      watch: <CourseStory>[
        CourseStory(
          id: 'w1',
          title: 'Morning Coffee',
          cefr: 'A1',
          theme: 'daily routines',
          videoUrl: 'https://cdn.example/w1.mp4',
          sentences: <String>[
            'A woman pours coffee.',
            'She takes a slow sip.',
          ],
          checkExercises: <CourseExercise>[
            CourseExercise(
              id: 'chk1',
              exerciseType: 'mcq',
              prompt: 'What does she make?',
              accepted: <String>[],
              options: <CourseOption>[
                CourseOption(
                    text: 'Coffee',
                    isCorrect: true,
                    explain: 'The clip shows her pouring coffee.'),
                CourseOption(text: 'Tea', isCorrect: false),
              ],
            ),
          ],
        ),
      ],
    );

Future<void> _pump(WidgetTester tester, ProviderContainer c,
    {String passageId = 'w1'}) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(home: WatchPlayerScreen(passageId: passageId)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders title + transcript sentences',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithWatch()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);
    expect(find.text('Morning Coffee'), findsWidgets);
    expect(find.text('A woman pours coffee.'), findsOneWidget);
    expect(find.text('She takes a slow sip.'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('watch-body')), findsOneWidget);
  });

  testWidgets('honest poster (no video, no read-aloud) when no backend is '
      'available', (WidgetTester tester) async {
    // Defaults in tests: videoRelay = Unavailable, speechTts = Unavailable.
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithWatch()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);
    expect(find.byKey(const ValueKey<String>('watch-poster')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('watch-video')), findsNothing);
    expect(
        find.byKey(const ValueKey<String>('watch-read-aloud')), findsNothing);
    // ...but the transcript is always readable (honest degrade).
    expect(find.byKey(const ValueKey<String>('watch-body')), findsOneWidget);
  });

  testWidgets('embeds the real video when the relay is available',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithWatch()),
      videoRelayProvider.overrideWithValue(_FakeAvailableVideoRelay()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);
    expect(find.byKey(const ValueKey<String>('watch-video')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('fake-video-view')), findsOneWidget);
    // No poster + no read-aloud fallback when the real video renders.
    expect(find.byKey(const ValueKey<String>('watch-poster')), findsNothing);
    expect(
        find.byKey(const ValueKey<String>('watch-read-aloud')), findsNothing);
  });

  testWidgets('degrades to browser read-aloud when only speech is available',
      (WidgetTester tester) async {
    final _FakeVoiceHandle voice = _FakeVoiceHandle();
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithWatch()),
      speechTtsProvider.overrideWithValue(_FakeAvailableSpeechTts(voice)),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);
    // No video (relay unavailable) -> poster + read-aloud fallback shows.
    expect(find.byKey(const ValueKey<String>('watch-poster')), findsOneWidget);
    final Finder btn = find.byKey(const ValueKey<String>('watch-read-aloud'));
    expect(btn, findsOneWidget);
    await tester.tap(btn);
    await tester.pumpAndSettle();
    expect(voice.playCount, 1);
  });

  testWidgets('comprehension MCQ grades a correct pick + reveals Explain',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithWatch()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);
    await tester.tap(find.byKey(const ValueKey<String>('watch-opt-chk1-0')));
    await tester.pumpAndSettle();
    expect(find.text('✓ Correct!'), findsOneWidget);
    await tester
        .tap(find.byKey(const ValueKey<String>('watch-explain-toggle-chk1')));
    await tester.pumpAndSettle();
    expect(find.text('The clip shows her pouring coffee.'), findsOneWidget);
  });

  testWidgets('comprehension MCQ marks a wrong pick',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithWatch()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);
    await tester.tap(find.byKey(const ValueKey<String>('watch-opt-chk1-1')));
    await tester.pumpAndSettle();
    expect(find.text('✕ Not quite'), findsOneWidget);
  });

  testWidgets('unknown passage shows an honest not-available message',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithWatch()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c, passageId: 'nope');
    expect(find.text('This video is not available.'), findsOneWidget);
  });
}
