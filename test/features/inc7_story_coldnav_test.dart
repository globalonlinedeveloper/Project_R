import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/common/content_unavailable_card.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/stories/story_reader_screen.dart';

// INC-7 Story cold-nav graceful default (DESIGN_VS_LIVE §S): a bare `/story`
// deep-link threads `passageId == null`, which used to render the honest
// "Content unavailable" card as a DEAD-END even though the course authors real
// stories. INC-7 resolves cold nav (and an explicit-but-unknown id) to the
// FIRST authored story so the surface opens a REAL story, while RESERVING the
// unavailable card for the one truly-honest case: a course with NO stories.
//
// Deliberately does NOT touch TTS/audio honesty (audio_ref still null -> no
// fake streaming), the check questions, the Stories list, or the router.

CourseSpine _spineWith2Stories() => const CourseSpine(
      courseCode: 'en',
      units: <CourseUnit>[],
      stories: <CourseStory>[
        CourseStory(
          id: 'p_first',
          title: 'Her First Day',
          cefr: 'A1',
          theme: 'first day at school',
          sentences: <String>[
            'She walks to school.',
            'It is her first day.',
          ],
        ),
        CourseStory(
          id: 'p_second',
          title: 'The Market Trip',
          cefr: 'A2',
          sentences: <String>[
            'He buys fresh bread.',
          ],
        ),
      ],
    );

/// A course that authors NO stories at all: the ONLY case that keeps the
/// honest ContentUnavailableCard under INC-7.
CourseSpine _spineNoStories() => const CourseSpine(
      courseCode: 'en',
      units: <CourseUnit>[],
    );

Future<void> _pump(
  WidgetTester tester,
  CourseSpine spine, {
  required String? passageId,
}) async {
  tester.view.physicalSize = const Size(460, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final ProviderContainer c = ProviderContainer(overrides: <Override>[
    courseSpineProvider.overrideWithValue(spine),
  ]);
  addTearDown(c.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(home: StoryReaderScreen(passageId: passageId)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'cold nav (passageId == null) opens the FIRST real story, not the card',
      (WidgetTester tester) async {
    await _pump(tester, _spineWith2Stories(), passageId: null);

    // The reader renders a real story body (the first authored story) -- NOT
    // the honest empty-state card.
    expect(find.byType(ContentUnavailableCard), findsNothing);
    expect(find.byKey(const ValueKey<String>('story-body')), findsOneWidget);
    expect(find.text('She walks to school.'), findsOneWidget);
    expect(find.text('It is her first day.'), findsOneWidget);
    // The default is deterministic: the FIRST story, not the second.
    expect(find.text('He buys fresh bread.'), findsNothing);
    expect(find.text('Her First Day'), findsWidgets); // app-bar title
  });

  testWidgets('empty course (no stories) still shows the honest unavailable card',
      (WidgetTester tester) async {
    await _pump(tester, _spineNoStories(), passageId: null);

    expect(find.byType(ContentUnavailableCard), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('story-body')), findsNothing);
    expect(find.text('Content unavailable'), findsOneWidget);
    expect(find.text('Go back'), findsOneWidget);
  });

  testWidgets('an explicit valid passageId still resolves to THAT exact story',
      (WidgetTester tester) async {
    await _pump(tester, _spineWith2Stories(), passageId: 'p_second');

    expect(find.byType(ContentUnavailableCard), findsNothing);
    expect(find.byKey(const ValueKey<String>('story-body')), findsOneWidget);
    // The SECOND story's content, proving exact-id match wins over the default.
    expect(find.text('He buys fresh bread.'), findsOneWidget);
    expect(find.text('She walks to school.'), findsNothing);
    expect(find.text('The Market Trip'), findsWidgets); // app-bar title
  });

  testWidgets(
      'explicit-but-unknown id falls back to the first story (graceful, not dead-end)',
      (WidgetTester tester) async {
    await _pump(tester, _spineWith2Stories(), passageId: 'does-not-exist');

    // Graceful default: a real id that is not in the spine no longer dead-ends;
    // it opens the first authored story. (Only a truly-empty course is honest
    // "unavailable" now.)
    expect(find.byType(ContentUnavailableCard), findsNothing);
    expect(find.byKey(const ValueKey<String>('story-body')), findsOneWidget);
    expect(find.text('She walks to school.'), findsOneWidget);
  });
}
