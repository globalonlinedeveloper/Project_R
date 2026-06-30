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
      setState(() => _error = 'Enter a handle like @mia (2–20 letters, numbers, _).');
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
      setState(() => _error = 'You already have a connection with @$handle.');
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
          'Friends',
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
              const RatelSectionHeader(label: 'Requests'),
              const SizedBox(height: RatelSpace.sm),
              for (final FriendRecord r in incoming) ...<Widget>[
                _requestRow(context, r),
                const SizedBox(height: RatelSpace.sm),
              ],
              const SizedBox(height: RatelSpace.md),
            ],
            const RatelSectionHeader(label: 'Your friends'),
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
              const RatelSectionHeader(label: 'Pending'),
              const SizedBox(height: RatelSpace.sm),
              for (final FriendRecord r in outgoing) ...<Widget>[
                _pendingRow(context, r),
                const SizedBox(height: RatelSpace.sm),
              ],
            ],
            if (feed.isNotEmpty) ...<Widget>[
              const SizedBox(height: RatelSpace.md),
              const RatelSectionHeader(label: 'Friend activity'),
              const SizedBox(height: RatelSpace.sm),
              for (final FriendActivity a in feed) ...<Widget>[
                _feedRow(context, a),
                const SizedBox(height: RatelSpace.sm),
              ],
            ],
            const SizedBox(height: RatelSpace.lg),
            _note(context,
                'Your social graph is real and private to you. Friend requests are delivered, and "${'passed you'}" appears, once the durable cross-user graph goes live — the same go-live step as every other durable counter. Nothing here is faked.'),
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
                  hintText: 'Add a friend by @handle…',
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
                label: 'Accept',
                variant: RatelButtonVariant.success,
                expand: false,
                onPressed: () =>
                    ref.read(friendsControllerProvider.notifier).accept(r.userId),
              ),
            ),
            const SizedBox(width: RatelSpace.xs),
            IconButton(
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
        subtitle: '@${f.handle} · ${_xp(f.weeklyXp)} XP this week',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (passedYou) ...<Widget>[
              const RatelChip(label: 'Passed you', tone: RatelChipTone.coral),
              const SizedBox(width: RatelSpace.xs),
            ],
            PopupMenuButton<String>(
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
                  const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(value: 'remove', child: Text('Remove')),
                PopupMenuItem<String>(value: 'block', child: Text('Block')),
                PopupMenuItem<String>(
                    value: 'report', child: Text('Report & block')),
              ],
            ),
          ],
        ),
      );

  Widget _pendingRow(BuildContext context, FriendRecord r) => RatelListRow(
        leadingEmoji: r.avatarEmoji,
        title: r.displayName,
        subtitle: 'Request sent',
        trailing: TextButton(
          onPressed: () =>
              ref.read(friendsControllerProvider.notifier).remove(r.userId),
          child: Text('Cancel',
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: context.palette.muted)),
        ),
      );

  Widget _feedRow(BuildContext context, FriendActivity a) => RatelListRow(
        leadingEmoji: a.avatarEmoji,
        title: a.actorName,
        subtitle: a.summary,
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
            Text('No friends yet',
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.cardTitle,
                    color: context.palette.ink)),
            const SizedBox(height: RatelSpace.xs),
            Text('Add someone by their @handle to start sharing progress.',
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
