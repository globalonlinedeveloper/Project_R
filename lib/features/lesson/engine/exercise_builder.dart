import '../../../content/loader/content_loader.dart';
import '../../../content/models/models.dart';
import 'exercise.dart';

/// Builds the ordered exercise queue for a lesson off a local `ContentBatch`
/// (R-L3). Only on-device-gradable selection types (mcq/cloze) enter this
/// slice. Prompt + why-card come from glosses when present, else a templated
/// fallback (schema frozen — we read rows, never add columns).
List<Exercise> buildLessonExercises(ContentBatch batch, {int max = 8}) {
  final out = <Exercise>[];
  for (final item in batch.items) {
    if (item.exerciseType != ExerciseType.mcq &&
        item.exerciseType != ExerciseType.cloze) {
      continue;
    }
    final accepted = (item.answerSpec?.accepted ?? const <String>[])
        .map((a) => a.trim().toLowerCase())
        .where((a) => a.isNotEmpty)
        .toList();
    if (accepted.isEmpty) continue;
    final answer = accepted.first;
    out.add(Exercise(
      itemId: item.itemId,
      type: item.exerciseType,
      prompt: _prompt(batch, item, answer),
      options: _options(batch, answer),
      accepted: accepted,
      whyCard: _whyCard(batch, item, answer),
    ));
    if (out.length >= max) break;
  }
  return out;
}

String _prompt(ContentBatch batch, Item item, String answer) {
  final g = _glossOf(batch, item.promptRef, ContentKind.prompt);
  if (g != null && g.text.isNotEmpty) return g.text;
  final s = _sentenceWith(batch, answer);
  if (s != null) {
    final idx = s.targetText.toLowerCase().indexOf(answer);
    if (idx >= 0) {
      return s.targetText.replaceRange(idx, idx + answer.length, '___');
    }
    return s.targetText;
  }
  return 'Choose the correct word';
}

List<String> _options(ContentBatch batch, String answer) {
  final pool = <String>{};
  for (final s in batch.sentences) {
    for (final tok in s.tokens) {
      final w = tok.surface.trim().toLowerCase();
      if (w.length >= 3 && w != answer) pool.add(w);
    }
  }
  final opts = <String>{answer, ...pool.take(3)}.toList()..sort();
  return opts;
}

String _whyCard(ContentBatch batch, Item item, String answer) {
  final hint = _glossOf(batch, item.promptRef, ContentKind.hint);
  if (hint != null && hint.text.isNotEmpty) return hint.text;
  final sense = _firstSenseGloss(batch);
  final meaning = sense == null ? '' : ' — ${sense.text}';
  return '"$answer" is the correct answer$meaning.';
}

Gloss? _glossOf(ContentBatch batch, String contentId, ContentKind kind) {
  for (final g in batch.glosses) {
    if (g.contentId == contentId && g.contentKind == kind) return g;
  }
  return null;
}

Gloss? _firstSenseGloss(ContentBatch batch) {
  for (final g in batch.glosses) {
    if (g.contentKind == ContentKind.sense && g.text.isNotEmpty) return g;
  }
  return null;
}

Sentence? _sentenceWith(ContentBatch batch, String answer) {
  for (final s in batch.sentences) {
    if (s.targetText.toLowerCase().contains(answer)) return s;
  }
  return batch.sentences.isEmpty ? null : batch.sentences.first;
}
