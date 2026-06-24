// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// SAVEDWORDS-1 [R-G9] tests for the pure saved-words intake core. Properties
// proven: the dedup key normalizes lemma + case + surrounding whitespace and is
// scoped per course (re-saving a word in any case is a no-op); a brand-new word
// is always admitted (saving is never blocked), feeding FSRS only; a word whose
// key matches the calibrated catalog is promoted and DOES feed θ; dedup wins
// over promote; a bulk save-all-unknown dedupes within the batch so it creates
// one card per lemma; the daily-intake meter drips min(remaining-cap, backlog)
// and backlogs the rest, with the cap injected (raise/lower changes the drip,
// 0 pauses); the lemmatizer is an injected seam; everything is deterministic.
// No clock, no I/O, no randomness.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

/// A toy stemmer proving the injected lemmatizer seam is actually used: it
/// collapses a few inflections to a shared lemma so "running"/"ran"/"runs"
/// dedupe to "run". NOT a real lemmatizer — just enough to prove the seam.
String _toyStem(String raw) {
  const lemmas = <String, String>{
    'running': 'run',
    'ran': 'run',
    'runs': 'run',
  };
  return lemmas[raw.toLowerCase()] ?? raw;
}

void main() {
  const SavedWordsModel model = SavedWordsModel();

  group('normalization + dedup key', () {
    test('the same lemma in any case shares one key', () {
      final lower = model.keyFor('es', 'hola');
      expect(model.keyFor('es', 'Hola'), lower);
      expect(model.keyFor('es', 'HOLA'), lower);
      expect(model.keyFor('es', 'hOlA'), lower);
    });

    test('surrounding whitespace is ignored', () {
      expect(model.keyFor('es', '  hola  '), model.keyFor('es', 'hola'));
      expect(model.normalize('  Hola\t'), 'hola');
    });

    test('different lemmas yield different keys', () {
      expect(model.keyFor('es', 'hola') == model.keyFor('es', 'adios'), isFalse);
    });

    test('dedup is scoped per course', () {
      expect(model.keyFor('es', 'hola') == model.keyFor('fr', 'hola'), isFalse);
    });

    test('keys have value-equality + hashCode (usable in a Set)', () {
      final set = <SavedWordKey>{model.keyFor('es', 'hola')};
      expect(set.contains(model.keyFor('es', 'HOLA')), isTrue);
      expect(set.contains(model.keyFor('es', 'adios')), isFalse);
      expect(model.keyFor('es', 'Hola').hashCode,
          model.keyFor('es', 'hola').hashCode);
    });
  });

  group('classify — dedup-and-promote', () {
    test('a brand-new word is admitted (FSRS-only, never θ)', () {
      final d = model.classify(
        courseId: 'es',
        rawWord: 'hola',
        alreadySaved: const <SavedWordKey>{},
      );
      expect(d.disposition, SavedWordDisposition.admitted);
      expect(d.createsCard, isTrue);
      expect(d.feedsTheta, isFalse);
      expect(d.key, model.keyFor('es', 'hola'));
    });

    test('re-saving is a case-insensitive no-op', () {
      final saved = <SavedWordKey>{model.keyFor('es', 'hola')};
      final d = model.classify(
        courseId: 'es',
        rawWord: 'HOLA',
        alreadySaved: saved,
      );
      expect(d.disposition, SavedWordDisposition.duplicate);
      expect(d.createsCard, isFalse);
      expect(d.feedsTheta, isFalse);
    });

    test('a calibrated-catalog match is promoted and feeds θ', () {
      final catalog = <SavedWordKey>{model.keyFor('es', 'correr')};
      final d = model.classify(
        courseId: 'es',
        rawWord: 'Correr',
        alreadySaved: const <SavedWordKey>{},
        calibratedCatalog: catalog,
      );
      expect(d.disposition, SavedWordDisposition.promoted);
      expect(d.createsCard, isTrue);
      expect(d.feedsTheta, isTrue);
    });

    test('dedup wins over promote (already saved beats a catalog match)', () {
      final key = model.keyFor('es', 'hola');
      final d = model.classify(
        courseId: 'es',
        rawWord: 'Hola',
        alreadySaved: <SavedWordKey>{key},
        calibratedCatalog: <SavedWordKey>{key},
      );
      expect(d.disposition, SavedWordDisposition.duplicate);
      expect(d.feedsTheta, isFalse);
    });

    test('promote is per-course (a catalog key in one course does not leak)', () {
      final catalog = <SavedWordKey>{model.keyFor('es', 'correr')};
      final inEs = model.classify(
        courseId: 'es',
        rawWord: 'correr',
        alreadySaved: const <SavedWordKey>{},
        calibratedCatalog: catalog,
      );
      final inFr = model.classify(
        courseId: 'fr',
        rawWord: 'correr',
        alreadySaved: const <SavedWordKey>{},
        calibratedCatalog: catalog,
      );
      expect(inEs.disposition, SavedWordDisposition.promoted);
      expect(inFr.disposition, SavedWordDisposition.admitted);
    });
  });

  group('classifyAll — bulk save-all-unknown', () {
    test('two different new lemmas both admit', () {
      final out = model.classifyAll(
        courseId: 'es',
        rawWords: const ['hola', 'adios'],
        alreadySaved: const <SavedWordKey>{},
      );
      expect(out.length, 2);
      expect(out.every((d) => d.createsCard), isTrue);
      expect(out.map((d) => d.disposition),
          everyElement(SavedWordDisposition.admitted));
    });

    test('within-batch duplicates collapse to a single card', () {
      final out = model.classifyAll(
        courseId: 'es',
        rawWords: const ['hola', 'HOLA', '  hola '],
        alreadySaved: const <SavedWordKey>{},
      );
      expect(out.map((d) => d.disposition).toList(), [
        SavedWordDisposition.admitted,
        SavedWordDisposition.duplicate,
        SavedWordDisposition.duplicate,
      ]);
      expect(out.where((d) => d.createsCard).length, 1);
    });

    test('a batch word matching the catalog promotes once', () {
      final out = model.classifyAll(
        courseId: 'es',
        rawWords: const ['hola', 'hola'],
        alreadySaved: const <SavedWordKey>{},
        calibratedCatalog: <SavedWordKey>{model.keyFor('es', 'hola')},
      );
      expect(out.first.disposition, SavedWordDisposition.promoted);
      expect(out.last.disposition, SavedWordDisposition.duplicate);
    });

    test('already-saved words in a batch are no-ops, new ones admit', () {
      final out = model.classifyAll(
        courseId: 'es',
        rawWords: const ['hola', 'nuevo'],
        alreadySaved: <SavedWordKey>{model.keyFor('es', 'hola')},
      );
      expect(out.map((d) => d.disposition).toList(), [
        SavedWordDisposition.duplicate,
        SavedWordDisposition.admitted,
      ]);
    });

    test('order is preserved and length matches the input', () {
      final out = model.classifyAll(
        courseId: 'es',
        rawWords: const ['uno', 'dos', 'tres'],
        alreadySaved: const <SavedWordKey>{},
      );
      expect(out.map((d) => d.key.normalizedLemma).toList(), ['uno', 'dos', 'tres']);
    });
  });

  group('daily-intake meter', () {
    test('admits up to the default ~20/day and backlogs the rest', () {
      final m = model.meter(admittedToday: 0, backlog: 50);
      expect(m.dripNow, 20);
      expect(m.backlogAfter, 30);
    });

    test('a partial day admits only the remaining capacity', () {
      final m = model.meter(admittedToday: 15, backlog: 50);
      expect(m.dripNow, 5);
      expect(m.backlogAfter, 45);
    });

    test('at or over the cap drips nothing', () {
      expect(model.meter(admittedToday: 20, backlog: 9).dripNow, 0);
      final over = model.meter(admittedToday: 25, backlog: 9);
      expect(over.dripNow, 0);
      expect(over.backlogAfter, 9);
    });

    test('an empty backlog drips nothing', () {
      final m = model.meter(admittedToday: 0, backlog: 0);
      expect(m.dripNow, 0);
      expect(m.backlogAfter, 0);
    });

    test('a backlog smaller than the remaining capacity all drips in', () {
      final m = model.meter(admittedToday: 0, backlog: 3);
      expect(m.dripNow, 3);
      expect(m.backlogAfter, 0);
    });

    test('a raised cap drips more, a lowered cap drips less (cap is injected)', () {
      final raised = model.meter(
          admittedToday: 0, backlog: 50, config: const IntakeConfig(dailyCap: 50));
      expect(raised.dripNow, 50);
      expect(raised.backlogAfter, 0);
      final lowered = model.meter(
          admittedToday: 0, backlog: 50, config: const IntakeConfig(dailyCap: 5));
      expect(lowered.dripNow, 5);
      expect(lowered.backlogAfter, 45);
    });

    test('a cap of 0 pauses intake (backlog holds)', () {
      final m = model.meter(
          admittedToday: 0, backlog: 50, config: const IntakeConfig(dailyCap: 0));
      expect(m.dripNow, 0);
      expect(m.backlogAfter, 50);
    });

    test('drip == min(max(0,cap-admitted), backlog) across a sweep', () {
      const caps = [0, 5, 20, 50];
      for (final cap in caps) {
        final config = IntakeConfig(dailyCap: cap);
        for (var admitted = 0; admitted <= 25; admitted++) {
          for (var backlog = 0; backlog <= 30; backlog++) {
            final m =
                model.meter(admittedToday: admitted, backlog: backlog, config: config);
            final remaining = cap - admitted > 0 ? cap - admitted : 0;
            final expected = remaining < backlog ? remaining : backlog;
            expect(m.dripNow, expected);
            expect(m.dripNow, lessThanOrEqualTo(backlog));
            expect(m.dripNow, lessThanOrEqualTo(remaining));
            expect(m.backlogAfter, backlog - expected);
          }
        }
      }
    });
  });

  group('determinism + invariants', () {
    test('identical inputs yield identical classify decisions', () {
      final a = model.classify(
          courseId: 'es', rawWord: 'hola', alreadySaved: const <SavedWordKey>{});
      final b = model.classify(
          courseId: 'es', rawWord: 'hola', alreadySaved: const <SavedWordKey>{});
      expect(a.disposition, b.disposition);
      expect(a.key, b.key);
    });

    test('identical inputs yield identical meter decisions', () {
      final a = model.meter(admittedToday: 7, backlog: 40);
      final b = model.meter(admittedToday: 7, backlog: 40);
      expect(a.dripNow, b.dripNow);
      expect(a.backlogAfter, b.backlogAfter);
    });

    test('saving is never blocked — any brand-new key always creates a card', () {
      for (final w in const ['alpha', 'beta', 'gamma', 'δ', 'Ünïcode']) {
        final d = model.classify(
            courseId: 'es', rawWord: w, alreadySaved: const <SavedWordKey>{});
        expect(d.createsCard, isTrue);
        expect(d.disposition, isNot(SavedWordDisposition.duplicate));
      }
    });

    test('the injected lemmatizer changes dedup (the seam is used)', () {
      const stem = SavedWordsModel(lemmatizer: _toyStem);
      expect(stem.keyFor('en', 'Running'), stem.keyFor('en', 'ran'));
      expect(stem.keyFor('en', 'runs'), stem.keyFor('en', 'run'));
      // The identity-lemma default keeps the inflections distinct, proving the
      // collapse comes from the injected seam, not a hard-coded rule.
      expect(model.keyFor('en', 'Running') == model.keyFor('en', 'ran'), isFalse);
    });
  });
}
