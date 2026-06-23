import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/content/models/models.dart' show ExerciseType;
import 'package:ratel/core/design_system/design_system.dart';
import 'package:ratel/features/lesson/engine/exercise.dart';
import 'package:ratel/features/lesson/lesson_controller.dart';
import 'package:ratel/features/lesson/lesson_screen.dart';

final _exEat = Exercise(
  itemId: 'a',
  type: ExerciseType.mcq,
  prompt: 'I ___ bread.',
  options: const ['eat', 'run', 'book'],
  accepted: const ['eat'],
  whyCard: 'It means to consume food.',
);

// Isolated harness: override the exercises (no asset load), force reduce-motion
// so the one-shot celebration + count-up are static (no pumpAndSettle hang), and
// inject onClose so quitting needs no real router.
Widget _harness(List<Exercise> exercises, {VoidCallback? onClose}) {
  return ProviderScope(
    overrides: [lessonExercisesProvider.overrideWith((ref) => exercises)],
    child: MaterialApp(
      theme: RatelTheme.light(),
      home: Builder(
        builder: (c) => MediaQuery(
          data: MediaQuery.of(c).copyWith(disableAnimations: true),
          child: LessonScreen(onClose: onClose),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the first exercise off the loaded batch', (tester) async {
    await tester.pumpWidget(_harness([_exEat]));
    await tester.pump(); // resolve the exercises future -> data
    expect(find.text('I ___ bread.'), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    expect(find.text('eat'), findsOneWidget); // an option
  });

  testWidgets('select + Check correct -> feedback -> Continue -> complete',
      (tester) async {
    await tester.pumpWidget(_harness([_exEat]));
    await tester.pump();

    await tester.tap(find.text('eat'));
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pump();

    expect(find.text('Correct!'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Lesson complete!'), findsOneWidget);
    expect(find.textContaining('XP'), findsOneWidget); // +10 XP
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('a miss shows the free why-card and re-asks (not complete)',
      (tester) async {
    await tester.pumpWidget(_harness([_exEat]));
    await tester.pump();

    await tester.tap(find.text('run')); // wrong
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pump();

    expect(find.text('Not quite'), findsOneWidget);
    expect(find.textContaining('consume food'), findsOneWidget); // why-card
    await tester.tap(find.text('Continue'));
    await tester.pump();

    // re-asked: back in the question phase, lesson not complete
    expect(find.text('Check'), findsOneWidget);
    expect(find.text('Lesson complete!'), findsNothing);
  });

  testWidgets('quit (X) confirms and discards via onClose', (tester) async {
    var closed = false;
    await tester.pumpWidget(_harness([_exEat], onClose: () => closed = true));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle(); // dialog in (finite transition)
    expect(find.text('Quit lesson?'), findsOneWidget);

    await tester.tap(find.text('Quit'));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
  });
}
