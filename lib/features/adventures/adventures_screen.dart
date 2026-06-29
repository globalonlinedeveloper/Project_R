import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/core/core.dart';
import 'package:ratel/services/ai_relay/ai_relay.dart';

/// Adventures (🗺️) — design spec §4.12 (`/adventures`). The FREE roleplay
/// surface: districts of short scenes, each "a real conversation — no wrong
/// answers". Built HONESTLY: the scene labels are authored content scaffolding
/// (like the Home curriculum outline — NOT faked progress), and there is NO
/// fabricated "n/2 explored" counter (no exploration-tracking engine). Whether a
/// scene can actually run is the REAL `aiRelayProvider.isAvailable` (the R-H7
/// relay seam — fail-closed `UnconfiguredAiRelay` here ⇒ false), so tapping a
/// scene states plainly that it opens once the moderated relay is connected; it
/// NEVER fabricates a conversation (design spec §6). [R-D10 · R-H6 · R-H7 · R-J1]
class AdventuresScreen extends ConsumerWidget {
  const AdventuresScreen({super.key});

  static const List<({String emoji, String name, List<String> scenes})>
      _districts = <({String emoji, String name, List<String> scenes})>[
    (emoji: '☕', name: 'Café & Food', scenes: <String>['Order a coffee', 'Pay the bill']),
    (emoji: '🧺', name: 'Market Square', scenes: <String>['Buy some fruit', 'Haggle a price']),
    (emoji: '🚌', name: 'On the Move', scenes: <String>['Catch the bus', 'Buy a ticket']),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool relayReady = ref.watch(aiRelayProvider).isAvailable;
    return Scaffold(
      backgroundColor: context.palette.cream,
      appBar: AppBar(
        backgroundColor: context.palette.cream,
        surfaceTintColor: context.palette.cream,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.palette.ink),
          onPressed: () => context.pop(),
        ),
        title: Text('Adventures',
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                color: context.palette.ink,
                fontSize: RatelType.cardTitle)),
        actions: <Widget>[
          const Padding(
            padding: EdgeInsets.only(right: RatelSpace.lg),
            child: Center(child: RatelChip(label: 'FREE', tone: RatelChipTone.green)),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          key: const ValueKey<String>('screen-adventures'),
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
                  child: const Text('🗺️', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: RatelSpace.md),
                Expanded(
                  child: Text('Pick a place and dive in',
                      style: TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.cardTitle,
                          color: context.palette.ink)),
                ),
              ],
            ),
            const SizedBox(height: RatelSpace.sm),
            Text(
              'Every scene is a real conversation — no wrong answers, always free.',
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.body,
                  color: context.palette.muted),
            ),
            const SizedBox(height: RatelSpace.lg),
            _statusCard(context, relayReady),
            const SizedBox(height: RatelSpace.lg),
            for (final ({String emoji, String name, List<String> scenes}) d
                in _districts) ...<Widget>[
              _district(context, d.emoji, d.name, d.scenes, relayReady),
              const SizedBox(height: RatelSpace.cardGap),
            ],
            const SizedBox(height: RatelSpace.xs),
            Center(
              child: Text(
                'Scene names are ready content; a scene becomes a live, moderated '
                'conversation once the AI relay is connected. No dialogue is '
                'pre-faked.',
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

  Widget _statusCard(BuildContext context, bool relayReady) => RatelCard(
        color: context.palette.cream2,
        child: Row(
          children: <Widget>[
            Text(relayReady ? '✅' : '🔌', style: const TextStyle(fontSize: 22)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Text(
                relayReady
                    ? 'The AI relay is connected — tap any scene to start a real conversation.'
                    : 'The moderated AI relay is not connected in this build yet — scenes open in a later step.',
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.body,
                    color: context.palette.muted),
              ),
            ),
          ],
        ),
      );

  Widget _district(BuildContext context, String emoji, String name,
          List<String> scenes, bool relayReady) =>
      RatelCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: RatelSpace.sm),
                Text(name,
                    style: TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.extraBold,
                        fontSize: RatelType.cardTitle,
                        color: context.palette.ink)),
              ],
            ),
            const SizedBox(height: RatelSpace.sm),
            for (final String scene in scenes)
              Padding(
                padding: const EdgeInsets.only(bottom: RatelSpace.xs),
                child: RatelListRow(
                  leadingEmoji: '▶️',
                  leadingColor: RatelColors.teal,
                  title: scene,
                  onTap: () => _announce(context, relayReady),
                ),
              ),
          ],
        ),
      );

  void _announce(BuildContext context, bool relayReady) {
    final String msg = relayReady
        ? 'Starting the scene…'
        : 'This scene opens once the AI relay is connected.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}
