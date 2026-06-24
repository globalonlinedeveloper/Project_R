/// Learning engine — pure, deterministic build-ahead cores: the FSRS
/// spaced-repetition scheduler (fsrs.dart) + the online θ ability model
/// (ability.dart). Logic + tests only; persistence/clock/due-queue wiring
/// lands at go-live. See each file for its purity + go-live contract.
library;

export 'ability.dart';
export 'fsrs.dart';
