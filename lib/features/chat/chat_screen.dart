import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/services/ai_relay/ai_relay.dart';

/// Chat tutor scaffold (💬) — design #22/#27 / lane C-C (`/chat`).
///
/// HONEST, FAIL-CLOSED SCAFFOLD. The chat chrome the design shows — the
/// "Ratel · Tutor / Chat with Ratel" header, the intro bubble, the quick-reply
/// chips, and the composer with a send button — all render. But the AI text
/// relay ([aiRelayProvider]) is the fail-closed [UnconfiguredAiRelay]
/// (`isAvailable == false`) in this build, so NO reply is ever produced or
/// faked. This mirrors the live-roleplay honesty (`live_roleplay_screen.dart`):
/// the composer and chips exist so the layout is real and testable, but
/// sending only surfaces an honest "not connected — no reply is simulated"
/// state. Ratel never fabricates an answer.
///
/// When the relay flips on (Stage 3, a moderated + cost-guarded seam), this
/// scaffold is where real turns wire in — the untrusted [RelayText] box must be
/// escaped before any sink (TS-13), so replies are not added blindly here.
///
/// Reached from the AI-Tutor hub Chat card (C-C1 wiring).
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _attempted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSend(bool relayReady) {
    // FAIL-CLOSED: with no relay, a sent message can NEVER get a real reply, so
    // none is faked. We surface the honest not-connected state instead.
    if (!relayReady) {
      setState(() => _attempted = true);
      _controller.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
            SnackBar(content: Text(context.l10n.chatSendBlocked)));
      return;
    }
    // (Real send path plugs in when the relay is enabled — intentionally not
    // implemented here so no simulated reply can ever appear.)
  }

  @override
  Widget build(BuildContext context) {
    final bool relayReady = ref.watch(aiRelayProvider).isAvailable;

    return Scaffold(
      backgroundColor: context.palette.cream,
      appBar: AppBar(
        backgroundColor: context.palette.white,
        surfaceTintColor: context.palette.white,
        elevation: 0,
        leadingWidth: 44,
        leading: Padding(
          padding: const EdgeInsets.only(left: RatelSpace.md),
          child: GestureDetector(
            key: const ValueKey<String>('chat-back'),
            onTap: () => context.pop(),
            child: Icon(RatelIcons.arrowBack,
                color: context.palette.ink, size: 24),
          ),
        ),
        title: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: context.palette.cream3, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Text('🦡', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: RatelSpace.sm),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.chatTitle,
                  style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.body,
                    color: context.palette.ink,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: relayReady
                            ? RatelColors.green
                            : context.palette.muted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.chatSubtitle,
                      style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontWeight: RatelType.semiBold,
                        fontSize: RatelType.caption,
                        color: relayReady
                            ? RatelColors.green
                            : context.palette.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          key: const ValueKey<String>('screen-chat'),
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                    RatelSpace.lg, RatelSpace.screen, RatelSpace.lg),
                children: <Widget>[
                  _introBubble(context),
                  const SizedBox(height: RatelSpace.lg),
                  _offlineNote(context),
                  if (_attempted) ...<Widget>[
                    const SizedBox(height: RatelSpace.md),
                    _attemptedNote(context),
                  ],
                ],
              ),
            ),
            _quickChips(context, relayReady),
            _composer(context, relayReady),
          ],
        ),
      ),
    );
  }

  Widget _introBubble(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(RatelSpace.md),
        decoration: BoxDecoration(
          color: context.palette.white,
          borderRadius: BorderRadius.circular(RatelRadius.card),
          border: Border.all(color: context.palette.border),
        ),
        child: Text(
          context.l10n.chatIntroBubble,
          style: TextStyle(
            fontFamily: RatelFont.body,
            fontSize: RatelType.body,
            height: 1.35,
            color: context.palette.ink,
          ),
        ),
      ),
    );
  }

  Widget _offlineNote(BuildContext context) {
    return RatelCard(
      color: context.palette.cream2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('🔌', style: TextStyle(fontSize: 22)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.chatOfflineTitle,
                  style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.body,
                    color: context.palette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.chatOfflineBody,
                  style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    height: 1.4,
                    color: context.palette.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _attemptedNote(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(RatelSpace.md),
        decoration: BoxDecoration(
          color: RatelColors.amber.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(RatelRadius.card),
        ),
        child: Text(
          context.l10n.chatSendBlocked,
          style: TextStyle(
            fontFamily: RatelFont.body,
            fontSize: RatelType.small,
            height: 1.35,
            color: context.palette.ink,
          ),
        ),
      ),
    );
  }

  Widget _quickChips(BuildContext context, bool relayReady) {
    final List<String> chips = <String>[
      context.l10n.chatQuickHowSay,
      context.l10n.chatQuickCorrect,
      context.l10n.chatQuickTalk,
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: RatelSpace.screen),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: RatelSpace.sm),
        itemBuilder: (BuildContext context, int i) => _chip(context, chips[i]),
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return Material(
      color: context.palette.white,
      borderRadius: BorderRadius.circular(RatelRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(RatelRadius.pill),
        // Honest: a quick-reply chip cannot send a real turn (relay fail-closed);
        // tapping only prefills the composer — it never produces a reply.
        onTap: () {
          _controller.text = label;
          _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: label.length));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: RatelSpace.md, vertical: RatelSpace.sm),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.semiBold,
                fontSize: RatelType.small,
                color: RatelColors.teal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _composer(BuildContext context, bool relayReady) {
    return Container(
      padding: const EdgeInsets.fromLTRB(RatelSpace.screen, RatelSpace.sm,
          RatelSpace.screen, RatelSpace.md),
      color: context.palette.cream,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: context.palette.white,
                borderRadius: BorderRadius.circular(RatelRadius.pill),
                border: Border.all(color: context.palette.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: RatelSpace.md),
              child: TextField(
                key: const ValueKey<String>('chat-composer'),
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.body,
                  color: context.palette.ink,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: context.l10n.chatComposerHint,
                  hintStyle: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: context.palette.muted,
                  ),
                ),
                onSubmitted: (_) => _onSend(relayReady),
              ),
            ),
          ),
          const SizedBox(width: RatelSpace.sm),
          GestureDetector(
            key: const ValueKey<String>('chat-send'),
            onTap: () => _onSend(relayReady),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: RatelColors.teal,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(RatelIcons.send,
                  color: RatelColors.onColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
