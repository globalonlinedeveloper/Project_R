import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/core/design_system/design_system.dart';

Widget _host(Widget child, {bool reduceMotion = false}) {
  return MaterialApp(
    theme: RatelTheme.light(),
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
            child: child,
          ),
        ),
      ),
    ),
  );
}

Finder _celebrationPaint() => find.descendant(
      of: find.byType(RatelCelebration),
      matching: find.byType(CustomPaint),
    );

void main() {
  group('RatelButton (R-L17 states + R-K8 target)', () {
    testWidgets('renders label and fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(
          RatelButton(label: 'Continue', onPressed: () => taps++)));
      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.byType(RatelButton));
      expect(taps, 1);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
          _host(const RatelButton(label: 'Off', onPressed: null)));
      final FilledButton b = tester.widget(find.byType(FilledButton));
      expect(b.onPressed, isNull);
    });

    testWidgets('loading shows a spinner and blocks taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(
          RatelButton(label: 'Go', loading: true, onPressed: () => taps++)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(RatelButton), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('meets the 48dp minimum tap target (R-K8)', (tester) async {
      await tester.pumpWidget(
          _host(RatelButton(label: 'Tap', onPressed: () {})));
      expect(tester.getSize(find.byType(FilledButton)).height,
          greaterThanOrEqualTo(48.0));
    });
  });

  group('Motion widgets honor MotionTier (R-N7)', () {
    testWidgets('CountUp jumps to final value under reduce-motion', (tester) async {
      await tester.pumpWidget(
          _host(const RatelCountUp(value: 42), reduceMotion: true));
      await tester.pump();
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('CountUp animates then reaches final value', (tester) async {
      await tester.pumpWidget(_host(const RatelCountUp(value: 42)));
      await tester.pumpAndSettle();
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('Celebration paints no particles under reduce-motion', (tester) async {
      await tester.pumpWidget(_host(
          const SizedBox(
              width: 200,
              height: 200,
              child: RatelCelebration(level: CelebrationLevel.lessonComplete)),
          reduceMotion: true));
      await tester.pump();
      expect(_celebrationPaint(), findsNothing);
    });

    testWidgets('Celebration paints particles when motion allowed', (tester) async {
      await tester.pumpWidget(_host(const SizedBox(
          width: 200,
          height: 200,
          child: RatelCelebration(level: CelebrationLevel.flourish))));
      await tester.pump();
      expect(_celebrationPaint(), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('ProgressRing builds at a clamped value', (tester) async {
      await tester.pumpWidget(
          _host(const RatelProgressRing(progress: 0.6), reduceMotion: true));
      await tester.pump();
      expect(find.byType(RatelProgressRing), findsOneWidget);
    });
  });
}
