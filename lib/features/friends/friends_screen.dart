import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/features/friends/friends_controller.dart';
import 'package:ratel/services/social/friends.dart';

/// Friends / social screen (👥, design spec §4 / R-I9 / R-L8: followers, friend
/// activity, "passed you"). Replaces the old `/friends` ComingSoon stub with a
/// REAL screen driven by the pure [FriendsEngine] over the learner's own
/// relationship state.
///
/// HONESTY (charter "don't fake depth", mirroring the Leagues solo cohort): the
/// graph is the learner's REAL relationships — a fresh account shows it
/// genuinely EMPTY (never a fabricated friend or bot). Send / accept / remove /
/// block are real engine operations on real state; they persist for a signed-in
/// learner and sync across users once the durable Supabase graph + RLS go live
/// (the same flagged go-live wiring as every other R-O1 counter), as the note
/// states plainly.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  static const FriendsEngine _engine = FriendsEngine();
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add(String raw) {
    final String handle = _engine.normalizeHandle(raw);
    if (!_engine.isValidHandle(raw)) {
      setState(() => _error = context.l10n.friendsHandleInvalid);
      return;
    }
    final List<FriendRecord> rels =
        ref.read(friendsControllerProvider).relationships;
    final FriendRecord target = FriendRecord(
      userId: handle,
      handle: handle,
      displayName: '@$handle',
      status: FriendStatus.none,
    );
    if (!_engine.canSendRequest(rels, target)) {
      setState(() => _error = context.l10n.friendsAlreadyConnected(handle));
      return;
    }
    ref.read(friendsControllerProvider.notifier).sendRequest(target);
    _controller.clear();
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final List<FriendRecord> friends = ref.watch(friendsListProvider);
    final List<FriendRecord> incoming = ref.watch(incomingRequestsProvider);
    final List<FriendRecord> outgoing = ref.watch(outgoingRequestsProvider);
    final List<FriendActivity> feed = ref.watch(friendFeedProvider);
    final Set<String> passed = ref
        .watch(whoPassedMeProvider)
        .map((FriendRecord r) => r.userId)
        .toSet();

    return Scaffold(
      backgroundColor: context.palette.cream,
      appBar: AppBar(
        backgroundColor: context.palette.cream,
        surfaceTintColor: context.palette.cream,
        elevation: 0,
        leading: IconButton(
          icon: Icon(RatelIcons.arrowBack, color: context.palette.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.l10n.profileFriends,
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            color: context.palette.ink,
            fontSize: RatelType.cardTitle,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(RatelSpace.screen, RatelSpace.sm,
              RatelSpace.screen, RatelSpace.xl),
          children: <Widget>[
            _addField(context),
            if (_error != null) ...<Widget>[
              const SizedBox(height: RatelSpace.sm),
              Text(_error!,
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      color: context.palette.ink)),
            ],
            const SizedBox(height: RatelSpace.lg),
            if (incoming.isNotEmpty) ...<Widget>[
              RatelSectionHeader(label: context.l10n.friendsRequests),
              const SizedBox(height: RatelSpace.sm),
              for (final FriendRecord r in incoming) ...<Widget>[
                _requestRow(context, r),
                const SizedBox(height: RatelSpace.sm),
              ],
              const SizedBox(height: RatelSpace.md),
            ],
            RatelSectionHeader(label: context.l10n.friendsYourFriends),
            const SizedBox(height: RatelSpace.sm),
            if (friends.isEmpty)
              _emptyFriends(context)
            else
              for (final FriendRecord f in friends) ...<Widget>[
                _friendRow(context, f, passed.contains(f.userId)),
                const SizedBox(height: RatelSpace.sm),
              ],
            if (outgoing.isNotEmpty) ...<Widget>[
              const SizedBox(height: RatelSpace.md),
              RatelSectionHeader(label: context.l10n.friendsPending),
              const SizedBox(height: RatelSpace.sm),
              for (final FriendRecord r in outgoing) ...<Widget>[
                _pendingRow(context, r),
                const SizedBox(height: RatelSpace.sm),
              ],
            ],
            if (feed.isNotEmpty) ...<Widget>[
              const SizedBox(height: RatelSpace.md),
              RatelSectionHeader(label: context.l10n.friendsActivity),
              const SizedBox(height: RatelSpace.sm),
              for (final FriendActivity a in feed) ...<Widget>[
                _feedRow(context, a),
                const SizedBox(height: RatelSpace.sm),
              ],
            ],
            const SizedBox(height: RatelSpace.lg),
            _note(context, context.l10n.friendsFootnote),
          ],
        ),
      ),
    );
  }

  Widget _addField(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: RatelSpace.lg),
        decoration: BoxDecoration(
          color: context.palette.white,
          borderRadius: BorderRadius.circular(RatelRadius.pill),
          border: Border.all(color: context.palette.border),
        ),
        child: Row(
          children: <Widget>[
            const Text('👥', style: TextStyle(fontSize: 16)),
            const SizedBox(width: RatelSpace.sm),
            Expanded(
              child: TextField(
                key: const ValueKey<String>('friend-add-field'),
                controller: _controller,
                onSubmitted: _add,
                textInputAction: TextInputAction.send,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: context.palette.ink),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: context.l10n.friendsAddHint,
                  hintStyle: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.body,
                      color: context.palette.muted),
                ),
              ),
            ),
            GestureDetector(
              key: const ValueKey<String>('friend-add-send'),
              onTap: () => _add(_controller.text),
              child: Text('Add',
                  style: TextStyle(
                      fontFamily: RatelFont.display,
                      fontWeight: RatelType.extraBold,
                      fontSize: RatelType.body,
                      color: context.palette.ink)),
            ),
          ],
        ),
      );

  Widget _requestRow(BuildContext context, FriendRecord r) => RatelListRow(
        leadingEmoji: r.avatarEmoji,
        title: r.displayName,
        subtitle: '@${r.handle}',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 92,
              child: RatelButton(
                label: context.l10n.friendsAccept,
                variant: RatelButtonVariant.success,
                expand: false,
                onPressed: () =>
                    ref.read(friendsControllerProvider.notifier).accept(r.userId),
              ),
            ),
            const SizedBox(width: RatelSpace.xs),
            IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(RatelIcons.close, color: context.palette.muted),
              onPressed: () =>
                  ref.read(friendsControllerProvider.notifier).decline(r.userId),
            ),
          ],
        ),
      );

  Widget _friendRow(BuildContext context, FriendRecord f, bool passedYou) =>
      RatelListRow(
        leadingEmoji: f.avatarEmoji,
        title: f.displayName,
        subtitle: context.l10n.friendsXpThisWeek(f.handle, _xp(f.weeklyXp)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (passedYou) ...<Widget>[
              RatelChip(label: context.l10n.friendsPassedYou, tone: RatelChipTone.coral),
              const SizedBox(width: RatelSpace.xs),
            ],
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Text('⋯',
                  style: TextStyle(
                      fontSize: 22, height: 1.0, color: context.palette.muted)),
              onSelected: (String v) {
                final FriendsController c =
                    ref.read(friendsControllerProvider.notifier);
                if (v == 'remove') c.remove(f.userId);
                if (v == 'block') c.block(f.userId);
                if (v == 'report') c.report(f.userId);
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                    value: 'remove', child: Text(context.l10n.friendsRemove)),
                PopupMenuItem<String>(
                    value: 'block', child: Text(context.l10n.friendsBlock)),
                PopupMenuItem<String>(
                    value: 'report',
                    child: Text(context.l10n.friendsReportBlock)),
              ],
            ),
          ],
        ),
      );

  Widget _pendingRow(BuildContext context, FriendRecord r) => RatelListRow(
        leadingEmoji: r.avatarEmoji,
        title: r.displayName,
        subtitle: context.l10n.friendsRequestSent,
        trailing: TextButton(
          onPressed: () =>
              ref.read(friendsControllerProvider.notifier).remove(r.userId),
          child: Text(context.l10n.commonCancel,
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: context.palette.muted)),
        ),
      );

  // Friend-feed summaries localize by activity TYPE at the render site — the
  // engine keeps emitting the stable English summary (pinned by service tests;
  // the stable-id pattern). Parametric summaries carry their value in the
  // always-English summary text.
  static String _feedSummary(BuildContext context, FriendActivity a) {
    switch (a.type) {
      case FriendActivityType.joined:
        return context.l10n.feedIsNowYourFriend;
      case FriendActivityType.leveledUp:
        return context.l10n.feedReachedLevel(a.summary.startsWith('reached ')
            ? a.summary.substring('reached '.length)
            : a.summary);
      case FriendActivityType.streak:
        final Match? m =
            RegExp(r'^(\d+)-day streak$').firstMatch(a.summary);
        return m != null
            ? context.l10n.feedDayStreak(int.parse(m.group(1)!))
            : a.summary;
      case FriendActivityType.passedYouInLeague:
        return context.l10n.feedPassedYou;
      case FriendActivityType.lessonsCompleted:
        return a.summary;
    }
  }

  Widget _feedRow(BuildContext context, FriendActivity a) => RatelListRow(
        leadingEmoji: a.avatarEmoji,
        title: a.actorName,
        subtitle: _feedSummary(context, a),
      );

  Widget _emptyFriends(BuildContext context) => Container(
        padding: const EdgeInsets.all(RatelSpace.lg),
        decoration: BoxDecoration(
          color: context.palette.white,
          borderRadius: BorderRadius.circular(RatelRadius.card),
          border: Border.all(color: context.palette.border),
        ),
        child: Column(
          children: <Widget>[
            const Text('👋', style: TextStyle(fontSize: 40)),
            const SizedBox(height: RatelSpace.sm),
            Text(context.l10n.friendsEmptyTitle,
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.cardTitle,
                    color: context.palette.ink)),
            const SizedBox(height: RatelSpace.xs),
            Text(context.l10n.friendsEmptyBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    color: context.palette.muted)),
          ],
        ),
      );

  String _xp(int n) {
    final String s = n.toString();
    final StringBuffer b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  Widget _note(BuildContext context, String text) => Container(
        padding: const EdgeInsets.all(RatelSpace.md),
        decoration: BoxDecoration(
          color: context.palette.cream2,
          borderRadius: BorderRadius.circular(RatelRadius.card),
        ),
        child: Text(text,
            style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.small,
                color: context.palette.muted)),
      );
}
