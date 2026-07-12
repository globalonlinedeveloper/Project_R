/// Learning engine — pure, deterministic build-ahead cores: the FSRS
/// spaced-repetition scheduler (fsrs.dart), the online θ ability model
/// (ability.dart), the cold-start CEFR-anchor difficulty/ability priors
/// (cold_start.dart), the IRT 1PL/2PL/3PL recall-probability family (irt.dart),
/// the batch IRT item re-calibration — the staged, thin-data-safe 1PL difficulty
/// + 2PL discrimination + mcq 3PL guessing re-fit from the append-only ReviewLog
/// (calibration.dart), the CAT
/// placement-test selection + EAP estimate (cat.dart), the learner-state entity
/// value-objects + append-only / derive-by-compose transitions
/// (learner_state.dart), the saved-words intake dedup + daily-cap metering
/// (saved_words.dart), and the path-serving encoding-phase + productive-retrieval
/// review-type selection rules (path_serving.dart). Logic + tests only;
/// persistence/clock/due-queue/calibration-scheduling+DB/item-bank/lemmatizer/
/// macro-spine/θ-source/partitioning wiring lands at go-live. See each file for
/// its purity + go-live contract.
library;

export 'ability.dart';
export 'calibration.dart';
export 'calibration_runner.dart';
export 'cat.dart';
export 'cold_start.dart';
export 'fsrs.dart';
export 'irt.dart';
export 'learner_state.dart';
export 'path_serving.dart';
export 'review_log_sink.dart';
export 'saved_words.dart';
export 'saved_words_store.dart';
export 'streak.dart';
