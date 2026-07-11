import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/stories/story_reader_screen.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart';

// INF-6: the un-gated Read&Listen reader renders a story's resolved sentences,
// offers browser read-aloud ONLY when the platform provides a voice (degrades
// honestly otherwise), and grades the comprehension checks deterministically.

class _FakeAudioHandle implements AudioHandle {
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
  final _FakeAudioHandle handle;
  @override
  bool get isAvailable => true;
  @override
  AudioHandle handleFor(String text, {String lang = ''}) => handle;
}

CourseSpine _spineWithStory() => const CourseSpine(
      courseCode: 'en',
      units: <CourseUnit>[],
      stories: <CourseStory>[
        CourseStory(
          id: 'p1',
          title: 'Her First Day',
          cefr: 'A1',
          theme: 'first day at school',
          sentences: <String>[
            'She walks to school.',
            'It is her first day.',
          ],
          checkExercises: <CourseExercise>[
            CourseExercise(
              id: 'chk1',
              exerciseType: 'mcq',
              prompt: 'Is it her first day?',
              accepted: <String>[],
              options: <CourseOption>[
                CourseOption(
                    text: 'Yes',
                    isCorrect: true,
                    explain: 'The story says it is her first day.'),
                CourseOption(text: 'No', isCorrect: false),
              ],
            ),
          ],
        ),
      ],
    );

Future<void> _pump(WidgetTester tester, ProviderContainer c) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: const MaterialApp(home: StoryReaderScreen(passageId: 'p1')),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders title + all resolved sentences', (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithStory()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    expect(find.text('Her First Day'), findsWidgets);
    expect(find.text('She walks to school.'), findsOneWidget);
    expect(find.text('It is her first day.'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('story-body')), findsOneWidget);
  });

  testWidgets('read-aloud is HIDDEN when no browser voice (honest degrade)',
      (WidgetTester tester) async {
    // Default speechTtsProvider = UnavailableSpeechTts in tests.
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithStory()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);
    expect(find.byKey(const ValueKey<String>('story-read-aloud')), findsNothing);
  });

  testWidgets('read-aloud speaks the passage when a voice is available',
      (WidgetTester tester) async {
    final _FakeAudioHandle handle = _FakeAudioHandle();
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithStory()),
      speechTtsProvider.overrideWithValue(_FakeAvailableSpeechTts(handle)),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    final Finder btn = find.byKey(const ValueKey<String>('story-read-aloud'));
    expect(btn, findsOneWidget);
    await tester.tap(btn);
    await tester.pumpAndSettle();
    expect(handle.playCount, 1);
  });

  testWidgets('comprehension MCQ grades correct + wrong picks',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithStory()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    // Correct option (index 0).
    await tester.tap(find.byKey(const ValueKey<String>('story-opt-chk1-0')));
    await tester.pumpAndSettle();
    expect(find.text('✓ Nicely done!'), findsOneWidget);
  });

  testWidgets('comprehension MCQ marks a wrong pick', (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithStory()),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    await tester.tap(find.byKey(const ValueKey<String>('story-opt-chk1-1')));
    await tester.pumpAndSettle();
    expect(find.text('✕ Not quite'), findsOneWidget);
  });

  testWidgets('unknown passage shows an honest not-available message',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineWithStory()),
    ]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: StoryReaderScreen(passageId: 'nope')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('This story is not available.'), findsOneWidget);
  });
}
