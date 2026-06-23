import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/mascot/mascot_view.dart';

Widget _host(Widget child, {bool reduceMotion = false}) {
  return MaterialApp(
    theme: RatelTheme.light(),
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (c) => MediaQuery(
            data: MediaQuery.of(c).copyWith(disableAnimations: reduceMotion),
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('reduce-motion -> static paused pose (settles, no loop)',
      (tester) async {
    await tester.pumpWidget(_host(const MascotView(), reduceMotion: true));
    await tester.pumpAndSettle(); // safe: no controller under static tier
    expect(find.byType(MascotView), findsOneWidget);
  });

  testWidgets('full motion -> idle loop (advance a slice, never settle-hang)',
      (tester) async {
    await tester.pumpWidget(_host(const MascotView(mood: MascotMood.cheer)));
    await tester.pump(); // first frame
    await tester.pump(const Duration(milliseconds: 120)); // advance the loop
    expect(find.byType(MascotView), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox()); // unmount -> dispose the controller
  });
}
