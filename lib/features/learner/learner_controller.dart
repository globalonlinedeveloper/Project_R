import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel;
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/learning/learning.dart';

/// An immutable snapshot of the learner's surfaced progress.
///
/// HONESTY (design spec §6): [theta] + [level] are REAL — derived by composing
/// the `learner_state` ability fold (seeded with the `cold_start` CEFR-anchor
/// prior, OR a θ restored from the durable store) over the in-memory answer log.
/// The counters ([lessonsCompleted], [xpTotal], [xpToday], [streakDays]) are
/// honest progress (R-O1): ZERO on a freshly-wiped backend, then — once a real
/// `auth.uid()` session exists — REHYDRATED from + WRITTEN THROUGH to the
/// Supabase `user_course` row so they survive a relaunch. A pure guest
/// (`uid == null`) keeps the byte-identical in-memory behaviour.
///
/// [xpToday] resets at the local day boundary (the injected `clockProvider`);
/// it has no durable column, so it also starts at zero on each relaunch.
/// [streakDays] is GOAL-GATED (R-I2): it advances only when [xpToday] reaches
/// the persisted daily goal, counts CONSECUTIVE days, and lapses to zero after a
/// missed day. The last goal-met day persists as `streak_last_active`, so the
/// run survives a relaunch. (Streak-FREEZE / the energy economy stay design-spec
/// §6 — no engine, honestly not faked.)
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

/// Bridges the learning engines (`learner_state` + `cold_start` + `streak`) to
/// the UI and to the durable store seam (R-G6 / R-M3 / R-O1).
///
/// Owns the in-memory append-only [ReviewLogEntry] log and re-derives ability /
/// level from it on every change via the pure [LearnerStateModel]. A brand-new
/// learner cold-starts at the A1 anchor (honest — not the mockup's A2). When a
/// real `auth.uid()` session exists, on first build it REHYDRATES xp / lessons /
/// streak (+ the last goal-met day) / θ from the learner's `user_course` row,
/// and every mutation is WRITTEN THROUGH (debounced) to that row. With no
/// session (guest) — or no Supabase config — the store/identity defaults make
/// load + save no-ops, so the flag-off behaviour is byte-identical to the
/// in-memory build.
class LearnerController extends Notifier<LearnerSnapshot> {
  /// The active course (single-course foundation; multi-course lands with the
  /// course picker). Matches the Supabase `user_course` key shape.
  static const String courseId = 'es';

  /// The `target_locale` the active [courseId] maps onto in `user_course`
  /// (the upsert conflict key is `(user_id, target_locale)`).
  static const String targetLocale = 'es';

  /// Reserved `theta_per_skill` key carrying the GLOBAL θ (the surfaced
  /// ability). Real skill ids are content-id shaped (start with a lowercase
  /// letter), so this underscored sentinel can never collide with one.
  static const String thetaGlobalKey = '__global__';

  final LearnerStateModel _engine = const LearnerStateModel();
  final ColdStartModel _cold = const ColdStartModel();
  final StreakModel _streakModel = const StreakModel();
  final List<ReviewLogEntry> _log = <ReviewLogEntry>[];

  /// Placement θ once a CAT placement test completes (null ⇒ cold-start A1).
  double? _placementTheta;

  /// θ + per-skill map restored from the durable store (seed the prior so the
  /// surfaced ability survives a relaunch even with an empty in-session log).
  double? _restoredTheta;
  Map<String, double> _restoredPerSkill = const <String, double>{};

  int _lessons = 0;
  int _xpTotal = 0;
  int _xpToday = 0;
  int _streak = 0;

  /// Calendar day [_xpToday] currently belongs to (day-boundary reset), and the
  /// day the streak last advanced (persisted as `streak_last_active`). Both are
  /// date-only (local midnight) or null when never set.
  DateTime? _xpTodayDate;
  DateTime? _lastGoalMetDate;

  bool _hydrated = false;
  bool _disposed = false;
  bool _saving = false;
  bool _dirty = false;

  /// Ability prior for the learner: the placement θ once a CAT placement test
  /// has run ([seedFromPlacement]), else a θ restored from the durable store,
  /// else the A1 CEFR anchor for a brand-new learner (design spec §4.11).
  AbilityState get _coldStart => AbilityState(
        thetaGlobal: _placementTheta ??
            _restoredTheta ??
            _cold.priorThetaForBand(CefrLevel.a1),
        thetaPerSkill: _placementTheta != null
            ? const <String, double>{}
            : _restoredPerSkill,
      );

