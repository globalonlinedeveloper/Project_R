import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/home/lesson_preview_sheet.dart';

GalaxyPlanet _planet({
  bool checkpoint = false,
  int lessonNo = 1,
  int lessons = 5,
  String title = 'Greetings',
}) =>
    GalaxyPlanet(
      x: 100,
      y: 180,
      section: 0,
      ui: 0,
      isCheckpoint: checkpoint,
      hue: 6,
      arch: PlanetArch.icy,
      ring: false,
      moon: true,
      lessonNo: lessonNo,
      lessons: lessons,
      unitTitle: title,
    );

Widget _host(Widget sheet) =>
    MaterialApp(theme: RatelTheme.space(), home: Scaffold(body: sheet));

void main() {
  testWidgets('available lesson → Start CTA, energy + XP chips', (tester) async {
    var started = 0;
    await tester.pumpWidget(_host(LessonPreviewSheet(
      planet: _planet(),
      state: PlanetState.active,
      onStart: () => started++,
      onReview: () {},
    )));
    expect(find.text('Lesson 1 of 5'), findsOneWidget);
    expect(find.text('−1 energy'), findsOneWidget);
    expect(find.text('+20 XP'), findsOneWidget);
    await tester.tap(find.text('Start lesson'));
    expect(started, 1);
  });

  testWidgets('completed lesson → free Review CTA', (tester) async {
    var reviewed = 0;
    await tester.pumpWidget(_host(LessonPreviewSheet(
      planet: _planet(),
      state: PlanetState.done,
      onStart: () {},
      onReview: () => reviewed++,
    )));
    expect(find.text('Lesson 1 · completed'), findsOneWidget);
    expect(find.text('Review · free'), findsOneWidget);
    await tester.tap(find.text('Review'));
    expect(reviewed, 1);
  });

  testWidgets('locked planet → disabled CTA, no start', (tester) async {
    var started = 0;
    await tester.pumpWidget(_host(LessonPreviewSheet(
      planet: _planet(),
      state: PlanetState.locked,
      onStart: () => started++,
      onReview: () {},
    )));
    expect(find.text('Locked — finish the earlier lessons first'), findsOneWidget);
    await tester.tap(find.byType(InkWell), warnIfMissed: false);
    expect(started, 0);
  });

  testWidgets('active checkpoint → checkpoint copy + reward chip', (tester) async {
    await tester.pumpWidget(_host(LessonPreviewSheet(
      planet: _planet(checkpoint: true, lessonNo: 5, lessons: 5),
      state: PlanetState.active,
      onStart: () {},
      onReview: () {},
    )));
    expect(find.text('Checkpoint: Greetings'), findsOneWidget);
    expect(find.text('+50 XP'), findsOneWidget);
    expect(find.text('Reward chest'), findsOneWidget);
  });
}
// Traceability: R-WT4
