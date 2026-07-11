import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ratel/services/economy/outfits.dart';
import 'package:ratel/services/economy/outfits_store.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/preferences/settings_store.dart';
import 'package:ratel/services/progress/study_stats.dart';
import 'package:ratel/services/progress/study_stats_store.dart';
import 'package:ratel/services/progress/xp_history_store.dart';
import 'package:ratel/services/adventures/adventure_progress_store.dart';
import 'package:ratel/services/notifications/earned_stamps_store.dart';

/// Stage-3 cross-device SYNC decorators (U-lane, S110). Each wraps the existing
/// device-local store (SharedPreferences in `main`, in-memory in tests) and
/// mirrors writes into its own-row Supabase table. The seam contract is
/// unchanged — synchronous [load] stays instant (device cache), [save] is
/// write-through (local ALWAYS; remote best-effort when signed in), and
/// `hydrate()` (called once at boot) pulls the durable row, MERGES it with the
/// device state, and converges both sides. Guests ([_db] null or no session)
/// are byte-identical to the plain local store. Every remote failure is
/// swallowed: offline never blocks the app (fail-open to local, R-O1).
///
/// Merge rules (documented, deliberate):
/// - settings: DB row wins at hydrate when present (last-boot-wins), device
///   seeds the DB on first sync;
/// - outfits: `owned` = UNION (purchases are never lost), `selected` = DB when
///   a row exists;
/// - xp history: per-day MAX;
/// - study stats: per-counter MAX (cumulative floors, never double-counted).
/// - earned stamps: per-id EARLIEST (the first genuine crossing is the earn
///   moment; later devices never overwrite it);
/// - adventure progress: UNION (explored anywhere = explored).

// ---------------------------------------------------------------- settings

/// Own-row `user_settings` sync decorator.
class SupabaseSettingsStore implements SettingsStore {
  SupabaseSettingsStore(this._db, this._local);

  final SupabaseClient? _db;
  final SettingsStore _local;

  static const String table = 'user_settings';

  String? get _uid => _db?.auth.currentUser?.id;

  @override
  AppSettings load() => _local.load();

  @override
  Future<void> save(AppSettings settings) async {
    await _local.save(settings);
    final SupabaseClient? db = _db;
    final String? uid = _uid;
    if (db == null || uid == null) return;
    try {
      await db.from(table).upsert(settingsRowFor(settings, uid));
    } catch (_) {/* offline-tolerant */}
  }

  /// Boot-time pull: DB row present → it wins locally; absent → seed it from
  /// the device state (first sync from this account's first device).
  Future<void> hydrate() async {
    final SupabaseClient? db = _db;
    final String? uid = _uid;
    if (db == null || uid == null) return;
    try {
      final Map<String, dynamic>? row =
          await db.from(table).select().eq('user_id', uid).maybeSingle();
      if (row == null) {
        await db.from(table).upsert(settingsRowFor(_local.load(), uid));
        return;
      }
      await _local.save(settingsFromRow(row));
    } catch (_) {/* offline-tolerant */}
  }

  /// Pure: an [AppSettings] as its own-row `user_settings` row (RLS requires
  /// `user_id == auth.uid()`).
  static Map<String, Object?> settingsRowFor(AppSettings s, String userId) =>
      <String, Object?>{
        'user_id': userId,
        'high_contrast': s.highContrast,
        'sound': s.sound,
        'haptics': s.haptics,
        'daily_goal': s.dailyGoal,
        'theme_mode': s.themeMode.name,
        'reduce_motion': s.reduceMotion,
        'display_name': s.displayName,
        'world_theme': s.worldTheme.name,
        'read_notifications': (s.readNotifications.toList()..sort()),
        'muted_notifications': (s.mutedNotifications.toList()..sort()),
        'recent_searches': s.recentSearches,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

  /// Pure: a `user_settings` row back into [AppSettings]. Reuses
  /// [AppSettings.fromMap]'s parsing + enum-name fallbacks by re-encoding the
  /// arrays into the exact CSV shapes the prefs store persists.
  static AppSettings settingsFromRow(Map<String, dynamic> row) {
    List<String> strings(Object? v) =>
        v is List ? v.map((Object? e) => e.toString()).toList() : <String>[];
    return AppSettings.fromMap(<String, Object?>{
      'highContrast': row['high_contrast'] as bool?,
      'sound': row['sound'] as bool?,
      'haptics': row['haptics'] as bool?,
      'dailyGoal': row['daily_goal'] as int?,
      'themeMode': row['theme_mode'] as String?,
      'reduceMotion': row['reduce_motion'] as bool?,
      'displayName': row['display_name'] as String?,
      'worldTheme': row['world_theme'] as String?,
      'readNotifications': strings(row['read_notifications']).join(','),
      'mutedNotifications': strings(row['muted_notifications']).join(','),
      'recentSearches':
          strings(row['recent_searches']).map(Uri.encodeComponent).join(','),
    });
  }
}

// ----------------------------------------------------------------- outfits

/// Own-row `user_outfits` sync decorator (owned outfits are gem purchases —
/// durable; never lost to a device wipe).
class SupabaseOutfitsStore implements OutfitsStore {
  SupabaseOutfitsStore(this._db, this._local);

