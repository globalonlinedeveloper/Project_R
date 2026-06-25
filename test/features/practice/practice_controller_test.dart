import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/models/models.dart';
import 'package:ratel/features/practice/practice_controller.dart';
import 'package:ratel/services/learning/learning.dart';

void main() {
  List<ReviewCard> cards(int n) => <ReviewCard>[
        for (int i = 0; i < n; i++) ReviewCard(id: 'v$i', front: 'word$i'),
      ];
  StateNotifierProvider<PracticeController, PracticeState> providerFor(int n) =>
      StateNotifierProvider<PracticeController, PracticeState>(
          (ref) => PracticeController(cards(n)));

  test('starts with the full due queue, nothing reviewed', () {
    final p = providerFor(3);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(p).dueCount, 3);
    expect(c.read(p).reviewed, 0);
    expect(c.read(p).isComplete, isFalse);
    expect(c.read(p).current!.id, 'v0');
  });

  test('Good clears the card, advances, and resets revealed', () {
    final p = providerFor(2);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(p.notifier).reveal();
    expect(c.read(p).revealed, isTrue);
    c.read(p.notifier).grade(FsrsRating.good);
    expect(c.read(p).reviewed, 1);
    expect(c.read(p).dueCount, 1);
    expect(c.read(p).current!.id, 'v1');
    expect(c.read(p).revealed, isFalse);
  });

  test('Again re-queues the card (still due this session)', () {
    final p = providerFor(2);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(p.notifier).grade(FsrsRating.again);
    expect(c.read(p).reviewed, 0);
    expect(c.read(p).dueCount, 2);
    expect(c.read(p).current!.id, 'v1');
  });

  test('completes when every card is cleared', () {
    final p = providerFor(2);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(p.notifier).grade(FsrsRating.good);
    c.read(p.notifier).grade(FsrsRating.easy);
    expect(c.read(p).isComplete, isTrue);
    expect(c.read(p).reviewed, 2);
  });

  test('buildReviewQueue is empty for empty vocab', () {
    expect(buildReviewQueue(const <VocabEntry>[]), isEmpty);
  });
}
