import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/content/models/enums.dart' show FsrsState;
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/learning/fsrs.dart';
import 'package:ratel/services/learning/saved_words.dart';

/// Injectable wall-clock seam. The learning ENGINES are deliberately clockless
/// (FSRS / saved-words take elapsed / now IN), so the scheduling LAYER owns the
/// clock here: a fresh review is timestamped against real time, and tests pin
/// it via an override. Defaults to the real [DateTime.now].
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// One saved-word flashcard: its dedup [key], the display [word], an optional
/// authored picture [glyph] (the lesson's correct-answer emoji, the meaning we
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
/// due-scheduling are REAL engine output. When a real `auth.uid()` session
/// exists, the FSRS scheduler state is REHYDRATED from + WRITTEN THROUGH to the
/// Supabase `user_item_state` table (R-G6), so the review schedule survives a
/// relaunch; a guest (`uid == null`) keeps the byte-identical in-memory queue.
/// That table is a pure FSRS scheduler-state store (no surface-form / glyph
/// columns), so a rehydrated card reviews recall-only off its normalized lemma —
/// the durable memory state + due date are what persist. The engine stays
/// clockless; this layer owns the injected [clockProvider].
class SavedWordsController extends Notifier<SavedWordsState> {
  /// The active course (matches [LearnerController.courseId]).
  static const String courseId = 'es';

  /// `user_item_state.item_id` prefix namespacing saved-word cards apart from
  /// lesson-item FSRS rows (`sw:<courseId>:<normalizedLemma>`).
  static const String itemIdPrefix = 'sw:';

  final SavedWordsModel _model = const SavedWordsModel();
  final Fsrs _fsrs = const Fsrs();

  bool _hydrated = false;
  bool _disposed = false;
  bool _saving = false;
  bool _dirty = false;

  DateTime _now() => ref.read(clockProvider)();

  @override
  SavedWordsState build() {
    ref.onDispose(() => _disposed = true);
    _hydrate(); // fire-and-forget; no-op for a guest / once hydrated
    return const SavedWordsState();
  }

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
      _persist();
    }
    return decision.disposition;
  }

  /// Fold a graded flashcard [rating] for [key] through the REAL FSRS-6
  /// scheduler and reschedule its next due date (now + the engine's whole-day
  /// interval), then persist. No-op if the key is unknown.
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
    _persist();
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

  // ── Durable persistence (R-G6 / R-M3) ────────────────────────────────────

  /// FSRS lifecycle ↔ the stored `fsrs_state` enum wire value (matches the
  /// schema `@JsonValue`s, so a row drops straight into `user_item_state`).
  static const Map<FsrsState, String> _stateToWire = <FsrsState, String>{
    FsrsState.new_: 'new',
    FsrsState.learning: 'learning',
    FsrsState.review: 'review',
    FsrsState.relearning: 'relearning',
  };

  static FsrsState _stateFromWire(Object? wire) {
    switch (wire) {
      case 'learning':
        return FsrsState.learning;
      case 'review':
        return FsrsState.review;
      case 'relearning':
        return FsrsState.relearning;
      default:
        return FsrsState.new_;
    }
  }

  String _itemId(SavedWordKey key) =>
      '$itemIdPrefix${key.courseId}:${key.normalizedLemma}';

  /// The `user_item_state` seam row for [card] (the store stamps `user_id`).
  Map<String, Object?> _itemRow(SavedWordCard card) {
    final DateTime due = (card.dueAt ?? _now()).toUtc();
    final int scheduled =
        (card.lastReviewedAt != null && card.dueAt != null)
            ? card.dueAt!.difference(card.lastReviewedAt!).inDays
            : 0;
    return <String, Object?>{
      'item_id': _itemId(card.key),
      'stability': card.fsrs.stability,
      'difficulty': card.fsrs.difficulty,
      'due': due.toIso8601String(),
      'last_review': card.lastReviewedAt?.toUtc().toIso8601String(),
      'reps': card.fsrs.reps,
      'lapses': card.fsrs.lapses,
      'scheduled_days': scheduled < 0 ? 0 : scheduled,
      'state': _stateToWire[card.fsrs.state],
    };
  }

  SavedWordCard? _cardFromRow(Map<Object?, Object?> row) {
    final Object? id = row['item_id'];
    if (id is! String || !id.startsWith(itemIdPrefix)) {
      return null; // not a saved-word row (e.g. a lesson item) — ignore
    }
    final List<String> parts = id.substring(itemIdPrefix.length).split(':');
    if (parts.length < 2) {
      return null;
    }
    final String course = parts.first;
    final String lemma = parts.sublist(1).join(':');
    final FsrsCard fsrs = FsrsCard(
      state: _stateFromWire(row['state']),
      stability: (row['stability'] as num?)?.toDouble(),
      difficulty: (row['difficulty'] as num?)?.toDouble(),
      reps: (row['reps'] as num?)?.toInt() ?? 0,
      lapses: (row['lapses'] as num?)?.toInt() ?? 0,
    );
    return SavedWordCard(
      key: SavedWordKey(courseId: course, normalizedLemma: lemma),
      word: lemma,
      addedAt: _parseDate(row['created_at']) ?? _now(),
      fsrs: fsrs,
      dueAt: _parseDate(row['due']),
      lastReviewedAt: _parseDate(row['last_review']),
    );
  }

  static DateTime? _parseDate(Object? raw) =>
      raw is String ? DateTime.tryParse(raw)?.toLocal() : null;

  /// Rehydrate saved-word cards from the learner's `user_item_state` rows.
  /// No-op for a guest (`uid == null`) or once hydrated, and a load failure
  /// never breaks boot — so the flag-off path is byte-identical.
  Future<void> _hydrate() async {
    if (_hydrated) return;
    final String? uid = ref.read(identityProvider).uid;
    if (uid == null) return;
    _hydrated = true;
    final LearnerStateStore store = ref.read(learnerStateStoreProvider);
    try {
      final Map<String, Object?> data = await store.load(uid);
      if (_disposed) return;
      final Object? items = data['items'];
      if (items is! List) return;
      final List<SavedWordCard> cards = <SavedWordCard>[];
      for (final Object? row in items) {
        if (row is Map) {
          final SavedWordCard? card = _cardFromRow(row.cast<Object?, Object?>());
          if (card != null) cards.add(card);
        }
      }
      if (cards.isNotEmpty) {
        state = SavedWordsState(cards: cards);
      }
    } catch (_) {
      // never break boot on a load failure — keep the empty queue
    }
  }

  /// Mark dirty and (debounced) write all cards through. No-op for a guest.
  void _persist() {
    if (ref.read(identityProvider).uid == null) return;
    _dirty = true;
    _drain();
  }

  Future<void> _drain() async {
    if (_saving) return;
    _saving = true;
    final Duration debounce = ref.read(persistDebounceProvider);
    try {
      while (_dirty && !_disposed) {
        _dirty = false;
        await Future<void>.delayed(debounce);
        if (_disposed) return;
        final String? uid = ref.read(identityProvider).uid;
        if (uid == null) return;
        final LearnerStateStore store = ref.read(learnerStateStoreProvider);
        final List<Object?> rows = <Object?>[
          for (final SavedWordCard c in state.cards) _itemRow(c),
        ];
        if (rows.isEmpty) continue;
        try {
          await store.save(uid, <String, Object?>{'items': rows});
        } catch (_) {
          // best-effort: a save failure must never break the session
        }
      }
    } finally {
      _saving = false;
    }
  }
}

final savedWordsControllerProvider =
    NotifierProvider<SavedWordsController, SavedWordsState>(
        SavedWordsController.new);
