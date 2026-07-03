import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/adventures/adventure_player_screen.dart';

// INF-8: the branching Adventure player -- choices branch to the authored
// next_scene_id (no grading); a scene with no choices is an ending.

CourseSpine _spine() => const CourseSpine(
      courseCode: 'en',
      units: <CourseUnit>[],
      adventures: <CourseScenario>[
        CourseScenario(
          id: 'adv1',
          kind: 'adventure',
          title: 'The market',
          cefr: 'A1',
          scenes: <CourseScene>[
            CourseScene(
              sceneId: 'a1',
              speaker: 'narrator',
              line: 'You reach a fork.',
              choices: <CourseChoice>[
                CourseChoice(label: 'Go left', nextSceneId: 'a2'),
                CourseChoice(label: 'Go right', nextSceneId: 'a3'),
              ],
            ),
            CourseScene(
                sceneId: 'a2', speaker: 'narrator', line: 'You find a cafe.'),
            CourseScene(
                sceneId: 'a3', speaker: 'narrator', line: 'You find a park.'),
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
    child: const MaterialApp(home: AdventurePlayerScreen(scenarioId: 'adv1')),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the opening scene + branch choices',
      (WidgetTester tester) async {
    final ProviderContainer c = _c();
    addTearDown(c.dispose);
    await _pump(tester, c);
    expect(find.text('You reach a fork.'), findsOneWidget);
    expect(find.text('Go left'), findsOneWidget);
    expect(find.text('Go right'), findsOneWidget);
  });

  testWidgets('the left choice branches to its authored next scene',
      (WidgetTester tester) async {
    final ProviderContainer c = _c();
    addTearDown(c.dispose);
    await _pump(tester, c);
    await tester.tap(find.byKey(const ValueKey<String>('adventure-choice-0')));
    await tester.pumpAndSettle();
    expect(find.text('You find a cafe.'), findsOneWidget);
    expect(find.text('You reach a fork.'), findsNothing);
  });

  testWidgets('the right choice reaches a different ending',
      (WidgetTester tester) async {
    final ProviderContainer c = _c();
    addTearDown(c.dispose);
    await _pump(tester, c);
    await tester.tap(find.byKey(const ValueKey<String>('adventure-choice-1')));
    await tester.pumpAndSettle();
    expect(find.text('You find a park.'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('adventure-ending')),
        findsOneWidget);
  });
}
