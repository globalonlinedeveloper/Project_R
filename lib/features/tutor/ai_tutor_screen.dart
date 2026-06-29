import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/ai_relay/ai_relay.dart';

/// AI Tutor (🦡) — design spec §4.8 (`/tutor`). Built HONESTLY around two REAL
/// signals: the billing PRO entitlement (`isProProvider`, free by default) and
/// the AI-relay availability (`aiRelayProvider.isAvailable` — the portability
/// seam R-H7, which is the fail-closed `UnconfiguredAiRelay` in this build, so
/// `isAvailable == false`). The three modes (Talk / Chat / Roleplay) are
/// presented with their real PRO gate; tapping one states plainly WHY it can't
/// start yet (PRO required, or the moderated relay isn't connected) — it NEVER
/// fabricates an AI reply (the relay's `complete()` fails closed, design spec
/// §6 "don't fake depth"). [R-H1 · R-H2 · R-H6 · R-H7 · R-J1 · R-J3]
class AiTutorScreen extends ConsumerWidget {
  const AiTutorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isPro = ref.watch(isProProvider);
    final bool relayReady = ref.watch(aiRelayProvider).isAvailable;

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
        title: Text('AI Tutor',
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                color: context.palette.ink,
                fontSize: RatelType.cardTitle)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          key: const ValueKey<String>('screen-tutor'),
          padding: const EdgeInsets.fromLTRB(
              RatelSpace.screen, RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      color: context.palette.cream3, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Text('🦡', style: TextStyle(fontSize: 30)),
                ),
                const SizedBox(width: RatelSpace.md),
                Expanded(
                  child: Text('Practice a real conversation',
                      style: TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.cardTitle,
                          color: context.palette.ink)),
                ),
              ],
            ),
            const SizedBox(height: RatelSpace.lg),
            _statusCard(context, isPro, relayReady),
            const SizedBox(height: RatelSpace.lg),
            _modeCard(
              context,
              gradient: const LinearGradient(
                  colors: <Color>[RatelColors.teal, RatelColors.tealDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              emoji: '🎙️',
              title: 'Talk to Ratel',
              subtitle: 'Live voice & video',
              isPro: isPro,
              relayReady: relayReady,
            ),
            const SizedBox(height: RatelSpace.cardGap),
            _modeCard(
              context,
              gradient: const LinearGradient(
                  colors: <Color>[RatelColors.blue, RatelColors.navy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              emoji: '💬',
              title: 'Chat with Ratel',
              subtitle: 'AI chat · writing feedback',
              isPro: isPro,
              relayReady: relayReady,
            ),
            const SizedBox(height: RatelSpace.cardGap),
            _modeCard(
              context,
              gradient: const LinearGradient(
                  colors: <Color>[RatelColors.purple, RatelColors.navy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              emoji: '🎭',
              title: 'Roleplay scenes',
              subtitle: 'Guided roleplay conversations',
              isPro: isPro,
              relayReady: relayReady,
            ),
            const SizedBox(height: RatelSpace.lg),
            if (!isPro)
              RatelButton(
                label: 'Unlock RATEL PRO',
                onPressed: () => context.push('/shop'),
              ),
            const SizedBox(height: RatelSpace.md),
            Center(
              child: Text(
                'Live AI tutoring runs on a moderated, cost-guarded relay and is '
                'a RATEL PRO feature. Replies are never simulated — a mode starts '
                'only once PRO and the relay are both active.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    color: context.palette.muted,
                    height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(BuildContext context, bool isPro, bool relayReady) {
    final String text = relayReady
        ? (isPro
            ? 'PRO active and the AI relay is connected — pick a mode to begin.'
            : 'The AI relay is connected. Live tutoring is a RATEL PRO feature.')
        : 'The moderated AI relay is not connected in this build yet — live '
            'tutoring turns on in a later step. Nothing below is simulated.';
    return RatelCard(
      color: context.palette.cream2,
      child: Row(
        children: <Widget>[
          Text(relayReady ? '✅' : '🔌', style: const TextStyle(fontSize: 22)),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: context.palette.muted)),
          ),
        ],
      ),
    );
  }

  Widget _modeCard(
    BuildContext context, {
    required Gradient gradient,
    required String emoji,
    required String title,
    required String subtitle,
    required bool isPro,
    required bool relayReady,
  }) =>
      RatelCard(
        gradient: gradient,
        onTap: () => _announce(context, isPro, relayReady),
        child: Row(
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: const TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.cardTitle,
                          color: RatelColors.onColor)),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: RatelFont.body,
                          fontSize: RatelType.small,
                          color: RatelColors.onColor)),
                ],
              ),
            ),
            if (!isPro) ...<Widget>[
              const SizedBox(width: RatelSpace.sm),
              RatelChip.pro(),
            ],
          ],
        ),
      );

  void _announce(BuildContext context, bool isPro, bool relayReady) {
    final String msg = !isPro
        ? 'RATEL PRO unlocks live AI tutoring.'
        : (!relayReady
            ? 'AI tutoring connects once the moderated relay is enabled.'
            : 'Starting your session…');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}
