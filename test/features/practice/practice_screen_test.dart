import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/practice/practice_screen.dart';

// Dedicated widget coverage for the Practice tab (R-L4). Previously the screen
// was only exercised indirectly via navigation_test + the perf gauntlet.
Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: RatelTheme.light(),
      home: Builder(
        builder: (c) => MediaQuery(
          data: MediaQuery.of(c).copyWith(disableAnimations: true),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders its key, app-bar title and review copy (R-L4)',
      (tester) async {
    await tester.pumpWidget(_wrap(const PracticeScreen()));
    await tester.pump();
    expect(find.byKey(const Key('practice-screen')), findsOneWidget);
    expect(find.text('Practice your mistakes'), findsOneWidget); // app-bar title
    expect(find.text('Smart review'), findsOneWidget);
  });

  testWidgets('lays out on a 360px phone with no overflow (R-N)',
      (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_wrap(const PracticeScreen()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
