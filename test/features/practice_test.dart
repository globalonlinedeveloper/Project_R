import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/app_providers.dart';
import 'package:ratel/app/ratel_app.dart';
import 'package:ratel/features/practice/practice_hub_screen.dart';
import 'package:ratel/services/learning/fsrs.dart' show FsrsRating;

// Practice hub (§4.2) — the saved-words flashcard review wired to the REAL
// FSRS-6 scheduler + the per-course dedup intake. No mockup numbers, no faked
// scheduling. [R-G5 FSRS due-scheduling · R-G9 saved-words → flashcards]

/// A pinned wall clock so FSRS due-scheduling is deterministic in tests.
final DateTime _t0 = DateTime(2026, 6, 29, 12, 0, 0);

ProviderContainer _container() => ProviderContainer(
      overrides: <Override>[clockProvider.overrideWithValue(() => _t0)],
    );

/// Pump the Practice hub alone on a TALL surface so the whole lazy ListView is
/// laid out (no below-the-fold finder/tap misses — S37/S39 lazy-list gotcha).
Future<void> _pumpTall(WidgetTester tester, ProviderContainer c) async {
  tester.view.physicalSize = const Size(440, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: const MaterialApp(home: PracticeHubScreen()),
  ));
  await tester.pump();
}

void main() {
  testWidgets(
      'Library → Practice hub opens the REAL screen (route promoted, not a stub)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RatelApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();

    final Finder row = find.text('Practice hub');
    await tester.scrollUntilVisible(row, 150,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(row);
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('screen-practice')), findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);
  });

  testWidgets('empty state is honest — no saved words, no fabricated numbers',
      (WidgetTester tester) async {
    final ProviderContainer c = _container();
    addTearDown(c.dispose);
    await _pumpTall(tester, c);

    expect(find.text('No saved words yet'), findsOneWidget);
    expect(find.text('Start a lesson'), findsOneWidget);
    // Never the mockup's saved-word stats.
    expect(find.textContaining('412'), findsNothing);
    expect(find.text('Review 1 word'), findsNothing);
  });

  testWidgets('saved words surface a REAL due queue and flashcard review',
      (WidgetTester tester) async {
    final ProviderContainer c = _container();
    addTearDown(c.dispose);
    // REAL intake — the only path that creates cards (dedup engine).
    c.read(savedWordsControllerProvider.notifier).save('manzana', glyph: '🍎');
    c.read(savedWordsControllerProvider.notifier).save('gato', glyph: '🐱');
    await _pumpTall(tester, c);

    // Overview reflects the real count + due queue (both new ⇒ due now).
    expect(find.text('2 saved words'), findsOneWidget);
    expect(find.text('Review 2 words'), findsOneWidget);

    await tester.tap(find.text('Review 2 words'));
    await tester.pump();
    expect(find.text('Word 1 of 2'), findsOneWidget);

    // Reveal shows the authored picture (emoji), never an invented translation.
    await tester.tap(find.text('Show answer'));
    await tester.pump();
    expect(find.textContaining('Good · '), findsOneWidget); // real FSRS interval

    await tester.tap(find.textContaining('Good · '));
    await tester.pump();
    expect(find.text('Word 2 of 2'), findsOneWidget);

    await tester.tap(find.text('Show answer'));
    await tester.pump();
    await tester.tap(find.textContaining('Easy · '));
    await tester.pump();

    expect(find.text('Review complete'), findsOneWidget);
    expect(find.textContaining('reviewed 2 words'), findsOneWidget);
  });

  test('FSRS grading reschedules a word OUT of the due queue (real engine)', () {
    final ProviderContainer c = _container();
    addTearDown(c.dispose);
    final SavedWordsController ctrl =
        c.read(savedWordsControllerProvider.notifier);

    ctrl.save('manzana', glyph: '🍎');
    // Dedup is real — re-saving the same lemma is a no-op.
    ctrl.save('  Manzana  ');
    SavedWordsState st = c.read(savedWordsControllerProvider);
    expect(st.count, 1);
    expect(st.dueCount(_t0), 1); // a brand-new card is due now
    expect(st.nextDueAt(_t0), isNull); // something is due now

    ctrl.review(st.cards.single.key, FsrsRating.good);

    st = c.read(savedWordsControllerProvider);
    expect(st.count, 1); // review never creates/removes a card
    expect(st.dueCount(_t0), 0); // rescheduled into the future by FSRS
    expect(st.cards.single.dueAt, isNotNull);
    expect(st.cards.single.dueAt!.isAfter(_t0), isTrue);
    expect(st.nextDueAt(_t0), isNotNull); // a real future due date
    // The projected interval the engine would schedule is a real whole day ≥ 1.
    expect(ctrl.projectedIntervalDays(st.cards.single, FsrsRating.good),
        greaterThanOrEqualTo(1));
  });
}
