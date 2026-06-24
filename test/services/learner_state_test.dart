// BUILD-AHEAD — not deployed; pending human review + go-live wiring.
//
// LEARNERSTATE-1 [R-G6] tests for the pure learner-state value-objects + the
// append-only / derive-by-compose transitions. Properties proven: appending
// returns a NEW unmodifiable log and never mutates the prior log (the
// append-only invariant); the FSRS item-state fold recomputes memory state
// deterministically and matches the FSRS engine run directly (and a golden first
// review); the θ course fold matches the ability engine run directly (a golden
// θ after a correct-then-wrong pair), is order-faithful, and treats an entry
// that does not feed θ as a no-op so ungraded reading never moves the score; the
// placement fold composes the CAT EAP estimator exactly (prior with no
// responses; more-correct ⇒ higher θ); the recall prediction recomputes the IRT
// probability from the frozen spine; entities are value-equal + Set/Map-usable;
// everything is deterministic. Golden arithmetic cross-checked in python. No
// clock, no I/O, no randomness.
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

/// Build a spine entry with sensible defaults; pass only the fields a test
/// varies (so no argument ever restates a default).
ReviewLogEntry _entry(
  String itemId,
  String skill, {
  FsrsRating grade = FsrsRating.good,
  bool correct = true,
  int elapsedDays = 0,
  double thetaBefore = 0.0,
  double irtB = 0.0,
  String source = 'lesson',
  bool feedsTheta = true,
}) =>
    ReviewLogEntry(
      itemId: itemId,
      skill: skill,
      grade: grade,
      correct: correct,
      elapsedMs: elapsedDays * Duration.millisecondsPerDay,
      thetaBefore: thetaBefore,
      irtBAtReview: irtB,
      source: source,
      feedsTheta: feedsTheta,
    );

