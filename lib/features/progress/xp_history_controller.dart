import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/services/data_access/data_access.dart' show clockProvider;
import 'package:ratel/services/progress/xp_history.dart';
import 'package:ratel/services/progress/xp_history_store.dart';

export 'package:ratel/services/progress/xp_history.dart' show DayXp;

/// Bridges the pure [XpHistoryModel] to the UI + the device-local store seam
/// (D1 · R-G6 / R-L14). Loads the recorded history at build, records each
/// lesson's earned XP into TODAY's bucket against the injected clock, prunes to
/// the retention window, and writes through. Device-local for everyone (guest
/// included) — mirrors the `AppSettings` persistence, not the uid-gated
/// `user_course`. Holds only REAL XP; inactive days stay honestly zero.
class XpHistoryController extends Notifier<Map<String, int>> {
  static const XpHistoryModel _model = XpHistoryModel();

  @override
  Map<String, int> build() => ref.read(xpHistoryStoreProvider).load();

  DateTime _today() {
    final DateTime now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  /// Add [xp] to today's bucket and write through. Non-positive XP is ignored
  /// (no-op), so nothing fake is ever recorded.
  void recordToday(int xp) {
    final Map<String, int> next =
        _model.record(history: state, day: _today(), xp: xp);
    if (identical(next, state)) return;
    state = next;
    // Best-effort device-local write; never blocks the lesson flow.
    ref.read(xpHistoryStoreProvider).save(next);
  }

  /// The last [n] days (oldest -> newest), zero-filled for inactive days.
  List<DayXp> lastDays({int n = 7}) =>
      _model.lastDays(history: state, today: _today(), n: n);

  /// Sum of recorded XP across the last [n] days.
  int totalOver({int n = 7}) =>
      _model.totalOver(history: state, today: _today(), n: n);
}

final xpHistoryControllerProvider =
    NotifierProvider<XpHistoryController, Map<String, int>>(
        XpHistoryController.new);

/// The last 7 days of recorded XP (oldest -> newest), recomputed when the
/// history changes. Honest zeros for inactive days (never fabricated).
final last7DaysXpProvider = Provider<List<DayXp>>((ref) {
  ref.watch(xpHistoryControllerProvider);
  return ref.read(xpHistoryControllerProvider.notifier).lastDays();
});
