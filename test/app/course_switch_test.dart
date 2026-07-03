import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/app/content_wiring.dart';
import 'package:ratel/app/course_switch.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/settings/settings_screen.dart';

// INF-3: the persisted-selectable course. The app root loads the SELECTED
// bundled course batch (ES default — existing learners see no change),
// derives the available courses from the ASSET MANIFEST (a new language =
// rows + one asset, the picker grows itself), and switches restart-free by
// remounting the ProviderScope onto the new spine. Fail-closed: an unknown
// course falls back to the ES beachhead, never a broken boot.
// [R-A3 · R-B3] course selection over the bundled authored catalogs.
/// Renders the injected [courseSpineProvider] state as plain text.
class _SpineProbe extends ConsumerWidget {
  const _SpineProbe();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CourseSpine spine = ref.watch(courseSpineProvider);
    return Scaffold(
        body: Text('course:${spine.courseCode} units:${spine.units.length}'));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('availableCourseCodes derives courses from the asset manifest',
      () async {
    final List<String> codes = await availableCourseCodes();
    expect(codes, containsAll(<String>['en', 'es']),
        reason: 'both bundled course batches must surface');
  });

  test('initContentOverrides loads the REQUESTED course (en)', () async {
    final List<Override> o = await initContentOverrides(course: 'en');
    expect(o, isNotEmpty);
    final ProviderContainer c = ProviderContainer(overrides: o);
    addTearDown(c.dispose);
    final CourseSpine spine = c.read(courseSpineProvider);
    expect(spine.courseCode, 'en');
    expect(spine.units.length, 72); // A1..C2 all S1+S2 = complete 6-level core (S100)
  });

  test('unknown course falls back to the ES beachhead (fail-closed ladder)',
      () async {
    final List<Override> o = await initContentOverrides(course: 'zz');
    expect(o, isNotEmpty);
    final ProviderContainer c = ProviderContainer(overrides: o);
    addTearDown(c.dispose);
    expect(c.read(courseSpineProvider).courseCode, 'es');
  });

  testWidgets('RatelCourseRoot switches es -> en restart-free',
      (WidgetTester tester) async {
    // Real asset I/O inside testWidgets runs under FakeAsync and never
    // completes unless routed through runAsync (session-craft §11 family).
    final List<Override> es =
        (await tester.runAsync<List<Override>>(initContentOverrides))!;
    await tester.pumpWidget(RatelCourseRoot(
      baseOverrides: const <Override>[],
      initialContent: es,
      initialCourse: 'es',
      availableCourses: const <String>['en', 'es'],
      // Light probe instead of the full app: the seam under test is the
      // persist+reload+remount machinery, rendered via the REAL provider.
      childOverride: const MaterialApp(home: _SpineProbe()),
    ));
    await tester.pump();
    expect(find.text('course:es units:2'), findsOneWidget);

    final CourseSwitchScope scope = CourseSwitchScope.maybeOf(
        tester.element(find.byType(_SpineProbe)))!;
    expect(scope.current, 'es');
    await tester.runAsync<void>(() => scope.switchCourse('en'));
    await tester.pump();
    await tester.pump();

    // The scope remounted onto the EN spine — 72 authored units, no restart.
    expect(find.text('course:en units:72'), findsOneWidget);
    final CourseSwitchScope after = CourseSwitchScope.maybeOf(
        tester.element(find.byType(_SpineProbe)))!;
    expect(after.current, 'en');
  });

  testWidgets('Settings shows the Course tile + picker under a scope',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(460, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? switched;
    await tester.pumpWidget(CourseSwitchScope(
      current: 'es',
      available: const <String>['en', 'es'],
      switchCourse: (String code) async => switched = code,
      child: const ProviderScope(
          child: MaterialApp(home: SettingsScreen())),
    ));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Course'));
    expect(find.text('Spanish (es)'), findsOneWidget); // current label
    await tester.tap(find.text('Course'));
    await tester.pumpAndSettle();
    // The sheet lists both manifest courses; picking English switches.
    expect(find.text('English (en)'), findsOneWidget);
    await tester.tap(find.text('English (en)'));
    await tester.pumpAndSettle();
    expect(switched, 'en');
  });

  testWidgets('Settings WITHOUT a scope renders no Course tile (regression)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: SettingsScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Course'), findsNothing);
  });
}
