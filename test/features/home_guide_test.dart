import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/features/home/path_geometry.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';

/// S96 (plan §3.2): section dividers de-dup per SECTION and the 📖 Guide opens
/// the unit's AUTHORED guide (pre-generated content) when present — Library
/// fallback otherwise. Codegen-free spine stand-ins (local-gate friendly).
CourseLesson _l(String id) => CourseLesson(
      id: id,
      title: id.toUpperCase(),
      cefr: 'A1',
      exercises: <CourseExercise>[
        CourseExercise(
            id: '${id}_x',
            exerciseType: 'mcq',
            prompt: 'p',
            accepted: <String>['a']),
      ],
    );

const String _kGuide =
    'Welcome! In this unit you learn to greet people politely.';

CourseSpine _unitSpine({bool withGuide = true}) =>
    CourseSpine(courseCode: 'en', units: <CourseUnit>[
      CourseUnit(
          section: 'SECTION 1 · FOUNDATIONS',
          title: 'First Words',
          guideText: withGuide ? _kGuide : null,
          lessons: <CourseLesson>[_l('a'), _l('b')]),
      CourseUnit(
          section: 'SECTION 1 · FOUNDATIONS',
          title: 'People & Things',
          lessons: <CourseLesson>[_l('c')]),
      CourseUnit(
          section: 'SECTION 2 · DAILY LIFE',
          title: 'Around Town',
          lessons: <CourseLesson>[_l('d')]),
    ]);

Widget _appWith(CourseSpine spine) => ProviderScope(
      overrides: <Override>[
        courseSpineProvider.overrideWithValue(spine),
        settingsStoreProvider.overrideWithValue(
            InMemorySettingsStore(const AppSettings(reduceMotion: true))),
      ],
      child: const RatelApp(),
    );

void main() {
  test('dividers emit once per SECTION (consecutive units share one divider)', () {
    final PathGeometry g =
        computePathGeometry(spine: _unitSpine(), activeIndex: 0);
    expect(g.dividers.length, 2); // 3 units, 2 sections
    expect(g.dividers.first.label, 'SECTION 1 · FOUNDATIONS');
    expect(g.dividers.last.label, 'SECTION 2 · DAILY LIFE');
    expect(g.nodes.length, 4); // every lesson still gets a node
  });

  testWidgets('📖 Guide opens the AUTHORED unit guide in a sheet', (WidgetTester tester) async {
    await tester.pumpWidget(_appWith(_unitSpine()));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('tab-home')), findsOneWidget);
    await tester.tap(find.text('Guide'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('home-guide-text')), findsOneWidget);
    expect(find.textContaining('Welcome!'), findsOneWidget);
    expect(find.text('First Words'), findsWidgets); // sheet title = unit title
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('home-guide-text')), findsNothing);
  });

  testWidgets('no authored guide → Guide keeps the historic Library fallback', (WidgetTester tester) async {
    await tester.pumpWidget(_appWith(_unitSpine(withGuide: false)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guide'));
    await tester.pumpAndSettle();
    // Navigated away from Home (to Library); no guide sheet anywhere.
    expect(find.byKey(const ValueKey<String>('home-guide-text')), findsNothing);
    expect(find.byKey(const ValueKey<String>('tab-home')), findsNothing);
  });
}
