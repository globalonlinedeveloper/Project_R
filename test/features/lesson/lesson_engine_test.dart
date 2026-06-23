import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/models/models.dart' show ExerciseType;
import 'package:ratel/features/lesson/engine/exercise.dart';
import 'package:ratel/features/lesson/engine/lesson_engine.dart';
import 'package:ratel/features/lesson/lesson_controller.dart';

Exercise _ex(String id, {String answer = 'eat'}) => Exercise(
      itemId: id,
      type: ExerciseType.mcq,
      prompt: 'Choose: ___',
      options: const ['eat', 'run', 'book'],
      accepted: [answer],
      whyCard: 'why $id',
    );

void main() {
  group('LessonEngine (R-L3 rules)', () {
    test('empty lesson is immediately complete; result is empty', () {
      final e = LessonEngine(const []);
      expect(e.isComplete, isTrue);
      expect(e.result.total, 0);
      expect(e.result.xp, 0);
      expect(e.result.accuracy, 0);
    });

    test('correct on first try -> 10 xp, accuracy 1.0', () {
      final e = LessonEngine([_ex('a')]);
      expect(e.phase, LessonPhase.question);
      final fb = e.submit('eat');
      expect(fb.correct, isTrue);
      expect(fb.revealed, isFalse);
      expect(e.phase, LessonPhase.feedback);
      e.proceed();
      expect(e.isComplete, isTrue);
      expect(e.result.xp, 10);
      expect(e.result.firstTryCorrect, 1);
      expect(e.result.accuracy, 1.0);
    });

    test('grading ignores case and surrounding whitespace', () {
      final e = LessonEngine([_ex('a')]);
      expect(e.submit('  EaT ').correct, isTrue);
    });

    test('wrong answer re-asks at lesson end (not stuck), then resolves', () {
      final e = LessonEngine([_ex('a')]);
      final miss = e.submit('run');
      expect(miss.correct, isFalse);
      expect(miss.revealed, isFalse);
      expect(miss.whyCard, 'why a'); // the free why-card is surfaced on a miss
      e.proceed();
      // a re-ask was queued -> not complete yet
      expect(e.isComplete, isFalse);
      expect(e.phase, LessonPhase.question);
      expect(e.submit('eat').correct, isTrue);
      e.proceed();
      expect(e.isComplete, isTrue);
      expect(e.result.firstTryCorrect, 0); // missed once -> not first-try
      expect(e.result.xp, 5); // resolved-after-miss
      expect(e.result.accuracy, 0.0);
    });

    test('two misses hit the cap -> auto-reveal + force-resolve (change #30)', () {
      final e = LessonEngine([_ex('a')]); // missCap = 2
      e.submit('run'); // miss 1 -> re-ask
      e.proceed();
      final capped = e.submit('book'); // miss 2 == cap
      expect(capped.correct, isFalse);
      expect(capped.revealed, isTrue);
      expect(capped.correctAnswer, 'eat');
      e.proceed();
      expect(e.isComplete, isTrue); // force-resolved, no infinite re-ask
      expect(e.result.xp, 0); // auto-revealed earns nothing
    });

    test('progress: resolvedCount tracks resolved exercises', () {
      final e = LessonEngine([_ex('a'), _ex('b')]);
      expect(e.totalCount, 2);
      expect(e.resolvedCount, 0);
      e.submit('eat');
      e.proceed();
      expect(e.resolvedCount, 1);
    });

    test('accuracy mixes first-try and missed across a multi-item lesson', () {
      final e = LessonEngine([_ex('a'), _ex('b')]);
      e.submit('eat'); // a first-try correct
      e.proceed();
      e.submit('run'); // b miss
      e.proceed();
      e.submit('eat'); // b re-ask correct
      e.proceed();
      expect(e.isComplete, isTrue);
      expect(e.result.firstTryCorrect, 1);
      expect(e.result.total, 2);
      expect(e.result.accuracy, 0.5);
      expect(e.result.xp, 15); // 10 (a) + 5 (b)
    });
  });

  group('LessonController', () {
    test('drives immutable LessonState; result null until complete', () {
      final c = LessonController(LessonEngine([_ex('a')]));
      expect(c.state.phase, LessonPhase.question);
      expect(c.state.result, isNull);
      expect(c.state.total, 1);

      c.submit('eat');
      expect(c.state.phase, LessonPhase.feedback);
      expect(c.state.feedback!.correct, isTrue);
      expect(c.state.result, isNull); // not committed mid-run

      c.proceed();
      expect(c.state.phase, LessonPhase.complete);
      expect(c.state.current, isNull);
      expect(c.state.result!.xp, 10);
      expect(c.state.progress, 1.0);
    });

    test('out-of-phase calls are no-ops (quit-safe)', () {
      final c = LessonController(LessonEngine([_ex('a')]));
      c.proceed(); // no-op in question phase
      expect(c.state.phase, LessonPhase.question);
      c.submit('eat');
      c.submit('eat'); // second submit ignored in feedback phase
      expect(c.state.phase, LessonPhase.feedback);
    });
  });
}
