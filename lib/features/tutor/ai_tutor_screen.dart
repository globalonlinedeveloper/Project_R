import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/learning_path/course_spine.dart';
import 'package:ratel/services/ai_relay/ai_relay.dart';
import 'package:ratel/services/live_session/live_session.dart';

/// AI Tutor (🦡) — design spec §4.8 (`/tutor`). Built HONESTLY around REAL
/// signals: the billing PRO entitlement (`isProProvider`, free by default), the
/// AI-relay availability (`aiRelayProvider.isAvailable` — the text-chat seam
/// R-H7, fail-closed `UnconfiguredAiRelay`, so `false` in this build) and the
/// live-voice engine (`liveSessionEngineProvider.isAvailable` — the seam Talk /
/// Roleplay actually gate on). The three modes (Talk / Chat / Roleplay) show
/// their real PRO gate; tapping one states plainly WHY it can't start yet — it
/// NEVER fabricates an AI reply (design spec §6 "don't fake depth").
///
/// UXA S115 inc2 (§4.8 conformance): Talk stays the dark-teal feature card;
/// Chat + Roleplay are white cards with a tinted emoji medallion + ink text +
/// trailing PRO (F-1). The mascot carries its subtitle (F-3). Roleplay shows
/// the REAL authored scene count (F-2 — `courseSpineProvider.roleplays.length`,
/// honest empty fallback, never a mock "18"). The status card keys off the
/// live-voice signal the cards gate on (F-6).
/// [R-H1 · R-H2 · R-H6 · R-H7 · R-J1 · R-J3]
class AiTutorScreen extends ConsumerWidget {
  const AiTutorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isPro = ref.watch(isProProvider);
    final bool relayReady = ref.watch(aiRelayProvider).isAvailable;
    // L-4 (S113): live VOICE rides the live_session seam (not the text relay).
    // Talk/Roleplay NAVIGATE only when the learner is PRO and the live engine is
    // really available; otherwise the tap stays the honest announce below.
    final bool liveReady = ref.watch(liveSessionEngineProvider).isAvailable;
    // F-2: honest roleplay scene count from the authored course spine (0 until
    // backend_wiring injects the bundled batch — never a fabricated number).
    final int roleplayCount = ref.watch(courseSpineProvider).roleplays.length;

    return Scaffold(
      backgroundColor: context.palette.cream,
      appBar: AppBar(
        backgroundColor: context.palette.cream,
        surfaceTintColor: context.palette.cream,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: RatelSpace.md),
          child: GestureDetector(
            onTap: () => context.pop(),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: context.palette.white,
              child: Icon(RatelIcons.arrowBack,
                  color: context.palette.ink, size: 20),
            ),
          ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Practice a real conversation',
                          style: TextStyle(
                              fontFamily: RatelFont.display,
                              fontWeight: RatelType.extraBold,
                              fontSize: RatelType.cardTitle,
                              color: context.palette.ink)),
                      const SizedBox(height: 2),
                      Text(
                          'Pick a scene and chat with Ratel — no wrong answers, '
                          'just practice.',
                          style: TextStyle(
                              fontFamily: RatelFont.body,
                              fontSize: RatelType.small,
                              height: 1.3,
                              color: context.palette.muted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: RatelSpace.lg),
            _statusCard(context, isPro, liveReady),
            const SizedBox(height: RatelSpace.lg),
            _modeCard(
              context,
              gradient: const LinearGradient(
                  colors: <Color>[RatelColors.teal, RatelColors.tealDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              accent: RatelColors.teal,
              emoji: '🎙️',
              title: 'Talk to Ratel',
              subtitle: 'Live voice & video speaking practice',
              isPro: isPro,
              relayReady: relayReady,
              onStart: isPro && liveReady
                  ? () => context.push('/roleplay-live?mode=free')
                  : null,
            ),
            const SizedBox(height: RatelSpace.cardGap),
            _modeCard(
              context,
              accent: RatelColors.blue,
              emoji: '💬',
              title: 'Chat with Ratel',
              subtitle: 'AI chat · writing feedback',
              isPro: isPro,
              relayReady: relayReady,
            ),
            const SizedBox(height: RatelSpace.cardGap),
            _modeCard(
              context,
              accent: RatelColors.purple,
              emoji: '🎭',
              title: 'Roleplay scenes',
              subtitle: roleplayCount > 0
                  ? '$roleplayCount scenes'
                  : 'Guided roleplay conversations',
              isPro: isPro,
              relayReady: relayReady,
              onStart: isPro && liveReady
                  ? () => context.push('/roleplay-live')
                  : null,
            ),
            const SizedBox(height: RatelSpace.lg),
            if (!isPro)
              RatelButton(
                label: 'Unlock RATEL PRO',
                onPressed: () => context.push('/paywall?source=tutor'),
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

  Widget _statusCard(BuildContext context, bool isPro, bool liveReady) {
    final String text = liveReady
        ? (isPro
            ? 'PRO active and the live tutor is connected — pick a mode to begin.'
            : 'The live tutor is connected. Live tutoring is a RATEL PRO feature.')
        : 'The moderated live tutor is not connected in this build yet — live '
            'tutoring turns on in a later step. Nothing below is simulated.';
    return RatelCard(
      color: context.palette.cream2,
      child: Row(
        children: <Widget>[
          Text(liveReady ? '✅' : '🔌', style: const TextStyle(fontSize: 22)),
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
    Gradient? gradient,
    required Color accent,
    required String emoji,
    required String title,
    required String subtitle,
    required bool isPro,
    required bool relayReady,
    VoidCallback? onStart,
  }) {
    final bool dark = gradient != null;
    final Color titleColor = dark ? RatelColors.onColor : context.palette.ink;
    final Color subColor = dark ? RatelColors.onColor : context.palette.muted;
    final Widget medallion = dark
        ? Text(emoji, style: const TextStyle(fontSize: 30))
        : Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          );
    return RatelCard(
      gradient: gradient,
      onTap: onStart ?? () => _announce(context, isPro, relayReady),
      child: Row(
        children: <Widget>[
          medallion,
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title,
                    style: TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.extraBold,
                        fontSize: RatelType.cardTitle,
                        color: titleColor)),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.small,
                        color: subColor)),
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
  }

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
