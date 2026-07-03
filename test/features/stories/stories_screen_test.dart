import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/stories/stories_screen.dart';

// INF-6: the Stories list renders whatever stories the course authors, grouped
// by CEFR level, and shows an HONEST empty state when there are none.

CourseSpine _spine(List<CourseStory> stories) =>
    CourseSpine(courseCode: 'en', units: const <CourseUnit>[], stories: stories);

Future<void> _pump(WidgetTester tester, CourseSpine spine) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[courseSpineProvider.overrideWithValue(spine)],
    child: const MaterialApp(home: StoriesScreen()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists authored stories by level', (WidgetTester tester) async {
    await _pump(
        tester,
        _spine(const <CourseStory>[
          CourseStory(
              id: 'a', title: 'Market Day', cefr: 'A1', sentences: <String>['x']),
          CourseStory(
              id: 'b', title: 'The Interview', cefr: 'B1', sentences: <String>['y']),
        ]));
    expect(find.text('Market Day'), findsOneWidget);
    expect(find.text('The Interview'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('story-row-a')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('story-row-b')), findsOneWidget);
  });

  testWidgets('honest empty state when the course has no stories',
      (WidgetTester tester) async {
    await _pump(tester, _spine(const <CourseStory>[]));
    expect(find.text('No stories in this course yet.'), findsOneWidget);
  });
}
