import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/features/notifications/earned_stamps_controller.dart';
import 'package:ratel/services/notifications/notifications.dart';

/// Bridges the REAL learner state + the persisted read-set to the pure
/// [NotificationsEngine] (R-L11 inbox — design spec §4.5 / §6). The feed
/// recomputes whenever the learner progresses or an item is marked read, so a
/// fresh account is an honest EMPTY inbox, never a fabricated feed. Mirrors the
/// `achievementsProvider` bridge.
NotificationStats _statsOf(LearnerSnapshot snap) => NotificationStats(
      lessonsCompleted: snap.lessonsCompleted,
      xpTotal: snap.xpTotal,
      streakDays: snap.streakDays,
      cefrOrdinal: snap.level.index,
    );

/// The projected inbox (biggest-earned-milestone first, each with its read
/// flag). Read-state comes from the persisted [AppSettings].
final notificationsProvider = Provider<List<AppNotification>>((ref) {
  final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
  final Set<String> read =
      ref.watch(appSettingsControllerProvider).readNotifications;
  // Real device-local earn moments (D-13) — absent ids honestly carry no label.
  final Map<String, DateTime> earnedAt =
      ref.watch(earnedStampsControllerProvider);
  return const NotificationsEngine()
      .project(_statsOf(snap), read, earnedAt: earnedAt);
});

/// Count of earned-but-unseen notifications (drives the Profile row badge).
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
  final Set<String> read =
      ref.watch(appSettingsControllerProvider).readNotifications;
  return const NotificationsEngine().unreadCount(_statsOf(snap), read);
});

/// All currently-earned ids — the screen passes these to "mark all read".
final earnedNotificationIdsProvider = Provider<Set<String>>((ref) =>
    const NotificationsEngine()
        .earnedIds(_statsOf(ref.watch(learnerControllerProvider))));
