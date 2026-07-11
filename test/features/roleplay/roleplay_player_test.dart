import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/roleplay/roleplay_player_screen.dart';

// INF-8: the graded Roleplay player -- pick the right reply, graded by
// is_correct with "Explain this", advancing scene by scene (authored data).

CourseSpine _spine() => const CourseSpine(
      courseCode: 'en',
      units: <CourseUnit>[],
      roleplays: <CourseScenario>[
        CourseScenario(
          id: 'rp1',
          kind: 'roleplay',
          title: 'Meet a friend',
          cefr: 'A1',
          goal: 'Introduce yourself',
          scenes: <CourseScene>[
            CourseScene(sceneId: 'sc1', speaker: 'Ben', line: 'Hi, I am Ben.'),
            CourseScene(
              sceneId: 'sc2',
              speaker: 'you',
              line: 'How do you reply?',
              choices: <CourseChoice>[
                CourseChoice(
                    label: 'Hello, I am Sam.',
                    isCorrect: true,
                    nextSceneId: 'sc3',
                    explain: 'A friendly greeting introduces you.'),
                CourseChoice(
                    label: 'Goodbye.', isCorrect: false, nextSceneId: 'sc3'),
              ],
            ),
            CourseScene(
                sceneId: 'sc3', speaker: 'Ben', line: 'Nice to meet you!'),
          ],
        ),
      ],
    );

ProviderContainer _c() => ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spine()),
    ]);

Future<void> _pump(WidgetTester tester, ProviderContainer c) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: const MaterialApp(home: RoleplayPlayerScreen(scenarioId: 'rp1')),
  ));
  await tester.pumpAndSettle();
}

Future<void> _toDecision(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey<String>('roleplay-continue')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the opening line + goal', (WidgetTester tester) async {
    final ProviderContainer c = _c();
    addTearDown(c.dispose);
    await _pump(tester, c);
    expect(find.text('Meet a friend'), findsWidgets);
    expect(find.text('Hi, I am Ben.'), findsOneWidget);
    expect(find.text('Introduce yourself'), findsOneWidget);
  });

  testWidgets('a correct reply grades OK and reveals Explain',
      (WidgetTester tester) async {
    final ProviderContainer c = _c();
    addTearDown(c.dispose);
    await _pump(tester, c);
    await _toDecision(tester);
    expect(find.text('How do you reply?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('roleplay-opt-0')));
    await tester.pumpAndSettle();
    expect(find.text('✓ Nicely done!'), findsOneWidget);
    await tester
        .tap(find.byKey(const ValueKey<String>('roleplay-explain-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('A friendly greeting introduces you.'), findsOneWidget);
  });

  testWidgets('a wrong reply grades not-quite', (WidgetTester tester) async {
    final ProviderContainer c = _c();
    addTearDown(c.dispose);
    await _pump(tester, c);
    await _toDecision(tester);
    await tester.tap(find.byKey(const ValueKey<String>('roleplay-opt-1')));
    await tester.pumpAndSettle();
    expect(find.text('✕ Not quite'), findsOneWidget);
  });

  testWidgets('advances through to scene complete',
      (WidgetTester tester) async {
    final ProviderContainer c = _c();
    addTearDown(c.dispose);
    await _pump(tester, c);
    await _toDecision(tester);
    await tester.tap(find.byKey(const ValueKey<String>('roleplay-opt-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('roleplay-continue')));
    await tester.pumpAndSettle();
    expect(find.text('Nice to meet you!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('roleplay-continue')));
    await tester.pumpAndSettle();
    expect(find.text('🎉 Scene complete!'), findsOneWidget);
  });
}
