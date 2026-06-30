// R-L12 · Global search — route promotion + live-results widget coverage.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/router.dart';
import 'package:ratel/features/common/coming_soon_screen.dart';
import 'package:ratel/features/learning_path/course_spine.dart';

const CourseSpine _spine = CourseSpine(
  courseCode: 'es',
  units: <CourseUnit>[
    CourseUnit(
      section: 'SECTION 1 · LEVEL A1',
      title: 'Level A1',
      lessons: <CourseLesson>[
        CourseLesson(
            id: 'es-food-1',
            title: 'Food & drink',
            cefr: 'A1',
            exercises: <CourseExercise>[]),
        CourseLesson(
            id: 'es-greet-1',
            title: 'Greetings',
            cefr: 'A1',
            exercises: <CourseExercise>[]),
      ],
    ),
  ],
);

void main() {
  test('/search is no longer a coming-soon stub', () {
    final Set<String> stubbed =
        kComingSoonRoutes.map((ComingSoonRoute r) => r.path).toSet();
    expect(stubbed.contains('/search'), isFalse);
    // /friends is now a REAL screen too (S64 / R-I9) — no honest stubs remain.
    expect(stubbed.contains('/friends'), isFalse);
    expect(stubbed, isEmpty);
  });

  testWidgets('the /search route renders the REAL search screen + live results',
      (WidgetTester tester) async {
    final router = buildRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          courseSpineProvider.overrideWithValue(_spine),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    router.go('/search');
    // NOTE: the search field autofocuses (a never-ending cursor blink), so
    // pumpAndSettle would time out — advance fixed slices instead (§11).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // It is the real screen (the autofocused search field), not the old stub.
    expect(find.byType(ComingSoonScreen), findsNothing);
    expect(find.byKey(const ValueKey<String>('search-field')), findsOneWidget);

    // Type a query → after the ~350 ms debounce, a REAL lesson hit appears.
    await tester.enterText(
        find.byKey(const ValueKey<String>('search-field')), 'food');
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Food & drink'), findsOneWidget);

    // A query with no matches is honest — no fabricated result.
    await tester.enterText(
        find.byKey(const ValueKey<String>('search-field')), 'zzzzzz');
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Food & drink'), findsNothing);
    expect(find.textContaining('No matches'), findsOneWidget);
  });
}