void main() {
  const LearnerStateModel model = LearnerStateModel();

  group('ReviewLogEntry spine value-object', () {
    test('elapsedDays converts the frozen milliseconds to days', () {
      expect(_entry('i', 's', elapsedDays: 3).elapsedDays, closeTo(3.0, 1e-12));
      const ReviewLogEntry half = ReviewLogEntry(
        itemId: 'i',
        skill: 's',
        grade: FsrsRating.good,
        correct: true,
        elapsedMs: 43200000, // half a day
        thetaBefore: 0.0,
        irtBAtReview: 0.0,
        source: 'lesson',
      );
      expect(half.elapsedDays, closeTo(0.5, 1e-12));
    });

    test('feedsTheta defaults to true', () {
      expect(_entry('i', 's').feedsTheta, isTrue);
    });

    test('value-equality + hashCode make it Set/Map-usable', () {
      final ReviewLogEntry a = _entry('i', 's', thetaBefore: 0.2, irtB: -0.3);
      final ReviewLogEntry b = _entry('i', 's', thetaBefore: 0.2, irtB: -0.3);
      final ReviewLogEntry c = _entry('i', 's', thetaBefore: 0.2, irtB: 0.9);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(<ReviewLogEntry>{a, b, c}, hasLength(2));
    });
  });

  group('append — the append-only invariant', () {
    test('returns a new log with the entry appended; the prior log is untouched',
        () {
      final List<ReviewLogEntry> base = <ReviewLogEntry>[_entry('a', 's')];
      final List<ReviewLogEntry> next = model.append(base, _entry('b', 's'));
      expect(base, hasLength(1));
      expect(next, hasLength(2));
      expect(next.first.itemId, 'a');
      expect(next.last.itemId, 'b');
    });

    test('the returned log is unmodifiable (existing entries are frozen)', () {
      final List<ReviewLogEntry> out =
          model.append(const <ReviewLogEntry>[], _entry('a', 's'));
      expect(() => out.add(_entry('b', 's')), throwsUnsupportedError);
    });
  });

  group('deriveItemState — FSRS fold composition', () {
    test('no entries for the item ⇒ a fresh, never-reviewed card', () {
      final UserItemState st = model.deriveItemState(
        'w',
        <ReviewLogEntry>[_entry('other', 's')],
      );
      expect(st.card.isNew, isTrue);
      expect(st.card.reps, 0);
      expect(st.intervalDays, 0);
    });

    test('a single good first review matches the FSRS golden', () {
      final UserItemState st = model.deriveItemState(
        'w',
        <ReviewLogEntry>[_entry('w', 'greet')],
      );
      expect(st.card.isNew, isFalse);
      expect(st.card.reps, 1);
      expect(st.card.stability!, closeTo(2.3065, 1e-9));
      expect(st.card.difficulty!, closeTo(2.1181039705, 1e-9));
      expect(st.intervalDays, 4);
    });

    test('the fold matches the FSRS engine run directly (order-faithful)', () {
      const Fsrs fsrs = Fsrs();
      final List<ReviewLogEntry> log = <ReviewLogEntry>[
        _entry('w', 'greet'),
        _entry('w', 'greet', elapsedDays: 4),
        _entry('w', 'greet', grade: FsrsRating.again, correct: false, elapsedDays: 2),
      ];
      final UserItemState got = model.deriveItemState('w', log);

      FsrsCard card = const FsrsCard.newItem();
      int iv = 0;
      for (final ReviewLogEntry e in log) {
        final FsrsReview r = fsrs.schedule(card, e.grade, e.elapsedDays);
        card = r.card;
        iv = r.intervalDays;
      }
      expect(got, UserItemState(itemId: 'w', card: card, intervalDays: iv));
      expect(got.card.reps, 3);
      expect(got.card.lapses, 1);
    });

    test('entries for other items are ignored', () {
      final List<ReviewLogEntry> log = <ReviewLogEntry>[
        _entry('w', 'greet'),
        _entry('z', 'greet', elapsedDays: 5),
      ];
      expect(model.deriveItemState('w', log).card.reps, 1);
      expect(model.deriveItemState('z', log).card.reps, 1);
    });
  });

  group('deriveAbility / deriveCourse — θ fold composition', () {
    test('the fold matches the ability engine run directly', () {
      const AbilityModel ab = AbilityModel();
      final List<ReviewLogEntry> log = <ReviewLogEntry>[
        _entry('i1', 'greet'),
        _entry('i2', 'farewell', correct: false, irtB: -0.5),
        _entry('i3', 'greet', irtB: 0.3),
      ];
      final AbilityState got = model.deriveAbility(log);

      AbilityState st = const AbilityState();
      for (final ReviewLogEntry e in log) {
        st = ab.update(
          st,
          skill: e.skill,
          itemDifficulty: e.irtBAtReview,
          correct: e.correct,
          graded: e.feedsTheta,
        );
      }
      expect(got.thetaGlobal, closeTo(st.thetaGlobal, 1e-12));
      expect(got.thetaForSkill('greet'), closeTo(st.thetaForSkill('greet'), 1e-12));
      expect(got.globalItemCount, st.globalItemCount);
    });

    test('golden θ after a correct@b0 then wrong@b1 pair', () {
      final UserCourse c = model.deriveCourse('course', <ReviewLogEntry>[
        _entry('i1', 'greet'),
        _entry('i2', 'greet', correct: false, irtB: 1.0),
      ]);
      expect(c.thetaGlobal, closeTo(0.140437458287, 1e-9));
      expect(c.thetaForSkill('greet'), closeTo(0.140437458287, 1e-9));
    });

    test('an entry that does not feed θ is a no-op (ungraded never moves θ)', () {
      final List<ReviewLogEntry> withRead = <ReviewLogEntry>[
        _entry('i1', 'greet'),
        _entry('read', 'greet', correct: false, irtB: 5.0, feedsTheta: false),
        _entry('i2', 'greet', correct: false, irtB: 1.0),
      ];
      final List<ReviewLogEntry> without = <ReviewLogEntry>[
        _entry('i1', 'greet'),
        _entry('i2', 'greet', correct: false, irtB: 1.0),
      ];
      expect(
        model.deriveCourse('c', withRead).thetaGlobal,
        closeTo(model.deriveCourse('c', without).thetaGlobal, 1e-12),
      );
    });

    test('a cold-start initial seeds θ for a never-graded skill', () {
      final UserCourse c = model.deriveCourse(
        'course',
        const <ReviewLogEntry>[],
        initial: const AbilityState.coldStart(1.0),
      );
      expect(c.thetaGlobal, closeTo(1.0, 1e-12));
      expect(c.thetaForSkill('anything'), closeTo(1.0, 1e-12));
      expect(c.thetaPerSkill, isEmpty);
    });

    test('the θ derive is order-faithful (order changes the result)', () {
      final ReviewLogEntry a = _entry('i1', 'greet');
      final ReviewLogEntry b = _entry('i2', 'greet', correct: false, irtB: 1.0);
      final double ab = model.deriveCourse('c', <ReviewLogEntry>[a, b]).thetaGlobal;
      final double ba = model.deriveCourse('c', <ReviewLogEntry>[b, a]).thetaGlobal;
      expect(ab, isNot(closeTo(ba, 1e-6)));
    });
  });

  group('derivePlacement — CAT estimator composition', () {
    test('an empty trace returns the prior estimate', () {
      final PlacementSession ps =
          model.derivePlacement('s', const <PlacementResponse>[]);
      expect(ps.estimate.theta, closeTo(0.0, 1e-9));
      expect(ps.estimate.se, closeTo(0.999559141113, 1e-9));
      expect(ps.responses, isEmpty);
    });

    test('the fold composes the CAT EAP estimator exactly', () {
      const List<PlacementResponse> trace = <PlacementResponse>[
        PlacementResponse(itemId: 'a', irtB: -1.0, correct: true),
        PlacementResponse(itemId: 'b', irtB: 0.5, correct: false),
        PlacementResponse(itemId: 'c', irtB: 1.0, correct: true),
      ];
      final PlacementSession ps = model.derivePlacement('s', trace);

      const CatModel cat = CatModel();
      final EapEstimate want = cat.eap(const <CatResponse>[
        CatResponse(item: CatItem(id: 'a', params: IrtItem(b: -1.0)), correct: true),
        CatResponse(item: CatItem(id: 'b', params: IrtItem(b: 0.5)), correct: false),
        CatResponse(item: CatItem(id: 'c', params: IrtItem(b: 1.0)), correct: true),
      ]);
      expect(ps.estimate.theta, closeTo(want.theta, 1e-12));
      expect(ps.estimate.se, closeTo(want.se, 1e-12));
    });

    test('a more-correct trace yields a higher θ than a more-wrong one', () {
      final PlacementSession hi = model.derivePlacement('h', const <PlacementResponse>[
        PlacementResponse(itemId: 'a', irtB: 0.0, correct: true),
        PlacementResponse(itemId: 'b', irtB: 0.0, correct: true),
        PlacementResponse(itemId: 'c', irtB: 0.0, correct: true),
      ]);
      final PlacementSession lo = model.derivePlacement('l', const <PlacementResponse>[
        PlacementResponse(itemId: 'a', irtB: 0.0, correct: false),
        PlacementResponse(itemId: 'b', irtB: 0.0, correct: false),
        PlacementResponse(itemId: 'c', irtB: 0.0, correct: false),
      ]);
      expect(hi.estimate.theta, greaterThan(lo.estimate.theta));
    });

    test('the stored placement trace is unmodifiable', () {
      final PlacementSession ps = model.derivePlacement(
        's',
        const <PlacementResponse>[
          PlacementResponse(itemId: 'a', irtB: 0.0, correct: true),
        ],
      );
      expect(
        () => ps.responses
            .add(const PlacementResponse(itemId: 'b', irtB: 0.0, correct: true)),
        throwsUnsupportedError,
      );
    });
  });

  group('predictedRecall — IRT recall-probability composition', () {
    test('golden σ values from the frozen θ-before + difficulty', () {
      expect(model.predictedRecall(_entry('i', 's', thetaBefore: 1.0)),
          closeTo(0.7310585786, 1e-9));
      expect(model.predictedRecall(_entry('i', 's', thetaBefore: 0.5, irtB: 1.5)),
          closeTo(0.2689414214, 1e-9));
    });
  });

  group('entity value-equality + determinism', () {
    test('UserItemState is value-equal over its fields + Set-usable', () {
      const Fsrs fsrs = Fsrs();
      final FsrsCard cardA =
          fsrs.schedule(const FsrsCard.newItem(), FsrsRating.good, 0.0).card;
      final FsrsCard cardB =
          fsrs.schedule(const FsrsCard.newItem(), FsrsRating.good, 0.0).card;
      final UserItemState s1 =
          UserItemState(itemId: 'x', card: cardA, intervalDays: 4);
      final UserItemState s2 =
          UserItemState(itemId: 'x', card: cardB, intervalDays: 4);
      expect(s1, s2);
      expect(s1.hashCode, s2.hashCode);
      expect(<UserItemState>{s1, s2}, hasLength(1));
      expect(s1, isNot(UserItemState(itemId: 'x', card: cardA)));
    });

    test('UserCourse θ-map equality is order-independent', () {
      const UserCourse a = UserCourse(
        courseId: 'c',
        thetaGlobal: 0.5,
        thetaPerSkill: <String, double>{'x': 1.0, 'y': 2.0},
      );
      const UserCourse b = UserCourse(
        courseId: 'c',
        thetaGlobal: 0.5,
        thetaPerSkill: <String, double>{'y': 2.0, 'x': 1.0},
      );
      const UserCourse d = UserCourse(
        courseId: 'c',
        thetaGlobal: 0.5,
        thetaPerSkill: <String, double>{'x': 1.0},
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(d));
    });

    test('PlacementResponse is value-equal + Set-usable', () {
      PlacementResponse pr(bool correct) =>
          PlacementResponse(itemId: 'a', irtB: 0.5, correct: correct);
      final PlacementResponse r1 = pr(true);
      final PlacementResponse r2 = pr(true);
      final PlacementResponse r3 = pr(false);
      expect(r1, r2);
      expect(r1.hashCode, r2.hashCode);
      expect(<PlacementResponse>{r1, r2}, hasLength(1));
      expect(r1, isNot(r3));
    });

    test('derives are deterministic (identical log ⇒ identical state)', () {
      final List<ReviewLogEntry> log = <ReviewLogEntry>[
        _entry('i1', 'greet'),
        _entry('i2', 'greet', correct: false, irtB: 0.8),
      ];
      expect(model.deriveCourse('c', log), model.deriveCourse('c', log));
      expect(model.deriveItemState('i1', log), model.deriveItemState('i1', log));
    });
  });
}
