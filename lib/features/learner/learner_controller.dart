import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel;
import 'package:ratel/services/learning/learning.dart';

/// An immutable snapshot of the learner's surfaced progress.
///
/// HONESTY (design spec §6): [theta] + [level] are REAL — derived by composing
/// the `learner_state` ability fold (seeded with the `cold_start` CEFR-anchor
/// prior) over the in-memory answer log. The counters ([lessonsCompleted],
/// [xpTotal], [xpToday], [streakDays]) are honest in-memory session state
/// (R-O1) that start at ZERO on the freshly-wiped backend — never the design
/// mockup's sample values. Durable persistence + real day-boundary streak/
/// freeze logic need a clock + the Supabase store (a later wiring step).
class LearnerSnapshot {
  const LearnerSnapshot({
    required this.theta,
    required this.level,
    this.lessonsCompleted = 0,
    this.xpTotal = 0,
    this.xpToday = 0,
    this.streakDays = 0,
  });

  /// Global ability on the IRT logit scale (REAL — from the ability fold).
  final double theta;

  /// CEFR level derived from [theta] via the cold-start anchors (REAL).
  final CefrLevel level;

  final int lessonsCompleted;
  final int xpTotal;
  final int xpToday;
  final int streakDays;

  @override
  bool operator ==(Object other) =>
      other is LearnerSnapshot &&
      other.theta == theta &&
      other.level == level &&
      other.lessonsCompleted == lessonsCompleted &&
      other.xpTotal == xpTotal &&
      other.xpToday == xpToday &&
      other.streakDays == streakDays;

  @override
  int get hashCode => Object.hash(
      theta, level, lessonsCompleted, xpTotal, xpToday, streakDays);
}

/// Bridges the learning engines (`learner_state` + `cold_start`) to the UI.
///
/// Owns the in-memory append-only [ReviewLogEntry] log and re-derives ability /
/// level from it on every change via the pure [LearnerStateModel]. A brand-new
/// learner cold-starts at the A1 anchor (honest — not the mockup's A2). The
/// gameplay counters are in-memory R-O1 state the screens drive (lesson
/// complete, daily activity).
class LearnerController extends Notifier<LearnerSnapshot> {
  /// The active course (single-course foundation; multi-course lands with the
  /// course picker). Matches the Supabase `user_course` key shape.
  static const String courseId = 'es';

  final LearnerStateModel _engine = const LearnerStateModel();
  final ColdStartModel _cold = const ColdStartModel();
  final List<ReviewLogEntry> _log = <ReviewLogEntry>[];

  int _lessons = 0;
  int _xpTotal = 0;
  int _xpToday = 0;
  int _streak = 0;

  /// Cold-start ability prior for a brand-new learner with no placement: the
  /// A1 CEFR anchor (design spec §4.11 — placement seeds a higher prior later).
  AbilityState get _coldStart =>
      AbilityState.coldStart(_cold.priorThetaForBand(CefrLevel.a1));

  @override
  LearnerSnapshot build() => _derive();

  LearnerSnapshot _derive() {
    final UserCourse course =
        _engine.deriveCourse(courseId, _log, initial: _coldStart);
    final CefrLevel level = _cold.bandFor(course.thetaGlobal) ?? CefrLevel.a1;
    return LearnerSnapshot(
      theta: course.thetaGlobal,
      level: level,
      lessonsCompleted: _lessons,
      xpTotal: _xpTotal,
      xpToday: _xpToday,
      streakDays: _streak,
    );
  }

  /// Append a graded answer to the immutable log and re-derive ability + level
  /// through the real engine (the only path that moves θ/level).
  void recordReview(ReviewLogEntry entry) {
    _log.add(entry);
    state = _derive();
  }

  /// Record a completed lesson (in-memory R-O1 — XP/lessons not yet persisted).
  void recordLessonComplete({int xp = 20}) {
    _lessons += 1;
    _xpTotal += xp;
    _xpToday += xp;
    state = _derive();
  }

  /// Mark today active. Simplistic in-memory streak — real day-boundary +
  /// streak-freeze logic needs a clock + persistence (design spec §6 flag).
  void noteDailyActive() {
    _streak += 1;
    state = _derive();
  }

  /// Reset to the cold-start state (sign-out / testing).
  void reset() {
    _log.clear();
    _lessons = _xpTotal = _xpToday = _streak = 0;
    state = _derive();
  }
}

final learnerControllerProvider =
    NotifierProvider<LearnerController, LearnerSnapshot>(LearnerController.new);
