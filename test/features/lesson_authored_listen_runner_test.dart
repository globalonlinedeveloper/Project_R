import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/lesson/lesson_runner_screen.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart';

// An AUTHORED 'listen' item (exercise_type: listen in the content batch) is
// served DIRECTLY by the runner via _fromExercise -- the word-bank "assemble
// what you hear" when browser speech is available and the phrase has >=2
// tokens. Because the lesson already carries an authored Listen, the
// synthesized _buildListenItem review is SUPPRESSED (no duplicate listen).
// Real authored content only. R-D5 (listen -- authored word-bank).

// A lesson whose ONLY exercise is an authored multi-token listen item, plus a
// second lesson supplying the REAL decoy words (ella/bebe/agua).
const CourseSpine _spineAuthoredListen =
    CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(
    section: 'SECTION 1 · LEVEL A1',
    title: 'Level A1',
    lessons: <CourseLesson>[
      CourseLesson(id: 'l1', title: 'Listen', cefr: 'A1', exercises: <CourseExercise>[
        CourseExercise(
            id: 'item_listen_1',
            exerciseType: 'listen',
            prompt: '',
            accepted: <String>['yo como pan']),
      ]),
      CourseLesson(id: 'l2', title: 'Decoys', cefr: 'A1', exercises: <CourseExercise>[
        CourseExercise(
            id: 'e2',
            exerciseType: 'translate',
            prompt: 'p',
            accepted: <String>['ella bebe agua']),
      ]),
    ],
  ),
]);

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

Future<void> _pump(WidgetTester tester, ProviderContainer c) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(home: LessonRunnerScreen(lessonId: 'l1')),
  ));
  await tester.pumpAndSettle();
}

/// A word-bank Listen: the audio row is present but there is no typed input
/// field (the honest distinguisher from type-what-you-hear).
bool _isWordBank() =>
    find.text('🔊').evaluate().isNotEmpty &&
    find.byKey(const ValueKey<String>('lesson-input')).evaluate().isEmpty;

void main() {
  testWidgets(
      'authored listen renders the word-bank AND suppresses the synthesized '
      'duplicate (exactly one listen)', (WidgetTester tester) async {
    final _FakeAudioHandle fake = _FakeAudioHandle();
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineAuthoredListen),
      speechTtsProvider.overrideWithValue(_FakeAvailableSpeechTts(fake)),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    // The authored listen surfaces as the DESIGNED word-bank, not typed.
    expect(_isWordBank(), isTrue);
    expect(find.text('Tap what you hear'), findsWidgets);
    expect(find.byKey(const ValueKey<String>('lesson-input')), findsNothing);
    for (final String w in const <String>['yo', 'como', 'pan']) {
      expect(find.text(w), findsOneWidget);
    }
    // A REAL decoy from the OTHER authored phrase is mixed in.
    expect(find.text('ella'), findsOneWidget);

    // Assembling in order self-grades correct + advances.
    for (final String w in const <String>['yo', 'como', 'pan']) {
      await tester.tap(find.text(w));
      await tester.pump();
    }
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('✓ Nicely done!'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Exactly ONE listen: the lesson completes right after the authored item.
    // A 2nd (synthesized) word-bank would mean the guard failed.
    expect(find.text('Lesson complete!'), findsOneWidget);
    expect(_isWordBank(), isFalse);
  });

  testWidgets('authored listen degrades to typed when speech is unavailable',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineAuthoredListen),
      // no speechTtsProvider override => the default Unavailable stub.
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    expect(find.text('🔊'), findsNothing);
    expect(find.text('Tap what you hear'), findsNothing);
    expect(find.byKey(const ValueKey<String>('lesson-input')), findsOneWidget);
  });
}
