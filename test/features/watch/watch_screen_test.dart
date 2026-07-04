import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/watch/watch_screen.dart';

// INF-9: the Watch list renders whatever video lessons the course authors,
// grouped by CEFR level, and shows an HONEST empty state when there are none.

CourseSpine _spine(List<CourseStory> watch) =>
    CourseSpine(courseCode: 'en', units: const <CourseUnit>[], watch: watch);

Future<void> _pump(WidgetTester tester, CourseSpine spine) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: <Override>[courseSpineProvider.overrideWithValue(spine)],
    child: const MaterialApp(home: WatchScreen()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists authored watch lessons by level',
      (WidgetTester tester) async {
    await _pump(
        tester,
        _spine(const <CourseStory>[
          CourseStory(
              id: 'a',
              title: 'Morning Coffee',
              cefr: 'A1',
              sentences: <String>['x'],
              videoUrl: 'https://cdn.example/a.mp4'),
          CourseStory(
              id: 'b',
              title: 'The Presentation',
              cefr: 'B2',
              sentences: <String>['y'],
              videoUrl: 'https://cdn.example/b.mp4'),
        ]));
    expect(find.text('Morning Coffee'), findsOneWidget);
    expect(find.text('The Presentation'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('watch-row-a')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('watch-row-b')), findsOneWidget);
  });

  testWidgets('honest empty state when the course has no watch lessons',
      (WidgetTester tester) async {
    await _pump(tester, _spine(const <CourseStory>[]));
    expect(find.text('No watch lessons in this course yet.'), findsOneWidget);
  });
}
