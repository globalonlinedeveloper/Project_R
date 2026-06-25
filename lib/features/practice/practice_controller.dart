import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/models/models.dart';
import '../../content/repository/content_providers.dart';
import '../../services/learning/learning.dart';

/// One card in the Practice ("Smart review") queue: a vocab lemma to recall plus
/// its live FSRS scheduler state (R-G5/R-G7). Immutable.
class ReviewCard {
  const ReviewCard({
    required this.id,
    required this.front,
    this.back,
    this.card = const FsrsCard.newItem(),
    this.intervalDays = 0,
  });

  /// Stable id (the vocab id) -- the per-item key the #7 store persists under.
  final String id;

  /// The prompt shown first (the lemma to recall).
  final String front;

  /// Revealed detail (part of speech / gloss); null if none.
  final String? back;

  /// The FSRS memory card for this item.
  final FsrsCard card;

  /// The last whole-day interval the card was scheduled to (0 before review).
  final int intervalDays;

  /// Copy with a rescheduled FSRS card.
  ReviewCard reschedule(FsrsCard next, int days) =>
      ReviewCard(id: id, front: front, back: back, card: next, intervalDays: days);
}

/// Immutable Practice session state: the remaining due [queue], how many cards
/// have been cleared this session ([reviewed]), and whether the current card's
/// answer is [revealed].
class PracticeState {
  const PracticeState({
    this.queue = const <ReviewCard>[],
    this.reviewed = 0,
    this.revealed = false,
  });

  final List<ReviewCard> queue;
  final int reviewed;
  final bool revealed;

  ReviewCard? get current => queue.isEmpty ? null : queue.first;
  bool get isComplete => queue.isEmpty;
  int get dueCount => queue.length;

  PracticeState copyWith({
    List<ReviewCard>? queue,
    int? reviewed,
    bool? revealed,
  }) =>
      PracticeState(
        queue: queue ?? this.queue,
        reviewed: reviewed ?? this.reviewed,
        revealed: revealed ?? this.revealed,
      );
}

/// Drives the Practice review session: pops the due queue, schedules each graded
/// card through the real FSRS engine, and re-queues lapses (Again) so they are
/// seen again before the session ends. Pure in-memory for the local-now slice;
/// the live cross-device due-queue binds through the #7 store once authEnabled.
class PracticeController extends StateNotifier<PracticeState> {
  PracticeController(List<ReviewCard> initial, {Fsrs fsrs = const Fsrs()})
      : _fsrs = fsrs,
        super(PracticeState(queue: List<ReviewCard>.unmodifiable(initial)));

  final Fsrs _fsrs;

  /// Flip the current card to show its answer.
  void reveal() {
    if (!state.revealed && state.current != null) {
      state = state.copyWith(revealed: true);
    }
  }

  /// Grade the current card. Again re-queues it (still due this session);
  /// Hard/Good/Easy schedule it forward and clear it from the session.
  void grade(FsrsRating rating) {
    final ReviewCard? cur = state.current;
    if (cur == null) {
      return;
    }
    final FsrsReview review =
        _fsrs.schedule(cur.card, rating, cur.intervalDays.toDouble());
    final List<ReviewCard> rest = state.queue.skip(1).toList();
    if (rating == FsrsRating.again) {
      state = PracticeState(
        queue: List<ReviewCard>.unmodifiable(<ReviewCard>[
          ...rest,
          cur.reschedule(review.card, review.intervalDays),
        ]),
        reviewed: state.reviewed,
      );
    } else {
      state = PracticeState(
        queue: List<ReviewCard>.unmodifiable(rest),
        reviewed: state.reviewed + 1,
      );
    }
  }
}

/// Build the cold-start review queue from the batch vocab, most-frequent first
/// (a sensible first-session order until live FSRS due-dates exist), capped so a
/// session is finishable.
List<ReviewCard> buildReviewQueue(List<VocabEntry> vocab, {int limit = 20}) {
  final List<VocabEntry> ordered = <VocabEntry>[...vocab]..sort(
      (VocabEntry a, VocabEntry b) =>
          (a.frequencyRank ?? 1 << 30).compareTo(b.frequencyRank ?? 1 << 30));
  return <ReviewCard>[
    for (final VocabEntry v in ordered.take(limit))
      ReviewCard(id: v.vocabId, front: v.lemma, back: v.pos.name),
  ];
}

/// The Practice session controller, seeded from the loaded content batch.
final practiceControllerProvider =
    StateNotifierProvider<PracticeController, PracticeState>((ref) {
  final batch = ref.watch(seedBatchProvider).asData?.value;
  final List<ReviewCard> cards =
      batch == null ? const <ReviewCard>[] : buildReviewQueue(batch.vocab);
  return PracticeController(cards);
});
