/// Learning engine — pure, deterministic build-ahead cores: the FSRS
/// spaced-repetition scheduler (fsrs.dart), the online θ ability model
/// (ability.dart), the cold-start CEFR-anchor difficulty/ability priors
/// (cold_start.dart), and the IRT 1PL/2PL/3PL recall-probability family
/// (irt.dart). Logic + tests only; persistence/clock/due-queue/calibration
/// wiring lands at go-live. See each file for its purity + go-live contract.
library;

export 'ability.dart';
export 'cold_start.dart';
export 'fsrs.dart';
export 'irt.dart';
