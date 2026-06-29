import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/app/router.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/lesson/lesson_runner_screen.dart';

// The §4.7 lesson runner — REAL CAT/IRT/θ selection + ability fold over a
// hand-authored bank; finishing awards real XP + saves real words. No mockup
// numbers, no faked engine output. [R-L3 · R-D13 · R-G2 · R-I1 · R-G9 · R-L19]

/// Pump the runner alone on a TALL surface so the bottom CTA / feedback panel
/// is laid out on-screen (no below-the-fold tap misses).
Future<void> _pump(WidgetTester tester, ProviderContainer c) async {
  tester.view.physicalSize = const Size(440, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: const MaterialApp(home: LessonRunnerScreen()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  test('/daily-quiz is removed from the coming-soon stubs (route promoted)', () {
    expect(
      kComingSoonRoutes.any((ComingSoonRoute r) => r.path == '/daily-quiz'),
      isFalse,
    );
  });

  testWidgets('Home → Start lesson opens the REAL runner, not the stub',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('home-active-node')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('screen-lesson')), findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);
    // A real exercise surface (progress pill + an adaptive option card).
    expect(find.byType(RatelProgressBar), findsWidgets);
    expect(find.byType(RatelOptionCard), findsWidgets);
  });

  testWidgets('a correct pick shows the green "Correct!" feedback',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    await _pump(tester, c);

    // First served item is the lowest-b pick item; option 0 is correct.
    await tester.tap(find.byKey(const ValueKey<String>('lesson-opt-0')));
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(find.text('✓ Correct!'), findsOneWidget);
    expect(find.text('✕ Not quite'), findsNothing);
  });

  testWidgets('a wrong pick shows the coral "Not quite" + reveals the answer',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    await _pump(tester, c);

    await tester.tap(find.byKey(const ValueKey<String>('lesson-opt-1')));
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(find.text('✕ Not quite'), findsOneWidget);
    expect(find.textContaining('Answer:'), findsOneWidget);
  });

  testWidgets('completing the lesson records REAL engine state (XP / lessons / words)',
      (WidgetTester tester) async {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    await _pump(tester, c);

    // Walk the whole adaptive lesson: answer current (correct for pick / any
    // tile for word-bank) → Check → Continue, until the complete screen.
    for (int i = 0;
        i < 14 && find.text('Lesson complete!').evaluate().isEmpty;
        i++) {
      final Finder pick = find.byType(RatelOptionCard);
      if (pick.evaluate().isNotEmpty) {
        await tester.tap(pick.first); // index 0 = correct
      } else {
        await tester.tap(find.byType(RatelWordTile).first);
      }
      await tester.pump();
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Lesson complete!'), findsOneWidget);
    // REAL counters moved through the engine — not the mockup's 88 / 412.
    final LearnerSnapshot snap = c.read(learnerControllerProvider);
    expect(snap.lessonsCompleted, 1);
    expect(snap.xpTotal, 20);
    expect(c.read(savedWordsControllerProvider), greaterThan(0));
  });
}
