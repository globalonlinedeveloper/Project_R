import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ratel/content/models/enums.dart' show CefrLevel;
import 'package:ratel/features/settings/settings_controller.dart';
import 'package:ratel/features/notifications/earned_stamps_controller.dart';
import 'package:ratel/features/progress/xp_history_controller.dart';
import 'package:ratel/services/data_access/data_access.dart';
import 'package:ratel/services/economy/economy.dart';
import 'package:ratel/services/identity/identity.dart';
import 'package:ratel/services/leagues/leagues.dart' show LeagueWeek;
import 'package:ratel/services/learning/learning.dart';
import 'package:ratel/services/notifications/notifications.dart'
    show NotificationStats;
import 'package:ratel/services/social/friends.dart' show FriendActivityType;
import 'package:ratel/services/social/friends_service.dart';

/// An immutable snapshot of the learner's surfaced progress.
///
/// HONESTY (design spec §6): [theta] + [level] are REAL — derived by composing
/// the `learner_state` ability fold (seeded with the `cold_start` CEFR-anchor
/// prior, OR a θ restored from the durable store) over the in-memory answer log.
/// The counters ([lessonsCompleted], [xpTotal], [xpToday], [streakDays],
/// [diamonds]) are honest progress (R-O1 / R-I4): ZERO on a freshly-wiped
/// backend, then — once a real
/// `auth.uid()` session exists — REHYDRATED from + WRITTEN THROUGH to the
/// Supabase `user_course` row so they survive a relaunch. A pure guest
/// (`uid == null`) keeps the byte-identical in-memory behaviour.
///
/// [xpToday] resets at the local day boundary (the injected `clockProvider`);
/// it has no durable column, so it also starts at zero on each relaunch.
/// [streakDays] is GOAL-GATED (R-I2): it advances only when [xpToday] reaches
/// the persisted daily goal, counts CONSECUTIVE days, and lapses to zero after a
/// missed day. The last goal-met day persists as `streak_last_active`, so the
/// run survives a relaunch. A held streak-FREEZE (R-I2, bought with 💎) is spent
/// automatically to cover a missed day so the run survives; the energy economy
/// stays design-spec §6 — no engine, honestly not faked.
class LearnerSnapshot {
  const LearnerSnapshot({
    required this.theta,
    required this.level,
    this.lessonsCompleted = 0,
    this.xpTotal = 0,
    this.xpToday = 0,
    this.xpWeekEarned = 0,
    this.streakDays = 0,
    this.diamonds = 0,
    this.streakFreezes = 0,
    this.energy = EnergyModel.cap,
  });

  /// Global ability on the IRT logit scale (REAL — from the ability fold).
  final double theta;

  /// CEFR level derived from [theta] via the cold-start anchors (REAL).
  final CefrLevel level;

  final int lessonsCompleted;
  final int xpTotal;
  final int xpToday;

  /// XP genuinely earned this LEAGUE week (Monday->Sunday). Like [xpToday]
  /// it has no durable column: it resets at the weekly boundary (the injected
  /// clock) and starts at zero on each relaunch (R-I6). Ranks the weekly
  /// leaderboard, never a fabricated cohort.
  final int xpWeekEarned;
  final int streakDays;

  /// 💎 earned diamonds (REAL — R-I4 earn side; spend sinks stay §6, see
  /// `DiamondsModel`). Durable: rehydrated from + written through to
  /// `user_course.diamonds`.
  final int diamonds;

  /// 💪 streak-freezes owned (REAL — R-I2 spend sink, bought via the 💎 wallet
  /// R-I4). Durable: rehydrated from + written through to
  /// `user_course.streak_freezes`.
  final int streakFreezes;

  /// ⚡ energy (REAL — R-I3: depletes 1 per lesson, regenerates over time
  /// toward [EnergyModel.cap]). DISPLAY-ONLY / NON-BLOCKING (S60) — never
  /// gates a lesson. Session-local for now (full on relaunch; the durable
  /// store is go-live wiring), so it is honestly real but not yet persisted.
  final int energy;