  /// Today's calendar date (date-only), from the injected wall clock.
  DateTime _today() {
    final DateTime now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  LearnerSnapshot build() {
    ref.onDispose(() => _disposed = true);
    _hydrate(); // fire-and-forget; no-op for a guest / once hydrated
    return _derive();
  }

  LearnerSnapshot _derive() {
    final UserCourse course =
        _engine.deriveCourse(courseId, _log, initial: _coldStart);
    final CefrLevel level = _cold.bandFor(course.thetaGlobal) ?? CefrLevel.a1;
    final DateTime today = _today();
    // Honest day-boundary display: today's XP is zero once the day has rolled
    // over since it was last earned, and the streak lapses after a missed day.
    final int xpToday =
        (_xpTodayDate != null && _xpTodayDate != today) ? 0 : _xpToday;
    return LearnerSnapshot(
      theta: course.thetaGlobal,
      level: level,
      lessonsCompleted: _lessons,
      xpTotal: _xpTotal,
      xpToday: xpToday,
      streakDays: _streakModel.current(
          streak: _streak, lastMet: _lastGoalMetDate, today: today),
    );
  }

  /// Append a graded answer to the immutable log and re-derive ability + level
  /// through the real engine (the only path that moves θ/level), then persist.
  void recordReview(ReviewLogEntry entry) {
    _log.add(entry);
    state = _derive();
    _persist();
  }

  /// Record a completed lesson (R-O1 XP/lessons). Rolls today's XP over the day
  /// boundary first, adds the lesson XP, then advances the goal-gated streak if
  /// today's XP just reached the daily goal — and writes the lot through.
  void recordLessonComplete({int xp = 20}) {
    final DateTime today = _today();
    _rollDay(today);
    _lessons += 1;
    _xpTotal += xp;
    _xpToday += xp;
    _maybeAdvanceStreak(today);
    state = _derive();
    _persist();
  }

  /// Reset today's XP when the calendar day has rolled over since it was last
  /// touched. [xpToday] has no durable column, so this only bites within a live
  /// session that crosses local midnight (a relaunch already starts it at zero).
  void _rollDay(DateTime today) {
    if (_xpTodayDate != null && _xpTodayDate != today) _xpToday = 0;
    _xpTodayDate = today;
  }

  /// Advance the streak the FIRST time today's XP reaches the daily goal
  /// (goal-gated, idempotent within a day). The goal is read at completion time
  /// from the persisted setting (floored at 1, matching `dailyGoalProvider`).
  void _maybeAdvanceStreak(DateTime today) {
    final int rawGoal = ref.read(appSettingsControllerProvider).dailyGoal;
    final int goal = rawGoal <= 0 ? 1 : rawGoal;
    if (_xpToday < goal) return; // goal not reached yet today
    if (_lastGoalMetDate == today) return; // already advanced today
    _streak = _streakModel.afterGoalMet(
        streak: _streak, lastMet: _lastGoalMetDate, today: today);
    _lastGoalMetDate = today;
  }

  /// Seed ability from a completed CAT placement (design spec §4.11 — the
  /// "Take a placement test" branch). Replaces the cold-start prior with the
  /// placement θ estimate (same IRT logit scale), clears any prior answer log
  /// so the placement defines the starting point, re-derives the CEFR level,
  /// and persists. [R-G4 · R-G7]
  void seedFromPlacement(double theta) {
    _placementTheta = theta;
    _log.clear();
    state = _derive();
    _persist();
  }

  /// Reset to the cold-start state (sign-out / testing). Clears in-memory state
  /// only — it deliberately does NOT wipe the durable store.
  void reset() {
    _log.clear();
    _placementTheta = null;
    _restoredTheta = null;
    _restoredPerSkill = const <String, double>{};
    _lessons = _xpTotal = _xpToday = _streak = 0;
    _xpTodayDate = null;
    _lastGoalMetDate = null;
    state = _derive();
  }

  // ── Durable persistence (R-O1 / R-M3) ────────────────────────────────────

  /// Rehydrate xp / lessons / streak (+ last goal-met day) / θ from the
  /// learner's `user_course` row. No-op for a guest (`uid == null`) or when
  /// already hydrated, so the flag-off path is byte-identical and a load
  /// failure never breaks boot.
  Future<void> _hydrate() async {
    if (_hydrated) return;
    final String? uid = ref.read(identityProvider).uid;
    if (uid == null) return;
    _hydrated = true;
    final LearnerStateStore store = ref.read(learnerStateStoreProvider);
    try {
      final Map<String, Object?> data = await store.load(uid);
      if (_disposed) return;
      final Object? courses = data['courses'];
      if (courses is List) {
        for (final Object? row in courses) {
          if (row is Map && row['target_locale'] == targetLocale) {
            _applyCourseRow(row);
            break;
          }
        }
      }
      state = _derive();
    } catch (_) {
      // never break boot on a load failure — keep the honest cold-start
    }
  }

  void _applyCourseRow(Map<Object?, Object?> row) {
    final Object? xp = row['xp_total'];
    if (xp is num) _xpTotal = xp.toInt();
    final Object? lessons = row['lessons_completed'];
    if (lessons is num) _lessons = lessons.toInt();
    final Object? streak = row['streak_days'];
    if (streak is num) _streak = streak.toInt();
    final Object? lastActive = row['streak_last_active'];
    if (lastActive is String) _lastGoalMetDate = _parseDate(lastActive);
    final Object? theta = row['theta_per_skill'];
    if (theta is Map) {
      final Map<String, double> perSkill = <String, double>{};
      double? global;
      theta.forEach((Object? k, Object? v) {
        if (v is num) {
          if (k == thetaGlobalKey) {
            global = v.toDouble();
          } else {
            perSkill[k.toString()] = v.toDouble();
          }
        }
      });
      _restoredPerSkill = perSkill;
      _restoredTheta = global;
    }
  }

  /// The `user_course` seam row for the current state (the global θ rides in
  /// `theta_per_skill` under [thetaGlobalKey]; the store stamps `user_id`).
  Map<String, Object?> courseRow() {
    final UserCourse course =
        _engine.deriveCourse(courseId, _log, initial: _coldStart);
    final Map<String, Object?> theta = <String, Object?>{
      for (final MapEntry<String, double> e in course.thetaPerSkill.entries)
        e.key: e.value,
      thetaGlobalKey: course.thetaGlobal,
    };
    return <String, Object?>{
      'target_locale': targetLocale,
      'xp_total': _xpTotal,
      'lessons_completed': _lessons,
      'streak_days': _streak,
      'streak_last_active': _fmtDate(_lastGoalMetDate),
      'theta_per_skill': theta,
    };
  }

  /// `YYYY-MM-DD` for a date-only value (the PG `date` column shape), or null.
  static String? _fmtDate(DateTime? d) => d == null
      ? null
      : '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

  /// Parse a stored `streak_last_active` value to a date-only [DateTime].
  static DateTime? _parseDate(Object? v) {
    if (v is! String || v.isEmpty) return null;
    final DateTime? d = DateTime.tryParse(v);
    return d == null ? null : DateTime(d.year, d.month, d.day);
  }

  /// Mark state dirty and (debounced) write it through. No-op for a guest.
  void _persist() {
    if (ref.read(identityProvider).uid == null) return;
    _dirty = true;
    _drain();
  }

  /// Trailing-edge debounce drain: one runner coalesces a burst of mutations
  /// into the latest write, never overlapping saves.
  Future<void> _drain() async {
    if (_saving) return;
    _saving = true;
    final Duration debounce = ref.read(persistDebounceProvider);
    try {
      while (_dirty && !_disposed) {
        _dirty = false;
        await Future<void>.delayed(debounce);
        if (_disposed) return;
        final String? uid = ref.read(identityProvider).uid;
        if (uid == null) return;
        final LearnerStateStore store = ref.read(learnerStateStoreProvider);
        try {
          await store.save(uid, <String, Object?>{
            'courses': <Object?>[courseRow()],
          });
        } catch (_) {
          // best-effort: a save failure must never break the session
        }
      }
    } finally {
      _saving = false;
    }
  }
}

final learnerControllerProvider =
    NotifierProvider<LearnerController, LearnerSnapshot>(LearnerController.new);
