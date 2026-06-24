import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/app/app_flags.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/content/models/models.dart' show ExerciseType;
import 'package:ratel/features/lesson/engine/exercise.dart';
import 'package:ratel/features/lesson/lesson_controller.dart';

// End-to-end "core journey" through the REAL app + router:
//   first-run onboarding -> Learn home -> start the daily lesson ->
//   answer correctly -> lesson complete.
// Runs in the standard `flutter test` gate (headless), complementing the
// emulator perf integration_test. Lesson content is overridden for determinism;
// the live seed batch is exercised by the lesson + onboarding tests.
final _ex = Exercise(
  itemId: 'a',
  type: ExerciseType.mcq,
  prompt: 'I ___ bread.',
  options: const ['eat', 'run', 'book'],
  accepted: const ['eat'],
  whyCard: 'It means to consume food.',
);

void main() {
  setUp(() => onboardingComplete.value = false);
  tearDown(() => onboardingComplete.value = false);

  testWidgets('onboarding -> home -> daily lesson -> complete (R-L2/L3/L4)',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [lessonExercisesProvider.overrideWith((ref) => [_ex])],
        child: const RatelApp(),
      ),
    );
    await tester.pumpAndSettle();

    // --- Onboarding (R-L2) ---
    expect(find.byKey(const Key('onboarding')), findsOneWidget);
    await tester.tap(find.text('Continue')); // language step (English default)
    await tester.pumpAndSettle();
    await tester.tap(find.text('Travel')); // motivation
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Regular - 10 min')); // daily goal
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Your first win!'), findsOneWidget);
    await tester.tap(find.text('eat')); // correct answer off the seed batch
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // --- Learn home (R-L4) ---
    expect(find.byKey(const Key('home-screen')), findsOneWidget);

    // --- Daily lesson: the first daily lesson is always free (R-L3) ---
    await tester.tap(find.text('Start lesson'));
    await tester.pumpAndSettle();
    expect(find.text('I ___ bread.'), findsOneWidget); // overridden content

    await tester.tap(find.text('eat'));
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pump();
    expect(find.text('Correct!'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    // Lesson-complete shows a looping celebration; pumpAndSettle would hang (§11).
    // Advance a fixed slice instead so the idle loop is ignored.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Lesson complete!'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}