  @override
  bool operator ==(Object other) =>
      other is LearnerSnapshot &&
      other.theta == theta &&
      other.level == level &&
      other.lessonsCompleted == lessonsCompleted &&
      other.xpTotal == xpTotal &&
      other.xpToday == xpToday &&
      other.xpWeekEarned == xpWeekEarned &&
      other.streakDays == streakDays &&
      other.diamonds == diamonds &&
      other.streakFreezes == streakFreezes &&
      other.energy == energy;

  @override
  int get hashCode => Object.hash(theta, level, lessonsCompleted, xpTotal,
      xpToday, xpWeekEarned, streakDays, diamonds, streakFreezes, energy);
}

/// Bridges the learning engines (`learner_state` + `cold_start` + `streak`) to
/// the UI and to the durable store seam (R-G6 / R-M3 / R-O1).
///
/// Owns the in-memory append-only [ReviewLogEntry] log and re-derives ability /
/// level from it on every change via the pure [LearnerStateModel]. A brand-new
/// learner cold-starts at the A1 anchor (honest — not the mockup's A2). When a
/// real `auth.uid()` session exists, on first build it REHYDRATES xp / lessons /
/// streak (+ the last goal-met day) / diamonds / θ from the learner's
/// `user_course` row,
/// and every mutation is WRITTEN THROUGH (debounced) to that row. With no
/// session (guest) — or no Supabase config — the store/identity defaults make
/// load + save no-ops, so the flag-off behaviour is byte-identical to the
/// in-memory build.
class LearnerController extends Notifier<LearnerSnapshot> {
  /// The active course (single-course foundation; multi-course lands with the
  /// course picker). Matches the Supabase `user_course` key shape.
  static const String courseId = 'en';

  /// The `target_locale` the active [courseId] maps onto in `user_course`
  /// (the upsert conflict key is `(user_id, target_locale)`).
  static const String targetLocale = 'en';

  /// Reserved `theta_per_skill` key carrying the GLOBAL θ (the surfaced
  /// ability). Real skill ids are content-id shaped (start with a lowercase
  /// letter), so this underscored sentinel can never collide with one.
  static const String thetaGlobalKey = '__global__';

  final LearnerStateModel _engine = const LearnerStateModel();
  final ColdStartModel _cold = const ColdStartModel();
  final StreakModel _streakModel = const StreakModel();
  final DiamondsModel _diamondsModel = const DiamondsModel();
  final StreakFreezeModel _freezeModel = const StreakFreezeModel();
  final List<ReviewLogEntry> _log = <ReviewLogEntry>[];
  final Fsrs _fsrs = const Fsrs();

  /// Placement θ once a CAT placement test completes (null ⇒ cold-start A1).
  double? _placementTheta;

  /// θ + per-skill map restored from the durable store (seed the prior so the
  /// surfaced ability survives a relaunch even with an empty in-session log).
  double? _restoredTheta;
  Map<String, double> _restoredPerSkill = const <String, double>{};

  int _lessons = 0;
  int _xpTotal = 0;
  int _xpToday = 0;
  int _xpWeek = 0;
  int _streak = 0;

  /// 💎 earned diamonds balance (R-I4 earn side; durable via `user_course`).
  int _diamonds = 0;

  /// 💪 streak-freezes owned (R-I2 spend sink; durable via `user_course`).
  int _streakFreezes = 0;

  /// ⚡ energy model + session-local state (R-I3, display-only/non-blocking,
  /// S60). [_energy] is the value at [_energyAnchor]; regen accrues from
  /// there. No durable column (full on relaunch — go-live wiring).
  final EnergyModel _energyModel = const EnergyModel();
  int _energy = EnergyModel.cap;
  DateTime? _energyAnchor;

  /// Calendar day [_xpToday] currently belongs to (day-boundary reset), and the
  /// day the streak last advanced (persisted as `streak_last_active`). Both are
  /// date-only (local midnight) or null when never set.
  DateTime? _xpTodayDate;
  DateTime? _xpWeekStart;
  DateTime? _lastGoalMetDate;

