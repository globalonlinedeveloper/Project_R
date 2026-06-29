import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/services/learning/fsrs.dart';
import 'package:ratel/services/learning/saved_words.dart';

/// Injectable wall-clock seam. The learning ENGINES are deliberately clockless
/// (FSRS / saved-words take elapsed / now IN), so the scheduling LAYER owns the
/// clock here: a fresh review is timestamped against real time, and tests pin
/// it via an override. Defaults to the real [DateTime.now].
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// One saved-word flashcard: its dedup [key], the display [word], an optional
/// authored picture [glyph] (the lesson's correct-answer emoji — the meaning we
/// can honestly reveal), plus its REAL FSRS memory state and scheduled [dueAt].
/// `dueAt == null` ⇒ a brand-new card, due immediately.
class SavedWordCard {
  const SavedWordCard({
    required this.key,
    required this.word,
    required this.addedAt,
    this.glyph,
    this.fsrs = const FsrsCard.newItem(),
    this.dueAt,
    this.lastReviewedAt,
  });

  /// The per-course dedup identity (matches the intake engine's key).
  final SavedWordKey key;

  /// The display surface form the learner saved (e.g. "manzana").
  final String word;

  /// An authored picture-meaning (the lesson's correct emoji, e.g. "🍎"), or
  /// null when the word was saved without one (then review is recall-only).
  final String? glyph;

  /// The REAL FSRS-6 memory state this card carries.
  final FsrsCard fsrs;

  /// When the card next comes due. Null for a never-reviewed card (due now).
  final DateTime? dueAt;

  /// When the card was last graded. Null before the first review.
  final DateTime? lastReviewedAt;

  /// When the card was first saved.
  final DateTime addedAt;

  /// New cards (never reviewed) are due now; reviewed cards are due at [dueAt].
  bool isDue(DateTime now) => dueAt == null || !dueAt!.isAfter(now);

  SavedWordCard copyWith({
    FsrsCard? fsrs,
    DateTime? dueAt,
    DateTime? lastReviewedAt,
  }) =>
      SavedWordCard(
        key: key,
        word: word,
        addedAt: addedAt,
        glyph: glyph,
        fsrs: fsrs ?? this.fsrs,
        dueAt: dueAt ?? this.dueAt,
        lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      );
}

/// Immutable snapshot of the saved-words vocabulary: the [cards] plus derived
/// views. [count] backs the §4.13 "words" stat; [dueCards] / [dueCount] back the
/// Practice-hub review queue (computed against an injected `now`).
class SavedWordsState {
  const SavedWordsState({this.cards = const <SavedWordCard>[]});

  /// Every saved flashcard, in save order.
  final List<SavedWordCard> cards;

  /// The "words" count (real per-course dedup).
  int get count => cards.length;

  /// The cards due for review at [now] (new cards are always due).
  List<SavedWordCard> dueCards(DateTime now) =>
      <SavedWordCard>[for (final SavedWordCard c in cards) if (c.isDue(now)) c];

  /// How many cards are due at [now].
  int dueCount(DateTime now) => dueCards(now).length;

  /// The soonest FUTURE due time (for the caught-up "next review in…" line), or
  /// null when something is already due now or nothing is saved.
  DateTime? nextDueAt(DateTime now) {
    DateTime? soonest;
    for (final SavedWordCard c in cards) {
      final DateTime? d = c.dueAt;
      if (d == null || !d.isAfter(now)) {
        return null; // something is due now → no "next review" countdown
      }
      if (soonest == null || d.isBefore(soonest)) {
        soonest = d;
      }
    }
    return soonest;
  }
}

/// Bridges the `saved_words` intake engine + the FSRS scheduler to the UI
/// (design spec §4.2 Practice hub, §4.13 "words" stat): the saved-words
/// flashcard review queue ([R-G9]) and its FSRS due-scheduling ([R-G5]). Holds
/// the saved cards, the REAL per-course dedup, and the FSRS due queue.
///
/// HONEST (§6 / charter "don't fake depth"): dedup, the FSRS interval and the
/// due-scheduling are REAL engine output; the scheduling state lives in-memory
/// this build (like every R-O1 counter) — the durable cross-restart store
/// (Supabase `user_item_state`) is the flagged go-live plug, NOT faked. The
/// engine stays clockless; this layer owns the injected [clockProvider].
class SavedWordsController extends Notifier<SavedWordsState> {
  /// The active course (matches [LearnerController.courseId]).
  static const String courseId = 'es';

  final SavedWordsModel _model = const SavedWordsModel();
  final Fsrs _fsrs = const Fsrs();

  DateTime _now() => ref.read(clockProvider)();

  @override
  SavedWordsState build() => const SavedWordsState();

  Set<SavedWordKey> get _keys =>
      <SavedWordKey>{for (final SavedWordCard c in state.cards) c.key};

  /// Save [rawWord] (optionally with an authored picture [glyph]); returns its
  /// disposition. A duplicate (already saved in this course, after
  /// normalization) is a no-op and does not create a second card.
  SavedWordDisposition save(String rawWord, {String? glyph}) {
    final SavedWordDecision decision = _model.classify(
      courseId: courseId,
      rawWord: rawWord,
      alreadySaved: _keys,
    );
    if (decision.createsCard) {
      final SavedWordCard card = SavedWordCard(
        key: decision.key,
        word: rawWord.trim(),
        glyph: glyph,
        addedAt: _now(),
      );
      state = SavedWordsState(cards: <SavedWordCard>[...state.cards, card]);
    }
    return decision.disposition;
  }

  /// Fold a graded flashcard [rating] for [key] through the REAL FSRS-6
  /// scheduler and reschedule its next due date (now + the engine's whole-day
  /// interval). No-op if the key is unknown.
  void review(SavedWordKey key, FsrsRating rating) {
    final int idx = state.cards.indexWhere((SavedWordCard c) => c.key == key);
    if (idx < 0) {
      return;
    }
    final DateTime now = _now();
    final SavedWordCard card = state.cards[idx];
    final FsrsReview r = _fsrs.schedule(card.fsrs, rating, _elapsedDays(card, now));
    final SavedWordCard updated = card.copyWith(
      fsrs: r.card,
      lastReviewedAt: now,
      dueAt: now.add(Duration(days: r.intervalDays)),
    );
    final List<SavedWordCard> next = <SavedWordCard>[...state.cards];
    next[idx] = updated;
    state = SavedWordsState(cards: next);
  }

  /// Project (WITHOUT persisting) the whole-day interval [rating] would schedule
  /// for [card] right now — drives the per-grade interval hints on the buttons.
  int projectedIntervalDays(SavedWordCard card, FsrsRating rating) =>
      _fsrs.schedule(card.fsrs, rating, _elapsedDays(card, _now())).intervalDays;

  double _elapsedDays(SavedWordCard card, DateTime now) =>
      card.lastReviewedAt == null
          ? 0.0
          : now.difference(card.lastReviewedAt!).inMicroseconds /
              Duration.microsecondsPerDay;

  void reset() {
    state = const SavedWordsState();
  }
}

final savedWordsControllerProvider =
    NotifierProvider<SavedWordsController, SavedWordsState>(
        SavedWordsController.new);
