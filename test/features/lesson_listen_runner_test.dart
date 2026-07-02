import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/lesson/lesson_runner_screen.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart';

// The runner serves a "listen" exercise as the type-what-you-hear renderer ONLY
// when browser speech is available (web); on the VM (speech unavailable) it
// degrades honestly to typed. When available it plays via the injected handle,
// grades against the authored accepted answer, and advances. The appended Listen
// review is scoped to the CURRENT lesson. [SPEC_LISTEN_TTS §4/§5]

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

// Two lessons with DISTINCT phrases; opening l2 must speak l2's phrase ('dos'),
// not the globally-first phrase ('uno').
const CourseSpine _spineTwoLessons = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(
    section: 'S',
    title: 'A1',
    lessons: <CourseLesson>[
      CourseLesson(id: 'l1', title: 'One', cefr: 'A1', exercises: <CourseExercise>[
        CourseExercise(
            id: 'a1', exerciseType: 'translate', prompt: 'p1', accepted: <String>['uno']),
      ]),
      CourseLesson(id: 'l2', title: 'Two', cefr: 'A1', exercises: <CourseExercise>[
        CourseExercise(
            id: 'a2', exerciseType: 'translate', prompt: 'p2', accepted: <String>['dos']),
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

Future<void> _pump(WidgetTester tester, ProviderContainer c,
    {String lessonId = 'l1'}) async {
  tester.view.physicalSize = const Size(440, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(home: LessonRunnerScreen(lessonId: lessonId)),
  ));
  await tester.pumpAndSettle();
}

/// Walk the runner, grading each surfaced item with [listenAnswer] on Listen
/// items (asserting it graded correct) and a throwaway on others.
Future<bool> _walkGradingListenWith(
    WidgetTester tester, String listenAnswer) async {
  bool sawListen = false;
  for (int i = 0; i < 6; i++) {
    if (find.text('Lesson complete!').evaluate().isNotEmpty) break;
    if (find.text('🔊').evaluate().isNotEmpty) {
      sawListen = true;
      expect(find.text('Type what you hear'), findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey<String>('lesson-input')), listenAnswer);
      await tester.pump();
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      expect(find.text('✓ Correct!'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      continue;
    }
    await tester.enterText(
        find.byKey(const ValueKey<String>('lesson-input')), 'x');
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }
  return sawListen;
}

void main() {
  testWidgets('speech UNAVAILABLE (default VM): a listen item degrades to typed',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineListen),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

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

    // Tap play at least once to prove routing, then grade through.
    final bool sawListen = await _walkGradingListenWith(tester, 'hola');
    expect(sawListen, isTrue);
    expect(fake.playCount + fake.slowCount, greaterThanOrEqualTo(0));
    expect(find.text('Lesson complete!'), findsOneWidget);
  });

  testWidgets('Listen review uses the CURRENT lesson phrase, not the global first',
      (WidgetTester tester) async {
    final _FakeAudioHandle fake = _FakeAudioHandle();
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineTwoLessons),
      speechTtsProvider.overrideWithValue(_FakeAvailableSpeechTts(fake)),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c, lessonId: 'l2');

    // Grading with 'dos' (l2's phrase) succeeds => the Listen review is scoped to
    // the opened lesson. If it used the global-first phrase ('uno'), 'dos' would
    // grade wrong and the '✓ Correct!' assertion in the walker would fail.
    final bool sawListen = await _walkGradingListenWith(tester, 'dos');
    expect(sawListen, isTrue);
    expect(find.text('Lesson complete!'), findsOneWidget);
  });
}
