import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/content/loader/content_loader.dart';
import 'package:ratel/content/spine/content_course_spine.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/features/roleplay/roleplay_player_screen.dart';

// S132: the REAL authored ES roleplay content drives the player end-to-end —
// correct grading, authored "Explain this", wrong-pick grading, completion.
// [R-D10 · R-B3]

CourseSpine _spine() => buildCourseSpine(const ContentLoader().loadString(
    File('assets/content/es/course.batch.json').readAsStringSync()));

void main() {
  testWidgets('plays the ES bakery roleplay start to finish',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(460, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final ProviderContainer c = ProviderContainer(overrides: <Override>[
      courseSpineProvider.overrideWithValue(_spine()),
    ]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
          home: RoleplayPlayerScreen(scenarioId: 'scenario_es_rp_pan1')),
    ));
    await tester.pumpAndSettle();

    // sc1: the authored opener renders.
    expect(find.text('¡Hola! ¿Qué le pongo?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('roleplay-continue')));
    await tester.pumpAndSettle();

    // sc2: honest prompt (no leaked answer) + the correct pick grades ✓ with
    // its authored explanation.
    expect(find.text('¿Qué respondes?'), findsOneWidget);
    await tester.tap(find.text('Dos panes, por favor.'));
    await tester.pumpAndSettle();
    expect(find.text('✓ Nicely done!'), findsOneWidget);
    await tester
        .tap(find.byKey(const ValueKey<String>('roleplay-explain-toggle')));
    await tester.pumpAndSettle();
    expect(
        find.text('Number + noun + por favor — a complete, polite order.'),
        findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('roleplay-continue')));
    await tester.pumpAndSettle();

    // sc3 → sc4: a wrong pick grades ✕.
    expect(find.text('Aquí tiene. ¿Algo más?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('roleplay-continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('El pan es azul.'));
    await tester.pumpAndSettle();
    expect(find.text('✕ Not quite'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('roleplay-continue')));
    await tester.pumpAndSettle();

    // sc5 closes → scene complete.
    expect(find.text('Son tres euros. ¡Gracias!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('roleplay-continue')));
    await tester.pumpAndSettle();
    expect(find.text('🎉 Scene complete!'), findsOneWidget);
  });
}
