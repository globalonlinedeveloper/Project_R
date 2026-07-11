import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ratel/features/lesson/lesson_runner_screen.dart';

// M-5 (screen review 2026-07 §2): pick-exercise narrow gauntlet. VERIFY-FIRST
// probe: the 2×2 pick grid (fallback bank — the real authored surface that
// drives the _pick renderer) must lay out without RenderFlex overflow at
// ≤360px, at 320px, and at the cruelest combo 360px @200% text scale.
// RatelOptionCard has no fixed heights (labels wrap), so the expectation is
// PASS — this test pins that as a permanent regression gauntlet; a breakpoint
// is only owed if this ever goes red (per the review: "add breakpoint only if
// the gauntlet shows clipping").

Future<void> _pump(WidgetTester tester,
    {required double width, double scale = 1.0}) async {
  tester.view.physicalSize = Size(width, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final ProviderContainer c = ProviderContainer();
  addTearDown(c.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(
      key: ValueKey<String>('$width-$scale'), // fresh State per variant (S124)
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: const LessonRunnerScreen(),
    ),
  ));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: 'w=$width scale=$scale');
}

void _expectGrid() {
  for (int i = 0; i < 4; i++) {
    expect(find.byKey(ValueKey<String>('lesson-opt-$i')), findsOneWidget,
        reason: 'option $i');
  }
}

void main() {
  testWidgets('pick 2×2 grid lays out at 360px', (WidgetTester tester) async {
    await _pump(tester, width: 360);
    _expectGrid();
  });

  testWidgets('pick 2×2 grid lays out at 320px', (WidgetTester tester) async {
    await _pump(tester, width: 320);
    _expectGrid();
  });

  testWidgets('pick 2×2 grid lays out at 360px @200% text scale',
      (WidgetTester tester) async {
    await _pump(tester, width: 360, scale: 2.0);
    _expectGrid();
  });
}
