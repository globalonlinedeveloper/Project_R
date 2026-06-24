/// Learning engine — the pure, deterministic FSRS spaced-repetition scheduler
/// core (one engine for lesson reviews + saved-word flashcards). Build-ahead:
/// scheduling math + tests only; persistence/clock/due-queue wiring lands at
/// go-live. See fsrs.dart for the purity + go-live contract.
library;

export 'fsrs.dart';
