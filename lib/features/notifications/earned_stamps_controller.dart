import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/services/data_access/data_access.dart'
    show clockProvider;
import 'package:ratel/services/notifications/earned_stamps_store.dart';
import 'package:ratel/services/notifications/notifications.dart';

export 'package:ratel/services/notifications/earned_stamps_store.dart'
    show
        EarnedStampsStore,
        InMemoryEarnedStampsStore,
        earnedStampsStoreProvider;

/// Bridges the pure [NotificationsEngine] milestone diff to the device-local
/// earn-stamp store (D-13 · R-L11 per-row timestamps). Holds `notification id
/// -> the REAL moment the learner crossed that threshold`, recorded against
/// the injected clock AT the crossing (`LearnerController` calls
/// [stampCrossings] from its mutation paths) and written through. Device-local
/// for everyone (guest included) — mirrors `XpHistoryController`, not the
/// uid-gated `user_course`.
///
/// HONESTY (charter "don't fake depth"): hydration/restore paths never stamp,
/// so a milestone earned before this shipped (or on another device) shows NO
/// time label rather than a fabricated one. A milestone that lapses (streak,
/// level) and is genuinely re-earned re-stamps at the new crossing.
class EarnedStampsController extends Notifier<Map<String, DateTime>> {
  static const NotificationsEngine _engine = NotificationsEngine();

  @override
  Map<String, DateTime> build() => ref.read(earnedStampsStoreProvider).load();

  /// Stamp every milestone crossing false→true between [before] and [after]
  /// with the injected clock's now (UTC). Overwrites a stale stamp on a
  /// genuine RE-crossing; a no-op when nothing newly crossed.
  void stampCrossings({
    required NotificationStats before,
    required NotificationStats after,
  }) {
    final Set<String> crossed = _engine.newlyEarned(before, after);
    if (crossed.isEmpty) return;
    final DateTime now = ref.read(clockProvider)().toUtc();
    final Map<String, DateTime> next = <String, DateTime>{
      ...state,
      for (final String id in crossed) id: now,
    };
    state = next;
    // Best-effort device-local write; never blocks the lesson flow.
    ref.read(earnedStampsStoreProvider).save(next);
  }
}

final earnedStampsControllerProvider =
    NotifierProvider<EarnedStampsController, Map<String, DateTime>>(
        EarnedStampsController.new);
