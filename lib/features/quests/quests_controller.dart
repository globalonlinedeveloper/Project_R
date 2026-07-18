import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/services/quests/quests.dart';
import 'package:ratel/features/friends/friends_controller.dart';
import 'package:ratel/services/social/friends.dart';
import 'package:ratel/services/social/friend_quest.dart';
import 'package:ratel/services/social/friend_quest_service.dart';
import 'package:ratel/services/identity/identity.dart';

/// Bridges the REAL learner state + the chosen daily goal to the pure
/// [QuestsEngine] (design spec §4.4 [R-I7]). Recomputes whenever the learner's
/// XP / streak or the daily-goal setting changes, so the quest board reflects
/// genuine daily progress — a fresh day shows the quests open with real
/// progress, never a fabricated board. Read-only over the existing learner +
/// settings providers (it never mutates them).
final questsProvider = Provider<List<QuestProgress>>((ref) {
  final LearnerSnapshot snap = ref.watch(learnerControllerProvider);
  final int goal = ref.watch(appSettingsControllerProvider).dailyGoal;
  final QuestStats stats = QuestStats(
    xpToday: snap.xpToday,
    streakDays: snap.streakDays,
    dailyGoal: goal <= 0 ? 1 : goal,
  );
  return const QuestsEngine().evaluate(stats);
});

/// Count of genuinely-completed quests (for the section header).
final completedQuestsCountProvider = Provider<int>((ref) =>
    ref.watch(questsProvider).where((QuestProgress p) => p.done).length);

/// INC-QF1 view-model for an HONEST competitive friend-quest: the real friend
/// just ahead of the learner in this week's league. Every field comes from a
/// real [FriendRecord] (published `weekly_xp`); nothing is fabricated.
class FriendQuestView {
  const FriendQuestView({
    required this.handle,
    required this.displayName,
    required this.avatarEmoji,
    required this.myWeeklyXp,
    required this.friendWeeklyXp,
  });

  final String handle;
  final String displayName;
  final String avatarEmoji;
  final int myWeeklyXp;
  final int friendWeeklyXp;

  /// XP the learner needs to out-earn the rival this week (always > 0 — the
  /// rival is drawn from `whoPassedMeProvider`, i.e. strictly ahead).
  int get gap => (friendWeeklyXp - myWeeklyXp) < 0 ? 0 : friendWeeklyXp - myWeeklyXp;
}

/// INC-QF1: a real "out-earn @friend this week" quest built ONLY from live data
/// — the friend just ahead of the learner (real `weekly_xp` via
/// `publish_weekly_xp`). Returns null when there is no rival ahead (or no
/// friends / the friends backend is off, the shipped default) so the screen
/// keeps the honest coming-soon card. NEVER invents a partner.
final friendQuestProvider = Provider<FriendQuestView?>((ref) {
  final List<FriendRecord> ahead = ref.watch(whoPassedMeProvider);
  if (ahead.isEmpty) return null;
  // whoPassedMe is sorted by weekly XP desc, so the closest rival to out-earn
  // first is the one with the SMALLEST weekly XP still above me = the last.
  final FriendRecord rival = ahead.last;
  final String handle = rival.handle.trim();
  if (handle.isEmpty) return null; // no real handle -> nothing honest to show
  return FriendQuestView(
    handle: handle,
    displayName: rival.displayName,
    avatarEmoji: rival.avatarEmoji,
    myWeeklyXp: ref.watch(learnerControllerProvider).xpWeekEarned,
    friendWeeklyXp: rival.weeklyXp,
  );
});


/// INC-QF2: the signed-in user's stable id (`auth.uid()`), or null for a guest.
/// The co-op tile needs it to resolve the partner + my own contribution from a
/// seat-relative [FriendQuest].
final currentUidProvider =
    Provider<String?>((ref) => ref.watch(identityProvider).uid);

/// INC-QF2: whether a real co-op friend-quest backend is wired. Honest false
/// for guests / friends-off ⇒ the co-op surface stays hidden (never fabricated).
final coopServiceAvailableProvider =
    Provider<bool>((ref) => ref.watch(friendQuestServiceProvider).isAvailable);

/// INC-QF2: the caller's co-op friend-quests (pending / active / completed),
/// live from the SECURITY DEFINER RPCs. FutureProvider so the tile stays silent
/// while loading and degrades to the honest coming-soon on error. Progress is
/// SERVER-derived — this client only displays it.
final coopFriendQuestsProvider = FutureProvider<List<FriendQuest>>(
    (ref) async => ref.watch(friendQuestServiceProvider).list());

/// INC-QF2: pick the ONE co-op quest to surface for [myUid] from [all] — an
/// ACTIVE quest first, else an INCOMING invite (I am the partner), else an
/// OUTGOING invite (I created it), else null. Pure + testable; completed quests
/// are intentionally NOT surfaced here (the live tile shows live quests only).
FriendQuest? pickCoopQuest(List<FriendQuest> all, String myUid) {
  FriendQuest? active;
  FriendQuest? incoming;
  FriendQuest? outgoing;
  for (final FriendQuest q in all) {
    if (q.isActive) {
      active ??= q;
    } else if (q.isPending) {
      if (q.partnerId == myUid) {
        incoming ??= q;
      } else if (q.creatorId == myUid) {
        outgoing ??= q;
      }
    }
  }
  return active ?? incoming ?? outgoing;
}
