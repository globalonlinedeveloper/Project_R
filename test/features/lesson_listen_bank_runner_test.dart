import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/lesson/lesson_runner_screen.dart';
import 'package:ratel/services/tts_relay/tts_relay.dart';

// The runner serves a "listen" exercise as the DESIGNED word-bank ("assemble
// what you hear") when browser speech is available AND the phrase has >=2
// tokens. Assembling the correct token order self-grades correct and advances;
// with speech unavailable the SAME item degrades honestly to the typed
// renderer. Decoys are REAL single-word tokens from OTHER authored phrases.
// [SPEC_LISTEN_TTS §4/§5 · owner word-bank decision]
// R-D5 (listen — word-bank "assemble what you hear" runner integration).

// l1: a multi-token 'listen' phrase -> word-bank. l2: a distinct phrase whose
// words (ella/bebe/agua) are the REAL decoy source.
const CourseSpine _spineBank = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(
    section: 'SECTION 1 · LEVEL A1',
    title: 'Level A1',
    lessons: <CourseLesson>[
      CourseLesson(id: 'l1', title: 'Listen', cefr: 'A1', exercises: <CourseExercise>[
        CourseExercise(
            id: 'e1',
            exerciseType: 'listen',
            prompt: 'ignored',
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

// A lesson whose FIRST exercise is a single word (hola) but a LATER exercise is
// a multi-token phrase -> the appended Listen review must PREFER the multi-token
// phrase and surface the word-bank (not the single-token typed fallback).
const CourseSpine _spinePrefersMulti = CourseSpine(courseCode: 'es', units: <CourseUnit>[
  CourseUnit(
    section: 'S',
    title: 'A1',
    lessons: <CourseLesson>[
      CourseLesson(id: 'l1', title: 'Mixed', cefr: 'A1', exercises: <CourseExercise>[
        CourseExercise(
            id: 's1', exerciseType: 'mcq', prompt: 'p', accepted: <String>['hola']),
        CourseExercise(
            id: 'm1',
            exerciseType: 'translate',
            prompt: 'q',
            accepted: <String>['yo como pan']),
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
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(home: LessonRunnerScreen(lessonId: lessonId)),
  ));
  await tester.pumpAndSettle();
}

/// True when the current item is a word-bank Listen (audio row present, but no
/// typed input field — the honest distinguisher from type-what-you-hear).
bool _isWordBank() =>
    find.text('🔊').evaluate().isNotEmpty &&
    find.byKey(const ValueKey<String>('lesson-input')).evaluate().isEmpty;

/// Assemble yo/como/pan in order, self-grade via the widget's own Check, assert
/// correct, and Continue. Walks every surfaced word-bank item to completion.
Future<void> _walkAssemblingCorrectly(WidgetTester tester) async {
  for (int i = 0; i < 6; i++) {
    if (find.text('Lesson complete!').evaluate().isNotEmpty) break;
    if (!_isWordBank()) break; // this spine serves only word-bank items
    for (final String w in const <String>['yo', 'como', 'pan']) {
      await tester.tap(find.text(w));
      await tester.pump();
    }
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('✓ Correct!'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets(
      'speech AVAILABLE + >=2 tokens: renders the word-bank, grades, advances',
      (WidgetTester tester) async {
    final _FakeAudioHandle fake = _FakeAudioHandle();
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineBank),
      speechTtsProvider.overrideWithValue(_FakeAvailableSpeechTts(fake)),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    // The DESIGNED word-bank shell, not the typed fallback.
    expect(_isWordBank(), isTrue);
    expect(find.text('Tap what you hear'), findsWidgets);
    expect(find.byKey(const ValueKey<String>('lesson-input')), findsNothing);
    expect(find.text('Type what you hear'), findsNothing);
    // Target tokens are all present as bank chips…
    for (final String w in const <String>['yo', 'como', 'pan']) {
      expect(find.text(w), findsOneWidget);
    }
    // …and a REAL decoy from the OTHER authored phrase is mixed in.
    expect(find.text('ella'), findsOneWidget);

    // Audio routes through the injected handle.
    await tester.tap(find.text('🔊'));
    await tester.pumpAndSettle();
    expect(fake.playCount, greaterThanOrEqualTo(1));

    await _walkAssemblingCorrectly(tester);
    expect(find.text('Lesson complete!'), findsOneWidget);
  });

  testWidgets('speech UNAVAILABLE: the same >=2-token listen degrades to typed',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineBank),
      // no speechTtsProvider override => the default Unavailable stub.
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    expect(find.text('🔊'), findsNothing);
    expect(find.text('Tap what you hear'), findsNothing);
    expect(find.byKey(const ValueKey<String>('lesson-input')), findsOneWidget);
  });

  testWidgets('assembling the WRONG order self-grades incorrect (honest grade)',
      (WidgetTester tester) async {
    final _FakeAudioHandle fake = _FakeAudioHandle();
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineBank),
      speechTtsProvider.overrideWithValue(_FakeAvailableSpeechTts(fake)),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    expect(_isWordBank(), isTrue);
    for (final String w in const <String>['pan', 'como', 'yo']) {
      await tester.tap(find.text(w));
      await tester.pump();
    }
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('✕ Not quite'), findsOneWidget);
    // The correct assembly is surfaced honestly.
    expect(find.textContaining('yo como pan'), findsWidgets);
  });

  testWidgets(
      'a lesson opening on a single word still surfaces the word-bank from a '
      'LATER multi-token phrase (prefers >=2 tokens, stays scoped)',
      (WidgetTester tester) async {
    final _FakeAudioHandle fake = _FakeAudioHandle();
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spinePrefersMulti),
      speechTtsProvider.overrideWithValue(_FakeAvailableSpeechTts(fake)),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    // Walk the lesson; a word-bank review MUST appear (if the picker still
    // returned the single-token 'hola', no word-bank would ever render).
    bool sawWordBank = false;
    for (int i = 0; i < 8; i++) {
      if (find.text('Lesson complete!').evaluate().isNotEmpty) break;
      if (_isWordBank()) {
        sawWordBank = true;
        for (final String w in const <String>['yo', 'como', 'pan']) {
          await tester.tap(find.text(w));
          await tester.pump();
        }
        await tester.tap(find.text('Check'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
      } else {
        await tester.enterText(
            find.byKey(const ValueKey<String>('lesson-input')), 'x');
        await tester.pump();
        await tester.tap(find.text('Check'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
      }
    }
    expect(sawWordBank, isTrue);
  });

  testWidgets(
      'C-7: the word-bank Listen Check lives in the FIXED footer, not the '
      'scroll body', (WidgetTester tester) async {
    final _FakeAudioHandle fake = _FakeAudioHandle();
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineBank),
      speechTtsProvider.overrideWithValue(_FakeAvailableSpeechTts(fake)),
    ]);
    addTearDown(c.dispose);
    await _pump(tester, c);

    expect(_isWordBank(), isTrue);
    // Place a token so the footer Check is enabled.
    await tester.tap(find.text('yo'));
    await tester.pump();

    // The Check is the runner's fixed footer button (paired with Skip), like
    // every other exercise type -- NOT a second button inside the scroll body.
    expect(find.text('Check'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.text('Check'),
      ),
      findsNothing,
    );
  });

  testWidgets('C-7: word-bank Listen renders without overflow @800',
      (WidgetTester tester) async {
    final _FakeAudioHandle fake = _FakeAudioHandle();
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spineBank),
      speechTtsProvider.overrideWithValue(_FakeAvailableSpeechTts(fake)),
    ]);
    addTearDown(c.dispose);
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: LessonRunnerScreen(lessonId: 'l1')),
    ));
    await tester.pumpAndSettle();
    expect(_isWordBank(), isTrue);
    expect(tester.takeException(), isNull);
  });
}
