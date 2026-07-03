import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/podcasts/podcasts_screen.dart';

// INF-7: the Podcasts list renders whatever podcasts the course authors, grouped
// by CEFR level, and shows an HONEST empty state when there are none.

CourseSpine _spine(List<CourseStory> podcasts) => CourseSpine(
    courseCode: 'en', units: const <CourseUnit>[], podcasts: podcasts);

Future<void> _pump(WidgetTester tester, CourseSpine spine) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[courseSpineProvider.overrideWithValue(spine)],
    child: const MaterialApp(home: PodcastsScreen()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists authored podcasts by level', (WidgetTester tester) async {
    await _pump(
        tester,
        _spine(const <CourseStory>[
          CourseStory(
              id: 'a',
              title: 'My Morning',
              cefr: 'A1',
              sentences: <String>['x'],
              audioUrl: 'https://cdn.example/a.mp3'),
          CourseStory(
              id: 'b',
              title: 'A Job Interview',
              cefr: 'B1',
              sentences: <String>['y'],
              audioUrl: 'https://cdn.example/b.mp3'),
        ]));
    expect(find.text('My Morning'), findsOneWidget);
    expect(find.text('A Job Interview'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('podcast-row-a')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('podcast-row-b')), findsOneWidget);
  });

  testWidgets('honest empty state when the course has no podcasts',
      (WidgetTester tester) async {
    await _pump(tester, _spine(const <CourseStory>[]));
    expect(find.text('No podcasts in this course yet.'), findsOneWidget);
  });
}