  final SupabaseClient? _db;
  final OutfitsStore _local;

  static const String table = 'user_outfits';

  String? get _uid => _db?.auth.currentUser?.id;

  @override
  OutfitState load() => _local.load();

  @override
  Future<void> save(OutfitState state) async {
    await _local.save(state);
    final SupabaseClient? db = _db;
    final String? uid = _uid;
    if (db == null || uid == null) return;
    try {
      await db.from(table).upsert(outfitsRowFor(state, uid));
    } catch (_) {/* offline-tolerant */}
  }

  /// Boot-time pull: UNION the owned sets (a purchase on any device sticks);
  /// `selected` follows the DB row when one exists. Pushes the merged result
  /// back when it grew the DB set.
  Future<void> hydrate() async {
    final SupabaseClient? db = _db;
    final String? uid = _uid;
    if (db == null || uid == null) return;
    try {
      final Map<String, dynamic>? row =
          await db.from(table).select().eq('user_id', uid).maybeSingle();
      final OutfitState local = _local.load();
      if (row == null) {
        await db.from(table).upsert(outfitsRowFor(local, uid));
        return;
      }
      final OutfitState remote = outfitsFromRow(row);
      final OutfitState merged = mergeOutfits(local: local, remote: remote);
      await _local.save(merged);
      if (!setEqualsStrings(merged.owned, remote.owned)) {
        await db.from(table).upsert(outfitsRowFor(merged, uid));
      }
    } catch (_) {/* offline-tolerant */}
  }

  /// Pure union merge: owned = local ∪ remote; selected = remote (the durable
  /// row wins at boot; a later local change write-throughs anyway).
  static OutfitState mergeOutfits(
          {required OutfitState local, required OutfitState remote}) =>
      OutfitState(
        owned: <String>{...local.owned, ...remote.owned},
        selected: remote.selected,
      );

  /// Pure: set equality without importing flutter foundation here.
  static bool setEqualsStrings(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);

  /// Pure: an [OutfitState] as its own-row `user_outfits` row.
  static Map<String, Object?> outfitsRowFor(OutfitState s, String userId) =>
      <String, Object?>{
        'user_id': userId,
        'owned': (s.owned.toList()..sort()),
        'selected': s.selected,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

  /// Pure: a `user_outfits` row back into an [OutfitState] ('classic' is
  /// always re-baked in by the model's constructor).
  static OutfitState outfitsFromRow(Map<String, dynamic> row) => OutfitState(
        owned: row['owned'] is List
            ? (row['owned'] as List).map((Object? e) => e.toString()).toSet()
            : const <String>{},
        selected: row['selected'] as String? ?? 'classic',
      );
}

// ------------------------------------------------------------- xp history

/// Own-row `user_progress_daily` sync decorator for the per-day XP map
/// (`YYYY-MM-DD` -> xp). Saves are DELTA-pushed: only days whose value changed
/// since the last push leave the device (one row per lesson in steady state,
/// never the whole history).
class SupabaseXpHistoryStore implements XpHistoryStore {
  SupabaseXpHistoryStore(this._db, this._local);

  final SupabaseClient? _db;
  final XpHistoryStore _local;

  static const String table = 'user_progress_daily';

  final Map<String, int> _pushed = <String, int>{};

  String? get _uid => _db?.auth.currentUser?.id;

  @override
  Map<String, int> load() => _local.load();

