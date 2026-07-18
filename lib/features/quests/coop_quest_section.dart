import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/services/social/friend_quest.dart';
import 'package:ratel/services/social/friend_quest_service.dart';
import 'package:ratel/features/quests/quests_controller.dart';

/// INC-QF2 [R-I9 / R-L8 / R-K6 / R-M3] — the CO-OP friend-quest surface,
/// rendered inside the Quests FRIEND QUEST section (below the header, above the
/// QF1 competitive tile).
///
/// Honesty contract (mirrors the rest of the social surface):
///  * hidden entirely (`SizedBox.shrink`) when the co-op backend is unavailable
///    (guest / friends-off) or while the live list is loading or errored — never
///    a fabricated partner or progress;
///  * ACTIVE quest → a progress tile ("Co-op with @bob · 7 of 12 lessons"),
///    progress SERVER-derived (this client only displays it);
///  * INCOMING invite (I am the partner) → an accept / decline tile;
///  * OUTGOING invite (I created it) → a muted "waiting to accept" tile;
///  * nothing live → a "start a co-op quest" row that opens the invite sheet
///    (goal is a fixed 12 combined lessons; reward is the flat 3💎 on the
///    server + the device-local credit added in the credit increment).
class CoopQuestSection extends ConsumerWidget {
  const CoopQuestSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Honest gate: no real co-op backend ⇒ show nothing at all.
    if (!ref.watch(coopServiceAvailableProvider)) {
      return const SizedBox.shrink();
    }
    final String? myUid = ref.watch(currentUidProvider);
    return ref.watch(coopFriendQuestsProvider).maybeWhen(
          data: (List<FriendQuest> list) {
            final FriendQuest? q =
                myUid == null ? null : pickCoopQuest(list, myUid);
            if (q == null) return _wrap(_startRow(context, ref));
            if (q.isActive) return _wrap(_progressTile(context, myUid!, q));
            // pending: incoming (I am the partner) vs outgoing (I created it).
            if (q.partnerId == myUid) {
              return _wrap(_inviteTile(context, ref, q));
            }
            return _wrap(_waitingTile(context, myUid!, q));
          },
          // Loading / error: honest silence — the QF1 tile / coming-soon shows.
          orElse: () => const SizedBox.shrink(),
        );
  }

  // Every shown variant carries its own bottom gap so it never crowds the QF1
  // tile below; nothing-to-show returns shrink (no gap).
  Widget _wrap(Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: RatelSpace.sm),
        child: child,
      );

  Widget _progressTile(BuildContext context, String myUid, FriendQuest q) {
    final String handle = q.otherHandle(myUid);
    return RatelCard(
      key: const ValueKey<String>('coop-quest-tile'),
      color: context.palette.cream2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('🤝', style: TextStyle(fontSize: 22)),
              const SizedBox(width: RatelSpace.md),
              Expanded(
                child: Text(
                  context.l10n
                      .questsCoopProgress(handle, q.combinedProgress, q.goalLessons),
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      color: context.palette.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: RatelSpace.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(RatelRadius.pill),
            child: LinearProgressIndicator(
              value: q.fraction,
              minHeight: 8,
              backgroundColor: context.palette.white,
              valueColor: const AlwaysStoppedAnimation<Color>(RatelColors.teal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inviteTile(BuildContext context, WidgetRef ref, FriendQuest q) =>
      RatelCard(
        key: const ValueKey<String>('coop-invite-tile'),
        color: context.palette.cream2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Text('🤝', style: TextStyle(fontSize: 22)),
                const SizedBox(width: RatelSpace.md),
                Expanded(
                  child: Text(
                    context.l10n.questsCoopInvited(q.creatorHandle),
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.small,
                        color: context.palette.ink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: RatelSpace.sm),
            Row(
              children: <Widget>[
                _pill(
                  context,
                  key: 'coop-accept',
                  label: context.l10n.questsCoopAccept,
                  filled: true,
                  onTap: () => _respond(ref, q.id, accept: true),
                ),
                const SizedBox(width: RatelSpace.sm),
                _pill(
                  context,
                  key: 'coop-decline',
                  label: context.l10n.questsCoopDecline,
                  filled: false,
                  onTap: () => _respond(ref, q.id, accept: false),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _waitingTile(BuildContext context, String myUid, FriendQuest q) =>
      RatelCard(
        key: const ValueKey<String>('coop-waiting-tile'),
        color: context.palette.cream2,
        child: Row(
          children: <Widget>[
            const Text('⏳', style: TextStyle(fontSize: 22)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Text(
                context.l10n.questsCoopWaiting(q.otherHandle(myUid)),
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    color: context.palette.muted),
              ),
            ),
          ],
        ),
      );

  Widget _startRow(BuildContext context, WidgetRef ref) => RatelListRow(
        key: const ValueKey<String>('coop-start-row'),
        leadingEmoji: '🤝',
        leadingColor: RatelColors.teal,
        title: context.l10n.questsCoopStart,
        subtitle: context.l10n.questsCoopStartHint,
        onTap: () => _openInvite(context, ref),
      );

  Widget _pill(
    BuildContext context, {
    required String key,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        key: ValueKey<String>(key),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: RatelSpace.lg, vertical: RatelSpace.xs),
          decoration: BoxDecoration(
            color: filled ? RatelColors.teal : context.palette.white,
            borderRadius: BorderRadius.circular(RatelRadius.pill),
            border: Border.all(color: context.palette.border),
          ),
          child: Text(
            label,
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                fontSize: RatelType.small,
                color: filled ? Colors.white : context.palette.ink),
          ),
        ),
      );

  Future<void> _respond(WidgetRef ref, String id, {required bool accept}) async {
    await ref.read(friendQuestServiceProvider).respond(id, accept: accept);
    ref.invalidate(coopFriendQuestsProvider);
  }

  Future<void> _openInvite(BuildContext context, WidgetRef ref) async {
    final String? handle = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.palette.white,
      builder: (BuildContext _) => const _InviteSheet(),
    );
    if (handle == null || handle.trim().isEmpty) return;
    final FriendQuest? created =
        await ref.read(friendQuestServiceProvider).create(handle);
    if (created == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.questsCoopInviteError)),
        );
      }
      return;
    }
    ref.invalidate(coopFriendQuestsProvider);
  }
}

/// The invite bottom-sheet: type a friend's @handle and send. Returns the raw
/// handle to the caller (which calls `create`, goal fixed at 12) or null on
/// cancel. The RPC re-normalizes + resolves the handle server-side.
class _InviteSheet extends StatefulWidget {
  const _InviteSheet();

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: RatelSpace.lg,
        right: RatelSpace.lg,
        top: RatelSpace.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + RatelSpace.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.questsCoopInviteTitle,
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                fontSize: RatelType.cardTitle,
                color: context.palette.ink),
          ),
          const SizedBox(height: RatelSpace.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: RatelSpace.lg),
            decoration: BoxDecoration(
              color: context.palette.white,
              borderRadius: BorderRadius.circular(RatelRadius.pill),
              border: Border.all(color: context.palette.border),
            ),
            child: Row(
              children: <Widget>[
                const Text('🤝', style: TextStyle(fontSize: 16)),
                const SizedBox(width: RatelSpace.sm),
                Expanded(
                  child: TextField(
                    key: const ValueKey<String>('coop-invite-field'),
                    controller: _controller,
                    autofocus: true,
                    onSubmitted: (_) => _send(),
                    textInputAction: TextInputAction.send,
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.body,
                        color: context.palette.ink),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: context.l10n.questsCoopInviteHint,
                      hintStyle: TextStyle(
                          fontFamily: RatelFont.body,
                          fontSize: RatelType.body,
                          color: context.palette.muted),
                    ),
                  ),
                ),
                GestureDetector(
                  key: const ValueKey<String>('coop-invite-send'),
                  onTap: _send,
                  child: Text(
                    context.l10n.questsCoopInviteSend,
                    style: TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.extraBold,
                        fontSize: RatelType.body,
                        color: context.palette.ink),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
