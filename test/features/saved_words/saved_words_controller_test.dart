import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/models/enums.dart';
import 'package:ratel/features/saved_words/saved_words_controller.dart';
import 'package:ratel/services/learning/path_serving.dart';
import 'package:ratel/services/learning/saved_words.dart';

void main() {
  StateNotifierProvider<SavedWordsController, SavedWordsState> fresh() =>
      StateNotifierProvider<SavedWordsController, SavedWordsState>(
          (ref) => SavedWordsController());

  test('saving a new word admits it; a duplicate is a no-op', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final p = fresh();
    final d1 = c.read(p.notifier).save('course_es', 'comer');
    expect(d1.createsCard, isTrue);
    expect(c.read(p).count, 1);
    final d2 = c.read(p.notifier).save('course_es', 'comer');
    expect(d2.disposition, SavedWordDisposition.duplicate);
    expect(c.read(p).count, 1);
  });

  test('distinct words accumulate; the meter respects the daily cap', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final p = fresh();
    c.read(p.notifier).save('es', 'comer');
    c.read(p.notifier).save('es', 'beber');
    expect(c.read(p).count, 2);
    final m = c.read(p.notifier).meterToday();
    expect(m.dripNow, 2);
    expect(m.backlogAfter, 0);
  });

  test('reviewTypesFor: recognition at cold-start, productive at B1 review', () {
    final cold =
        reviewTypesFor(band: CefrLevel.a1, phase: SelectionPhase.coldStart);
    final prod =
        reviewTypesFor(band: CefrLevel.b1, phase: SelectionPhase.review);
    expect(cold, isNotEmpty);
    expect(prod, isNotEmpty);
    expect(cold, isNot(equals(prod)));
  });
}