  @override
  Future<void> save(Map<String, int> history) async {
    await _local.save(history);
    final SupabaseClient? db = _db;
    final String? uid = _uid;
    if (db == null || uid == null) return;
    final List<Map<String, Object?>> rows = xpRowsFor(
      changedDays(previous: _pushed, next: history),
      uid,
    );
    if (rows.isEmpty) return;
    try {
      await db.from(table).upsert(rows, onConflict: 'user_id,day');
      _pushed
        ..clear()
        ..addAll(history);
    } catch (_) {/* offline-tolerant: retry rides the next save */}
  }

  /// Boot-time pull: per-day MAX merge of device + durable history, written
  /// back to both sides so they converge.
  Future<void> hydrate() async {
    final SupabaseClient? db = _db;
    final String? uid = _uid;
    if (db == null || uid == null) return;
    try {
      final List<Map<String, dynamic>> rows =
          await db.from(table).select('day, xp').eq('user_id', uid);
      final Map<String, int> remote = xpHistoryFromRows(rows);
      final Map<String, int> local = _local.load();
      final Map<String, int> merged = mergeXpHistory(local, remote);
      await _local.save(merged);
      final Map<String, int> toPush = changedDays(previous: remote, next: merged);
      if (toPush.isNotEmpty) {
        await db.from(table).upsert(xpRowsFor(toPush, uid), onConflict: 'user_id,day');
      }
      _pushed
        ..clear()
        ..addAll(merged);
    } catch (_) {/* offline-tolerant */}
  }

  /// Pure: per-day MAX (neither device's earned XP is ever shrunk).
  static Map<String, int> mergeXpHistory(
      Map<String, int> a, Map<String, int> b) {
    final Map<String, int> out = <String, int>{...a};
    b.forEach((String day, int xp) {
      final int? have = out[day];
      out[day] = have == null || xp > have ? xp : have;
    });
    return out;
  }

  /// Pure: the subset of [next] whose value differs from [previous].
  static Map<String, int> changedDays(
      {required Map<String, int> previous, required Map<String, int> next}) {
    final Map<String, int> out = <String, int>{};
    next.forEach((String day, int xp) {
      if (previous[day] != xp) out[day] = xp;
    });
    return out;
  }

  /// Pure: day->xp entries as own-row `user_progress_daily` rows.
  static List<Map<String, Object?>> xpRowsFor(
          Map<String, int> history, String userId) =>
      <Map<String, Object?>>[
        for (final MapEntry<String, int> e in history.entries)
          <String, Object?>{
            'user_id': userId,
            'day': e.key,
            'xp': e.value,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
      ];

  /// Pure: `user_progress_daily` rows back into the day->xp map (dates come
  /// back ISO `YYYY-MM-DD`, matching the seam's keys).
  static Map<String, int> xpHistoryFromRows(List<Map<String, dynamic>> rows) =>
      <String, int>{
        for (final Map<String, dynamic> r in rows)
          if (r['day'] != null)
            r['day'].toString().substring(0, 10): (r['xp'] as num?)?.toInt() ?? 0,
      };
}

// ------------------------------------------------------------ study stats

/// Own-row `user_study_stats` sync decorator for the lifetime counters.
class SupabaseStudyStatsStore implements StudyStatsStore {
  SupabaseStudyStatsStore(this._db, this._local);

  final SupabaseClient? _db;
  final StudyStatsStore _local;

  static const String table = 'user_study_stats';

  String? get _uid => _db?.auth.currentUser?.id;

  @override
  StudyStats load() => _local.load();

  @override
  Future<void> save(StudyStats stats) async {
    await _local.save(stats);
    final SupabaseClient? db = _db;
    final String? uid = _uid;
    if (db == null || uid == null) return;
    try {
      await db.from(table).upsert(statsRowFor(stats, uid));
    } catch (_) {/* offline-tolerant */}
  }

  /// Boot-time pull: per-counter MAX merge (cumulative floors; never
  /// double-counts a device that already synced), converged both sides.
  Future<void> hydrate() async {
    final SupabaseClient? db = _db;
    final String? uid = _uid;
    if (db == null || uid == null) return;
    try {
      final Map<String, dynamic>? row =
          await db.from(table).select().eq('user_id', uid).maybeSingle();
      final StudyStats local = _local.load();
      if (row == null) {
        await db.from(table).upsert(statsRowFor(local, uid));
        return;
      }
      final StudyStats remote = statsFromRow(row);
      final StudyStats merged = mergeStudyStats(local, remote);
      await _local.save(merged);
      if (merged != remote) {
        await db.from(table).upsert(statsRowFor(merged, uid));
      }
    } catch (_) {/* offline-tolerant */}
  }