  /// Session-local Double-XP boost expiry (E1 · R-I4). null ⇒ no boost; not
  /// persisted (gone on relaunch, like energy/xpToday) — the 💎 debit IS durable.
  DateTime? _xpBoostUntil;

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
    final DateTime weekStart = LeagueWeek.startOf(today);
    final int xpWeek =
        (_xpWeekStart != null && _xpWeekStart != weekStart) ? 0 : _xpWeek;
    final DateTime nowTs = ref.read(clockProvider)();
    final int energy = _energyAnchor == null
        ? _energy
        : _energyModel.regenerated(
            energy: _energy, elapsed: nowTs.difference(_energyAnchor!));
    return LearnerSnapshot(
      theta: course.thetaGlobal,
      level: level,
      lessonsCompleted: _lessons,
      xpTotal: _xpTotal,
      xpToday: xpToday,
      xpWeekEarned: xpWeek,
      streakDays: _streakModel.current(
          streak: _streak, lastMet: _lastGoalMetDate, today: today),
      diamonds: _diamonds,
      streakFreezes: _streakFreezes,
      energy: energy,
    );
  }

  /// Append a graded answer to the immutable log and re-derive ability + level
  /// through the real engine (the only path that moves θ/level), then persist.
  void recordReview(ReviewLogEntry entry) {
    final LearnerSnapshot snapBefore = state;
    final CefrLevel levelBefore = state.level;
    _log.add(entry);
    // Durable answer spine (R-G6): fire-and-forget append to the sink seam —
    // a no-op for guests/keyless boots, the own-row `review_log` INSERT when
    // the backend is wired. Never blocks or throws into grading.
    ref.read(reviewLogSinkProvider).append(targetLocale, entry);
    state = _derive();
    _persist();
    _stampMilestones(snapBefore);
    _maybeEmitLevelUp(levelBefore, state.level);
  }

  /// Record a completed lesson (R-O1 XP/lessons; R-I4 diamonds). Rolls today's
  /// XP over the day boundary first, adds the lesson XP, credits the lesson
  /// diamond, then — if today's XP just reached the daily goal — advances the
  /// goal-gated streak and credits the goal-met diamond bonus, and writes the
  /// lot through.
  void recordLessonComplete({int xp = 20}) {
    final LearnerSnapshot snapBefore = state;
    final int streakBefore = state.streakDays;
    final DateTime today = _today();
    _rollDay(today);
    _rollWeek(today);
    _coverMissedDays(today);
    _spendEnergyForLesson();
    final int gained = isDoubleXpActive ? xp * PowerUpPrices.doubleXpMultiplier : xp;
    _lessons += 1;
    _xpTotal += gained;
    _xpToday += gained;
    _xpWeek += gained;
    _diamonds = _diamondsModel
        .award(balance: _diamonds, event: DiamondEvent.lessonCompleted);
    _maybeAwardGoalMet(today);
    // D1: record the lesson's XP into the device-local 7-day history
    // (R-G6 / R-L14). Honest — only real earned XP, never fabricated.
    ref.read(xpHistoryControllerProvider.notifier).recordToday(gained);
    state = _derive();
    _persist();
    _stampMilestones(snapBefore);
    _maybeEmitStreak(streakBefore, state.streakDays);
    _maybePublishWeeklyXp();
  }

  /// Record a FIRST-TIME adventure exploration (L-4, design §4.12
  /// ADVENTURE COMPLETE: +15 XP · +5 💎 — owner-approved S131). Mirrors
  /// [recordLessonComplete]'s XP bookkeeping — day/week rolls, double-XP,
  /// goal-met crossing, 7-day history, milestone stamps, weekly publish —
  /// but does NOT count a lesson, advance lesson-count milestones, or spend
  /// energy (adventures are FREE by design). The caller
  /// (`AdventurePlayerScreen`) gates this on the exploration being genuinely
  /// NEW — re-plays never re-award.
  void recordAdventureExplored({int xp = 15}) {
    final LearnerSnapshot snapBefore = state;
    final int streakBefore = state.streakDays;
    final DateTime today = _today();
    _rollDay(today);
    _rollWeek(today);
    _coverMissedDays(today);
    final int gained =
        isDoubleXpActive ? xp * PowerUpPrices.doubleXpMultiplier : xp;
    _xpTotal += gained;
    _xpToday += gained;
    _xpWeek += gained;
    _diamonds = _diamondsModel.award(
        balance: _diamonds, event: DiamondEvent.adventureExplored);
    _maybeAwardGoalMet(today);
    // Real earned XP into the device-local 7-day history (R-G6 / R-L14).
    ref.read(xpHistoryControllerProvider.notifier).recordToday(gained);
    state = _derive();
    _persist();
    _stampMilestones(snapBefore);
    _maybeEmitStreak(streakBefore, state.streakDays);
    _maybePublishWeeklyXp();
  }

  /// Reset today's XP when the calendar day has rolled over since it was last
  /// touched. [xpToday] has no durable column, so this only bites within a live
  /// session that crosses local midnight (a relaunch already starts it at zero).
  void _rollDay(DateTime today) {
    if (_xpTodayDate != null && _xpTodayDate != today) _xpToday = 0;
    _xpTodayDate = today;
  }

  /// Reset this week's XP when the league week (Monday boundary) has rolled
  /// over since it was last touched. Mirrors [_rollDay]: [xpWeekEarned] has no
  /// durable column, so a relaunch already starts it at zero (R-I6).
  void _rollWeek(DateTime today) {
    final DateTime weekStart = LeagueWeek.startOf(today);
    if (_xpWeekStart != null && _xpWeekStart != weekStart) _xpWeek = 0;
    _xpWeekStart = weekStart;
  }

  /// Spend one ⚡ for a completed lesson, banking regen up to now first
  /// (R-I3, NON-BLOCKING — energy may reach 0 and the lesson still proceeds).
  void _spendEnergyForLesson() {
    final DateTime nowTs = ref.read(clockProvider)();
    final int settled = _energyAnchor == null
        ? _energy
        : _energyModel.regenerated(
            energy: _energy, elapsed: nowTs.difference(_energyAnchor!));
    _energy = _energyModel.afterLesson(energy: settled);
    _energyAnchor = nowTs;
  }

  /// Award the daily-goal-met rewards the FIRST time today's XP reaches the
  /// daily goal (goal-gated, idempotent within a day): advance the goal-gated
  /// streak (R-I2) and credit the diamond bonus (R-I4). The goal is read at
  /// completion time from the persisted setting (floored at 1, matching
  /// `dailyGoalProvider`).
  void _maybeAwardGoalMet(DateTime today) {
    final int rawGoal = ref.read(appSettingsControllerProvider).dailyGoal;
    final int goal = rawGoal <= 0 ? 1 : rawGoal;
    if (_xpToday < goal) return; // goal not reached yet today
    if (_lastGoalMetDate == today) return; // already rewarded today
    _streak = _streakModel.afterGoalMet(
        streak: _streak, lastMet: _lastGoalMetDate, today: today);
    _diamonds = _diamondsModel
        .award(balance: _diamonds, event: DiamondEvent.dailyGoalMet);
    _lastGoalMetDate = today;
  }

  /// Spend one held streak-freeze per missed day to keep a lapsing run alive
  /// (R-I2). Idempotent within a day: once the gap is covered the stored
  /// last-goal-met day reads as "yesterday", so a repeat call is a no-op.
  /// Returns whether any freeze was consumed (so the caller can persist).
  bool _coverMissedDays(DateTime today) {
    final ({DateTime? lastMet, int freezesConsumed}) r = _streakModel
        .applyFreezes(
            lastMet: _lastGoalMetDate, today: today, freezes: _streakFreezes);
    if (r.freezesConsumed <= 0) return false;
    _streakFreezes -= r.freezesConsumed;
    _lastGoalMetDate = r.lastMet;
    return true;
  }

  /// 💎 price of one streak-freeze (surfaced to the Shop).
  int get streakFreezeCost => StreakFreezeModel.cost;

  /// The most streak-freezes a learner may hold (surfaced to the Shop).
  int get maxStreakFreezes => StreakFreezeModel.maxHeld;

  /// Whether a streak-freeze can be bought right now (inventory room + funds).
  bool get canBuyStreakFreeze =>
      _freezeModel.canBuy(diamonds: _diamonds, held: _streakFreezes);

  /// Buy one streak-freeze (R-I2 streak-freeze · R-I4 gems spend side) — the
  /// first real diamond SPEND sink. Debits [streakFreezeCost] 💎 and adds one to
  /// inventory, capped at [maxStreakFreezes]; a no-op when unaffordable or at the
  /// cap (the UI disables the control then). Writes through durably.
  void buyStreakFreeze() {
    final ({int diamonds, int held}) r =
        _freezeModel.buy(diamonds: _diamonds, held: _streakFreezes);
    if (r.held == _streakFreezes) return; // no-op: at cap / unaffordable
    _diamonds = r.diamonds;
    _streakFreezes = r.held;
    state = _derive();
    _persist();
  }

  // ── E1 Shop spend sinks: Energy Refill + Streak Repair (R-I3 / R-I4) ──────

  /// The ⚡ energy cap (surfaced to the Shop for the "x/cap" status).
  int get energyCap => EnergyModel.cap;

  /// 💎 price of an energy refill (surfaced to the Shop).
  int get energyRefillCost => PowerUpPrices.energyRefillCost;

  /// ⚡ energy settled to the current clock (regen banked up to now).
  int _currentEnergy() {
    final DateTime nowTs = ref.read(clockProvider)();
    return _energyAnchor == null
        ? _energy
        : _energyModel.regenerated(
            energy: _energy, elapsed: nowTs.difference(_energyAnchor!));
  }

  /// Whether ⚡ energy can be refilled now: not already full AND enough 💎.
  bool get canBuyEnergyRefill =>
      _currentEnergy() < EnergyModel.cap &&
      _diamondsModel.canSpend(
          balance: _diamonds, amount: PowerUpPrices.energyRefillCost);

  /// Refill ⚡ energy to the cap for [energyRefillCost] 💎 (E1 · R-I3/R-I4).
  /// No-op when already full or unaffordable (the UI disables the control then).
  /// The 💎 debit is durable; energy is display-only/session-local (S60), so the
  /// refill shows this session — stated honestly in the Shop.
  void buyEnergyRefill() {
    if (!canBuyEnergyRefill) return;
    _diamonds = _diamondsModel.spend(
        balance: _diamonds, amount: PowerUpPrices.energyRefillCost);
    _energy = EnergyModel.cap;
    _energyAnchor = ref.read(clockProvider)();
    state = _derive();
    _persist();
  }

  /// 💎 price of a streak repair (surfaced to the Shop).
  int get streakRepairCost => PowerUpPrices.streakRepairCost;

  /// Whether the streak has LAPSED — a prior run exists but today's surfaced
  /// streak is 0 — so there is genuinely something to restore.
  bool get streakLapsed {
    final DateTime today = _today();
    return _streak > 0 &&
        _lastGoalMetDate != null &&
        _streakModel.current(
                streak: _streak, lastMet: _lastGoalMetDate, today: today) ==
            0;
  }

  /// Whether a lapsed streak can be repaired now (lapsed AND enough 💎).
  bool get canRepairStreak =>
      streakLapsed &&
      _diamondsModel.canSpend(
          balance: _diamonds, amount: PowerUpPrices.streakRepairCost);

  /// Restore a lapsed streak for [streakRepairCost] 💎 (E1 · R-I2/R-I4): re-
  /// anchors the last goal-met day to yesterday so the run resumes at its prior
  /// length. No-op when the streak is alive / never started or unaffordable.
  void repairStreak() {
    if (!canRepairStreak) return;
    _diamonds = _diamondsModel.spend(
        balance: _diamonds, amount: PowerUpPrices.streakRepairCost);
    final DateTime today = _today();
    _lastGoalMetDate = DateTime(today.year, today.month, today.day - 1);
    state = _derive();
    _persist();
  }

  /// 💎 price of a Double-XP boost (surfaced to the Shop).
  int get doubleXpCost => PowerUpPrices.doubleXpCost;

  /// Whether a Double-XP boost is currently running (clock-checked).
  bool get isDoubleXpActive {
    final DateTime? until = _xpBoostUntil;
    return until != null && ref.read(clockProvider)().isBefore(until);
  }

  /// Time left on the active Double-XP boost, or null when none is running.
  Duration? get doubleXpRemaining {
    final DateTime? until = _xpBoostUntil;
    if (until == null) return null;
    final Duration d = until.difference(ref.read(clockProvider)());
    return d > Duration.zero ? d : null;
  }

  /// Whether a Double-XP boost can be bought now: none active AND enough 💎.
  bool get canBuyDoubleXp =>
      !isDoubleXpActive &&
      _diamondsModel.canSpend(
          balance: _diamonds, amount: PowerUpPrices.doubleXpCost);

  /// Activate a Double-XP boost for [PowerUpPrices.doubleXpDuration] for
  /// [doubleXpCost] 💎 (E1 · R-I4 spend · R-I1 XP). No-op when one is already
  /// running or unaffordable. The 💎 debit is durable; the boost window is
  /// session-local (gone on relaunch) — stated honestly in the Shop. While
  /// active, every completed lesson earns 2× XP.
  void buyDoubleXp() {
    if (!canBuyDoubleXp) return;
    _diamonds = _diamondsModel.spend(
        balance: _diamonds, amount: PowerUpPrices.doubleXpCost);
    _xpBoostUntil =
        ref.read(clockProvider)().add(PowerUpPrices.doubleXpDuration);
    state = _derive();
    _persist();
  }

  /// Spend [amount] 💎 if affordable (E1 generic sink — e.g. cosmetics). Returns
  /// whether the debit happened; updates state + persists on success, and is a
  /// no-op (false) when unaffordable or [amount] is negative.
  bool trySpendDiamonds(int amount) {
    if (amount < 0 ||
        !_diamondsModel.canSpend(balance: _diamonds, amount: amount)) {
      return false;
    }
    _diamonds = _diamondsModel.spend(balance: _diamonds, amount: amount);
    state = _derive();
    _persist();
    return true;
  }

  /// Seed ability from a completed CAT placement (design spec §4.11 — the
  /// "Take a placement test" branch). Replaces the cold-start prior with the
  /// placement θ estimate (same IRT logit scale), clears any prior answer log
  /// so the placement defines the starting point, re-derives the CEFR level,
  /// and persists. [R-G4 · R-G7]
  void seedFromPlacement(double theta) {
    final LearnerSnapshot snapBefore = state;
    _placementTheta = theta;
    _log.clear();
    state = _derive();
    _persist();
    _stampMilestones(snapBefore);
  }

  /// Re-derive the surfaced snapshot for the CURRENT clock day WITHOUT mutating
  /// stored progress. The day-scoped surfaces (the lapsing streak + the
  /// xpToday reset) are computed in [_derive] against the injected clock, but a
  /// cached [Notifier] snapshot only recomputes on a mutation or rebuild — so
  /// the app shell calls this on resume to refresh them across a day boundary
  /// even when the learner has done nothing yet.
  void refreshDay() {
    final bool spent = _coverMissedDays(_today());
    state = _derive();
    if (spent) _persist();
  }

  /// Reset to the cold-start state (sign-out / testing). Clears in-memory state
  /// only — it deliberately does NOT wipe the durable store.
  void reset() {
    _log.clear();
    _placementTheta = null;
    _restoredTheta = null;
    _restoredPerSkill = const <String, double>{};
    _lessons = _xpTotal = _xpToday = _streak = _diamonds = _streakFreezes = 0;
    _xpWeek = 0;
    _energy = EnergyModel.cap;
    _energyAnchor = null;
    _xpTodayDate = null;
    _xpWeekStart = null;
    _lastGoalMetDate = null;
    _xpBoostUntil = null;
    state = _derive();
  }

  // ── Friend activity production (R-I9 / R-L8 / R-L11) ──────────────────────

  /// Broadcast a `leveledUp` friend-activity event when a graded answer just
  /// pushed the learner across a CEFR band (the REAL, theta-driven rise — never
  /// fabricated). Fire-and-forget + session-guarded: a guest (or the default
  /// UnavailableFriendsService) routes nothing, so flag-off is byte-identical.
  /// Map a snapshot onto the notification milestone metrics (mirrors the
  /// `notificationsProvider` bridge).
  static NotificationStats _notifStatsOf(LearnerSnapshot s) =>
      NotificationStats(
        lessonsCompleted: s.lessonsCompleted,
        xpTotal: s.xpTotal,
        streakDays: s.streakDays,
        cefrOrdinal: s.level.index,
      );

  /// Stamp any notification milestone genuinely crossed by this mutation with
  /// the real injected clock (D-13 per-row timestamps). Hydration/restore
  /// paths never call this, so restored milestones honestly stay unstamped.
  void _stampMilestones(LearnerSnapshot before) {
    ref.read(earnedStampsControllerProvider.notifier).stampCrossings(
        before: _notifStatsOf(before), after: _notifStatsOf(state));
  }

  void _maybeEmitLevelUp(CefrLevel before, CefrLevel after) {
    if (after.index <= before.index) return;
    if (ref.read(identityProvider).uid == null) return;
    unawaited(ref.read(friendsServiceProvider).emitActivity(
        FriendActivityType.leveledUp.name,
        summary: 'reached ${after.name.toUpperCase()}'));
  }

  /// Broadcast a `streak` friend-activity event when a completed lesson just
  /// advanced the goal-gated streak to a milestone length (avoids per-day feed
  /// spam). Same session guard + fire-and-forget as [_maybeEmitLevelUp].
  void _maybeEmitStreak(int before, int after) {
    if (after <= before || !_isStreakMilestone(after)) return;
    if (ref.read(identityProvider).uid == null) return;
    unawaited(ref.read(friendsServiceProvider).emitActivity(
        FriendActivityType.streak.name, summary: '$after-day streak'));
  }

  /// Publish the learner's REAL weekly league XP to friends (the durable,
  /// cross-user mirror) after a completed lesson moved it — and let the
  /// `publish_weekly_xp` definer emit `passedYouInLeague` to any friend just
  /// overtaken. Session-guarded + fire-and-forget: a guest (or the default
  /// UnavailableFriendsService) routes nothing, so flag-off is byte-identical.
  void _maybePublishWeeklyXp() {
    if (ref.read(identityProvider).uid == null) return;
    unawaited(
        ref.read(friendsServiceProvider).publishWeeklyXp(state.xpWeekEarned));
  }

  /// Streak lengths worth announcing to friends (keeps the feed meaningful).
  static bool _isStreakMilestone(int days) =>
      days == 3 ||
      days == 7 ||
      days == 14 ||
      days == 30 ||
      days == 50 ||
      (days > 0 && days % 100 == 0);

  // ── D2 retention (R-G5 / R-G6) ────────────────────────────────────────────

  /// Predicted FSRS recall probability averaged over the DISTINCT items reviewed
  /// this session, at a [horizonDays]-day horizon (D2 retention). Folds the
  /// in-memory review log per item through the REAL FSRS engine; null when
  /// nothing has been reviewed yet (honest "no data"). Session-scoped — the
  /// durable per-item scheduler with real review timestamps is go-live wiring.
  double? retentionEstimate({double horizonDays = 1.0}) {
    if (_log.isEmpty) return null;
    final Map<String, FsrsCard> cards = <String, FsrsCard>{};
    for (final ReviewLogEntry e in _log) {
      final FsrsCard card = cards[e.itemId] ?? const FsrsCard();
      cards[e.itemId] = _fsrs.schedule(card, e.grade, e.elapsedDays).card;
    }
    if (cards.isEmpty) return null;
    double sum = 0;
    for (final FsrsCard c in cards.values) {
      sum += _fsrs.retrievability(c, horizonDays);
    }
    return sum / cards.length;
  }

  /// Distinct items reviewed this session (the basis for [retentionEstimate]).
  int get reviewedItemCount =>
      _log.map((ReviewLogEntry e) => e.itemId).toSet().length;

  // ── Durable persistence (R-O1 / R-M3) ────────────────────────────────────

  /// Rehydrate xp / lessons / streak (+ last goal-met day) / diamonds / θ from
  /// the learner's `user_course` row. No-op for a guest (`uid == null`) or when
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
      final bool spent = _coverMissedDays(_today());
      state = _derive();
      if (spent) _persist();
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
    final Object? diamonds = row['diamonds'];
    if (diamonds is num) _diamonds = diamonds.toInt();
    final Object? freezes = row['streak_freezes'];
    if (freezes is num) _streakFreezes = freezes.toInt();
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
      'diamonds': _diamonds,
      'streak_freezes': _streakFreezes,
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
