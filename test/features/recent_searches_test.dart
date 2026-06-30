// R-L12 · Global search — recent searches (device-local persistence) coverage.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/router.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

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
      ],
    ),
  ],
);

void main() {
  test('addRecentSearch: most-recent-first, case-insensitive dedup, capped, clear',
      () {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    final AppSettingsController ctrl =
        c.read(appSettingsControllerProvider.notifier);

    ctrl.addRecentSearch('food');
    ctrl.addRecentSearch('greetings');
    ctrl.addRecentSearch('FOOD'); // dedups 'food', jumps to the front
    expect(c.read(appSettingsControllerProvider).recentSearches,
        <String>['FOOD', 'greetings']);

    ctrl.addRecentSearch('   '); // blank ignored
    expect(c.read(appSettingsControllerProvider).recentSearches,
        <String>['FOOD', 'greetings']);

    for (int i = 0; i < 12; i++) {
      ctrl.addRecentSearch('q$i');
    }
    final List<String> recents =
        c.read(appSettingsControllerProvider).recentSearches;
    expect(recents.length, 8); // capped
    expect(recents.first, 'q11'); // most-recent-first

    ctrl.clearRecentSearches();
    expect(c.read(appSettingsControllerProvider).recentSearches, isEmpty);
  });

  testWidgets('idle shows persisted Recent searches; tapping one re-runs it',
      (WidgetTester tester) async {
    final router = buildRouter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          courseSpineProvider.overrideWithValue(_spine),
          settingsStoreProvider.overrideWithValue(
            InMemorySettingsStore(
                const AppSettings(recentSearches: <String>['food'])),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    router.go('/search');
    await tester.pump(); // autofocus blink → never pumpAndSettle (§11)
    await tester.pump(const Duration(milliseconds: 50));

    // The persisted recent query renders as a chip in the empty/idle state.
    expect(find.text('food'), findsOneWidget);

    // Tapping it re-runs the search → the real lesson surfaces.
    await tester.tap(find.text('food'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Food & drink'), findsOneWidget);
  });
}
