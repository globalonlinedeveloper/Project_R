import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/lesson/lesson_runner_screen.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart';

// The runner serves a "listen" exercise as the type-what-you-hear renderer ONLY
// when browser speech is available (web); on the VM (speech unavailable) it
// degrades honestly to typed. When available it plays via the injected handle,
// grades against the authored accepted answer, and advances. [SPEC_LISTEN_TTS §4/§5]

const CourseSpine _spineListen = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(
    section: 'SECTION 1 · LEVEL A1',
    title: 'Level A1',
    lessons: <CourseLesson>[
      CourseLesson(id: 'l1', title: 'Listen', cefr: 'A1', exercises: <CourseExercise>[
        CourseExercise(
            id: 'e1', exerciseType: 'listen', prompt: 'ignored', accepted: <String>['hola']),
      ]),
    ],
  ),
]);

class _FakeAudioHandle implements AudioHandle {
  int playCount = 0;
  int slowCount = 0;
  @override
  bool get isPlaying => false;
  @override
  Future<void> play() async => playCount++;
  @override
  Future<void> playSlow() async => slowCount++;
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

Future<void> _pump(WidgetTester tester, ProviderContainer c) async {
  tester.view.physicalSize = const Size(440, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: const MaterialApp(home: LessonRunnerScreen(lessonId: 'l1')),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('speech UNAVAILABLE (default VM): a listen item degrades to typed',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineListen),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    // No audio affordance; the honest typed renderer is shown instead.
    expect(find.text('🔊'), findsNothing);
    expect(find.text('Type what you hear'), findsNothing);
    expect(find.byKey(const ValueKey<String>('lesson-input')), findsOneWidget);
  });

  testWidgets('speech AVAILABLE: renders audio + typed, plays, grades, advances',
      (WidgetTester tester) async {
    final _FakeAudioHandle fake = _FakeAudioHandle();
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineListen),
      speechTtsProvider.overrideWithValue(_FakeAvailableSpeechTts(fake)),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    bool sawListen = false;
    for (int i = 0; i < 6; i++) {
      if (find.text('Lesson complete!').evaluate().isNotEmpty) break;
      if (find.text('🔊').evaluate().isNotEmpty) {
        sawListen = true;
        expect(find.text('Type what you hear'), findsOneWidget);
        await tester.tap(find.text('🔊'));
        await tester.pumpAndSettle();
        expect(fake.playCount, greaterThan(0));
        await tester.enterText(
            find.byKey(const ValueKey<String>('lesson-input')), 'hola');
        await tester.pump();
        await tester.tap(find.text('Check'));
        await tester.pumpAndSettle();
        expect(find.text('✓ Correct!'), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        continue;
      }
      // Any other item type: advance it with a throwaway answer.
      await tester.enterText(
          find.byKey(const ValueKey<String>('lesson-input')), 'x');
      await tester.pump();
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }
    expect(sawListen, isTrue);
    expect(find.text('Lesson complete!'), findsOneWidget);
  });
}
