import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/services/learning/saved_words.dart';

/// Bridges the `saved_words` intake engine to the UI (design spec §4.13 "words"
/// stat, §4.2 weak-words practice). Holds the in-memory set of saved keys and
/// exposes the live count. Dedup is REAL (per-course normalize + de-dup via the
/// pure [SavedWordsModel]); persistence to the vocab store is a later step.
class SavedWordsController extends Notifier<int> {
  /// The active course (matches [LearnerController.courseId]).
  static const String courseId = 'es';

  final SavedWordsModel _model = const SavedWordsModel();
  final Set<SavedWordKey> _saved = <SavedWordKey>{};

  @override
  int build() => _saved.length;

  /// Save [rawWord]; returns its disposition. A duplicate (already saved in this
  /// course, after normalization) is a no-op and does not change the count.
  SavedWordDisposition save(String rawWord) {
    final SavedWordDecision decision = _model.classify(
      courseId: courseId,
      rawWord: rawWord,
      alreadySaved: _saved,
    );
    if (decision.createsCard) {
      _saved.add(decision.key);
      state = _saved.length;
    }
    return decision.disposition;
  }

  void reset() {
    _saved.clear();
    state = 0;
  }
}

final savedWordsControllerProvider =
    NotifierProvider<SavedWordsController, int>(SavedWordsController.new);