  /// Pure: per-counter MAX, re-clamped so `correct <= total` always holds
  /// (the DB check constraint mirrors it).
  static StudyStats mergeStudyStats(StudyStats a, StudyStats b) {
    final int total = a.total > b.total ? a.total : b.total;
    final int correctRaw = a.correct > b.correct ? a.correct : b.correct;
    return StudyStats(
      correct: correctRaw > total ? total : correctRaw,
      total: total,
      studySeconds:
          a.studySeconds > b.studySeconds ? a.studySeconds : b.studySeconds,
    );
  }

  /// Pure: a [StudyStats] as its own-row `user_study_stats` row.
  static Map<String, Object?> statsRowFor(StudyStats s, String userId) =>
      <String, Object?>{
        'user_id': userId,
        'correct': s.correct,
        'total': s.total,
        'study_seconds': s.studySeconds,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

  /// Pure: a `user_study_stats` row back into [StudyStats].
  static StudyStats statsFromRow(Map<String, dynamic> row) => StudyStats(
        correct: (row['correct'] as num?)?.toInt() ?? 0,
        total: (row['total'] as num?)?.toInt() ?? 0,
        studySeconds: (row['study_seconds'] as num?)?.toInt() ?? 0,
      );
}

// ------------------------------------------------------- earned stamps (L-3)

/// Own-row `user_earned_stamps` sync decorator (S131d — L-3). Mirrors
/// [SupabaseXpHistoryStore]: local always, remote best-effort, boot [hydrate]
/// converges both sides. Merge = per-id EARLIEST stamp (the first genuine
/// crossing IS the earn moment — a second device that re-derives the milestone
/// later never overwrites history; honesty rule from D-13/S126).
class SupabaseEarnedStampsStore implements EarnedStampsStore {
  SupabaseEarnedStampsStore(this._db, this._local);

  final SupabaseClient? _db;
  final EarnedStampsStore _local;

  static const String table = 'user_earned_stamps';

  final Map<String, DateTime> _pushed = <String, DateTime>{};

  String? get _uid => _db?.auth.currentUser?.id;

  @override
  Map<String, DateTime> load() => _local.load();

  @override
  Future<void> save(Map<String, DateTime> stamps) async {
    await _local.save(stamps);
    final SupabaseClient? db = _db;
    final String? uid = _uid;
    if (db == null || uid == null) return;
    final List<Map<String, Object?>> rows =
        stampRowsFor(changedStamps(previous: _pushed, next: stamps), uid);
    if (rows.isEmpty) return;
    try {
      await db
          .from(table)
          .upsert(rows, onConflict: 'user_id,notification_id');
      _pushed
        ..clear()
        ..addAll(stamps);
    } catch (_) {/* offline-tolerant: retry rides the next save */}
  }

  /// Boot-time pull: EARLIEST-wins merge of device + durable stamps, written
  /// back to both sides so they converge.
  Future<void> hydrate() async {
    final SupabaseClient? db = _db;
    final String? uid = _uid;
    if (db == null || uid == null) return;
    try {
      final List<Map<String, dynamic>> rows = await db
          .from(table)
          .select('notification_id, earned_at')
          .eq('user_id', uid);
      final Map<String, DateTime> remote = stampsFromRows(rows);
      final Map<String, DateTime> merged =
          mergeStamps(_local.load(), remote);
      await _local.save(merged);
      final Map<String, DateTime> toPush =
          changedStamps(previous: remote, next: merged);
      if (toPush.isNotEmpty) {
        await db
            .from(table)
            .upsert(stampRowsFor(toPush, uid),
                onConflict: 'user_id,notification_id');
      }
      _pushed
        ..clear()
        ..addAll(merged);
    } catch (_) {/* offline-tolerant */}
  }

  /// Pure: per-id EARLIEST (the first genuine crossing wins forever).
  static Map<String, DateTime> mergeStamps(
      Map<String, DateTime> a, Map<String, DateTime> b) {
    final Map<String, DateTime> out = <String, DateTime>{...a};
    b.forEach((String id, DateTime at) {
      final DateTime? have = out[id];
      out[id] = have == null || at.isBefore(have) ? at : have;
    });
    return out;
  }

