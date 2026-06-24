/// Learning engine — pure, deterministic build-ahead cores: the FSRS
/// spaced-repetition scheduler (fsrs.dart), the online θ ability model
/// (ability.dart), the cold-start CEFR-anchor difficulty/ability priors
/// (cold_start.dart), the IRT 1PL/2PL/3PL recall-probability family (irt.dart),
/// the CAT placement-test selection + EAP estimate (cat.dart), and the
/// saved-words intake dedup + daily-cap metering (saved_words.dart). Logic +
/// tests only; persistence/clock/due-queue/calibration/item-bank/lemmatizer
/// wiring lands at go-live. See each file for its purity + go-live contract.
library;

export 'ability.dart';
export 'cat.dart';
export 'cold_start.dart';
export 'fsrs.dart';
export 'irt.dart';
export 'saved_words.dart';