  /// Pure: the subset of [next] whose value differs from [previous].
  static Map<String, DateTime> changedStamps(
      {required Map<String, DateTime> previous,
      required Map<String, DateTime> next}) {
    final Map<String, DateTime> out = <String, DateTime>{};
    next.forEach((String id, DateTime at) {
      if (previous[id] != at) out[id] = at;
    });
    return out;
  }

  /// Pure: id->moment entries as own-row `user_earned_stamps` rows.
  static List<Map<String, Object?>> stampRowsFor(
          Map<String, DateTime> stamps, String userId) =>
      <Map<String, Object?>>[
        for (final MapEntry<String, DateTime> e in stamps.entries)
          <String, Object?>{
            'user_id': userId,
            'notification_id': e.key,
            'earned_at': e.value.toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
      ];

  /// Pure: rows back into the id->moment map; malformed rows are skipped,
  /// never faked (mirrors the Prefs store's posture).
  static Map<String, DateTime> stampsFromRows(
      List<Map<String, dynamic>> rows) {
    final Map<String, DateTime> out = <String, DateTime>{};
    for (final Map<String, dynamic> r in rows) {
      final Object? id = r['notification_id'];
      final Object? at = r['earned_at'];
      if (id is! String || id.isEmpty || at is! String) continue;
      final DateTime? parsed = DateTime.tryParse(at);
      if (parsed == null) continue;
      out[id] = parsed.toUtc();
    }
    return out;
  }
}

// -------------------------------------------- adventure exploration (L-3/L-4)

/// Own-row `user_adventure_progress` sync decorator (S131d — closes L-4's
/// sync tail). Merge = UNION: an adventure genuinely explored on ANY device
/// stays explored (ids are only ever added by reaching a real ending; nothing
/// is fabricated by merging).
class SupabaseAdventureProgressStore implements AdventureProgressStore {
  SupabaseAdventureProgressStore(this._db, this._local);

  final SupabaseClient? _db;
  final AdventureProgressStore _local;

  static const String table = 'user_adventure_progress';

  final Set<String> _pushed = <String>{};

  String? get _uid => _db?.auth.currentUser?.id;

  @override
  Set<String> load() => _local.load();

  @override
  Future<void> save(Set<String> explored) async {
    await _local.save(explored);
    final SupabaseClient? db = _db;
    final String? uid = _uid;
    if (db == null || uid == null) return;
    final List<Map<String, Object?>> rows =
        exploredRowsFor(explored.difference(_pushed), uid);
    if (rows.isEmpty) return;
    try {
      await db
          .from(table)
          .upsert(rows, onConflict: 'user_id,scenario_id');
      _pushed
        ..clear()
        ..addAll(explored);
    } catch (_) {/* offline-tolerant: retry rides the next save */}
  }

  /// Boot-time pull: UNION of device + durable explored sets, written back
  /// to both sides so they converge.
  Future<void> hydrate() async {
    final SupabaseClient? db = _db;
    final String? uid = _uid;
    if (db == null || uid == null) return;
    try {
      final List<Map<String, dynamic>> rows = await db
          .from(table)
          .select('scenario_id')
          .eq('user_id', uid);
      final Set<String> remote = exploredFromRows(rows);
      final Set<String> merged = _local.load().union(remote);
      await _local.save(merged);
      final Set<String> toPush = merged.difference(remote);
      if (toPush.isNotEmpty) {
        await db
            .from(table)
            .upsert(exploredRowsFor(toPush, uid),
                onConflict: 'user_id,scenario_id');
      }
      _pushed
        ..clear()
        ..addAll(merged);
    } catch (_) {/* offline-tolerant */}
  }

  /// Pure: explored ids as own-row `user_adventure_progress` rows.
  static List<Map<String, Object?>> exploredRowsFor(
          Set<String> ids, String userId) =>
      <Map<String, Object?>>[
        for (final String id in ids.toList()..sort())
          <String, Object?>{
            'user_id': userId,
            'scenario_id': id,
          },
      ];

  /// Pure: rows back into the explored-id set; malformed rows skipped.
  static Set<String> exploredFromRows(List<Map<String, dynamic>> rows) =>
      <String>{
        for (final Map<String, dynamic> r in rows)
          if (r['scenario_id'] is String &&
              (r['scenario_id'] as String).isNotEmpty)
            r['scenario_id'] as String,
      };
}
